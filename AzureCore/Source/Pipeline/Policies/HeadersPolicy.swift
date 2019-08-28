//
//  HeadersPolicy.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/28/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

@objc public class HeadersPolicy: SansIOHttpPolicy {
    
    private var _headers: HttpHeaders
    public var headers: HttpHeaders {
        return self._headers
    }
    
    @objc public init(baseHeaders: HttpHeaders?) {
        self._headers = baseHeaders ?? HttpHeaders()
    }
    
    @objc public func add(header: HttpHeaderType, value: String) {
        self._headers[header.name()] = value
    }
    
    override public func onRequest(_ request: PipelineRequest) {
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
