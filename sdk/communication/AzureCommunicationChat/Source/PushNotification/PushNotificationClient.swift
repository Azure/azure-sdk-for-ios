// --------------------------------------------------------------------------
//
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// The MIT License (MIT)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the ""Software""), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
//
// --------------------------------------------------------------------------

import AzureCommunicationCommon
import AzureCore
import Foundation

/// ChatClient class for ChatThread operations.
internal class PushNotificationClient {
    // MARK: Properties

    private let credential: CommunicationTokenCredential
    private let options: AzureCommunicationChatClientOptions
    private var registrarClient: RegistrarClient?
    internal var registrationId: String
    internal var deviceRegistrationToken: String
    internal var pushNotificationsStarted: Bool
    private var aesKey: String
    private var authKey: String
    private static let cryptoMethod: String = "0x70"

    // MARK: Initializers

    internal init(
        credential: CommunicationTokenCredential,
        options: AzureCommunicationChatClientOptions,
        registrationId: String
    ) {
        self.credential = credential
        self.options = options
        self.registrarClient = nil
        self.registrationId = registrationId
        self.deviceRegistrationToken = ""
        self.pushNotificationsStarted = false
        self.aesKey = ""
        self.authKey = ""
    }

    internal func startPushNotifications(
        deviceRegistrationToken: String,
        encryptionKeyPair: EncryptionKeyPair,
        completionHandler: @escaping (Result<HTTPResponse?, AzureError>) -> Void
    ) {
        self.deviceRegistrationToken = deviceRegistrationToken

        // Create RegistrarClient
        createRegistrarClient(
            credential: credential,
            options: options,
            registrationId: registrationId,
            completionHandler: { result in
                switch result {
                case let .success(createdRegistrarClient):
                    // Get encryption keys
                    let firstKey = encryptionKeyPair.firstKey
                    let secondKey = encryptionKeyPair.secondKey

                    /* If the encryption keys are empty or are not in correct format, we generate random keys for a successful registration.
                       How we define "correct format": AES256 key is a base64-encoded string with a size of 44.
                       Since the Contoso can't access these randomply keys, it should not be able to decrypt the message payload when receiving the notification. Under this scenario the Contoso should not expect to customize the Message Title or Message Body in alert banner.
                     */
                    if firstKey.count != 44 || secondKey
                        .count != 44 || Data(base64Encoded: firstKey) == nil || Data(base64Encoded: secondKey) == nil {
                        self.aesKey = "0000000000000000B00000000000000000000000AES="
                        self.authKey = "0000000000000000B0000000000000000000000AUTH="
                    } else {
                        self.aesKey = firstKey
                        self.authKey = secondKey
                    }

                    // Create RegistrarClientDescription (It should match valid APNS templates)
                    let clientDescription = RegistrarClientDescription(
                        aesKey: self.aesKey,
                        authKey: self.authKey,
                        cryptoMethod: PushNotificationClient.cryptoMethod
                    )

                    // Create RegistrarTransportSettings (Path is device token)
                    let transport = RegistrarTransportSettings(
                        path: self.deviceRegistrationToken
                    )

                    // Register for push notifications
                    self.registrarClient = createdRegistrarClient

                    guard let registrarClient = self.registrarClient else {
                        completionHandler(.failure(
                            AzureError
                                .client("Failed to start push notifications. RegistrarClient is nil.")
                        ))
                        return
                    }

                    registrarClient.setRegistration(with: clientDescription, for: [transport]) { result in
                        switch result {
                        case let .success(response):
                            self.pushNotificationsStarted = true
                            completionHandler(.success(response))
                        case let .failure(error):
                            self.options.logger
                                .error("Failed to start push notifications with error: \(error.localizedDescription)")
                            completionHandler(.failure(AzureError.client("Failed to start push notifications", error)))
                        }
                    }
                case let .failure(error):
                    completionHandler(.failure(AzureError.client("Failed to initialize the RegistrarClient.", error)))
                }
            }
        )
    }

    internal func stopPushNotifications(
        completionHandler: @escaping (Result<HTTPResponse?, AzureError>) -> Void
    ) {
        guard let registrarClient = registrarClient else {
            completionHandler(.failure(
                AzureError
                    .client(
                        "RegistrarClient is not initialized, cannot stop push notificaitons. Ensure startPushNotifications() is called first."
                    )
            ))
            return
        }

        registrarClient.deleteRegistration { result in
            switch result {
            case let .success(response):
                self.pushNotificationsStarted = false
                completionHandler(.success(response))
            case let .failure(error):
                self.options.logger
                    .error("Failed to stop push notifications with error: \(error.localizedDescription)")
                completionHandler(.failure(AzureError.client("Failed to stop push notifications", error)))
            }
        }
    }

    internal static func decryptPayload(
        encryptedStr: String,
        encryptionKeyPairCollection: [EncryptionKeyPair]
    ) throws -> String {
        do {
            // 1.Decode the Base64 input string into [UInt8].
            guard let decodedData = Data(base64Encoded: encryptedStr) else {
                throw AzureError
                    .client(
                        "Failed to initialize a data object with the given cryptoKey. Please ensure the encryptedStr is a Base64 encoded string."
                    )
            }
            let encryptedBytes = Array(decodedData)

            // 2.Split [UInt8] into different blocks.
            let iv: [UInt8] = CryptoUtils.extractInitializationVector(result: encryptedBytes)
            let cipherText: [UInt8] = CryptoUtils.extractCipherText(result: encryptedBytes)
            let hmac: [UInt8] = CryptoUtils.extractHmac(result: encryptedBytes)
            let cipherModeIVCipherText: [UInt8] = CryptoUtils.extractCipherModeIVCipherText(result: encryptedBytes)

            // 3.Loop over the keyPair array and find the keyPair used for encryption
            for keyPair in encryptionKeyPairCollection {
                let aesKey = keyPair.firstKey
                let authKey = keyPair.secondKey

                // Each auth key can be computed into a unique HMAC signature. If the computed signature matches the included signature, "verifyHMACResult" will be true.
                let verifyHMACResult = try verifyEncryptedPayload(
                    cipherModeIVCipherText: cipherModeIVCipherText,
                    authKey: authKey,
                    actualHmac: hmac
                )

                // If the "verifyHMACResult" is true, it indicates that the current keyPair is the one used by PNH for encryption.
                if verifyHMACResult {
                    // Here we use aesKey to decrypt the payload.
                    let decryptedString = try decryptPushNotificationPayload(
                        cipherText: cipherText,
                        iv: iv,
                        cryptoKey: aesKey
                    )

                    return decryptedString
                }
            }

            // 4. Failed to decrypt the push notification if thre is no keyPair used for encryption.
            throw AzureError
                .client(
                    "Failed to decrypt the push notification."
                )

        } catch {
            throw AzureError.client("Error in decrypting the notification payload: \(error)")
        }
    }
}
