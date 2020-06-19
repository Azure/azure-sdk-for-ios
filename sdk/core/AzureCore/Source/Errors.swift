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

public protocol AzureError: LocalizedError {
    var message: String { get }
}

public protocol ServiceError { }

extension AzureError {
    public var errorDescription: String? {
        return "\(message) (\(String(reflecting: type(of: self))))"
    }
}

public struct AzureSdkError: AzureError {
    public var message: String
    public var innerError: Error?

    public init(_ message: String, innerError: Error? = nil) {
        self.message = message
        self.innerError = innerError
    }

    public init(innerError: Error) {
        self.message = innerError.localizedDescription
        self.innerError = innerError
    }
}

public struct AzureServiceError<T: ServiceError>: AzureError {
    public var message: String
    public var serviceError: T

    public init(_ message: String, _ serviceError: T) {
        self.message = message
        self.serviceError = serviceError
    }

    public init(_ serviceError: T) {
        self.message = "A service error occurred."
        self.serviceError = serviceError
    }
}
