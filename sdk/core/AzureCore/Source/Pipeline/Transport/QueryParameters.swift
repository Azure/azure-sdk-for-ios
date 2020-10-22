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

public protocol UrlStringConvertible {
    var queryValue: String { get }
}

public typealias QueryParameter = (key: String, value: String)

public struct UrlParameters {
    internal var parameters = [QueryParameter]()

    public init(_ params: (key: String, value: Any?)...) {
        // swiftlint:disable force_cast
        let nonNilParams = params.filter { $0.value as? QueryStringConvertible != nil }
            .map { (key: $0.key, value: ($0.value as! QueryStringConvertible).queryValue) }
        self.parameters = nonNilParams
    }

    public mutating func add(key: String, value: UrlStringConvertible?) {
        // skip values that evaluate to nil
        guard let val = value else { return }
        parameters.append((key: key, value: val.queryValue))
    }

    /// Returns an unordered `Dictionary` version of the parameter collection.
    public func toDict() -> [String: String] {
        let dict: [String: String] = parameters.reduce(into: [:]) { result, next in
            result[next.key] = next.value
        }
        return dict
    }
}

extension Int: UrlStringConvertible {
    public var queryValue: String {
        return String(self)
    }
}

extension String: UrlStringConvertible {
    public var queryValue: String {
        return self
    }
}

extension Bool: UrlStringConvertible {
    public var queryValue: String {
        return String(self)
    }
}

extension Data: UrlStringConvertible {
    public var queryValue: String {
        guard let dataString = String(bytes: self, encoding: .utf8) else {
            assertionFailure("Unable to encode bytes")
            return ""
        }
        return dataString
    }
}

extension Array: UrlStringConvertible {
    public var queryValue: String {
        var strings = [String]()
        for value in self {
            if let val = value as? UrlStringConvertible {
                strings.append(val.queryValue)
            } else {
                strings.append("")
            }
        }
        return strings.joined(separator: ",")
    }
}
