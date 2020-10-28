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

class CustomPolicy: PipelineStage {
    var next: PipelineStage?

    func on(request: PipelineRequest, completionHandler: @escaping OnRequestCompletionHandler) {
        let count = request.context?.value(forKey: "CustomOnRequestCalled") as? Int ?? 0
        request.context?.add(value: (count + 1) as AnyObject, forKey: "CustomOnRequestCalled")
        completionHandler(request, nil)
    }

    func on(response: PipelineResponse, completionHandler: @escaping OnResponseCompletionHandler) {
        let count = response.context?.value(forKey: "CustomOnResponseCalled") as? Int ?? 0
        response.context?.add(value: (count + 1) as AnyObject, forKey: "CustomOnResponseCalled")
        completionHandler(response, nil)
    }
}

class CustomPerRetryPolicy: PipelineStage {
    var next: PipelineStage?

    func on(request: PipelineRequest, completionHandler: @escaping OnRequestCompletionHandler) {
        let count = request.context?.value(forKey: "CustomPerRetryOnRequestCalled") as? Int ?? 0
        request.context?.add(value: (count + 1) as AnyObject, forKey: "CustomPerRetryOnRequestCalled")
        completionHandler(request, nil)
    }

    func on(response: PipelineResponse, completionHandler: @escaping OnResponseCompletionHandler) {
        let count = response.context?.value(forKey: "CustomPerRetryOnResponseCalled") as? Int ?? 0
        response.context?.add(value: (count + 1) as AnyObject, forKey: "CustomPerRetryOnResponseCalled")
        completionHandler(response, nil)
    }
}

// swiftlint:disable force_try
class PipelineTests: XCTestCase {
    func createPipelineClient() -> PipelineClient {
        let baseUrl = URL(string: "http://www.microsoft.com")!
        let client = PipelineClient(
            endpoint: baseUrl,
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
        let context = PipelineContext.of(keyValues: [
            "context": "value" as AnyObject
        ])
        var requestCompleted = false
        client.request(request, context: context) { result, httpResponse in
            switch result {
            case .success:
                didFinishRun.fulfill()
            case let .failure(error):
                XCTFail("Network call failed. \(error) - \(String(describing: httpResponse))")
            }
            requestCompleted = true
        }
        wait(for: [didFinishRun], timeout: 10.0, enforceOrder: true)
        XCTAssertTrue(requestCompleted) // Ensure the request callback runs before the test finishes
    }

    func test_PipelineClient_NoPoliciesRuns() {
        let baseUrl = URL(string: "http://www.microsoft.com")!
        let client = PipelineClient(
            endpoint: baseUrl,
            transport: URLSessionTransport(),
            policies: [],
            logger: ClientLoggers.default(),
            options: TestClientOptions()
        )
        let request = try! HTTPRequest(method: .get, url: "http://www.microsoft.com", headers: [:])
        let didFinishRun = expectation(description: "run completion handler called.")
        let context = PipelineContext()
        var requestCompleted = false
        client.request(request, context: context) { result, httpResponse in
            switch result {
            case .success:
                didFinishRun.fulfill()
            case let .failure(error):
                XCTFail("Network call failed. \(error) - \(String(describing: httpResponse))")
            }
            requestCompleted = true
        }
        wait(for: [didFinishRun], timeout: 10.0, enforceOrder: true)
        XCTAssertTrue(requestCompleted) // Ensure the request callback runs before the test finishes
    }

    func test_PipelineClient_UserPerRequestPolicies() {
        let baseUrl = URL(string: "http://www.microsoft.com")!
        var options = TestClientOptions()
        options.transportOptions = TransportOptions(perRequestPolicies: [CustomPolicy()])
        let client = PipelineClient(
            endpoint: baseUrl,
            transport: URLSessionTransport(),
            policies: [
                UserAgentPolicy(sdkName: "Test", sdkVersion: "1.0"),
                LoggingPolicy()
            ],
            logger: ClientLoggers.default(),
            options: options
        )
        let request = try! HTTPRequest(method: .get, url: "http://www.microsoft.com", headers: [:])
        let didFinishRun = expectation(description: "run completion handler called.")
        let context = PipelineContext()
        var requestCompleted = false
        client.request(request, context: context) { result, httpResponse in
            switch result {
            case .success:
                XCTAssertTrue(context.value(forKey: "CustomOnRequestCalled") != nil)
                XCTAssertTrue(context.value(forKey: "CustomOnResponseCalled") != nil)
                didFinishRun.fulfill()
            case let .failure(error):
                XCTFail("Network call failed. \(error) - \(String(describing: httpResponse))")
            }
            requestCompleted = true
        }
        wait(for: [didFinishRun], timeout: 10.0, enforceOrder: true)
        XCTAssertTrue(requestCompleted) // Ensure the request callback runs before the test finishes
    }

    func test_PipelineClient_WithRetryPolicy() {
        let baseUrl = URL(string: "http://www.microsoft.com")!
        var options = TestClientOptions()
        let client = PipelineClient(
            endpoint: baseUrl,
            transport: URLSessionTransport(),
            policies: [
                UserAgentPolicy(sdkName: "Test", sdkVersion: "1.0"),
                RetryPolicy(),
                LoggingPolicy()
            ],
            logger: ClientLoggers.default(),
            options: TestClientOptions()
        )
        let request = try! HTTPRequest(method: .get, url: "http://www.microsoft.com", headers: [:])
        let didFinishRun = expectation(description: "run completion handler called.")
        let context = PipelineContext()
        var requestCompleted = false
        client.request(request, context: context) { result, httpResponse in
            switch result {
            case .success:
                didFinishRun.fulfill()
            case let .failure(error):
                XCTFail("Network call failed. \(error) - \(String(describing: httpResponse))")
            }
            requestCompleted = true
        }
        wait(for: [didFinishRun], timeout: 10.0, enforceOrder: true)
        XCTAssertTrue(requestCompleted) // Ensure the request callback runs before the test finishes
    }

    func test_PipelineClient_WithUserRetryPolicy() {
        let baseUrl = URL(string: "http://www.microsoft.com")!
        var options = TestClientOptions()
        options.transportOptions = TransportOptions(
            perRequestPolicies: [CustomPolicy()],
            perRetryPolicies: [CustomPerRetryPolicy()]
        )
        let client = PipelineClient(
            endpoint: baseUrl,
            transport: URLSessionTransport(),
            policies: [
                UserAgentPolicy(sdkName: "Test", sdkVersion: "1.0"),
                RetryPolicy(),
                LoggingPolicy()
            ],
            logger: ClientLoggers.default(),
            options: options
        )
        let request = try! HTTPRequest(method: .get, url: "http://www.microsoft.com", headers: [:])
        let didFinishRun = expectation(description: "run completion handler called.")
        let context = PipelineContext()
        XCTAssert(client.pipeline.policies.count == 6, "Incorrect number of policies")
        XCTAssert(client.pipeline.policies[0] is UserAgentPolicy, "Policies in incorrect order")
        XCTAssert(client.pipeline.policies[1] is CustomPolicy, "Policies in incorrect order")
        XCTAssert(client.pipeline.policies[2] is RetryPolicy, "Policies in incorrect order")
        XCTAssert(client.pipeline.policies[3] is LoggingPolicy, "Policies in incorrect order")
        XCTAssert(client.pipeline.policies[4] is CustomPerRetryPolicy, "Policies in incorrect order")
        XCTAssert(client.pipeline.policies[5] is TransportStage, "Policies in incorrect order")
        var requestCompleted = false
        client.request(request, context: context) { result, httpResponse in
            switch result {
            case .success:
                let perRetryRequestCount = context.value(forKey: "CustomPerRetryOnRequestCalled") as? Int
                let perRetryResponseCount = context.value(forKey: "CustomPerRetryOnResponseCalled") as? Int
                XCTAssertTrue(perRetryRequestCount == 1)
                XCTAssertTrue(perRetryResponseCount == 1)
                didFinishRun.fulfill()
            case let .failure(error):
                XCTFail("Network call failed. \(error) - \(String(describing: httpResponse))")
            }
            requestCompleted = true
        }
        wait(for: [didFinishRun], timeout: 10.0, enforceOrder: true)
        XCTAssertTrue(requestCompleted) // Ensure the request callback runs before the test finishes
    }
}
