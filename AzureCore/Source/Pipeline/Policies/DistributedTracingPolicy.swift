//
//  DistributedTracingPolicy.swift
//  AzureCore
//
//  Created by Travis Prescott on 9/11/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

@objc public class DistributedTracingPolicy: NSObject, SansIOHttpPolicy {

    @objc public func onRequest(_ request: PipelineRequest) {
    }

    @objc public func onResponse(_ response: PipelineResponse, request: PipelineRequest) {
    }

    @objc public func onError(request: PipelineRequest) -> Bool {
        return false
    }
}
