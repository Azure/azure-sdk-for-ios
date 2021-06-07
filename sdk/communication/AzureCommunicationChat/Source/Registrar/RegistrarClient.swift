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

/// POST request body.
internal struct RegistrarPostBody: Codable {
    /// The registration id.
    internal let registrationId: String
    /// Node id.
    internal let nodeId: String
    /// Client description
    internal let clientDescription: RegistrarClientDescription
    /// Transports
    internal let transports: [String: [RegistrarTransport]]

    internal init(
        registrationId: String,
        nodeId: String,
        clientDescription: RegistrarClientDescription,
        transports: [String: [RegistrarTransport]]
    ) {
        self.registrationId = registrationId
        self.nodeId = nodeId
        self.clientDescription = clientDescription
        self.transports = transports
    }
}

/// Client description for set registration requests.
internal struct RegistrarClientDescription: Codable {
    /// The AppId.
    internal let appId: String
    /// IETF Language tags.
    internal let languageId: String
    /// Client platform.
    internal let platform: String
    /// Platform ID.
    internal let platformUIVersion: String
    /// Template key.
    internal let templateKey: String
    /// Template version.
    internal let templateVersion: String?

    internal init(
        appId: String,
        languageId: String,
        platform: String,
        platformUIVersion: String,
        templateKey: String,
        templateVersion: String? = nil
    ) {
        self.appId = appId
        self.languageId = languageId
        self.platform = platform
        self.platformUIVersion = platformUIVersion
        self.templateKey = templateKey
        self.templateVersion = templateVersion
    }
}

/// Registrar transport.
internal struct RegistrarTransport: Codable {
    /// TTL in seconds. Maximum value is 15552000.
    internal let ttl: Int
    /// APNS device token.
    internal let path: String
    /// Optional context.
    internal let context: String
    /// Creation time as RFC 1123 formatted date.
    internal let creationTime: String?
    /// Snooze time in seconds. Maximum value is 15552000.
    internal let snoozeSeconds: Int?

    internal init(
        ttl: Int,
        path: String,
        context: String,
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

internal enum RegistrarHeaders {
    /// Content-type header.
    static let contentType = "Content-Type"
    /// Skype token for authentication.
    static let skypeTokenHeader = "X-Skypetoken"
}

internal class RegistrarClient {
    // MARK: Properties

    /// Registrar URL.
    private let url: URL
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
    ) throws {
        guard let url = URL(string: endpoint) else {
            throw AzureError.client("Unable to form base registrar URL.")
        }

        self.url = url
        self.credential = credential
        self.registrationId = registrationId
        self.session = URLSession(configuration: sessionConfiguration ?? .default)
    }

    // MARK: Private Methods

    /// Create a POST request from a base Registrar request.
    /// - Parameters:
    ///   - baseRequest: The base request.
    ///   - deviceToken: APNS push token.
    private func postRequest(
        from baseRequest: URLRequest,
        with deviceToken: String?
    ) -> (URLRequest?, AzureError?) {
        guard let deviceToken = deviceToken else {
            return (nil, AzureError.client("Missing device token."))
        }

        // Client description should match valid APNS templates
        let clientDescription = RegistrarClientDescription(
            appId: RegistrarSettings.appId,
            languageId: RegistrarSettings.languageId,
            platform: RegistrarSettings.platform,
            platformUIVersion: RegistrarSettings.platformUIVersion,
            templateKey: RegistrarSettings.templateKey
        )

        // Path is APNS token
        let transport = RegistrarTransport(
            ttl: RegistrarSettings.ttl,
            path: deviceToken,
            context: RegistrarSettings.context
        )

        let postBody = RegistrarPostBody(
            registrationId: registrationId,
            nodeId: RegistrarSettings.nodeId,
            clientDescription: clientDescription,
            transports: [
                RegistrarSettings.pushNotificationTransport: [transport]
            ]
        )

        guard let data = try? JSONEncoder().encode(postBody) else {
            return (nil, AzureError.client("Failed to serialize POST request body."))
        }

        // Add body and content-type header for POST
        var postRequest = baseRequest
        postRequest.httpBody = data
        postRequest.setValue("application/json", forHTTPHeaderField: RegistrarHeaders.contentType)

        return (postRequest, nil)
    }

    /// Create a DELETE request from a base Registrar request.
    /// - Parameter baseRequest: The base request.
    private func deleteRequest(
        from baseRequest: URLRequest
    ) -> URLRequest {
        var deleteRequest = baseRequest
        deleteRequest.url?.appendPathComponent("/\(registrationId)")
        return deleteRequest
    }

    /// Create an HTTP request for the Registrar API.
    /// - Parameters:
    ///   - method: The HTTP method.
    ///   - completionHandler: Returns the request, or an error if the request failed to be created.
    private func createRequest(
        for method: HTTPMethod,
        with deviceToken: String? = nil,
        completionHandler: @escaping (URLRequest?, AzureError?) -> Void
    ) {
        credential.token { token, error in
            // All client requests must be authenticated
            guard let skypeToken = token?.token else {
                completionHandler(nil, AzureError.client("Failed to get token from CommunicationTokenCredential."))
                return
            }

            // Set HTTP method and token
            var baseRequest = URLRequest(url: self.url)
            baseRequest.httpMethod = method.rawValue
            baseRequest.setValue(skypeToken, forHTTPHeaderField: RegistrarHeaders.skypeTokenHeader)

            switch method {
            case .post:
                let (request, error) = self.postRequest(from: baseRequest, with: deviceToken)
                completionHandler(request, error)

            case .delete:
                // TODO: - remove if shouldn't delete
                let request = self.deleteRequest(from: baseRequest)
                completionHandler(request, nil)

            case .patch:
                // TODO: - invalidate path
                break

            default:
                completionHandler(nil, AzureError.client("Unsupported method \(method)."))
            }
        }
    }

    /// Sends an HTTP request to Registrar.
    /// - Parameters:
    ///   - method: The HTTP method.
    ///   - completionHandler: Returns the URLResponse, and an error if any errors occurred.
    private func sendRequest(
        method: HTTPMethod,
        with deviceToken: String? = nil,
        completionHandler: @escaping (URLResponse?, AzureError?) -> Void
    ) {
        createRequest(for: method, with: deviceToken) { request, error in
            guard let request = request else {
                completionHandler(nil, AzureError.client("Failed to create Registrar request", error))
                return
            }

            self.session.dataTask(with: request) { _, response, error in
                if error != nil {
                    completionHandler(response, AzureError.service("Registrar request failed", error))
                    return
                }
                completionHandler(response, nil)
            }.resume()
        }
    }

    // MARK: Internal Methods

    /// Registers for notifications by sending a POST request to Registrar.
    /// - Parameters:
    ///   - completionHandler: Returns the response. Success indicates the registration was received.
    internal func setRegistration(
        for deviceToken: String,
        completionHandler: @escaping (Result<Void, AzureError>, URLResponse?) -> Void
    ) {
        sendRequest(method: .post, with: deviceToken) { response, error in
            if let error = error {
                completionHandler(.failure(error), response)
            } else {
                completionHandler(.success(()), response)
            }
        }
    }

    /// Unregisters from notifications by sending a DELETE request to Registrar
    /// - Parameters:
    ///   - completionHandler: Returns the response. Success indicates the registration was deleted.
    internal func deleteRegistration(
        completionHandler: @escaping (Result<Void, AzureError>, URLResponse?) -> Void
    ) {
        sendRequest(method: .delete) { response, error in
            if let error = error {
                completionHandler(.failure(error), response)
            } else {
                completionHandler(.success(()), response)
            }
        }
    }

    // REMOVE - TEMPORARY for testing
    internal func getRegistrations(
        completionHandler: @escaping () -> Void
    ) {
        credential.token { accessToken, error in
            guard let token = accessToken?.token else {
                return
            }

            // Construct the POST request
            var request = URLRequest(url: self.url)
            request.httpMethod = "GET"
            request.setValue(token, forHTTPHeaderField: RegistrarHeaders.skypeTokenHeader)

            self.session.dataTask(with: request) { data, response, error in
                if error != nil {
                    print("failed")
                    return
                }

                guard let response = data else {
                    return
                }

                do {
                    let json = try JSONSerialization.jsonObject(with: response)
                    print(json)
                    completionHandler()
                } catch {
                    print(error)
                    completionHandler()
                }
            }.resume()
        }
    }
}
