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

class PipelineTests: XCTestCase {
    func createPipelineClient() -> PipelineClient {
        let baseUrl = "http://www.microsoft.com"
        let client = PipelineClient(
            baseUrl: baseUrl,
            transport: URLSessionTransport(),
            policies: [
                UserAgentPolicy(sdkName: "Test", sdkVersion: "1.0"),
                LoggingPolicy()
            ],
            logger: ClientLoggers.default()
        )
        return client
    }

    func test_HTTPRequest_Inits() {
        let headers: HTTPHeaders = ["headerParam": "myHeaderParam"]
        let request = HTTPRequest(method: .get, url: "test", headers: headers)
        request.add(queryParams: [("a", "1"), ("b", "2")])
        XCTAssertEqual(request.url, "test?a=1&b=2")
        XCTAssertEqual(request.httpMethod, .get)
        XCTAssertEqual(request.headers, headers)
    }

    func test_PipelineClient_CanFormatUrl() {
        let client = createPipelineClient()
        let url = client.url(forTemplate: "{a}/{b}/test", withKwargs: [
            "a": "cat",
            "b": "hat"
        ])
        XCTAssertEqual(url, "\(client.baseUrl)cat/hat/test")
    }

    func test_PipelineClient_CanRun() {
        let client = createPipelineClient()
        let request = HTTPRequest(method: .get, url: "test", headers: [:])
        let didFinishRun = expectation(description: "run completion handler called.")
        let context = PipelineContext.of(keyValues: [
            "context": "value" as AnyObject
        ])
        client.request(request, context: context) { result, httpResponse in
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

    func test_PipelineClient_CanLogError() {
        XCTFail("TODO: Implement test.")
    }
}
