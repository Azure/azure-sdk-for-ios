//
//  Pipeline.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/29/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

internal class SansIOHttpPolicyRunner: HttpPolicy {

    var next: PipelineSendable?
    let policy: SansIOHttpPolicy

    init(policy: SansIOHttpPolicy) {
        self.policy = policy
    }

    func send(request: PipelineRequest) throws -> PipelineResponse {
        var response: PipelineResponse
        self.policy.onRequest(request)
        do {
            response = try self.next!.send(request: request)
            self.policy.onResponse(response, request: request)
            return response
        } catch {
            if !(self.policy.onError(request: request)) {
                throw error
            }
        }
        return PipelineResponse(request: request.httpRequest,
                                response: HttpResponse(request: request.httpRequest), context: request.context)
    }
}

internal class TransportRunner: PipelineSendable {

    var next: PipelineSendable?
    let sender: HttpTransport

    init(sender: HttpTransport) {
        self.sender = sender
    }

    func send(request: PipelineRequest) throws -> PipelineResponse {
        return PipelineResponse(
            request: request.httpRequest,
            response: try self.sender.send(request: request).httpResponse,
            context: request.context
        )
    }
}

internal class Pipeline {

    private var implPolicies: [PipelineSendable]
    private let transport: HttpTransport

    public init(transport: HttpTransport, policies: [AnyObject] = [AnyObject]()) {
        self.transport = transport
        self.implPolicies = [PipelineSendable]()
        var prevPolicy: PipelineSendable?
        for policy in policies {
            var newPolicy: PipelineSendable
            if let policy = policy as? SansIOHttpPolicy {
                newPolicy = SansIOHttpPolicyRunner(policy: policy)
            } else if let policy = policy as? HttpPolicy {
                newPolicy = policy
            } else {
                fatalError("Unrecognized policy type: \(type(of: policy))")
            }
            if prevPolicy != nil {
                prevPolicy!.next = newPolicy
            }
            self.implPolicies.append(newPolicy)
            prevPolicy = newPolicy
        }
        var lastPolicy = self.implPolicies.removeLast()
        lastPolicy.next = transport
        self.implPolicies.append(lastPolicy)
    }

    public func run(request: PipelineRequest) throws -> PipelineResponse {
        let firstNode = self.implPolicies.first ?? TransportRunner(sender: self.transport)
        return try firstNode.send(request: request)
    }
}
