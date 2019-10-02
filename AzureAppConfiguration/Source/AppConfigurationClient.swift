//
//  AppConfigurationClient.swift
//  AzureAppConfiguration
//
//  Created by Travis Prescott on 9/23/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import AzureCore
import Foundation
import os.log

public class AppConfigurationClient: PipelineClient {
    
    public let apiVersion: String!

    public init(connectionString: String, apiVersion: String? = nil) throws {
        let credential = try AppConfigurationCredential(connectionString: connectionString)
        let authPolicy = AppConfigurationAuthenticationPolicy(credential: credential, scopes: [credential.endpoint])
        self.apiVersion = apiVersion ?? Constants.latestApiVersion
        super.init(baseUrl: credential.endpoint,
                   headersPolicy: HeadersPolicy(),
                   userAgentPolicy: UserAgentPolicy(),
                   authenticationPolicy: authPolicy,
                   contentDecodePolicy: ContentDecodePolicy(),
                   transport: UrlSessionTransport())
    }

    public func getConfigurationSettings(forKey key: String?, forLabel label: String?,
                                         completion: @escaping HttpResultHandler<PagedCollection<ConfigurationSetting>>) {

        // Python: error_map = kwargs.pop('error_map', None)
        // let comp = "list"

        // Construct URL
        let urlTemplate = "kv"
        let url = self.format(urlTemplate: urlTemplate)

        var queryParams = [String: String]()
        queryParams["key"] = key ?? "*"
        queryParams["label"] = label ?? "*"
        // if let fields = fields { queryParams["fields"] = fields }
        // if let select = select { queryParams["$select"] = select }

        // Construct headers
        var headerParams = HttpHeaders()
        headerParams["x-ms-version"] = apiVersion
        // if let acceptDatetime = acceptDatetime { headerParams["Accept-Datetime"] = acceptDatetime }
        // if let requestId = requestId { headerParams["x-ms-client-request-id"] = requestId }

        // Construct and send request
        let request = self.request(method: HttpMethod.GET,
                                   url: url,
                                   queryParams: queryParams,
                                   headerParams: headerParams)
        let allowedStatusCodes = [200]
        self.run(request: request, allowedStatusCodes: allowedStatusCodes, completion: { result, httpResponse in
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
            case .success(let data):
                let codingKeys = PagedCodingKeys(continuationToken: "@nextLink")
                do {
                    let paged = try PagedCollection<ConfigurationSetting>(client: self, request: request, data: data,
                                                                          codingKeys: codingKeys)
                    completion(.success(paged), httpResponse)
                } catch {
                    completion(.failure(error), httpResponse)
                }
            case .failure(let error):
                completion(.failure(error), httpResponse)
            }
        })
    }
}
