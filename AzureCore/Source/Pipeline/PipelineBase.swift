//
//  PipelineBase.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/30/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

public typealias PipelineCompletionHandler = (PipelineResponse?, Error?) -> Void

public typealias ResultHandler<T> = (T?, HttpResponse?, Error?) -> Void

public protocol PipelineStageProtocol {
    var next: PipelineStageProtocol? { get set }

    func onRequest(_ request: PipelineRequest)
    func onResponse(_ response: PipelineResponse, request: PipelineRequest)
    func onError(request: PipelineRequest) -> Bool

    func process(request: PipelineRequest, completion: @escaping PipelineCompletionHandler)
}

extension PipelineStageProtocol {
    public func onRequest(_ request: PipelineRequest) {}
    public func onResponse(_ response: PipelineResponse, request: PipelineRequest) {}
    public func onError(request: PipelineRequest) -> Bool { return false }

    public func process(request: PipelineRequest, completion: @escaping PipelineCompletionHandler) {
        self.onRequest(request)
        self.next!.process(request: request, completion: { pipelineResponse, error in
            if let pipelineResponse = pipelineResponse {
                self.onResponse(pipelineResponse, request: request)
            }
            completion(pipelineResponse, error)
        })
    }
}
