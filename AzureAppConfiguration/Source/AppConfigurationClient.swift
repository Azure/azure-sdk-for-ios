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

    internal init(baseUrl: String, transport: HttpTransportable, policies: [PipelineStageProtocol],
                  withOptions options: AppConfigurationClientOptions) {
        self.options = options
        super.init(baseUrl: baseUrl, transport: transport, policies: policies, logger: self.options.logger)
    }

    public static func from(connectionString: String, withOptions options: AppConfigurationClientOptions? = nil) throws
        -> AppConfigurationClient {
            let clientOptions = options ?? AppConfigurationClientOptions(apiVersion: ApiVersion.latest.rawValue)
            let credential = try AppConfigurationCredential(connectionString: connectionString)
            let authPolicy = AppConfigurationAuthenticationPolicy(credential: credential, scopes: [credential.endpoint])
            return AppConfigurationClient(
                baseUrl: credential.endpoint,
                transport: UrlSessionTransport(),
                policies: [
                    HeadersPolicy(),
                    UserAgentPolicy(),
                    authPolicy,
                    ContentDecodePolicy(),
                    LoggingPolicy()
                ],
                withOptions: clientOptions)
    }

    // MARK: API Calls

    public func listConfigurationSettings(forKey key: String?, forLabel label: String?,
                                          completion: @escaping HttpResultHandler<PagedCollection<ConfigurationSetting>>) {
        // Python: error_map = kwargs.pop('error_map', None)
        // let comp = "list"

        // Construct URL
        let urlTemplate = "kv"
        let url = format(urlTemplate: urlTemplate)

        var queryParams = [String: String]()
        queryParams["key"] = key ?? "*"
        queryParams["label"] = label ?? "*"
        // if let fields = fields { queryParams["fields"] = fields }
        // if let select = select { queryParams["$select"] = select }

        // Construct headers
        var headerParams = HttpHeaders()
        headerParams["x-ms-version"] = self.options.apiVersion
        // if let acceptDatetime = acceptDatetime { headerParams["Accept-Datetime"] = acceptDatetime }
        // if let requestId = requestId { headerParams["x-ms-client-request-id"] = requestId }

        // Construct and send request
        let request = self.request(method: HttpMethod.GET,
                                   url: url,
                                   queryParams: queryParams,
                                   headerParams: headerParams)
        run(request: request, context: nil, completion: { result, httpResponse in
            //        header_dict = {}
            //        deserialized = None
            //        if response.status_code == 200:
            //            deserialized = self._deserialize('ListContainersSegmentResponse', response)
            //            header_dict = {
            //                'x-ms-client-request-id': self._deserialize('str', response.headers.get('x-ms-client-request-id')),
            //                'x-ms-request-id': self._deserialize('str', response.headers.get('x-ms-request-id')),
            //                'x-ms-version': self._deserialize('str', response.headers.get('x-ms-version')),
            //                'x-ms-error-code': self._deserialize('str', response.headers.get('x-ms-error-code')),
            //            }
            //
            //        if cls:
            //            return cls(response, deserialized, header_dict)
            //
            //        return deserialized
            switch result {
            case let .success(data):
                let codingKeys = PagedCodingKeys(continuationToken: "@nextLink")
                do {
                    let paged = try PagedCollection<ConfigurationSetting>(client: self, request: request, data: data,
                                                                          codingKeys: codingKeys)
                    completion(.success(paged), httpResponse)
                } catch {
                    completion(.failure(error), httpResponse)
                }
            case let .failure(error):
                completion(.failure(error), httpResponse)
            }
        })
    }
}
