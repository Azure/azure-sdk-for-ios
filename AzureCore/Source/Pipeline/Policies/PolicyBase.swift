//
//  SansIOHttpPolicy.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/28/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

@objc public protocol SansIOHttpPolicy {
    @objc optional func onRequest(_ request: PipelineRequest)
    @objc optional func onResponse(_ response: PipelineResponse, request: PipelineRequest)
    @objc optional func onError(request: PipelineRequest) -> Bool
}

@objc public protocol HttpPolicy: PipelineSendable {
    @objc var next: PipelineSendable? { get set }
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
