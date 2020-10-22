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

public protocol RequestStringConvertible {
    var requestString: String { get }
}

extension RequestStringConvertible {
    public static func == (lhs: RequestStringConvertible, rhs: RequestStringConvertible) -> Bool {
        return lhs.requestString == rhs.requestString
    }
}

public typealias HeaderParameters = RequestParameters
public typealias PathParameters = RequestParameters
public typealias QueryParameters = RequestParameters
public typealias RequestParameter = (key: RequestStringConvertible, value: String)

public struct RequestParameters: Sequence, IteratorProtocol, Equatable {
    internal var parameters = [RequestParameter]()

    internal var iterator: Array<RequestParameter>.Iterator?

    public var count: Int {
        return parameters.count
    }

    public var keys: [RequestStringConvertible] {
        return parameters.map { $0.key }
    }

    // MARK: Initializers

    public init(_ params: (key: RequestStringConvertible, value: RequestStringConvertible?)...) {
        for param in params {
            add(value: param.value, forKey: param.key)
        }
    }

    // MARK: Subscripting

    public subscript(index: RequestStringConvertible) -> String? {
        get {
            let first = parameters.first { $0.key.requestString == index.requestString }
            return first?.value
        }

        set {
            if let firstIndex = parameters.firstIndex(where: { $0.key.requestString == index.requestString }) {
                if let value = newValue {
                    // update the value
                    parameters[firstIndex].value = value
                } else {
                    // remove the value
                    parameters.remove(at: firstIndex)
                }
            } else {
                // add the value
                guard let value = newValue else { return }
                parameters.append((key: index.requestString, value: value))
            }
        }
    }

    public subscript(index: HTTPHeader) -> String? {
        get {
            self[index.requestString]
        }

        set {
            self[index.requestString] = newValue
        }
    }

    // MARK: Methods

    public mutating func add(value: RequestStringConvertible?, forKey key: RequestStringConvertible) {
        // skip values that evaluate to nil
        guard let val = value else { return }
        parameters.append((key: key, value: val.requestString))
    }

    @discardableResult
    public mutating func removeValue(forKey key: RequestStringConvertible) -> String? {
        var removedValue: String?
        if let firstIndex = parameters.firstIndex(where: { $0.key.requestString == key.requestString }) {
            removedValue = parameters[firstIndex].value
            parameters.remove(at: firstIndex)
        }
        return removedValue
    }

    /// Returns an unordered `Dictionary` version of the parameter collection.
    public func toDict() -> [String: String] {
        let dict: [String: String] = parameters.reduce(into: [:]) { result, next in
            result[next.key.requestString] = next.value.requestString
        }
        return dict
    }

    // MARK: IteratorProtocol

    public mutating func next() -> RequestParameter? {
        if iterator == nil {
            iterator = parameters.makeIterator()
        }
        return iterator?.next()
    }

    // MARK: Equatable

    public static func == (lhs: RequestParameters, rhs: RequestParameters) -> Bool {
        return lhs.toDict() == rhs.toDict()
    }
}

extension Int: RequestStringConvertible {
    public var requestString: String {
        return String(self)
    }
}

extension String: RequestStringConvertible {
    public var requestString: String {
        return self
    }
}

extension Bool: RequestStringConvertible {
    public var requestString: String {
        return String(self)
    }
}

extension Data: RequestStringConvertible {
    public var requestString: String {
        guard let dataString = String(bytes: self, encoding: .utf8) else {
            assertionFailure("Unable to encode bytes")
            return ""
        }
        return dataString
    }
}

extension Array: RequestStringConvertible {
    public var requestString: String {
        var strings = [String]()
        for value in self {
            if let val = value as? RequestStringConvertible {
                strings.append(val.requestString)
            } else {
                strings.append("")
            }
        }
        return strings.joined(separator: ",")
    }
}
