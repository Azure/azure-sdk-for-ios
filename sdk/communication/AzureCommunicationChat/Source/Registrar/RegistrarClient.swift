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

    /// Create the data for the a Registrar POST request body.
    /// - Parameters:
    ///   - clientDescription: RegistrarClientDescription which is added to the request body.
    ///   - transports: RegistrarTransports which are added to the body, transport contains APNS push token as the path.
    private func createPostData(
        with clientDescription: RegistrarClientDescription,
        for transports: [RegistrarTransport]
    ) -> Data? {
        let data = RegistrarRequestBody(
            registrationId: registrationId,
            nodeId: RegistrarSettings.nodeId,
            clientDescription: clientDescription,
            transports: [
                RegistrarSettings.pushNotificationTransport: transports
            ]
        )

        return try? JSONEncoder().encode(data)
    }

    /// Sets the authentication header on a Registrar request.
    /// - Parameters:
    ///   - request: The  HTTP request.
    ///   - completionHandler: Returns the request, or an error if the request failed to be authenticated.
    private func setAuthHeader(
        on request: URLRequest,
        completionHandler: @escaping (URLRequest?, AzureError?) -> Void
    ) {
        credential.token { token, error in
            guard let skypeToken = token?.token else {
                completionHandler(
                    nil,
                    AzureError.client("Failed to get token from CommunicationTokenCredential.", error)
                )
                return
            }

            var authenticatedRequest = request
            authenticatedRequest.setValue(skypeToken, forHTTPHeaderField: RegistrarHeader.skypeTokenHeader)
            completionHandler(authenticatedRequest, nil)
        }
    }

    /// Create a Registrar DELETE request.
    private func createDeleteRequest(
        completionHandler: @escaping (URLRequest?, AzureError?) -> Void
    ) {
        let url = self.url.appendingPathComponent("/\(registrationId)")
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.delete.rawValue

        setAuthHeader(on: request, completionHandler: completionHandler)
    }

    /// Create a Registrar POST request.
    /// - Parameters:
    ///   - clientDescription: RegistrarClientDescription.
    ///   - transports: RegistrarTranports, a transport contains the APNS token as the path.
    ///   - completionHandler: Returns the POST request.
    private func createPostRequest(
        with clientDescription: RegistrarClientDescription,
        for transports: [RegistrarTransport],
        completionHandler: @escaping (URLRequest?, AzureError?) -> Void
    ) {
        guard let data = createPostData(with: clientDescription, for: transports) else {
            completionHandler(nil, AzureError.client("Failed to serialize POST request body."))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.httpBody = data
        request.setValue(RegistrarMimeType.json, forHTTPHeaderField: RegistrarHeader.contentType)

        setAuthHeader(on: request, completionHandler: completionHandler)
    }

    /// Sends an HTTP request to Registrar.
    /// - Parameters:
    ///   - method: The HTTP method.
    ///   - completionHandler: Returns the URLResponse, and an error if any errors occurred.
    private func sendHttpRequest(
        _ request: URLRequest,
        completionHandler: @escaping (HTTPURLResponse?, AzureError?) -> Void
    ) {
        session.dataTask(with: request) { _, response, error in
            let httpResponse = response as? HTTPURLResponse
            if (error != nil) || (httpResponse?.statusCode != RegistrarStatusCode.success) {
                completionHandler(httpResponse, AzureError.service("Registration request failed", error))
            } else {
                completionHandler(httpResponse, nil)
            }
        }.resume()
    }

    // MARK: Internal Methods

    /// Sets a registration in Registrar.
    /// - Parameters:
    ///   - clientDescription: RegistrarClientDescription.
    ///   - transports: RegistrarTransports, a transport contains the APNS token as the path.
    ///   - completionHandler: Returns the response. Success indicates the registration was received.
    internal func setRegistration(
        with clientDescription: RegistrarClientDescription,
        for transports: [RegistrarTransport],
        completionHandler: @escaping (HTTPURLResponse?, AzureError?) -> Void
    ) {
        createPostRequest(with: clientDescription, for: transports) { request, error in
            guard let request = request else {
                completionHandler(nil, AzureError.client("Failed to create POST request.", error))
                return
            }

            self.sendHttpRequest(request) { response, error in
                completionHandler(response, error)
            }
        }
    }

    /// Deletes a registration in Registrar.
    /// - Parameters:
    ///   - completionHandler: Returns the response. Success indicates the registration was deleted.
    internal func deleteRegistration(
        completionHandler: @escaping (HTTPURLResponse?, AzureError?) -> Void
    ) {
        createDeleteRequest { request, error in
            guard let request = request else {
                completionHandler(nil, AzureError.client("Failed to create DELETE request.", error))
                return
            }

            self.sendHttpRequest(request) { response, error in
                completionHandler(response, error)
            }
        }
    }
}
