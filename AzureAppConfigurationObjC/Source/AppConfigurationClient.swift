//
//  AppConfigurationClient.swift
//  DemoAppObjC
//
//  Created by Travis Prescott on 8/8/19.
//  Copyright © 2019 Travis Prescott. All rights reserved.
//

import AzureCore
import Foundation

struct Contants {
    static let apiVersion = "2019-01-01"
}

public class AppConfigurationClient: PipelineClient {

    private static let apiVersion = Contants.apiVersion

    public init(connectionString: String) throws {
        guard let credential = try? AppConfigurationCredential(connectionString: connectionString) else {
            throw AzureError.general
        }
        let config = PipelineConfiguration(
            headersPolicy: HeadersPolicy(),
            redirectPolicy: RedirectPolicy(),
            retryPolicy: RetryPolicy(),
            customHookPolicy: CustomHookPolicy(),
            contentDecodePolicy: ContentDecodePolicy(),
            loggingPolicy: NetworkTraceLoggingPolicy(),
            userAgentPolicy: UserAgentPolicy(),
            authenticationPolicy: AppConfigurationAuthenticationPolicy(credential: credential, scopes: [credential.endpoint]),
            distributedTracingPolicy: DistributedTracingPolicy()
        )
        let policies: [AnyObject] = [
            config.userAgentPolicy,
            config.headersPolicy,
            config.authenticationPolicy as AnyObject,
            config.contentDecodePolicy,
            config.redirectPolicy,
            config.retryPolicy,
            config.loggingPolicy
        ]
        let pipeline = Pipeline(transport: UrlSessionTransport(), policies: policies)
        super.init(baseUrl: credential.endpoint, config: config, pipeline: pipeline)
    }

    public func getConfigurationSettings(forKey key: String?, forLabel label: String?, withResponse response: HttpResponse? = nil) throws -> Collection<ConfigurationSetting>? {
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
                let deserialized = try? decoder.decode(Collection<ConfigurationSetting>.self, from: data)
                return deserialized
            } else {
                throw HttpResponseError.general
            }
        } else {
            throw HttpResponseError.general
        }
    }

}
