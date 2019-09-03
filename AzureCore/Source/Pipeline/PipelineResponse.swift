//
//  PipelineResponse.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/29/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

@objc public class PipelineResponse: NSObject {
    internal var httpRequest: HttpRequest
    internal var httpResponse: HttpResponse
    internal var context: PipelineContext?
    
    @objc convenience init(request: HttpRequest, response: HttpResponse) {
        self.init(request: request, response: response, context: nil)
    }
    
    @objc init(request: HttpRequest, response: HttpResponse, context: PipelineContext?) {
        self.httpRequest = request
        self.httpResponse = response
        self.context = context
    }
    
}
