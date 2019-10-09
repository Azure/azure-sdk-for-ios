//
//  PipelineBase.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/30/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

public typealias ResultHandler<TSuccess, TError: Error> = (Result<TSuccess, TError>, HttpResponse) -> Void
public typealias HttpResultHandler<T> = ResultHandler<T, Error>
public typealias PipelineStageResultHandler = ResultHandler<PipelineResponse, PipelineError>

public protocol PipelineStageProtocol {
    var next: PipelineStageProtocol? { get set }

    func onRequest(_ request: inout PipelineRequest)
    func onResponse(_ response: inout PipelineResponse)
    func onError(_ error: PipelineError) -> Bool

    func process(request: inout PipelineRequest, completion: @escaping PipelineStageResultHandler)
}

extension PipelineStageProtocol {
    public func onRequest(_: inout PipelineRequest) {}
    public func onResponse(_: inout PipelineResponse) {}
    public func onError(_: PipelineError) -> Bool { return false }

    public func process(request: inout PipelineRequest, completion: @escaping PipelineStageResultHandler) {
        onRequest(&request)
        next!.process(request: &request, completion: { result, httpResponse in
            switch result {
            case var .success(pipelineResponse):
                self.onResponse(&pipelineResponse)
                completion(.success(pipelineResponse), httpResponse)
            case let .failure(error):
                let handled = self.onError(error)
                if !handled {
                    completion(.failure(error), httpResponse)
                }
            }
        })
    }
}
