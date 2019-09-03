//
//  PipelineRequest.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/29/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

@objc public class PipelineRequest: NSObject {
    internal var httpRequest: HttpRequest
    internal var context: PipelineContext?
    
    @objc convenience init(request: HttpRequest) {
        self.init(request: request, context: nil)
    }
    
    @objc init(request: HttpRequest, context: PipelineContext?) {
        self.httpRequest = request
        self.context = context
    }
}
