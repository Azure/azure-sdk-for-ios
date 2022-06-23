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

import AzureCore
import Foundation

public protocol ChatClientPushNotificationProtocol: AnyObject {
    func onPersistKey(_ encryptionKey: String, expiryTime: Date)

    func onRetrieveKeys() -> [String]?
}

extension ChatClientPushNotificationProtocol {
    /// Handle the data payload for an incoming push notification.
    /// - Parameters:
    ///   - notification: The APNS push notification payload ( including "aps" and "data" )
    public func decryptPayload(
        notification: [AnyHashable: Any]
    ) throws -> PushNotificationEvent {
        // Retrieve the "data" part from the APNS push notification payload
        guard let dataPayload = notification["data"] as? [String: AnyObject] else {
            throw AzureError.client("Push notification does not contain data payload")
        }

        do {
            // 1.get "eventId"
            guard let eventId = dataPayload["eventId"] as? Int else {
                throw AzureError
                    .client("Push notification does not contain eventId or eventId can't be downcast to Int.")
            }

            let chatEventType = try PushNotificationChatEventType(forCode: eventId)

            // 2.get "e"
            guard let encryptedPayload = dataPayload["e"] as? String else {
                throw AzureError
                    .client(
                        "Push notification does not contain encryptedPayload or payload can't be downcast to String."
                    )
            }

            // 3.Delegate "getKeys" behaviour
            guard let encryptionKeys = onRetrieveKeys(),
                  encryptionKeys.count > 0
            else {
                throw AzureError.client("Failed to get decryption keys. Failed to decrypt Notification payload.")
            }

            // 4.Verify and decrypt the encrypted notification payload
            let decryptedPayload = try decryptPayload(
                encryptedStr: encryptedPayload,
                encryptionKeys: encryptionKeys
            )

            guard let data = decryptedPayload.data(using: .utf8) else {
                throw AzureError.client("Failed to create utf8 encoded Data from decrypted string.")
            }

            // 5. Create and return the PushNotificationEvent Model
            let pushNotificationEvent = try PushNotificationEvent(chatEventType: chatEventType, from: data)

            return pushNotificationEvent

        } catch {
            throw AzureError.client("Error in decrypting the notification payload: \(error)")
        }
    }

    internal func decryptPayload(
        encryptedStr: String,
        encryptionKeys: [String]
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

            // 3.Loop over the key array and find the key used for encryption
            for encryptionKey in encryptionKeys {
                let encryptionKeys = splitEncryptionKey(encryptionKey: encryptionKey)
                let aesKey = encryptionKeys[0]
                let authKey = encryptionKeys[1]

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
