//
//  AppConfigurationClient.swift
//  AzureAppConfiguration
//
//  Created by Travis Prescott on 9/23/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import AzureCore
import Foundation

public class AppConfigurationClient: PipelineClient {

    private static let apiVersion = Contants.apiVersion

    public init(connectionString: String) throws {
        guard let credential = try? AppConfigurationCredential(connectionString: connectionString) else {
            throw AzureError.general
        }
        let authPolicy = AppConfigurationAuthenticationPolicy(credential: credential, scopes: [credential.endpoint])
        super.init(baseUrl: credential.endpoint,
                   headersPolicy: HeadersPolicy(),
                   userAgentPolicy: UserAgentPolicy(),
                   authenticationPolicy: authPolicy,
                   transport: UrlSessionTransport())
    }

    public func getConfigurationSettings(forKey key: String?, forLabel label: String?,
                                         completion: @escaping HttpResultHandler<PagedCollection<ConfigurationSetting>>) {
        // TODO: Additional supported functionality
        // $select query param
        // Accept-Datetime header
        let queryParams = [
            "key": key ?? "*",
            "label": label ?? "*",
            "fields": ""
        ]
        let request = self.request(method: HttpMethod.GET,
                                   urlTemplate: "/kv",
                                   queryParams: queryParams)
        self.run(request: request, completion: { result, httpResponse in
            switch result {
            case .success(let data):
                let codingKeys = PagedCodingKeys(continuationToken: "@nextLink")
                do {
                    let paged = try PagedCollection<ConfigurationSetting>(client: self, data: data, codingKeys: codingKeys)
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
