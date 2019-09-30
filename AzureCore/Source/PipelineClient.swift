//
//  PipelineClientBase.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/29/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

open class PipelineClient {

    internal var pipeline: Pipeline

    internal var baseUrl: String

    internal let headersPolicy: HeadersPolicy
    internal let userAgentPolicy: UserAgentPolicy
    internal let authenticationPolicy: PipelineStageProtocol
    internal let contentDecodePolicy: ContentDecodePolicy
    internal let transport: HttpTransportable

    public init(baseUrl: String, headersPolicy: HeadersPolicy, userAgentPolicy: UserAgentPolicy,
                authenticationPolicy: AuthenticationProtocol, contentDecodePolicy: ContentDecodePolicy,
                transport: HttpTransportable) {
        self.baseUrl = baseUrl

        self.headersPolicy = headersPolicy
        self.userAgentPolicy = userAgentPolicy
        self.authenticationPolicy = authenticationPolicy
        self.contentDecodePolicy = contentDecodePolicy
        self.transport = transport

        let policies: [PipelineStageProtocol] = [
            headersPolicy,
            userAgentPolicy,
            authenticationPolicy as PipelineStageProtocol,
            contentDecodePolicy
        ]
        self.pipeline = Pipeline(transport: transport, policies: policies)
    }

    public func run(request: HttpRequest, completion: @escaping (Result<Data?, Error>, HttpResponse) -> Void) {
        var pipelineRequest = PipelineRequest(request: request)
        self.pipeline.run(request: &pipelineRequest, completion: { result, httpResponse in
            switch result {
            case .success(let pipelineResponse):
                let deserialized = pipelineResponse.getValue(forKey: "deserializedData")
                if let data = pipelineResponse.httpResponse?.data {
                    completion(.success(data), httpResponse)
                }
            case .failure(let error):
                completion(.failure(error), httpResponse)
            }
        })
    }

    public func request(method: HttpMethod, urlTemplate: String?, queryParams: [String: String]? = nil,
                        content: Data? = nil, formContent: [String: AnyObject]? = nil,
                        streamContent: AnyObject? = nil) -> HttpRequest {
        // TODO: Why isn't this part of the pipeline!?!
        let request = HttpRequest(httpMethod: method, url: format(urlTemplate: urlTemplate))
        if let queryParams = queryParams {
            request.format(queryParams: queryParams)
        }
        return request
    }

    private func formatUrlSection(template: String) -> String {
        // TODO: replace {these} with their values
        // let components = template.components(separatedBy: "/")
        return template
    }

    private func format(urlTemplate: String?) -> String {
        var url: String
        if let urlTemplate = urlTemplate {
            url = formatUrlSection(template: "\(baseUrl)\(urlTemplate)")
            // TODO: Some more URL parsing here...
        } else {
            url = baseUrl
        }
        return url
    }
}
