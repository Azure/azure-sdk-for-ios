//
//  Context.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/23/19.
//

import Foundation

@objc
public class Context: NSObject {
    // private let logger = ClientLogger(Context.class)

    private let parent: Context?
    private let key: AnyHashable
    private let value: AnyObject?
    
    @objc init(key: AnyHashable, value: AnyObject?) {
        self.parent = nil
        self.key = key
        self.value = value
    }
    
    private init(parent: Context, key: AnyHashable, value: AnyObject?) {
        self.parent = parent
        self.key = key
        self.value = value
    }
    
    @objc public func add(value: AnyObject, forKey key: AnyHashable) -> Context {
        return Context(parent: self, key: key, value: value)
    }
    
    @objc public static func of(keyValues: [AnyHashable: AnyObject]) -> Context {
        var context: Context? = nil
        for (key, value) in keyValues {
            context = context?.add(value: value, forKey: key)
            if context == nil {
                context = Context(key: key, value: value)
            }
        }
        return context!
    }
    
    @objc public func getValue(forKey key: AnyHashable) -> AnyObject? {
        var current: Context? = self
        repeat {
            if key == current?.key {
                return current?.value
            }
            current = self.parent
        } while current != nil
        return nil
    }
}
