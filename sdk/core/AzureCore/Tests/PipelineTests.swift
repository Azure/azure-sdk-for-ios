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
class PipelineTests: XCTestCase {
    func createPipelineClient() -> PipelineClient {
        let baseUrl = URL(string: "http://www.microsoft.com")!
        let client = PipelineClient(
            baseUrl: baseUrl,
            transport: URLSessionTransport(),
            policies: [
                UserAgentPolicy(sdkName: "Test", sdkVersion: "1.0"),
                LoggingPolicy()
            ],
            logger: ClientLoggers.default(),
            options: TestClientOptions()
        )
        return client
    }

    func test_HTTPRequest_Inits() {
        let headers: HTTPHeaders = ["headerParam": "myHeaderParam"]
        let request = try! HTTPRequest(method: .get, url: "www.test.com", headers: headers)
        request.url = request.url.appendingQueryParameters([("a", "1"), ("b", "2")])!
        XCTAssertEqual(request.url.absoluteString, "www.test.com?a=1&b=2")
        XCTAssertEqual(request.httpMethod, .get)
        XCTAssertEqual(request.headers, headers)
    }

    func test_PipelineClient_CanFormatUrl() {
        let client = createPipelineClient()
        let url = client.url(forTemplate: "{a}/{b}/test", withKwargs: [
            "a": "cat",
            "b": "hat"
        ])
        XCTAssertEqual(url?.absoluteString, "\(client.endpoint)cat/hat/test")
    }

    func test_PipelineClient_CanRun() {
        let client = createPipelineClient()
        let request = try! HTTPRequest(method: .get, url: "http://www.microsoft.com", headers: [:])
        let didFinishRun = expectation(description: "run completion handler called.")
        let context = options?.context ?? PipelineContext.of(keyValues: [
            "context": "value" as AnyObject
        ])
        var requestCompleted = false
        client.request(request, context: context) { result, httpResponse in
            didFinishRun.fulfill()
            switch result {
            case let .failure(error):
                XCTFail("Network call failed. \(error) - \(String(describing: httpResponse))")
            default:
                break
            }
            requestCompleted = true
        }
        wait(for: [didFinishRun], timeout: 10.0, enforceOrder: true)
        XCTAssertTrue(requestCompleted) // Ensure the request callback runs before the test finishes
    }
}
