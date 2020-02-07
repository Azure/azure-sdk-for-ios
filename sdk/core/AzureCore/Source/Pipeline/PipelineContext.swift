// --------------------------------------------------------------------------
//
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// The MIT License (MIT)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the ""Software""), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
//
// --------------------------------------------------------------------------

import Foundation

// MARK: - ContextKey enum

public enum ContextKey: String {
    case allowedStatusCodes
    case deserializedData
    case requestStartTime
    case xmlMap
}

// MARK: PipelineContextSupporting Protocol

public protocol PipelineContextSupporting {
    // MARK: Required Properties

    var context: PipelineContext? { get set }

    // MARK: Required Methods

    mutating func add(value: AnyObject, forKey key: AnyHashable)
    mutating func add(value: AnyObject, forKey key: ContextKey)
    func value(forKey key: AnyHashable) -> AnyObject?
    func value(forKey key: ContextKey) -> AnyObject?
}

extension PipelineContextSupporting {
    public mutating func add(value: AnyObject, forKey key: AnyHashable) {
        if let context = self.context {
            return context.add(value: value, forKey: key)
        } else {
            context = PipelineContext.of(keyValues: [key: value])
        }
    }

    public mutating func add(value: AnyObject, forKey key: ContextKey) {
        if let context = self.context {
            return context.add(value: value, forKey: key)
        } else {
            context = PipelineContext.of(keyValues: [key.rawValue: value])
        }
    }

    public func value(forKey key: AnyHashable) -> AnyObject? {
        return context?.value(forKey: key)
    }

    public func value(forKey key: ContextKey) -> AnyObject? {
        return context?.value(forKey: key)
    }
}

// MARK: PipelineContext

public class PipelineContext {
    // MARK: Properties

    internal var node: PipelineContextNode?

    internal var count: Int {
        var count = 0
        var current: PipelineContextNode? = node
        while current != nil {
            count += 1
            current = current?.parent
        }
        return count
    }

    // MARK: Static Methods

    public static func of(keyValues: [AnyHashable: AnyObject]) -> PipelineContext {
        let context = PipelineContext()
        for (key, value) in keyValues {
            context.add(value: value, forKey: key)
        }
        return context
    }

    // MARK: Public Methods

    public func add(value: AnyObject, forKey key: AnyHashable) {
        if let node = self.node {
            self.node = node.add(value: value, forKey: key)
        } else {
            node = PipelineContextNode(key: key, value: value)
        }
    }

    public func add(value: AnyObject, forKey key: ContextKey) {
        add(value: value, forKey: key.rawValue)
    }

    public func value(forKey key: AnyHashable) -> AnyObject? {
        return node?.value(forKey: key)
    }

    public func value(forKey key: ContextKey) -> AnyObject? {
        return value(forKey: key.rawValue)
    }
}

internal class PipelineContextNode {
    // MARK: Properties

    internal let parent: PipelineContextNode?
    internal let key: AnyHashable
    internal let value: AnyObject?

    // MARK: Initializers

    internal convenience init(key: AnyHashable, value: AnyObject?) {
        self.init(parent: nil, key: key, value: value)
    }

    internal init(parent: PipelineContextNode?, key: AnyHashable, value: AnyObject?) {
        self.parent = parent
        self.key = key
        self.value = value
    }

    // MARK: Internal Methods

    internal func add(value: AnyObject, forKey key: AnyHashable) -> PipelineContextNode {
        return PipelineContextNode(parent: self, key: key, value: value)
    }

    internal func value(forKey key: AnyHashable) -> AnyObject? {
        var current: PipelineContextNode? = self
        repeat {
            if key == current?.key {
                return current?.value
            }
            current = current?.parent
        } while current != nil
        return nil
    }
}
