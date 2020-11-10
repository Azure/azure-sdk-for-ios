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
    func test_HTTPRequest_Inits() {
        let headers = HTTPHeaders([HTTPHeader("headerParam"): "myHeaderParam"])
        let request = try! HTTPRequest(method: .get, url: "www.test.com", headers: headers)
        request.url = request.url.appendingQueryParameters(RequestParameters(
            (.query, "a", "1", .encode),
            (.query, "b", "2", .encode)
        ))!
        XCTAssertEqual(request.url.absoluteString, "www.test.com?a=1&b=2")
        XCTAssertEqual(request.httpMethod, .get)
        XCTAssertEqual(request.headers, headers)
    }

    func test_PipelineClient_CanFormatUrl() {
        let client = TestClient()
        let url = client.url(template: "{a}/{b}/test", params: RequestParameters(
            (.path, "a", "cat", .encode),
            (.path, "b", "hat", .encode)
        ))
        XCTAssertEqual(url?.absoluteString, "\(client.endpoint)cat/hat/test")
    }

    func test_PipelineClient_CanRun() {
        let didFinishRun = expectation(description: "run completion handler called.")
        var requestCompleted = false

        let client = TestClient()
        client.testCall(value: "test") { result, httpResponse in
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
        let didFinishRun = expectation(description: "run completion handler called.")
        var requestCompleted = false

        let client = TestClient(customPolicies: [])
        client.testCall(value: "test") { result, httpResponse in
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
        let didFinishRun = expectation(description: "run completion handler called.")
        var requestCompleted = false

        var options = TestClientOptions()
        options.transportOptions = TransportOptions(perRequestPolicies: [CustomPolicy()])
        let client = TestClient(defaultPoliciesWithOptions: options)

        client.testCall(value: "test") { result, httpResponse in
            switch result {
            case let .success(context):
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
        let didFinishRun = expectation(description: "run completion handler called.")
        var requestCompleted = false

        let client = TestClient(customPolicies: [
            UserAgentPolicy(sdkName: "Test", sdkVersion: "1.0"),
            RetryPolicy(),
            LoggingPolicy()
        ])
        client.testCall(value: "test") { result, httpResponse in
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
        let didFinishRun = expectation(description: "run completion handler called.")
        var requestCompleted = false

        var options = TestClientOptions()
        options.transportOptions = TransportOptions(
            perRequestPolicies: [CustomPolicy()],
            perRetryPolicies: [CustomPerRetryPolicy()]
        )
        let client = TestClient(customPolicies: [
            UserAgentPolicy(sdkName: "Test", sdkVersion: "1.0"),
            RetryPolicy(),
            LoggingPolicy()
        ], withOptions: options)
        client.testCall(value: "test") { result, httpResponse in
            switch result {
            case let .success(context):
                XCTAssert(client.pipeline.policies.count == 6, "Incorrect number of policies")
                XCTAssert(client.pipeline.policies[0] is UserAgentPolicy, "Policies in incorrect order")
                XCTAssert(client.pipeline.policies[1] is CustomPolicy, "Policies in incorrect order")
                XCTAssert(client.pipeline.policies[2] is RetryPolicy, "Policies in incorrect order")
                XCTAssert(client.pipeline.policies[3] is LoggingPolicy, "Policies in incorrect order")
                XCTAssert(client.pipeline.policies[4] is CustomPerRetryPolicy, "Policies in incorrect order")
                XCTAssert(client.pipeline.policies[5] is TransportStage, "Policies in incorrect order")

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

    func test_PipelineClient_WithCustomUserContext() {
        let didFinishRun = expectation(description: "run completion handler called.")
        var requestCompleted = false

        var clientOptions = TestClientOptions()
        clientOptions.transportOptions = TransportOptions(perRequestPolicies: [CustomPolicy()])
        let client = TestClient(defaultPoliciesWithOptions: clientOptions)

        // Test overriding the pipeline values
        let context = PipelineContext()
        context.add(value: 2 as AnyObject, forKey: "CustomOnRequestCalled")
        context.add(value: "passed" as AnyObject, forKey: "myCustomKey")
        let options = TestCallOptions(context: context)

        client.testCall(value: "test", withOptions: options) { result, httpResponse in
            switch result {
            case let .success(context):
                XCTAssertTrue(context.value(forKey: "CustomOnRequestCalled") as? Int == 3)
                XCTAssertTrue(context.value(forKey: "CustomOnResponseCalled") as? Int == 1)
                XCTAssertTrue(context.value(forKey: "myCustomKey") as? String == "passed")
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
