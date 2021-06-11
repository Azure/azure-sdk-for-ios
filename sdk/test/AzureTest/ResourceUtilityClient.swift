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

public final class ResourceUtilityClient: PipelineClient {
    public let subscriptionId: String

    /// Options provided to configure this `ResourceUtilityClient`.
    public let options: ResourceUtilityClientOptions

    // MARK: Initializers

    /// Create an Azure resource client.
    /// - Parameters:
    ///   - baseUrl: Base URL for the client.
    ///   - subscriptionId: Subscription ID for the client.
    ///   - authPolicy: An `Authenticating` policy to use for authenticating client requests.
    ///   - options: Options used to configure the client.
    public init(
        endpoint: URL,
        subscriptionId: String,
        authPolicy: Authenticating,
        withOptions options: ResourceUtilityClientOptions
    ) throws {
        self.options = options
        self.subscriptionId = subscriptionId
        super.init(
            endpoint: endpoint,
            transport: options.transportOptions.transport ?? URLSessionTransport(),
            policies: [
                UserAgentPolicy(for: ResourceUtilityClient.self, telemetryOptions: options.telemetryOptions),
                RequestIdPolicy(),
                AddDatePolicy(),
                authPolicy,
                ContentDecodePolicy(),
                HeadersValidationPolicy(validatingHeaders: []),
                LoggingPolicy(
                    allowHeaders: [],
                    allowQueryParams: []
                ),
                NormalizeETagPolicy()
            ],
            logger: self.options.logger,
            options: options
        )
    }

    // MARK: Operations

    public func deploy(armTemplate _: String) -> String {
        // TODO: Deploy the provided ARM template to Azure.
        return ""
    }

    public func delete(resource _: String) {
        // TODO: Delete a resource
    }

    /// Deletes a resource group.
    /// - Parameters:
    ///    - resourceGroup: Resource group to be deleted.
    ///    - completionHandler: A completion handler that receives a status code on
    ///     success.
    public func delete(
        resourceGroup: String,
        completionHandler: @escaping HTTPResultHandler<Void>
    ) {
        let dispatchQueue = options.dispatchQueue ?? commonOptions.dispatchQueue ?? DispatchQueue.main

        // Create request parameters
        let params = RequestParameters(
            (.uri, "endpoint", endpoint.absoluteString, .skipEncoding),
            (.path, "subscriptionId", subscriptionId, .encode),
            (.path, "resourceGroup", resourceGroup, .encode),
            (.query, "api-version", options.apiVersion, .encode),
            (.header, "Accept", "application/json", .encode)
        )

        // Construct request
        let urlTemplate = "/subscriptions/{subscriptionId}/resourcegroups/{resourceGroup}"
        guard let requestUrl = url(host: "{endpoint}", template: urlTemplate, params: params),
            let request = try? HTTPRequest(method: .delete, url: requestUrl, headers: params.headers)
        else {
            options.logger.error("Failed to construct HTTP request.")
            return
        }

        // Send request
        let context = PipelineContext.of(keyValues: [
            ContextKey.allowedStatusCodes.rawValue: [200, 202, 401, 404, 409] as AnyObject
        ])
        self.request(request, context: context) { result, httpResponse in
            switch result {
            case .success:
                guard let statusCode = httpResponse?.statusCode else {
                    let noStatusCodeError = AzureError.client("Expected a status code in response but didn't find one.")
                    dispatchQueue.async {
                        completionHandler(.failure(noStatusCodeError), httpResponse)
                    }
                    return
                }
                switch statusCode {
                case 200:
                    fallthrough
                case 202:
                    dispatchQueue.async {
                        completionHandler(
                            .success(()),
                            httpResponse
                        )
                    }
                case 401:
                    dispatchQueue.async {
                        completionHandler(.failure(AzureError.service("Unauthorized.", nil)), httpResponse)
                    }
                case 404:
                    dispatchQueue.async {
                        completionHandler(.failure(AzureError.service("Resource not found.", nil)), httpResponse)
                    }
                case 409:
                    dispatchQueue.async {
                        completionHandler(.failure(AzureError.service("Resource exists.", nil)), httpResponse)
                    }
                default:
                    break
                }
            case let .failure(error):
                dispatchQueue.async {
                    completionHandler(.failure(error), httpResponse)
                }
            }
        }
    }
}
