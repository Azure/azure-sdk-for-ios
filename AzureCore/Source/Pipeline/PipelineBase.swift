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

    func onRequest(_ request: inout PipelineRequest)
    func onResponse(_ response: inout PipelineResponse)
    func onError(_ error: Error) -> Bool

    func process(request: inout PipelineRequest, completion: @escaping PipelineStageResultHandler)
}

extension PipelineStageProtocol {
    public func onRequest(_ request: inout PipelineRequest) {}
    public func onResponse(_ response: inout PipelineResponse) {}
    public func onError(_ error: Error) -> Bool { return false }

    public func process(request: inout PipelineRequest, completion: @escaping PipelineStageResultHandler) {
        self.onRequest(&request)
        self.next!.process(request: &request, completion: { result, httpResponse in
            switch result {
            case .success(var pipelineResponse):
                self.onResponse(&pipelineResponse)
                completion(.success(pipelineResponse), httpResponse)
            case .failure(let error):
                let handled = self.onError(error, fromResponse: httpResponse)
                if !handled {
                    completion(.failure(error), httpResponse)
                }
            }
        })
    }
}
