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

internal class RegistrarClient: PipelineClient {
    // MARK: Properties

    /// Registrar URL.
    private let url: URL
    /// CommunicationTokenCredential for authenticating requests.
    private let credential: CommunicationTokenCredential
    /// Unique identifier for the registration.
    private let registrationId: String
    /// URL Session.
    private let session: URLSession
    /// Options provided to configure this RegistrarClient
    internal let options: ClientOptions

    // MARK: Initializers

    internal init(
        endpoint: String,
        credential: CommunicationTokenCredential,
        registrationId: String,
        sessionConfiguration: URLSessionConfiguration? = nil,
        authPolicy: Authenticating,
        withOptions options: ClientOptions

    ) throws {
        guard let registrarUrl = URL(string: endpoint) else {
            throw AzureError.client("Unable to form base registrar URL.")
        }
        self.url = registrarUrl
        self.credential = credential
        self.registrationId = registrationId
        self.session = URLSession(configuration: sessionConfiguration ?? .default)
        self.options = options
        super.init(
            endpoint: registrarUrl,
            transport: options.transportOptions.transport ?? URLSessionTransport(),
            policies: [
                UserAgentPolicy(for: RegistrarClient.self, telemetryOptions: options.telemetryOptions),
                RequestIdPolicy(),
                AddDatePolicy(),
                authPolicy,
                LoggingPolicy()
            ],
            logger: options.logger,
            options: options
        )
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

    /// Create a Registrar POST request.
    /// - Parameters:
    ///   - clientDescription: RegistrarClientDescription.
    ///   - transports: RegistrarTranports, a transport contains the APNS token as the path.
    ///   - completionHandler: Returns the POST request.
    private func createPostRequest(
        with clientDescription: RegistrarClientDescription,
        for transports: [RegistrarTransport],
        completionHandler: @escaping (HTTPRequest?, AzureError?) -> Void
    ) {
        guard let data = createPostData(with: clientDescription, for: transports) else {
            completionHandler(nil, AzureError.client("Failed to serialize POST request body."))
            return
        }

        guard let request =
            try? HTTPRequest(method: HTTPMethod.post, url: url, data: data)
        else {
            completionHandler(nil, AzureError.client("Failed to create POST request in registration process."))
            return
        }

        setRequestHeader(on: request, completionHandler: completionHandler)
    }

    /// Create a Registrar DELETE request.
    private func createDeleteRequest(
        completionHandler: @escaping (HTTPRequest?, AzureError?) -> Void
    ) {
        let url = self.url.appendingPathComponent("/\(registrationId)")

        guard let request =
            try? HTTPRequest(method: HTTPMethod.delete, url: url)
        else {
            completionHandler(nil, AzureError.client("Failed to create DELETE request in registration process."))
            return
        }

        setRequestHeader(on: request, completionHandler: completionHandler)
    }

    /// Sets the header on a Registrar request.
    /// - Parameters:
    ///   - request: The  HTTP request.
    ///   - completionHandler: Returns the request, or an error if the request header failed to be created or added
    private func setRequestHeader(
        on request: HTTPRequest,
        completionHandler: @escaping (HTTPRequest?, AzureError?) -> Void
    ) {
        credential.token { accessToken, error in
            do {
                // Get token from CommunicationTokenCredential to set the authentication header
                guard let skypeToken = accessToken?.token else {
                    completionHandler(
                        nil,
                        AzureError.client("Failed to get token from CommunicationTokenCredential.", error)
                    )
                    return
                }

                let httpHeaders: HTTPHeaders = [
                    RegistrarHeader.contentType.rawValue: RegistrarMimeType.json.rawValue,
                    RegistrarHeader.skypeTokenHeader.rawValue: skypeToken
                ]

                let httpRequest = try HTTPRequest(
                    method: request.httpMethod,
                    url: request.url,
                    headers: httpHeaders,
                    data: request.data
                )

                completionHandler(httpRequest, nil)
            } catch {
                let azureError = AzureError.client("Failed to add headers to the Register request.", error)
                completionHandler(nil, azureError)
            }
        }
    }

    /// Sends an HTTP request to Registrar.
    /// - Parameters:
    ///   - request: The HTTP request.
    ///   - completionHandler: Returns the URLResponse, and an error if any errors occurred.
    private func sendHttpRequest(
        _ request: HTTPRequest,
        completionHandler: @escaping (Result<HTTPResponse?, AzureError>) -> Void
    ) {
        let dispatchQueue = DispatchQueue.main

        let context = PipelineContext.of(keyValues: [
            ContextKey.allowedStatusCodes.rawValue: [202] as AnyObject
        ])

        self.request(request, context: context) { result, httpResponse in
            switch result {
            case .success:
                guard (httpResponse?.statusCode) == 202 else {
                    let invalidStatusCodeError = AzureError.client("Didn't find a valid status code.")
                    dispatchQueue.async {
                        completionHandler(.failure(invalidStatusCodeError))
                    }
                    return
                }
                dispatchQueue.async {
                    completionHandler(.success(httpResponse))
                }
            case .failure:
                dispatchQueue.async {
                    completionHandler(.failure(AzureError.client("Registration request failed.")))
                }
            }
        }
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
        completionHandler: @escaping (Result<HTTPResponse?, AzureError>) -> Void
    ) {
        createPostRequest(with: clientDescription, for: transports) { request, error in
            guard let request = request else {
                completionHandler(.failure(AzureError.client("Failed to create POST request.", error)))
                return
            }

            self.sendHttpRequest(request) { result in
                switch result {
                case let .success(response):
                    completionHandler(.success(response))
                case let .failure(error):
                    completionHandler(.failure(AzureError.client("Registration request failed.", error)))
                }
            }
        }
    }

    /// Deletes a registration in Registrar.
    /// - Parameters:
    ///   - completionHandler: Returns the response. Success indicates the registration was deleted.
    internal func deleteRegistration(
        completionHandler: @escaping (Result<HTTPResponse?, AzureError>) -> Void
    ) {
        createDeleteRequest { request, error in
            guard let request = request else {
                completionHandler(.failure(AzureError.client("Failed to create DELETE request.", error)))
                return
            }

            self.sendHttpRequest(request) { result in
                switch result {
                case let .success(response):
                    completionHandler(.success(response))
                case let .failure(error):
                    completionHandler(.failure(AzureError.client("Registration request failed.", error)))
                }
            }
        }
    }
}
