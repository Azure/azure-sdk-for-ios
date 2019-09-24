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

    public func getConfigurationSettings(forKey key: String?, forLabel label: String?, withResponse response: HttpResponse? = nil, completion: @escaping CompletionHandler) throws {
        // TODO: Additional supported functionality
        // $select query param
        // Accept-Datetime header
        let queryParams = [
            "key": key ?? "*",
            "label": label ?? "*",
            "fields": ""
        ]
        let request = PipelineRequest(
            request: self.request(
                method: HttpMethod.GET,
                urlTemplate: "/kv",
                queryParams: queryParams),
            completion: completion
        )
        try self.run(request: request, onResult: { response, error in
            let test = "best"
            //        // update response if passed in
            //        if let responseIn = response {
            //            responseIn.update(withResponse: pipelineResponse.httpResponse)
            //        }
            //        if let data = pipelineResponse.httpResponse.data {
            //            let decoder = JSONDecoder()
            //            var deserialized = try? decoder.decode(PagedCollection<ConfigurationSetting>.self, from: data)
            //            deserialized?.client = self
            //            deserialized?.request = request
            //            return deserialized
            //        } else {
            //            throw HttpResponseError.general
            //        }
            completion(response, error)
        })
    }
}
