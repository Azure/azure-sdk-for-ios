//
//  RetryPolicy.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/28/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

@objc public class RetryPolicy: NSObject, HttpPolicy {

    public var next: HttpPolicy?

    private let backoffMax = 120
    
    public func send(request: PipelineRequest) throws -> PipelineResponse {
        var retryActive = true
//        let retrySettings = self.configureRetries(request.context)
//        while retryActive {
//            do {
//                response = self.next?.send(request: request)
//                // TODO: more implmentation
//            } catch {
//                // TODO: Error stuff
//            }
//        }
    }
}
