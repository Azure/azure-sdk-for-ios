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

@objc public class RequestHistory: NSObject {
    @objc let httpRequest: HttpRequest
    @objc let httpResponse: HttpResponse
    @objc let error: Error?
    @objc let context: PipelineContext?
    
    @objc public init(request: HttpRequest, response: HttpResponse, context: PipelineContext?, error: Error?) {
        // TODO: request should be a deep copy
        self.httpRequest = request
        self.httpResponse = response
        self.error = error
        self.context = context
    }
}
