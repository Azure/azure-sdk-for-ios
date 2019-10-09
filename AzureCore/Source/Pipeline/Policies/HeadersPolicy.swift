//
//  HeadersPolicy.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/28/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

public class HeadersPolicy: PipelineStageProtocol {
    public var next: PipelineStageProtocol?

    private var _headers: HttpHeaders
    public var headers: HttpHeaders {
        return _headers
    }

    public init(baseHeaders: HttpHeaders? = nil) {
        _headers = baseHeaders ?? HttpHeaders()
    }

    public func add(header: HttpHeader, value: String) {
        _headers[header] = value
    }

    public func onRequest(_ request: inout PipelineRequest) {
        for (key, value) in headers {
            request.httpRequest.headers[key] = value
        }
        if let additionalHeaders = request.context?.value(forKey: "headers") as? HttpHeaders {
            for (key, value) in additionalHeaders {
                request.httpRequest.headers[key] = value
            }
        }
    }
}
