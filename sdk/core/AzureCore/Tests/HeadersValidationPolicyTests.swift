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
        let validateHeaders = [HTTPHeader.requestId.requestString]
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

    /// Test that the headers validation policy fails when headers don't match.
    func test_HeadersValidationPolicy_FailsWhenHeadersDontMatch() {
        let validateHeaders = [HTTPHeader.requestId.requestString]
        let policy = HeadersValidationPolicy(validatingHeaders: validateHeaders)
        let req = PipelineRequest()
        let res = PipelineResponse(request: req)

        // set up context where request ID is allowed
        let context = PipelineContext()
        let allowHeaders: Set = [HTTPHeader.requestId.requestString.lowercased()]
        context.add(value: allowHeaders as AnyObject, forKey: .allowedHeaders)
        req.context = context
        res.context = context

        req.httpRequest.headers[.requestId] = "test"
        res.httpResponse?.headers[.requestId] = "fail"
        policy.on(response: res) { _, error in
            XCTAssertNotNil(error)
            XCTAssertTrue(error!.localizedDescription.contains("Expected: test Actual: fail"))
        }
    }

    /// Test that the headers validation policy redacts unallowed values when failing.
    func test_HeadersValidationPolicy_RedactsUnallowedHeadersOnFail() {
        let validateHeaders = [HTTPHeader.requestId.requestString]
        let policy = HeadersValidationPolicy(validatingHeaders: validateHeaders)
        let req = PipelineRequest()
        let res = PipelineResponse(request: req)

        // set up context where request ID is not allowed
        let context = PipelineContext()
        let allowHeaders: Set = [HTTPHeader.contentType.requestString.lowercased()]
        context.add(value: allowHeaders as AnyObject, forKey: .allowedHeaders)
        req.context = context
        res.context = context

        req.httpRequest.headers[.requestId] = "test"
        res.httpResponse?.headers[.requestId] = "fail"
        policy.on(response: res) { _, error in
            XCTAssertNotNil(error)
            XCTAssertTrue(error!.localizedDescription.contains("Expected: REDACTED Actual: REDACTED"))
        }
    }

    /// Test that the headers validation policy redacts all values when no allowHeaders are provided in the context.
    func test_HeadersValidationPolicy_RedactsAllHeadersOnFailWhenNoAllowHeadersProvided() {
        let validateHeaders = [HTTPHeader.requestId.requestString]
        let policy = HeadersValidationPolicy(validatingHeaders: validateHeaders)
        let req = PipelineRequest()
        let res = PipelineResponse(request: req)

        req.httpRequest.headers[.requestId] = "test"
        res.httpResponse?.headers[.requestId] = "fail"
        policy.on(response: res) { _, error in
            XCTAssertNotNil(error)
            XCTAssertTrue(error!.localizedDescription.contains("Expected: REDACTED Actual: REDACTED"))
        }
    }

    /// Test that the headers validation policy passes when response does not include header.
    func test_HeadersValidationPolicy_PassesWhenResponseDoesntContainHeader() {
        let validateHeaders = [HTTPHeader.requestId.requestString]
        let policy = HeadersValidationPolicy(validatingHeaders: validateHeaders)
        let req = PipelineRequest()
        let res = PipelineResponse(request: req)

        req.httpRequest.headers[.requestId] = "test"
        policy.on(response: res) { _, error in
            XCTAssertNil(error)
        }
    }

    /// Test that the headers validation policy fails when response includes header but request doesn't.
    func test_HeadersValidationPolicy_FailsWhenResponseContainsHeaderAndRequestDoesnt() {
        let validateHeaders = [HTTPHeader.requestId.requestString]
        let policy = HeadersValidationPolicy(validatingHeaders: validateHeaders)
        let req = PipelineRequest()
        let res = PipelineResponse(request: req)

        // set up context where request ID is allowed
        let context = PipelineContext()
        let allowHeaders: Set = [HTTPHeader.requestId.requestString.lowercased()]
        context.add(value: allowHeaders as AnyObject, forKey: .allowedHeaders)
        req.context = context
        res.context = context

        res.httpResponse?.headers[.requestId] = "test"
        policy.on(response: res) { _, error in
            XCTAssertNotNil(error)
            XCTAssertTrue(error!.localizedDescription.contains("Expected: nil Actual: test"))
        }
    }
}
