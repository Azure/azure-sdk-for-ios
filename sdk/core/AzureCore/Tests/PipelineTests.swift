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

class PipelineTests: XCTestCase {

    func createPipelineClient() -> PipelineClient {
        let baseUrl = "http://www.microsoft.com"
        let client = PipelineClient(
            baseUrl: baseUrl,
            transport: UrlSessionTransport(),
            policies: [
                UserAgentPolicy(),
                LoggingPolicy()
            ],
            logger: ClientLoggers.default(tag: "test")
        )
        return client
    }

    func testPipelineClientRequest() {
        let client = createPipelineClient()
        let headers: HttpHeaders = [
            "headerParam": "myHeaderParam"
        ]
        let request = client.request(method: .get, url: "test",
                                     queryParams: ["a": "1", "b": "2"], headerParams: headers)
        XCTAssertTrue(["test?a=1&b=2", "test?b=2&a=1"].contains(request.url))
        XCTAssertEqual(request.httpMethod, .get)
        XCTAssertEqual(request.headers, headers)
    }

    func testPipelineClientFormat() {
        let client = createPipelineClient()
        let url = client.format(urlTemplate: "{a}/{b}/test", withKwargs: [
            "a": "cat",
            "b": "hat"
        ])
        XCTAssertEqual(url, "\(client.baseUrl)cat/hat/test")
    }

    func testPipelineClientRun() {
        let client = createPipelineClient()
        let request = client.request(method: .get, url: "", queryParams: [:], headerParams: [:])
        let didFinishRun = expectation(description: "run completion handler called.")
        client.run(request: request, context: ["context": "value" as AnyObject]) { result, httpResponse in
            didFinishRun.fulfill()
            switch result {
            case let .failure(error):
                XCTFail("Network call failed. \(error) - \(httpResponse)")
            default:
                break
            }
        }
        wait(for: [didFinishRun], timeout: 2.0, enforceOrder: true)
    }

    func testPipelineClientLogError() {
        XCTFail("TODO: Implement test.")
    }
}
