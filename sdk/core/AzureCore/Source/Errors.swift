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

public enum AuthenticationError: BaseError {
    case interactiveRequired

    var message: String {
        switch self {
        case .interactiveRequired:
            return "Interactive authentication required"
        }
    }
}

public enum AzureError: BaseError {
    case general(_ message: String)
    case fileSystem(_ message: String)
    case serviceRequest(_ message: String)
    case serviceResponse(_ message: String)

    var message: String {
        switch self {
        case let .general(msg),
             let .serviceRequest(msg),
             let .fileSystem(msg),
             let .serviceResponse(msg):
            return msg
        }
    }
}

public enum HTTPResponseError: BaseError {
    case general(_ message: String)
    case decode(_ message: String)
    case resourceExists(_ message: String)
    case resourceNotFound(_ message: String)
    case clientAuthentication(_ message: String)
    case resourceModified(_ message: String)
    case tooManyRedirects(_ message: String)
    case statusCode(_ message: String)

    public var message: String {
        switch self {
        case let .general(msg),
             let .decode(msg),
             let .resourceExists(msg),
             let .resourceNotFound(msg),
             let .clientAuthentication(msg),
             let .resourceModified(msg),
             let .tooManyRedirects(msg),
             let .statusCode(msg):
            return msg
        }
    }
}
