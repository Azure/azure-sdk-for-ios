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

protocol BaseError: LocalizedError {
    var message: String { get }
    var label: String { get }
}

extension BaseError {
    var label: String {
        let mirror = Mirror(reflecting: self)
        let label = mirror.children.first?.label ?? String(describing: self)
        return "\(String(reflecting: type(of: self))).\(label)"
    }

    public var errorDescription: String? {
        return "\(message) (\(label))"
    }
}

public enum AzureError: BaseError {
    case client(String, Error? = nil)
    case service(String, Error? = nil)

    private func message(_ msg: String, withInnerError innerError: Error?) -> String {
        var message = msg
        if let wrapped = innerError {
            message = "\(message): (\(wrapped.localizedDescription))"
        }
        return message
    }

    public var message: String {
        switch self {
        case let .client(msg, innerError):
            return message(msg, withInnerError: innerError)
        case let .service(msg, innerError):
            return message(msg, withInnerError: innerError)
        }
    }

    public var innerError: Error? {
        switch self {
        case let .client(_, innerError):
            return innerError
        case let .service(_, innerError):
            return innerError
        }
    }
}

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}

extension Int: LocalizedError {
    public var errorDescription: String? { return String(self) }
}

extension Int32: LocalizedError {
    public var errorDescription: String? { return String(self) }
}

extension Int64: LocalizedError {
    public var errorDescription: String? { return String(self) }
}
