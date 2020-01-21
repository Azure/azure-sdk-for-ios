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

import XCTest
@testable import AzureCore

class HttpRequestTests: XCTestCase {

    func test_HttpRequest_WithQueryString_UpdatesQueryString() {
        let headers = HTTPHeaders()
        let httpRequest = HTTPRequest(
            method: .post, url: "https://www.test.com?a=1&b=2", queryParams: [:], headers: headers)
        var query = httpRequest.query
        XCTAssertEqual(query?.count, 2, "Failure converting query string from URL into query items.")

        let queryParams = ["a": "0", "c": "3"]
        httpRequest.update(queryParams: queryParams)
        query = httpRequest.query
        XCTAssertEqual(query?.count, 3, "Failure merging query string with updates.")
        let queryItems = query?.reduce(into: [String: String]()) {
            $0[$1.name] = $1.value
        }
        XCTAssertEqual(queryItems?["a"], "0", "Failed to update query string value.")
        XCTAssertEqual(queryItems?["b"], "2", "Update unexpectedly changed query string value.")
        XCTAssertEqual(queryItems?["c"], "3", "Update failed to add new value.")
    }

    func test_HttpHeaders_WithEnumOrStringKey_CanBeModified() {
        // ensure headers can be added by string or enum key
        var headers = HTTPHeaders()
        headers[.accept] = "json"
        let httpRequest = HTTPRequest(
            method: .post, url: "https://www.test.com?a=1&b=2", queryParams: [:], headers: headers)
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
        result = httpRequest.headers.removeValue(forKey: .authorization)
        XCTAssertEqual(httpRequest.headers.count, 0, "Failed to remove header by enum key.")
        XCTAssertEqual(result, "token")

        // receive nil if header not found
        result = httpRequest.headers.removeValue(forKey: "Test")
        XCTAssertNil(result)
        result = httpRequest.headers.removeValue(forKey: .acceptCharset)
        XCTAssertNil(result)
    }
}
