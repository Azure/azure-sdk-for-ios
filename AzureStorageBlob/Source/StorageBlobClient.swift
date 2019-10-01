//
//  AzureStorageBlobClient.swift
//  AzureStorageBlob
//
//  Created by Travis Prescott on 9/27/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import AzureCore
import Foundation

public class StorageBlobClient: PipelineClient {
    
    private let apiVersion: String!

    public init(baseUrl: String, apiVersion: String? = nil) throws {
        let authPolicy = StorageAuthenticationPolicy()
        self.apiVersion = apiVersion ?? Constants.latestApiVersion
        super.init(baseUrl: baseUrl,
                   headersPolicy: HeadersPolicy(),
                   userAgentPolicy: UserAgentPolicy(),
                   authenticationPolicy: authPolicy,
                   contentDecodePolicy: ContentDecodePolicy(),
                   transport: UrlSessionTransport())
    }

    public func listContainers(withPrefix prefix: String? = nil, completion: @escaping HttpResultHandler<PagedCollection<BlobContainer>>) {

        // Python: error_map = kwargs.pop('error_map', None)
        let comp = "list"

        // Construct URL
        let urlTemplate = "{url}"
        var pathFormatArgs = [String: String]()
        pathFormatArgs["url"] = "/"
        let url = self.format(urlTemplate: urlTemplate, withKwargs: pathFormatArgs)

        // Construct parameters
        var queryParams = [String: String]()
        // TODO: Need to serialize each query arg
        // query_parameters['marker'] = self._serialize.query("marker", marker, 'str')
        if let prefix = prefix { queryParams["prefix"] = prefix }
//        if let marker = marker { queryParams["marker"] = marker }
//        if let maxResults = maxResults { queryParams["maxResults"] = maxResults }
//        if let include = include { queryParams["include"] = include }
//        if let timeout = timeout { queryParams["timeout"] = timeout }
        queryParams["comp"] = comp

        
        // Construct headers
        // TODO: need to serialize each header
        var headerParams = HttpHeaders()
        headerParams[HttpHeader.accept] = "application/xml"
        headerParams["x-ms-version"] = apiVersion
        // if let requestId = requestId { headerParams["x-ms-client-request-id"] = requestId }

        // Construct and send request
        let request = self.request(method: HttpMethod.GET,
                                   url: url,
                                   queryParams: queryParams,
                                   headerParams: headerParams)
        let allowedStatusCodes = [200]
        self.run(request: request, allowedStatusCodes: allowedStatusCodes, completion: { result, httpResponse in
            switch result {
            case .success(let data):
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
                guard let data = data else {
                    let noDataError = HttpResponseError.decode("Response data expected but not found.")
                    completion(.failure(noDataError), httpResponse)
                    return
                }
                let codingKeys = PagedCodingKeys(items: "Containers", continuationToken: "NextMarker")
                do {
                    let paged = try PagedCollection<BlobContainer>(client: self, request: request, data: data,
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
