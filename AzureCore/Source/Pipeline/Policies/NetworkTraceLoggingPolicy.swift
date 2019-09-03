//
//  NetworkTraceLoggingPolicy.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/28/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

@objc public class NetworkTraceLoggingPolicy: NSObject, SansIOHttpPolicy {
    
    @objc public var enableLogging: Bool
    
    @objc public init(enableLogging: Bool = false) {
        self.enableLogging = enableLogging
    }
    
    @objc public func onRequest(_ request: PipelineRequest) {
        let enableLogging = request.context?.getValue(forKey: "enableLogging") as? Bool ?? self.enableLogging
        guard enableLogging else { return }
        request.context = request.context?.add(value: true as AnyObject, forKey: "enableLogging")
        // TODO: implement
        // if logger not enabled for debug return
        // log response request URL
        // log request method
        // log request headers
        // log request body
        // log "file upload" for binary data, else the body string
        // on error, log error
    }
    
    @objc public func onResponse(_ response: PipelineResponse, request: PipelineRequest) {
        let enableLogging = request.context?.getValue(forKey: "enableLogging") as? Bool ?? self.enableLogging
        guard enableLogging else { return }
        // TODO: implement
        // if logger not enabled for debug return
        // log response status code
        // log response headers
        // log response content if not binary...
        // on error, log error
    }
}
