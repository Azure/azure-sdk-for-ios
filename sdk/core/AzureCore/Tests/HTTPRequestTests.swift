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
class HttpRequestTests: XCTestCase {
    func test_HttpRequest_WithQueryString_AppendsToQueryString() {
        let httpRequest = try! HTTPRequest(method: .post, url: "https://www.test.com?a=1&b=2")
        var query = URLComponents(url: httpRequest.url, resolvingAgainstBaseURL: true)!.queryItems!
        XCTAssertEqual(query.count, 2, "Failure converting query string from URL into query items.")

        httpRequest.url = httpRequest.url.appendingQueryParameters(RequestParameters(
            (.query, "a", "0", .encode),
            (.query, "c", "3", .encode)
        ))!
        query = URLComponents(url: httpRequest.url, resolvingAgainstBaseURL: true)!.queryItems!
        XCTAssertEqual(query.count, 4, "Failure adding new query string parameters.")
        let queryItems = query.reduce(into: [String: [String?]]()) { acc, item in
            if acc[item.name] == nil { acc[item.name] = [] }
            acc[item.name]!.append(item.value)
        }
        XCTAssert(queryItems["a"]!.contains("0"), "Failed to add duplicate query string value.")
        XCTAssert(queryItems["a"]!.contains("1"), "Failed to retain original query string value.")
        XCTAssert(queryItems["b"]!.contains("2"), "Add unexpectedly changed unrelated query string value.")
        XCTAssert(queryItems["c"]!.contains("3"), "Failed to add new query string value.")
    }

    func test_HttpHeaders_WithEnumOrStringKey_CanBeModified() {
        // ensure headers can be added by string or enum key
        let headers = HTTPHeaders([HTTPHeader.accept: "json"])
        let httpRequest = try! HTTPRequest(method: .post, url: "https://www.test.com?a=1&b=2", headers: headers)
        XCTAssertEqual(httpRequest.headers.count, 1, "Failed to accept headers.")
        httpRequest.headers["Authorization"] = "token"
        XCTAssertEqual(httpRequest.headers.count, 2, "Failed to add new header.")

        // headers can be subscripted by string or enum
        XCTAssertEqual(httpRequest.headers[.authorization], "token")
        XCTAssertEqual(httpRequest.headers["Accept"], "json")

        // remove a header using its string key
        var result = httpRequest.headers.removeValue(forKey: "Accept")
        XCTAssertEqual(httpRequest.headers.count, 1, "Failed to remove header by string key.")
        XCTAssertEqual(result, "json")

        // remove a header using its enum key
        result = httpRequest.headers.removeValue(forKey: HTTPHeader.authorization)
        XCTAssertEqual(httpRequest.headers.count, 0, "Failed to remove header by enum key.")
        XCTAssertEqual(result, "token")

        // receive nil if header not found
        result = httpRequest.headers.removeValue(forKey: "Test")
        XCTAssertNil(result)
        result = httpRequest.headers.removeValue(forKey: HTTPHeader.acceptCharset)
        XCTAssertNil(result)
    }
}
