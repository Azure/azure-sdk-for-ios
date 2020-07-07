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
    case sdk(String)
    case service(String)
    case wrapped(Error, PipelineResponse)

    var message: String {
        switch self {
        case let .sdk(msg),
             let .service(msg):
            return msg
        case let .wrapped(error, _):
            return error.localizedDescription
        }
    }
}

extension Error {
    public var toAzureError: AzureError {
        if self is AzureError {
            // swiftlint:disable force_cast
            return self as! AzureError
        }
        return AzureError.sdk(localizedDescription)
    }
}
