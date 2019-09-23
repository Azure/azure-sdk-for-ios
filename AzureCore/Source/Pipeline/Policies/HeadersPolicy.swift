//
//  HeadersPolicy.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/28/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

public class HeadersPolicy: SansIOHttpPolicy {

    private var _headers: HttpHeaders
    public var headers: HttpHeaders {
        return self._headers
    }

    public init(baseHeaders: HttpHeaders? = nil) {
        self._headers = baseHeaders ?? HttpHeaders()
    }

    public func add(header: HttpHeader, value: String) {
        self._headers[header] = value
    }

    public func onRequest(_ request: PipelineRequest) {
        for (key, value) in self.headers {
            request.httpRequest.headers[key] = value
        }
        if let additionalHeaders = request.context?.getValue(forKey: "headers") as? HttpHeaders {
            for (key, value) in additionalHeaders {
                request.httpRequest.headers[key] = value
            }
        }
    }
}
