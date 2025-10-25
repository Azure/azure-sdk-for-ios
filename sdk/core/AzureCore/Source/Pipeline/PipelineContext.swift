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
    case allowedHeaders
    case cancellationToken
    case deserializedData
    case requestStartTime
    case xmlMap
    case xmlErrorMap
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

public extension PipelineContextSupporting {
    mutating func add(value: AnyObject, forKey key: AnyHashable) {
        if let context = context {
            return context.add(value: value, forKey: key)
        } else {
            context = PipelineContext.of(keyValues: [key: value])
        }
    }

    mutating func add(value: AnyObject, forKey key: ContextKey) {
        if let context = context {
            return context.add(value: value, forKey: key)
        } else {
            context = PipelineContext.of(keyValues: [key.rawValue: value])
        }
    }

    func value(forKey key: AnyHashable) -> AnyObject? {
        return context?.value(forKey: key)
    }

    func value(forKey key: ContextKey) -> AnyObject? {
        return context?.value(forKey: key)
    }
}

// MARK: PipelineContext

public class PipelineContext: Sequence {
    // MARK: Properties

    private enum Sentinel {
        case end
    }

    var head: PipelineContextNode

    var count: Int {
        var count = 0
        var current: PipelineContextNode = head
        while current.value as? Sentinel == nil {
            count += 1
            guard let parent = current.parent else { break }
            current = parent
        }
        return count
    }

    // MARK: Static Methods

    /// Create a `PipelineContext` from a simple dictionary of key-value pairs.
    /// - Parameter keyValues: `Dictionary` of key-value pairs. Value must be cast to `AnyObject`.
    /// - Returns: `PipelineContext` representing the provided dictionary.
    public static func of(keyValues: [AnyHashable: AnyObject]) -> PipelineContext {
        let context = PipelineContext()
        for (key, value) in keyValues {
            context.add(value: value, forKey: key)
        }
        return context
    }

    /// Create an empty `PipelineContext`.
    public init() {
        self.head = PipelineContextNode(key: "", value: Sentinel.end as AnyObject)
    }

    // MARK: Public Methods

    /// Adds a value to the `PipelineContext`.
    /// - Parameters:
    ///   - value: Object to be added, as `AnyObject`.
    ///   - key: String key with which to store the object.
    public func add(value: AnyObject, forKey key: AnyHashable) {
        head = head.add(value: value, forKey: key)
    }

    /// Adds a value to the `PipelineContext`.
    /// - Parameters:
    ///   - value: Object to be added, as `AnyObject`.
    ///   - key: `ContextKey` with which to store the object.
    public func add(value: AnyObject, forKey key: ContextKey) {
        add(value: value, forKey: key.rawValue)
    }

    /// Retrieves a keyed value from the `PipelineContext`.
    /// - Parameter key: Raw string key to retrieve.
    /// - Returns: Value for the given property key, if found, as `AnyObject`.
    public func value(forKey key: AnyHashable) -> AnyObject? {
        return head.value(forKey: key)
    }

    /// Retrieves a keyed value from the `PipelineContext`.
    /// - Parameter key: `ContextKey` to retrieve.
    /// - Returns: Value for the given property key, if found, as `AnyObject`.
    public func value(forKey key: ContextKey) -> AnyObject? {
        return value(forKey: key.rawValue)
    }

    /// Convert the `PipelineContext` linked list into a simple dictionary.
    /// - Returns: `Dictionary` representation of the `PipelineContext`.
    public func toDict() -> [AnyHashable: AnyObject?] {
        var dict = [AnyHashable: AnyObject]()
        for node in self {
            // do not overwrite a value once added
            guard dict[node.key] == nil else { continue }
            dict[node.key] = node.value
        }
        return dict
    }

    /// Add a `CancellationToken` while applying smart defaulting logic. If the client transport options
    /// specify a timeout, this will be used to automatically create `CancellationToken`s for each call,
    /// even when a token is not specified. If the client call options contain a `CancellationToken` with
    /// no timeout the default timeout will be applied, if specified in `ClientOptions`.
    /// - Parameters:
    ///   - cancellationToken: Optional `CancellationToken` object.
    ///   - clientOptions: `ClientOptions` for the client generating the request.
    public func add(cancellationToken: CancellationToken?, applying clientOptions: ClientOptions) {
        let defaultTimeout = clientOptions.transportOptions.timeout
        if let token = cancellationToken {
            token.timeout = token.timeout ?? defaultTimeout
            add(value: token as AnyObject, forKey: .cancellationToken)
        } else if let timeout = defaultTimeout {
            add(
                value: CancellationToken(timeout: timeout) as AnyObject,
                forKey: .cancellationToken
            )
        }
    }

    public func merge(with newContext: PipelineContext?) {
        guard let context = newContext else { return }
        for node in context {
            add(value: node.value as AnyObject, forKey: node.key)
        }
    }

    // MARK: Sequence, IteratorProtocol

    public typealias Iterator = PipelineContextIterator

    public __consuming func makeIterator() -> PipelineContextIterator {
        return PipelineContextIterator(head)
    }

    public class PipelineContextIterator: IteratorProtocol {
        public typealias Element = PipelineContextNode

        var current: PipelineContextNode

        init(_ node: PipelineContextNode) {
            self.current = node
        }

        public func next() -> PipelineContextNode? {
            // Do not return the sentinel
            guard current.value as? Sentinel == nil else { return nil }
            guard let parent = current.parent else { return nil }
            defer { current = parent }
            return current
        }
    }
}

extension PipelineContext: Equatable {
    public static func == (lhs: PipelineContext, rhs: PipelineContext) -> Bool {
        // FIXME: This is likely too restrictive for Equatable
        return lhs === rhs
    }
}

public class PipelineContextNode {
    // MARK: Properties

    let parent: PipelineContextNode?
    let key: AnyHashable
    let value: AnyObject?

    // MARK: Initializers

    convenience init(key: AnyHashable, value: AnyObject?) {
        self.init(parent: nil, key: key, value: value)
    }

    init(parent: PipelineContextNode?, key: AnyHashable, value: AnyObject?) {
        self.parent = parent
        self.key = key
        self.value = value
    }

    // MARK: Internal Methods

    func add(value: AnyObject, forKey key: AnyHashable) -> PipelineContextNode {
        return PipelineContextNode(parent: self, key: key, value: value)
    }

    func value(forKey key: AnyHashable) -> AnyObject? {
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
