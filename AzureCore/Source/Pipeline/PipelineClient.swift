//
//  PipelineClientBase.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/29/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

open class AzureOptions {
    /// A client-generated, opaque value with 1KB character limit that is recorded in analytics logs.
    /// Highly recommended for correlating client-side activites with requests received by the server.
    public var clientRequestId: String?

    public init() {
        clientRequestId = nil
    }
}

open class PipelineClient {
    public var logger: ClientLogger

    internal var pipeline: Pipeline
    internal var baseUrl: String

    public init(baseUrl: String, transport: HttpTransportable, policies: [PipelineStageProtocol],
                logger: ClientLogger) {
        self.baseUrl = baseUrl
        if self.baseUrl.suffix(1) != "/" { self.baseUrl += "/" }
        self.logger = logger
        pipeline = Pipeline(transport: transport, policies: policies)
    }

    public func run(request: HttpRequest, context: [String: AnyObject]?,
                    completion: @escaping (Result<Data?, Error>, HttpResponse) -> Void) {
        var pipelineRequest = PipelineRequest(request: request, logger: logger)
        if let context = context {
            for (key, value) in context {
                pipelineRequest.add(value: value as AnyObject, forKey: key)
            }
        }
        pipeline.run(request: &pipelineRequest, completion: { result, httpResponse in
            switch result {
            case let .success(pipelineResponse):
                let deserializedData = pipelineResponse.value(forKey: .deserializedData) as? Data

                // invalid status code is a failure
                let statusCode = httpResponse.statusCode ?? -1
                let allowedStatusCodes = pipelineResponse.value(forKey: .allowedStatusCodes) as? [Int] ?? [200]
                if !allowedStatusCodes.contains(httpResponse.statusCode ?? -1) {
                    var message = "Service returned invalid status code [\(statusCode)]."
                    if let errorData = deserializedData,
                        let errorJson = try? JSONSerialization.jsonObject(with: errorData) {
                        message += " \(String(describing: errorJson))"
                    }
                    let error = HttpResponseError.statusCode(message)
                    completion(.failure(error), httpResponse)
                    return
                }

                if let deserialized = deserializedData {
                    completion(.success(deserialized), httpResponse)
                } else if let data = httpResponse.data {
                    completion(.success(data), httpResponse)
                }
            case let .failure(error):
                completion(.failure(error), httpResponse)
            }
        })
    }

    public func request(method: HttpMethod, url: String, queryParams: [String: String], headerParams: HttpHeaders,
                        content _: Data? = nil, formContent _: [String: AnyObject]? = nil,
                        streamContent _: AnyObject? = nil) -> HttpRequest {
        let request = HttpRequest(httpMethod: method, url: url, headers: headerParams)
        request.format(queryParams: queryParams)
        return request
    }

    public func format(urlTemplate: String?, withKwargs kwargs: [String: String] = [String: String]()) -> String {
        var template = urlTemplate ?? ""
        if template.hasPrefix("/") { template = String(template.dropFirst()) }
        var url: String
        if template.starts(with: baseUrl) {
            url = template
        } else {
            url = baseUrl + template
        }
        for (key, value) in kwargs {
            url = url.replacingOccurrences(of: "{\(key)}", with: value)
        }
        return url
    }
}
