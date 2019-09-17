//
//  AppConfigurationClient.swift
//  DemoAppObjC
//
//  Created by Travis Prescott on 8/8/19.
//  Copyright © 2019 Travis Prescott. All rights reserved.
//

import AzureCore
import Foundation

@objc class AppConfigurationClient: PipelineClient {

    private static let apiVersion = "2019-01-01"
        
    @objc public init(connectionString: String) throws {
        guard let credential = try? AppConfigurationCredential(connectionString: connectionString) else {
            throw ErrorUtil.makeNSError(.General, withMessage: "Invalid connection string.")
        }
        let config = PipelineConfiguration(
            headersPolicy: HeadersPolicy(),
            proxyPolicy: ProxyPolicy(),
            redirectPolicy: RedirectPolicy(),
            retryPolicy: RetryPolicy(),
            customHookPolicy: CustomHookPolicy(),
            contentDecodePolicy: ContentDecodePolicy(),
            loggingPolicy: NetworkTraceLoggingPolicy(),
            userAgentPolicy: UserAgentPolicy(),
            authenticationPolicy: AppConfigurationAuthenticationPolicy(credential: credential, scopes: [credential.endpoint]),
            distributedTracingPolicy: DistributedTracingPolicy()
        )
        let policies: [NSObject] = [
            config.userAgentPolicy,
            config.headersPolicy,
            config.authenticationPolicy as! NSObject,
            config.contentDecodePolicy,
            config.proxyPolicy,
            config.redirectPolicy,
            config.retryPolicy,
            config.loggingPolicy
        ]
        let pipeline = Pipeline(transport: UrlSessionTransport(), policies: policies)
        super.init(baseUrl: credential.endpoint, config: config, pipeline: pipeline)
    }

    @objc public func getConfigurationSettings(forKey key: String?, forLabel label: String?, withResponse response: HttpResponse? = nil) throws -> AZCPagedCollection {
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
                let json = try? JSONSerialization.jsonObject(with: data, options: [.mutableContainers, .mutableLeaves]) as? Dictionary<String, AnyObject>
                let items = json?["items"] as? [Any]
                let nextLink = json?["@nextLink"] as? String
                if items != nil {
                    return AZCPagedCollection(items: items!, withNextLink: nextLink)
                } else {
                    throw ErrorUtil.makeNSError(.Decode, withMessage: "Unable to decode response body.", response: pipelineResponse.httpResponse)
                }
            } else {
                throw ErrorUtil.makeNSError(.General, withMessage: "Expected response body but didn't find one.", response: pipelineResponse.httpResponse)
            }
        } else {
            throw ErrorUtil.makeNSError(.General, withMessage: "Failure obtaining HTTP response.", response: nil)
        }
    }
    
    @objc public func set(parameters: ConfigurationSettingPutParameters, key: String, label: String?, withResponse response: HttpResponse? = nil) throws -> ConfigurationSetting {
        // TODO: Additional supported functionality
        // If-Match (eTag) header
        // If-None-Match (eTag) header

        let queryParams = [
            "label": label ?? "*"
        ]
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        guard let body = try? encoder.encode(parameters) else {
            throw ErrorUtil.makeNSError(.General, withMessage: "Unable to serialize parameters.")
        }
        let request = PipelineRequest(request: self.request(
            method: HttpMethod.PUT,
            urlTemplate: "/kv/\(key)",
            queryParams: queryParams,
            headers: ["Content-Type": "application/vnd.microsoft.appconfig.kv+json;"],
            content: body))

        if let pipelineResponse = try? self.pipeline.run(request: request) {
            // update response if passed in
            if let responseIn = response {
                responseIn.update(withResponse: pipelineResponse.httpResponse)
            }
            if let data = pipelineResponse.httpResponse.data {
                let decoder = JSONDecoder()
                let deserialized = try decoder.decode(ConfigurationSetting.self, from: data)
                return deserialized
            } else {
                throw ErrorUtil.makeNSError(.General, withMessage: "Expected response body but didn't find one.", response: pipelineResponse.httpResponse)
            }
        } else {
            throw ErrorUtil.makeNSError(.General, withMessage: "Failure obtaining HTTP response.", response: nil)
        }
    }
}
