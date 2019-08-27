//
//  HttpPipelineCallContext.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/23/19.
//

import Foundation

@objc
public final class HttpPipelineCallContext: NSObject {
    internal let httpRequest: HttpRequest
    private let context: Context?
    
    @objc convenience init(request: HttpRequest) {
        self.init(request: request, context: nil)
    }
    
    @objc init(request: HttpRequest, context: Context?) {
        self.httpRequest = request
        self.context = context
    }
}
