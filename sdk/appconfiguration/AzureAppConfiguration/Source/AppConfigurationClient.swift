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
import os.log

public class AppConfigurationClient: PipelineClient {
    public enum ApiVersion: String {
        case latest = "2019-01-01"
    }

    public let options: AppConfigurationClientOptions

    // MARK: Initializers

    internal init(
        baseURL: URL,
        transport: HTTPTransportStage,
        policies: [PipelineStage],
        withOptions options: AppConfigurationClientOptions
    ) {
        self.options = options
        super.init(baseURL: baseURL, transport: transport, policies: policies, logger: self.options.logger)
    }

    public static func from(connectionString: String, withOptions options: AppConfigurationClientOptions? = nil) throws
        -> AppConfigurationClient {
            let clientOptions = options ?? AppConfigurationClientOptions(apiVersion: ApiVersion.latest.rawValue)
            let credential = try AppConfigurationCredential(connectionString: connectionString)
            let authPolicy = AppConfigurationAuthenticationPolicy(credential: credential, scopes: [credential.endpoint])

            let headers = HTTPHeaders([
                .returnClientRequestId: "true",
                .contentType: "application/json",
                .accept: "application/vnd.microsoft.azconfig.kv+json"
            ])

            guard let baseURL = URL(string: credential.endpoint) else {
                throw AzureError.fileSystem("Unable to resolve base URL.")
            }

            return AppConfigurationClient(
                baseURL: baseURL,
                transport: URLSessionTransport(),
                policies: [
                    UserAgentPolicy(for: AppConfigurationClient.self),
                    RequestIdPolicy(),
                    HeadersPolicy(addingHeaders: headers),
                    AddDatePolicy(),
                    authPolicy,
                    ContentDecodePolicy(),
                    LoggingPolicy()
                ],
                withOptions: clientOptions
            )
        }

    // MARK: API Calls

    public func listConfigurationSettings(
        forKey key: String?,
        forLabel label: String?,
        then completion: @escaping HTTPResultHandler<PagedCollection<ConfigurationSetting>>
    ) {
        // Construct URL
        let url = "kv"
        let queryParams = [
            ("key", key ?? "*"),
            ("label", label ?? "*")
        ]
        // if let fields = fields { queryParams["fields"] = fields }
        // if let select = select { queryParams["$select"] = select }

        // Construct headers
        let headers = HTTPHeaders([.apiVersion: options.apiVersion])
        // if let acceptDatetime = acceptDatetime { headers["Accept-Datetime"] = acceptDatetime }
        // if let requestId = requestId { headers[.clientRequestId] = requestId }

        // Construct and send request
        guard let request = try? HTTPRequest(method: .get, url: url, headers: headers) else { return }
        request.add(queryParams: queryParams)
        self.request(request, context: nil) { result, httpResponse in
            /*
             header_dict = {}
             deserialized = None
             if response.status_code == 200:
                 deserialized = self._deserialize('ListContainersSegmentResponse', response)
                 header_dict = {
                     'x-ms-client-request-id': self._deserialize('str', response.headers.get('x-ms-client-request-id')),
                     'x-ms-request-id': self._deserialize('str', response.headers.get('x-ms-request-id')),
                     'x-ms-version': self._deserialize('str', response.headers.get('x-ms-version')),
                     'x-ms-error-code': self._deserialize('str', response.headers.get('x-ms-error-code')),
                 }

             if cls:
                 return cls(response, deserialized, header_dict)

             return deserialized
             */
            switch result {
            case let .success(data):
                let codingKeys = PagedCodingKeys(continuationToken: "@nextLink")
                do {
                    let paged = try PagedCollection<ConfigurationSetting>(
                        client: self,
                        request: request,
                        data: data,
                        codingKeys: codingKeys
                    )
                    completion(.success(paged), httpResponse)
                } catch {
                    completion(.failure(error), httpResponse)
                }
            case let .failure(error):
                completion(.failure(error), httpResponse)
            }
        }
    }
}
