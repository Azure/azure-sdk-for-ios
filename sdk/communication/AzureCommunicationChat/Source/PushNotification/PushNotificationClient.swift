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
    }

    internal func startPushNotifications(
        deviceRegistrationToken: String,
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
                    // Create RegistrarClientDescription (It should match valid APNS templates)
                    self.registrarClient = createdRegistrarClient

                    let clientDescription = RegistrarClientDescription()

                    // Create RegistrarTransportSettings (Path is device token)
                    let transport = RegistrarTransportSettings(
                        path: self.deviceRegistrationToken
                    )

                    // Register for push notifications
                    guard let registrarClient = self.registrarClient else {
                        completionHandler(.failure(AzureError.client("Failed to start push notifications")))
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
        // Report an error if registrarClient doesn't exist
        if registrarClient == nil {
            completionHandler(.failure(
                AzureError
                    .client(
                        "RegistrarClient is not initialized, cannot stop push notificaitons. Ensure startPushNotifications() is called first."
                    )
            ))
        } else {
            // Unregister for Push Notifications
            registrarClient!.deleteRegistration { result in
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
}
