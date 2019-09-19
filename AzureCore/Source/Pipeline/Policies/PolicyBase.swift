//
//  SansIOHttpPolicy.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/28/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

public protocol SansIOHttpPolicy {
    func onRequest(_ request: PipelineRequest)
    func onResponse(_ response: PipelineResponse, request: PipelineRequest)
    func onError(request: PipelineRequest) -> Bool
}

extension SansIOHttpPolicy {
    public func onRequest(_ request: PipelineRequest) {}
    public func onResponse(_ response: PipelineResponse, request: PipelineRequest) {}
    public func onError(request: PipelineRequest) -> Bool { return false }
}

public protocol HttpPolicy: PipelineSendable {
    var next: PipelineSendable? { get set }
}

public class RequestHistory {
    let httpRequest: HttpRequest
    let httpResponse: HttpResponse
    let error: Error?
    let context: PipelineContext?

    public init(request: HttpRequest, response: HttpResponse, context: PipelineContext?, error: Error?) {
        // TODO: request should be a deep copy
        self.httpRequest = request
        self.httpResponse = response
        self.error = error
        self.context = context
    }
}
