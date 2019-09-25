//
//  PipelineBase.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/30/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

public typealias HttpResultHandler<T> = (Result<T, Error>, HttpResponse) -> Void
public typealias PipelineStageResultHandler = HttpResultHandler<PipelineResponse>

public protocol PipelineStageProtocol {
    var next: PipelineStageProtocol? { get set }

    func onRequest(_ request: PipelineRequest)
    func onResponse(_ response: PipelineResponse, request: PipelineRequest)
    func onError(request: PipelineRequest) -> Bool

    func process(request: PipelineRequest, completion: @escaping PipelineStageResultHandler)
}

extension PipelineStageProtocol {
    public func onRequest(_ request: PipelineRequest) {}
    public func onResponse(_ response: PipelineResponse, request: PipelineRequest) {}
    public func onError(request: PipelineRequest) -> Bool { return false }

    public func process(request: PipelineRequest, completion: @escaping PipelineStageResultHandler) {
        self.onRequest(request)
        self.next!.process(request: request, completion: { result, httpResponse in
            switch result {
            case .success(let pipelineResponse):
                self.onResponse(pipelineResponse, request: request)
                completion(.success(pipelineResponse), httpResponse)
            case .failure(let error):
                completion(.failure(error), httpResponse)
            }
        })
    }
}
