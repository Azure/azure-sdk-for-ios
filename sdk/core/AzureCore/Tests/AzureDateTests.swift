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
        let unixTime: UnixTime
        let simpleDate: SimpleDate
        let rfc1123Date: Rfc1123Date
        let iso8601Date: Iso8601Date

        init(_ date: Date) {
            self.unixTime = UnixTime(date)!
            self.simpleDate = SimpleDate(date)!
            self.rfc1123Date = Rfc1123Date(date)!
            self.iso8601Date = Iso8601Date(date)!
        }
    }

    func test_AzureDate_canDecode() throws {
        let jsonData = """
            {"myDate":"2016-04-13","simpleDate":"2016-04-13","unixTime":1460505600,
             "rfc1123Date":"Wed, 13 Apr 2016 00:00:00 GMT","iso8601Date":"2016-04-13T00:00:00Z"}
        """.data(using: .utf8)!
        let decoder = JSONDecoder()
        let testObject = try! decoder.decode(TestObjectWithDate.self, from: jsonData)
        // ensure that the format you put in is what you get back out
        XCTAssert(testObject.simpleDate.requestString == "2016-04-13")
        XCTAssert(testObject.unixTime.requestString == "1460505600")
        XCTAssert(testObject.rfc1123Date.requestString == "Wed, 13 Apr 2016 00:00:00 GMT")
        XCTAssert(testObject.iso8601Date.requestString == "2016-04-13T00:00:00.000Z")
    }

    func test_AzureDate_canEncode() throws {
        let date = Iso8601Date(string: "2016-04-13T00:00:00Z")!.value
        let testObject = TestObjectWithDate(date)
        let encoder = JSONEncoder()
        let testObjectData = try! encoder.encode(testObject)

        let decoder = JSONDecoder()
        let testObjectDecoded = try! decoder.decode(TestObjectWithDate.self, from: testObjectData)

        XCTAssert(testObject.iso8601Date.requestString == testObjectDecoded.iso8601Date.requestString)
        XCTAssert(testObject.unixTime.requestString == testObjectDecoded.unixTime.requestString)
        XCTAssert(testObject.rfc1123Date.requestString == testObjectDecoded.rfc1123Date.requestString)
        XCTAssert(testObject.simpleDate.requestString == testObjectDecoded.simpleDate.requestString)
    }
}
