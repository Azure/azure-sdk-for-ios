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

class Iso8601DurationTests: XCTestCase {
    func test_duration_round_trip() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        let strings = [
            "P123DT22H14M12.011S",
            "P5DT1H0M0S"
        ]

        for string in strings {
            let duration = Iso8601Duration(string: string)
            let requestString = duration?.requestString ?? ""
            XCTAssert(
                duration?.requestString ?? "" == string,
                "RequestString Error. Expected: \(string) Actual: \(requestString)"
            )
            do {
                let encoded = try encoder.encode(duration)
                let decoded = try decoder.decode(Iso8601Duration.self, from: encoded)
                let actual = decoded.requestString
                XCTAssert(actual == string, "RT Error. Expected: \(string) Actual: \(actual)")
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
    }
}
