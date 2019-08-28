//
//  Base.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/28/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

@objc public class PipelineContext: NSObject {
    // TODO: Compare to Python's context implementation...
    // private let logger = ClientLogger(Context.class)
    
    private let parent: PipelineContext?
    private let key: AnyHashable
    private let value: AnyObject?
    
    @objc init(key: AnyHashable, value: AnyObject?) {
        self.parent = nil
        self.key = key
        self.value = value
    }
    
    private init(parent: PipelineContext, key: AnyHashable, value: AnyObject?) {
        self.parent = parent
        self.key = key
        self.value = value
    }
    
    @objc public func add(value: AnyObject, forKey key: AnyHashable) -> PipelineContext {
        return PipelineContext(parent: self, key: key, value: value)
    }
    
    @objc public static func of(keyValues: [AnyHashable: AnyObject]) -> PipelineContext {
        var context: PipelineContext? = nil
        for (key, value) in keyValues {
            context = context?.add(value: value, forKey: key)
            if context == nil {
                context = PipelineContext(key: key, value: value)
            }
        }
        return context!
    }
    
    @objc public func getValue(forKey key: AnyHashable) -> AnyObject? {
        var current: PipelineContext? = self
        repeat {
            if key == current?.key {
                return current?.value
            }
            current = self.parent
        } while current != nil
        return nil
    }
}

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
