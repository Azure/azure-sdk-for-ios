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
            let decoder = JSONDecoder()
            let type = PagedCollection<ConfigurationSetting>.self
            // TODO: Find way to do this in the pipeline!
            switch result {
            case .success(let data):
                if let data = data {
                    do {
                        let deserialized = try decoder.decode(type, from: data)
                        completion(.success(deserialized), httpResponse)
                    } catch {
                        completion(.failure(error), httpResponse)
                    }
                } else {
                    completion(.failure(HttpResponseError.decode), httpResponse)
                }
            case .failure(let error):
                completion(.failure(error), httpResponse)
            }
        })
    }
}
