//
//  HttpPipelineNextPolicy.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/23/19.
//

import Foundation

@objc
public class HttpPipelineNextPolicy: NSObject {
    private let pipeline: HttpPipeline
    private let context: PipelineRequest
    private var currentPolicyIndex: Int
    
    @objc public init(pipeline: HttpPipeline, context: PipelineRequest) {
        self.pipeline = pipeline
        self.context = context
        self.currentPolicyIndex = -1
    }
    
    @objc public func process() -> HttpResponse? {
        let size = self.pipeline.pipelinePolicies.count
        if (self.currentPolicyIndex > size) {
            // TODO: Error handling
            // IllegalState: There are no more policies to execute.
            return nil
        }
        
        self.currentPolicyIndex += 1
        if (self.currentPolicyIndex == size) {
            return self.pipeline.httpClient.send(request: self.context.httpRequest)
        } else {
            return self.pipeline.pipelinePolicies[self.currentPolicyIndex].process(context: self.context, next: self)
        }
    }
}
