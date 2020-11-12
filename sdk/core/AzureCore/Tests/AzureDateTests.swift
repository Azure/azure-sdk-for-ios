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

// swiftlint:disable force_try
class AzureDateTests: XCTestCase {
    class TestObjectWithDate: Codable {
        let startDate: MyDate

        init(startDate: Date) {
            self.startDate = MyDate(startDate)!
        }

        init?(startDate: MyDate?) {
            guard let date = startDate else { return nil }
            self.startDate = date
        }
    }

    func test_AzureDate_canDecode() throws {
        let jsonData = "{\"startDate\":\"2000-01-02\"}".data(using: .utf8)!
        let decoder = JSONDecoder()
        let testObject = try! decoder.decode(TestObjectWithDate.self, from: jsonData)
        XCTAssert(testObject.startDate.requestString == "2000-01-02")
    }

    func test_AzureDate_canEncode() throws {
        let date = MyDate(string: "2000-01-02")!
        let testObject = TestObjectWithDate(startDate: date.value)
        let encoder = JSONEncoder()
        let testObjectData = try! encoder.encode(testObject)
        let testObjectEncoded = String(data: testObjectData, encoding: .utf8)
        XCTAssert(testObjectEncoded == "{\"startDate\":\"2000-01-02\"}")
    }
}
