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
    public func onRequest(_ request: inout PipelineRequest) {}
    public func onResponse(_ response: inout PipelineResponse) {}
    public func onError(_ error: PipelineError) -> Bool { return false }

    public func process(request: inout PipelineRequest, completion: @escaping PipelineStageResultHandler) {
        self.onRequest(&request)
        self.next!.process(request: &request, completion: { result, httpResponse in
            switch result {
            case .success(var pipelineResponse):
                self.onResponse(&pipelineResponse)
                completion(.success(pipelineResponse), httpResponse)
            case .failure(let error):
                let handled = self.onError(error)
                if !handled {
                    completion(.failure(error), httpResponse)
                }
            }
        })
    }
}
