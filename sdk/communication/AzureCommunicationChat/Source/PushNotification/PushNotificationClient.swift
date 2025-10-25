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
        encryptionKey: String,
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
                    do {
                        // Generate and persist encryption key
                        /* We require the Contoso to pass in a 512-bit key. Need to split it into two 256-bit keys, taking the first part for decrytion and the second part for authorization.
                         */
                        if encryptionKey != "" {
                            let encryptionKeys = try splitEncryptionKey(encryptionKey: encryptionKey)
                            self.aesKey = encryptionKeys[0]
                            self.authKey = encryptionKeys[1]
                        } else {
                            // If the Contoso doesn't want to implement encryption and we get an empty encrytionKey, we
                            // just register two fake values. Encryption keys are required for a successful
                            // registration.
                            self.aesKey = "0000000000000000B00000000000000000000000AES="
                            self.authKey = "0000000000000000B0000000000000000000000AUTH="
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
                                    .error(
                                        "Failed to start push notifications with error: \(error.localizedDescription)"
                                    )
                                completionHandler(.failure(
                                    AzureError
                                        .client("Failed to start push notifications", error)
                                ))
                            }
                        }
                    } catch {
                        completionHandler(.failure(AzureError.client("Failed to split the encryption key: ", error)))
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
}
