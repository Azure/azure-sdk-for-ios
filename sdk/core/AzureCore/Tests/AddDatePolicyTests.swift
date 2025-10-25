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

class AddDatePolicyTests: XCTestCase {
    /// Test that the add date policy adds a non-empty date header
    func test_AddDatePolicy_AddsHeaderToRequest() {
        let policy = AddDatePolicy()
        let req = PipelineRequest()
        policy.on(request: req) { _, _ in }
        let value = req.httpRequest.headers[.date]
        XCTAssertTrue(value != nil && !value!.isEmpty)
    }

    /// Test that the add date policy adds a header whose value looks like an RFC1123 date
    func test_AddDatePolicy_HeaderValueIsDate() {
        let policy = AddDatePolicy()
        let req = PipelineRequest()
        policy.on(request: req) { _, _ in }
        let value = req.httpRequest.headers[.date]
        XCTAssertNotNil(Rfc1123Date(string: value!))
    }

    /// Test that the add date policy overwrites any existing Date header
    func test_AddDatePolicy_OverwritesExistingDateHeader() {
        let policy = AddDatePolicy()
        let headers = HTTPHeaders([.date: "ABCDEF"])
        let req = PipelineRequest(headers: headers)
        policy.on(request: req) { _, _ in }
        let value = req.httpRequest.headers[.date]
        XCTAssertNotEqual(value, "ABCDEF")
    }
}
