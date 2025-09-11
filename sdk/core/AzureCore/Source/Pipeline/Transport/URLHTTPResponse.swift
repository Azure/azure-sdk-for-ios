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
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public class URLHTTPResponse: HTTPResponse {
    // MARK: Properties

    private var internalResponse: HTTPURLResponse?

    // MARK: Initializers

    public init(request: HTTPRequest, response: HTTPURLResponse?) {
        self.internalResponse = response
        let statusCode = response?.statusCode
        super.init(request: request, statusCode: statusCode)
        guard let internalHeaders = response?.allHeaderFields else { return }
        for (key, value) in internalHeaders {
            guard let keyVal = key as? String else { continue }
            guard let val = value as? String else { continue }
            headers[keyVal] = val
        }
    }
}
