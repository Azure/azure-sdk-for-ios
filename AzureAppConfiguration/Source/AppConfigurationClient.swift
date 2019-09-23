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
        let config = PipelineConfiguration(
            headersPolicy: HeadersPolicy(),
            userAgentPolicy: UserAgentPolicy(),
            authenticationPolicy: AppConfigurationAuthenticationPolicy(credential: credential, scopes: [credential.endpoint])
        )
        let policies: [AnyObject] = [
            config.userAgentPolicy,
            config.headersPolicy,
            config.authenticationPolicy as AnyObject
        ]
        let pipeline = Pipeline(transport: UrlSessionTransport(), policies: policies)
        super.init(baseUrl: credential.endpoint, config: config, pipeline: pipeline)
    }

    public func getConfigurationSettings(forKey key: String?, forLabel label: String?, withResponse response: HttpResponse? = nil) throws -> PagedCollection<ConfigurationSetting>? {
        // TODO: Additional supported functionality
        // $select query param
        // Accept-Datetime header
        let queryParams = [
            "key": key ?? "*",
            "label": label ?? "*",
            "fields": ""
        ]
        let request = PipelineRequest(request: self.request(
            method: HttpMethod.GET,
            urlTemplate: "/kv",
            queryParams: queryParams
        ))
        request.add(value: [ConfigurationSetting].self as AnyObject, forKey: "deserializedType")
        if let pipelineResponse = try? self.pipeline.run(request: request) {
            // update response if passed in
            if let responseIn = response {
                responseIn.update(withResponse: pipelineResponse.httpResponse)
            }
            if let data = pipelineResponse.httpResponse.data {
                let decoder = JSONDecoder()
                var deserialized = try? decoder.decode(PagedCollection<ConfigurationSetting>.self, from: data)
                deserialized?.client = self
                deserialized?.request = request
                return deserialized
            } else {
                throw HttpResponseError.general
            }
        } else {
            throw HttpResponseError.general
        }
    }
}
