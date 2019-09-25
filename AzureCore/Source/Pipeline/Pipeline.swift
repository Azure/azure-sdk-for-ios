//
//  Pipeline.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/29/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

internal class Pipeline {

    private var policies: [PipelineStageProtocol]
    private let transport: HttpTransportable

    public init(transport: HttpTransportable, policies: [PipelineStageProtocol]) {
        self.transport = transport
        self.policies = policies
        var prevPolicy: PipelineStageProtocol?
        for policy in policies {
            if prevPolicy != nil {
                prevPolicy!.next = policy
            }
            prevPolicy = policy
        }
        var lastPolicy = self.policies.removeLast()
        lastPolicy.next = transport
        self.policies.append(lastPolicy)
    }

    public func run(request: PipelineRequest, completion: @escaping PipelineStageResultHandler) {
        if let firstPolicy = policies.first {
            firstPolicy.process(request: request, completion: { result, httpResponse in
                switch result {
                case .success(let pipelineResponse):
                    completion(.success(pipelineResponse), httpResponse)
                case .failure(let error):
                    completion(.failure(error), httpResponse)
                }
            })
        }
    }
}
