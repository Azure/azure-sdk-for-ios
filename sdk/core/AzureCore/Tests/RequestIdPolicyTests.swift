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

@testable import AzureCore
import XCTest

class RequestIdPolicyTests: XCTestCase {
    /// Test that the request id policy adds a non-empty request ID header
    func test_RequestIdPolicy_AddsHeaderToRequest() {
        let policy = RequestIdPolicy()
        let req = PipelineRequest()
        policy.on(request: req) { _, _ in }
        let value = req.httpRequest.headers[.clientRequestId]
        XCTAssertTrue(value != nil && !value!.isEmpty)
    }

    /// Test that the request id policy adds a header whose value looks like a uuid
    func test_RequestIdPolicy_HeaderValueIsUUID() {
        let policy = RequestIdPolicy()
        let req = PipelineRequest()
        policy.on(request: req) { _, _ in }
        let value = req.httpRequest.headers[.clientRequestId]
        XCTAssertNotNil(UUID(uuidString: value!))
    }
}
