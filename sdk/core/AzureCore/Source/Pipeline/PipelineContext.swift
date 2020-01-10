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

// MARK: - PipelineContextProtocol

public protocol PipelineContextProtocol {

    // MARK: Required Properties

    var context: PipelineContext? { get set }

    // MARK: Required Methods

    mutating func add(value: AnyObject, forKey key: AnyHashable)
    func value(forKey key: AnyHashable) -> AnyObject?
}

// MARK: - PipelineContextProtocol extension

extension PipelineContextProtocol {
    public mutating func add(value: AnyObject, forKey key: AnyHashable) {
        if let context = self.context {
            self.context = context.add(value: value, forKey: key)
        } else {
            context = PipelineContext(key: key, value: value)
        }
    }

    public mutating func add(value: AnyObject, forKey key: ContextKey) {
        add(value: value, forKey: key.rawValue)
    }

    public func value(forKey key: AnyHashable) -> AnyObject? {
        return context?.value(forKey: key)
    }

    public func value(forKey key: ContextKey) -> AnyObject? {
        return value(forKey: key.rawValue)
    }
}

public class PipelineContext {

    // MARK: Properties

    private let parent: PipelineContext?
    private let key: AnyHashable
    private let value: AnyObject?

    public var count: Int {
        var count = 0
        var current: PipelineContext? = self
        while current != nil {
            count += 1
            current = current?.parent
        }
        return count
    }

    // MARK: Initializers

    internal convenience init(key: AnyHashable, value: AnyObject?) {
        self.init(parent: nil, key: key, value: value)
    }

    internal init(parent: PipelineContext?, key: AnyHashable, value: AnyObject?) {
        self.parent = parent
        self.key = key
        self.value = value
    }

    // MARK: Static Methods

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

    // MARK: Public Methods

    public func add(value: AnyObject, forKey key: AnyHashable) -> PipelineContext {
        return PipelineContext(parent: self, key: key, value: value)
    }

    public func value(forKey key: AnyHashable) -> AnyObject? {
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
