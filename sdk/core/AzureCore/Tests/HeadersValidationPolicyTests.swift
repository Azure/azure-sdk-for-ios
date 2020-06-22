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

@testable import AzureCore
import XCTest

class HeadersValidationPolicyTests: XCTestCase {
    /// Test that the headers validation policy passes when headers match.
    func test_HeadersValidationPolicy_PassesWhenHeadersMatch() {
        let validateHeaders = [HTTPHeader.requestId.rawValue]
        let policy = HeadersValidationPolicy(validatingHeaders: validateHeaders)
        let req = PipelineRequest()
        let res = PipelineResponse(request: req)
        req.httpRequest.headers[.requestId] = "test"
        res.httpResponse?.headers[.requestId] = "test"
        // success
        policy.on(response: res) { _, error in
            XCTAssertNil(error)
        }
    }

    /// Test that the headers validation policy passes when headers match.
    func test_HeadersValidationPolicy_FailsWhenHeadersDontMatch() {
        let validateHeaders = [HTTPHeader.requestId.rawValue]
        let policy = HeadersValidationPolicy(validatingHeaders: validateHeaders)
        let req = PipelineRequest()
        let res = PipelineResponse(request: req)
        req.httpRequest.headers[.requestId] = "test"
        res.httpResponse?.headers[.requestId] = "fail"
        policy.on(response: res) { _, error in
            XCTAssertNotNil(error)
        }
    }
}
