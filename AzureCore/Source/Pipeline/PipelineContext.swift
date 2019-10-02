//
//  Base.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/28/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

public enum ContextKey: String {
    case deserializedData
}

// MARK: - PipelineContextProtocol

public protocol PipelineContextProtocol {
    var context: PipelineContext? { get set }

    mutating func add(value: AnyObject, forKey key: AnyHashable)
    func getValue(forKey key: AnyHashable) -> AnyObject?
}

// MARK: - PipelineContextProtocol extension

extension PipelineContextProtocol {

    mutating public func add(value: AnyObject, forKey key: AnyHashable) {
        if let context = self.context {
            self.context = context.add(value: value, forKey: key)
        } else {
            self.context = PipelineContext(key: key, value: value)
        }
    }

    mutating public func add(value: AnyObject, forKey key: ContextKey) {
        add(value: value, forKey: key.rawValue)
    }

    public func getValue(forKey key: AnyHashable) -> AnyObject? {
        return context?.getValue(forKey: key)
    }

    public func getValue(forKey key: ContextKey) -> AnyObject? {
        return getValue(forKey: key.rawValue)
    }
}

public class PipelineContext: CustomDebugStringConvertible {

    private let parent: PipelineContext?
    private let key: AnyHashable
    private let value: AnyObject?

    public var debugDescription: String {
        var debugString = "\(key) "
        if let parent = parent {
            debugString += parent.debugDescription
        }
        return debugString
    }

    convenience internal init(key: AnyHashable, value: AnyObject?) {
        self.init(parent: nil, key: key, value: value)
    }

    internal init(parent: PipelineContext?, key: AnyHashable, value: AnyObject?) {
        self.parent = parent
        self.key = key
        self.value = value
    }

    public func add(value: AnyObject, forKey key: AnyHashable) -> PipelineContext {
        return PipelineContext(parent: self, key: key, value: value)
    }

    public static func of(keyValues: [AnyHashable: AnyObject]) -> PipelineContext {
        var context: PipelineContext?
        for (key, value) in keyValues {
            context = context?.add(value: value, forKey: key)
            if context == nil {
                context = PipelineContext(key: key, value: value)
            }
        }
        return context!
    }

    public func getValue(forKey key: AnyHashable) -> AnyObject? {
        var current: PipelineContext? = self
        repeat {
            if key == current?.key {
                return current?.value
            }
            current = current?.parent
        } while current != nil
        return nil
    }
}
