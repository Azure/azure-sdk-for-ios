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
        encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
        let encoded = try! encoder.encode(patch)
        return String(data: encoded, encoding: .utf8)
    }

    func test_JSONPatch_NullValues() {
        let patch1 = testMethod(value: "test_value")
        let patch2 = testMethod(value: nil)
        let patch3 = testMethod()
        // test janky way of setting null
        let patch4 = testMethod(value: "null")
        print(patch1!)
        print(patch2!)
        print(patch3!)
        print(patch4!)
        XCTAssertNotNil(patch1)
        XCTAssertNotNil(patch2)
        XCTAssertNotNil(patch3)
        XCTAssertNotNil(patch4)
        XCTFail("Test implementation not complete.")
    }
}
