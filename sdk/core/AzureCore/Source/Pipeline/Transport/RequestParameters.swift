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

public typealias RequestParameter = (
    location: RequestParameterLocation,
    key: String,
    value: String,
    encodingStrategy: EncodingStrategy
)

/// Identifies where the parameter goes in the request
public enum RequestParameterLocation {
    case host
    case path
    case query
    case header
    case body
    case uri
}

public enum EncodingStrategy {
    case encode
    case skipEncoding
}

public struct RequestParameters: Sequence, IteratorProtocol {
    var parameters = [RequestParameter]()

    var iterator: Array<RequestParameter>.Iterator?

    public var count: Int {
        return parameters.count
    }

    public var keys: [RequestStringConvertible] {
        return parameters.map { $0.key }
    }

    public var headers: HTTPHeaders {
        return dict(for: .header)
    }

    // MARK: Initializers

    public init(_ params: (
        location: RequestParameterLocation,
        key: RequestStringConvertible,
        value: RequestStringConvertible?,
        encodingStrategy: EncodingStrategy
    )...) {
        for param in params {
            // Skip values that evaluate to nil
            guard let value = param.value else { continue }
            parameters.append((
                location: param.location,
                key: param.key.requestString,
                value: value.requestString,
                encodingStrategy: param.encodingStrategy
            ))
        }
    }

    // MARK: Methods

    public mutating func add(_ params: (
        location: RequestParameterLocation,
        key: RequestStringConvertible,
        value: RequestStringConvertible?,
        encodingStrategy: EncodingStrategy
    )...) {
        for param in params {
            // Skip values that evaluate to nil
            guard let value = param.value else { continue }
            parameters.append((
                location: param.location,
                key: param.key.requestString,
                value: value.requestString,
                encodingStrategy: param.encodingStrategy
            ))
        }
    }

    /// Lookup a value in the `RequestParameters` collection.
    /// - Parameters:
    ///   - key: The key to search for.
    ///   - location: The type of parameters to search. If nil, all parameters are searched.
    /// - Returns: String value, if found, or nil.
    public func value(for key: String, in location: RequestParameterLocation? = nil) -> String? {
        var collection: [RequestParameter]
        if let loc = location {
            collection = values(for: loc)
        } else {
            collection = parameters
        }
        return collection.first(where: { $0.key == key })?.value
    }

    /// Returns the subset of parameters for a certain location.
    /// - Parameter location: The parameter location to filter by.
    /// - Returns: A subset of `RequestParameter`s for the specified location.
    public func values(for location: RequestParameterLocation) -> [RequestParameter] {
        return parameters.filter { $0.location == location }
    }

    /// Returns the unordered dictionary representation of parameters for a given location.
    /// - Parameter location: The parameter location to filter by.
    /// - Returns: A `Dictionary` representation of the subset of `RequestParameter`s for a the specified location.
    public func dict(for location: RequestParameterLocation) -> [String: String] {
        let dict: [String: String] = values(for: location).reduce(into: [:]) { result, next in
            result[next.key] = next.value
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
}
