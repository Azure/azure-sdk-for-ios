//
//  PipelineRequest.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/29/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

@objc public class PipelineRequest: NSObject, PipelineContextSupportable {
    
    @objc public var httpRequest: HttpRequest
    internal var context: PipelineContext?
    
    @objc public convenience init(request: HttpRequest) {
        self.init(request: request, context: nil)
    }
    
    @objc public init(request: HttpRequest, context: PipelineContext?) {
        self.httpRequest = request
        self.context = context
    }
    
    @objc public func add(value: AnyObject, forKey key: AnyHashable) {
        if let context = self.context {
            self.context = context.add(value: value, forKey: key)
        } else {
            self.context = PipelineContext(key: key, value: value)
        }
    }
    
    @objc public func getValue(forKey key: AnyHashable) -> AnyObject? {
        return self.context?.getValue(forKey: key)
    }
}
