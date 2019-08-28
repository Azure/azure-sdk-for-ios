//
//  SansIOHttpPolicy.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/28/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

public class SansIOHttpPolicy: NSObject {
    func onRequest(_ request: PipelineRequest) {
        return
    }
    
    func onResponse(request: PipelineRequest, response: PipelineResponse) {
        return
    }

    func onError(request: PipelineRequest) -> Bool {
        return false
    }
}

@objc public protocol HttpPolicy {
    @objc var next: HttpPolicy? { get set }
    @objc func send(request: PipelineRequest) throws -> PipelineResponse
}
