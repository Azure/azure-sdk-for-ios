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

// swiftlint:disable force_try
class JSONPatchTests: XCTestCase {
    /// Represents a simple method with a simple, optional type.
    func testMethod(value: String? = nil) -> String? {
        let patch = JSONPatchObject()
        if let val = value {
            patch.replace(atPath: "value/", withValue: val)
        }
        let encoder = JSONEncoder()
        let encoded = try! encoder.encode(patch)
        return String(data: encoded, encoding: .utf8)
    }

    func test_JSONPatch_RegularValue() {
        let patch = testMethod(value: "test_value")
        let expected =
            "{\"operations\":[{\"path\":\"value\\/\",\"operation\":\"replace\",\"value\":\"\\\"test_value\\\"\",\"from\":null}]}"
        XCTAssertEqual(patch!, expected)
    }

    func test_JSONPatch_ExplicitNilsIgnored() {
        let patch = testMethod(value: nil)
        let expected = "{\"operations\":[]}"
        XCTAssertEqual(patch!, expected)
    }

    func test_JSONPatch_DefaultNilsIgnored() {
        let patch = testMethod()
        let expected = "{\"operations\":[]}"
        XCTAssertEqual(patch!, expected)
    }

    func test_JSONPatch_SentinelValueNullifies() {
        let patch = testMethod(value: JSONPatch.null)
        let expected =
            "{\"operations\":[{\"path\":\"value\\/\",\"operation\":\"replace\",\"value\":null,\"from\":null}]}"
        XCTAssertEqual(patch!, expected)
    }

    func test_JSONPatch_EscapedSentinelValueWorks() {
        let patch = testMethod(value: "__NULL__")
        let expected =
            "{\"operations\":[{\"path\":\"value\\/\",\"operation\":\"replace\",\"value\":\"\\\"__NULL__\\\"\",\"from\":null}]}"
        XCTAssertEqual(patch!, expected)
    }
}
