//
//  DistributedTracingPolicy.swift
//  AzureCore
//
//  Created by Travis Prescott on 9/11/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

public class DistributedTracingPolicy: SansIOHttpPolicy {

    public init() {}
    
    public func onRequest(_ request: PipelineRequest) {
    }

    public func onResponse(_ response: PipelineResponse, request: PipelineRequest) {
    }

    public func onError(request: PipelineRequest) -> Bool {
        return false
    }
}
