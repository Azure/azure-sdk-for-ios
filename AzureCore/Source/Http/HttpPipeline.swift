//
//  HttpPipeline.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/23/19.
//

import Foundation

@objc
public final class HttpPipeline: NSObject {
    @objc let httpClient: HttpClient
    @objc let pipelinePolicies: [HttpPipelinePolicy]
    
    @objc init(client: HttpClient, pipelinePolicies: [HttpPipelinePolicy]) {
        self.httpClient = client
        self.pipelinePolicies = pipelinePolicies
    }
    
    @objc func send(request: HttpRequest) -> HttpResponse? {
        return self.send(context: HttpPipelineCallContext(request: request))
    }
    
    @objc func send(request: HttpRequest, context: Context) -> HttpResponse? {
        return self.send(context: HttpPipelineCallContext(request: request, context: context))
    }
    
    @objc func send(context: HttpPipelineCallContext) -> HttpResponse? {
        // TODO: convert Java
//        return Mono.defer(() -> {
//            HttpPipelineNextPolicy next = new HttpPipelineNextPolicy(this, context);
//            return next.process();
//        });
        return nil
    }
}
