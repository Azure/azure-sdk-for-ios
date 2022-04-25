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
        headersPolicy: HeadersPolicy,
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
                headersPolicy,
                LoggingPolicy()
            ],
            logger: options.logger,
            options: options
        )
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
                dispatchQueue.async {
                    completionHandler(.success(httpResponse))
                }
            case let .failure(error):
                dispatchQueue.async {
                    completionHandler(.failure(AzureError.client("Registration request failed.", error)))
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
        for registrarTransportSettings: [RegistrarTransportSettings],
        completionHandler: @escaping (Result<HTTPResponse?, AzureError>) -> Void
    ) {
        let registrarRequestBody = RegistrarRequestBody(
            registrationId: registrationId,
            clientDescription: clientDescription,
            registrarTransportSettings: [
                "APNS": registrarTransportSettings
            ]
        )

        guard let data = try? JSONEncoder().encode(registrarRequestBody) else {
            completionHandler(.failure(AzureError.client("Failed to serialize POST request body.")))
            return
        }

        guard let request = try? HTTPRequest(method: HTTPMethod.post, url: url, data: data) else {
            completionHandler(.failure(AzureError.client("Failed to create POST request in registration process.")))
            return
        }

        sendHttpRequest(request) { result in
            switch result {
            case let .success(response):
                completionHandler(.success(response))
            case let .failure(error):
                completionHandler(.failure(AzureError.client("Registration request failed.", error)))
            }
        }
    }

    /// Deletes a registration in Registrar.
    /// - Parameters:
    ///   - completionHandler: Returns the response. Success indicates the registration was deleted.
    internal func deleteRegistration(
        completionHandler: @escaping (Result<HTTPResponse?, AzureError>) -> Void
    ) {
        let url = self.url.appendingPathComponent("/\(registrationId)")

        guard let request = try? HTTPRequest(method: HTTPMethod.delete, url: url) else {
            completionHandler(.failure(AzureError.client("Failed to create DELETE request in registration process.")))
            return
        }

        sendHttpRequest(request) { result in
            switch result {
            case let .success(response):
                completionHandler(.success(response))
            case let .failure(error):
                completionHandler(.failure(AzureError.client("Registration request failed.", error)))
            }
        }
    }
}

internal func createRegistrarClient(
    credential: CommunicationTokenCredential,
    options: AzureCommunicationChatClientOptions,
    registrationId: String,
    completionHandler: @escaping (Result<RegistrarClient, AzureError>) -> Void
) {
    // Internal options do not use the CommunicationSignalingErrorHandler
    let internalOptions = AzureCommunicationChatClientOptionsInternal(
        apiVersion: AzureCommunicationChatClientOptionsInternal.ApiVersion(options.apiVersion),
        logger: options.logger,
        telemetryOptions: options.telemetryOptions,
        transportOptions: options.transportOptions,
        dispatchQueue: options.dispatchQueue
    )

    // Get skypeToken from CommunicationTokenCredential
    credential.token { accessToken, _ in
        guard let token = accessToken?.token else {
            completionHandler(
                .failure(AzureError.client("Failed to get token from CommunicationTokenCredential."))
            )
            return
        }

        // Use skypeToken to set authentication header and create headersPolicy
        let httpHeaders = [
            RegistrarHeader.contentType.rawValue: RegistrarMimeType.json.rawValue,
            RegistrarHeader.skypeTokenHeader.rawValue: token
        ]

        let headersPolicy = HeadersPolicy(addingHeaders: httpHeaders)

        // Use skypeToken to get the Registrar Service Url
        guard let registrarServiceUrl = try? getRegistrarServiceUrl(token: token) else {
            completionHandler(.failure(AzureError.client("Failed to get Registrar Service URL.")))
            return
        }

        // Initialize the RegistrarClient
        guard let registrarClient = try? RegistrarClient(
            endpoint: registrarServiceUrl,
            credential: credential,
            registrationId: registrationId,
            headersPolicy: headersPolicy,
            withOptions: internalOptions
        ) else {
            completionHandler(.failure(AzureError.client("Failed to initialize the RegistrarClient.")))
            return
        }

        completionHandler(.success(registrarClient))
    }
}
