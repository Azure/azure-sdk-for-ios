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

    public func run(request: HttpRequest, allowedStatusCodes: [Int],
                    completion: @escaping (Result<Data?, Error>, HttpResponse) -> Void) {
        var pipelineRequest = PipelineRequest(request: request)
        self.pipeline.run(request: &pipelineRequest, completion: { result, httpResponse in

            // invalid status code is a failure
            let statusCode = httpResponse.statusCode ?? -1
            if !allowedStatusCodes.contains(httpResponse.statusCode ?? -1) {
                let message = "Service returned invalid status code [\(statusCode)]."
                let error = HttpResponseError.statusCode(statusCode, message)
                completion(.failure(error), httpResponse)
                return
            }

            switch result {
            case .success(let pipelineResponse):
                if let deserialized = pipelineResponse.getValue(forKey: "deserializedData") as? Data {
                    completion(.success(deserialized), httpResponse)
                } else {
                    let error = HttpResponseError.decode("Deserialized data expected but not found.")
                    completion(.failure(error), httpResponse)
                }
            case .failure(let error):
                completion(.failure(error), httpResponse)
            }
        })
    }

    public func request(method: HttpMethod, url: String, queryParams: [String: String], headerParams: HttpHeaders,
                        content: Data? = nil, formContent: [String: AnyObject]? = nil,
                        streamContent: AnyObject? = nil) -> HttpRequest {
        let request = HttpRequest(httpMethod: method, url: url, headers: headerParams)
        request.format(queryParams: queryParams)
        return request
    }

    public func format(urlTemplate: String?, withKwargs kwargs: [String: String] = [String: String]()) -> String {
        let urlTemplate = baseUrl + (urlTemplate ?? "")
        var url = urlTemplate
        for (key, value) in kwargs {
            url = url.replacingOccurrences(of: "{\(key)}", with: value)
        }
        return url
    }
}
