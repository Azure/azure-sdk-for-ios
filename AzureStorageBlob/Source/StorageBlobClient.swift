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

    private static let apiVersion = Constants.apiVersion

    public init(baseUrl: String) throws {
        let authPolicy = StorageAuthenticationPolicy()
        super.init(baseUrl: baseUrl,
                   headersPolicy: HeadersPolicy(),
                   userAgentPolicy: UserAgentPolicy(),
                   authenticationPolicy: authPolicy,
                   contentDecodePolicy: ContentDecodePolicy(),
                   transport: UrlSessionTransport())
    }

    public func listContainers(withPrefix prefix: String? = nil, completion: @escaping HttpResultHandler<PagedCollection<BlobContainer>>) {
        let queryParams = [
            "prefix": prefix ?? ""
        ]
        let request = self.request(method: HttpMethod.GET,
                                   urlTemplate: "/?comp=list",
                                   queryParams: queryParams)
        self.run(request: request, completion: { result, httpResponse in
            switch result {
            case .success(let data):
                var xmlString = ""
                if let data = data {
                    xmlString = String(data: data, encoding: .utf8) ?? ""
                }
                debugPrint(xmlString)
                let codingKeys = PagedCodingKeys(items: "Containers", continuationToken: "NextMarker")
                do {
                    let paged = try PagedCollection<BlobContainer>(client: self, data: data, codingKeys: codingKeys)
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
