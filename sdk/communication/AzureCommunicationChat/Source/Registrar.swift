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

import Foundation
import AzureCore
import AzureCommunicationCommon

/// Client description for set registration requests.
internal struct RegistrarClientDescription {
    /// The AppId.
    internal let appId: String
    /// IETF Language tags.
    internal let language: [String]
    /// Client platform.
    internal let platform: String
    /// Platform ID.
    internal let platformUiVersion: String
    /// Template key.
    internal let templateKey: String
    /// Template version.
    internal let templateVersion: String

    internal init(
        appId: String,
        language: [String],
        platform: String,
        platformUiVersion: String,
        templateKey: String,
        templateVersion: String
    ) {
        self.appId = appId
        self.language = language
        self.platform = platform
        self.platformUiVersion = platformUiVersion
        self.templateKey = templateKey
        self.templateVersion = templateVersion
    }
}

internal struct RegistrarTransports {
    /// TTL in seconds. Maximum value is 15552000.
    internal let ttl: Int
    /// APNS device token.
    internal let path: String
    /// Optional context.
    internal let context: String?
    /// Creation time as RFC 1123 formatted date.
    internal let creationTime: String?
    /// Snooze time in seconds. Maximum value is 15552000.
    internal let snoozeSeconds: Int?

    internal init(
        ttl: Int,
        path: String,
        context: String? = nil,
        creationTime: String? = nil,
        snoozeSeconds: Int? = nil
    ) {
        self.ttl = ttl
        self.path = path
        self.context = context
        self.creationTime = creationTime
        self.snoozeSeconds = snoozeSeconds
    }
}

internal struct RegistrarHeaders {
    /// Content-type header.
    static let contentType = "Content-Type"
    /// Skype token for authentication.
    static let skypeTokenHeader = "X-Skypetoken"
}

internal class Registrar {
    // MARK: Properties

    /// Registrar API endpoint.
    private let endpoint: String
    /// CommunicationTokenCredential for authenticating requests.
    private let credential: CommunicationTokenCredential
    /// Unique identifier for the registration.
    private let registrationId: String
    /// URL Session.
    private let session: URLSession

    // MARK: Initializers

    internal init(
        endpoint: String,
        credential: CommunicationTokenCredential,
        registrationId: String,
        sessionConfiguration: URLSessionConfiguration? = nil
    ) {
        self.endpoint = endpoint
        self.credential = credential
        self.registrationId = registrationId
        self.session = URLSession(configuration: sessionConfiguration ?? .default)
    }

    // MARK: Private Methods

    /// Construct the body of the HTTP request for setting a registration.
    /// - Parameters:
    ///   - clientDescription: Client description.
    ///   - transports: Transports.
    private func createHttpBody(
        clientDescription: RegistrarClientDescription,
        transports: RegistrarTransports
    ) -> Data? {
        let json: [String: Any] = [
            "registrationId": self.registrationId,
            "nodeId": "0", // Ask Gloria about this
            "clientDescription": clientDescription,
            "transports": transports
        ]

        return try? JSONSerialization.data(withJSONObject: json)
    }
    
    /// Create the HTTP request for setting a registration.
    /// - Parameters:
    ///   - clientDescription: Client description added to the request body.
    ///   - transports: Transports added to the request body.
    ///   - completionHandler: Returns the request, or an error if the request failed to be created.
    private func createRequest(
        clientDescription: RegistrarClientDescription,
        transports: RegistrarTransports,
        completionHandler: @escaping (URLRequest?, AzureError?) -> Void
    ) {
        do {
            guard let url = URL(string: self.endpoint) else {
                throw AzureError.client("Failed to construct URL from endpoint.")
            }
            
            guard let httpBody = createHttpBody(clientDescription: clientDescription, transports: transports) else {
                throw AzureError.client("Failed to construct http body.")
            }

            self.credential.token() { accessToken, error in
                guard let token = accessToken?.token else {
                    completionHandler(nil, AzureError.client("Failed to get token from CommunicationTokenCredential."))
                    return
                }

                // Construct the POST request
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.httpBody = httpBody
                request.setValue("application/json", forHTTPHeaderField: RegistrarHeaders.contentType)
                request.setValue(token, forHTTPHeaderField: RegistrarHeaders.skypeTokenHeader)

                completionHandler(request, nil)
            }
        } catch {
            completionHandler(nil, AzureError.client("Error creating Registrar request", error))
        }
    }

    // MARK: Internal Methods
    
    /// Registers for notifications..
    /// - Parameters:
    ///   - clientDescription: RegistrarClientDescription options that describe what notifications we are registering for.
    ///   - transports: RegistrarTransport options.
    internal func setRegistration(
        clientDescription: RegistrarClientDescription,
        transports: RegistrarTransports,
        completionHandler: @escaping (Result<Void, AzureError>, URLResponse?) -> Void
    ) {
        createRequest(clientDescription: clientDescription, transports: transports) { request, error in
            guard let request = request else {
                completionHandler(.failure(AzureError.client("Failed to send Registrar request", error)), nil)
                return
            }

            self.session.dataTask(with: request) { _, response, error in
                if error != nil {
                    completionHandler(.failure(AzureError.client("Registrar request failed", error)), response)
                    return
                }
                completionHandler(.success(()), response)
            }
        }
    }

    /// Unregisters from notifications.
    /// - Parameter deviceToken: APNS device token.
    internal func deleteRegistration(
        deviceToken: String
    ) {
        // Given params
        // Send DELETE request with skypetoken header
        // Return Result
    }
}
