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

// swiftlint:disable file_length type_body_length
class LoggingPolicyTests: XCTestCase {
    // MARK: onRequest

    /// Test that the logging policy starts the request log with the request ID
    func test_LoggingPolicy_OnRequestWithRequestId_LogsRequestIdFirstAtInfoLevel() {
        let policy = LoggingPolicy()
        let logger = TestClientLogger(.info)
        let headers = HTTPHeaders([.clientRequestId: "123"])
        let req = PipelineRequest(method: .get, url: "http://www.example.com", headers: headers, logger: logger)
        policy.on(request: req) { _, _ in }
        LoggingPolicy.queue.sync {}
        let msg = logger.messages.first
        XCTAssertEqual(msg?.level, .info)
        XCTAssertEqual(msg?.text, "--> [123]")
    }

    /// Test that the logging policy ends the request log with the request ID
    func test_LoggingPolicy_OnRequestWithRequestId_LogsRequestIdLastAtInfoLevel() {
        let policy = LoggingPolicy()
        let logger = TestClientLogger(.info)
        let headers = HTTPHeaders([.clientRequestId: "123"])
        let req = PipelineRequest(method: .get, url: "http://www.example.com", headers: headers, logger: logger)
        policy.on(request: req) { _, _ in }
        LoggingPolicy.queue.sync {}
        let msg = logger.messages.last
        XCTAssertEqual(msg?.level, .info)
        XCTAssertEqual(msg?.text, "--> [END 123]")
    }

    /// Test that the logging policy redacts all request headers when the allowHeaders parameter is empty
    func test_LoggingPolicy_OnRequestWithNoAllowedHeaders_RedactsAllHeaders() {
        let policy = LoggingPolicy(allowHeaders: [])
        let logger = TestClientLogger(.debug)
        var headers = HTTPHeaders([.accept: "application/json"])
        headers["MyCustomHeader"] = "SecretValue"
        let req = PipelineRequest(method: .get, url: "http://www.example.com", headers: headers, logger: logger)
        policy.on(request: req) { _, _ in }
        LoggingPolicy.queue.sync {}
        XCTAssertEqual(
            logger.messages.first { $0.text.starts(with: HTTPHeader.accept.requestString) }?.text,
            "Accept: REDACTED"
        )
        XCTAssertEqual(
            logger.messages.first { $0.text.starts(with: "MyCustomHeader") }?.text,
            "MyCustomHeader: REDACTED"
        )
    }

    /// Test that the logging policy redacts request headers not included in the defaultAllowHeaders property
    func test_LoggingPolicy_OnRequestWithDefaultAllowedHeaders_RedactsHeaders() {
        let policy = LoggingPolicy()
        let logger = TestClientLogger(.debug)
        var headers = HTTPHeaders([.accept: "application/json"])
        headers["MyCustomHeader"] = "SecretValue"
        let req = PipelineRequest(method: .get, url: "http://www.example.com", headers: headers, logger: logger)
        policy.on(request: req) { _, _ in }
        LoggingPolicy.queue.sync {}
        XCTAssertEqual(
            logger.messages.first { $0.text.starts(with: HTTPHeader.accept.requestString) }?.text,
            "Accept: application/json"
        )
        XCTAssertEqual(
            logger.messages.first { $0.text.starts(with: "MyCustomHeader") }?.text,
            "MyCustomHeader: REDACTED"
        )
    }

    /// Test that the logging policy redacts request headers not included in the supplied allowHeaders parameter
    func test_LoggingPolicy_OnRequestWithCustomAllowedHeaders_RedactsHeaders() {
        let policy = LoggingPolicy(allowHeaders: ["MyCustomHeader"])
        let logger = TestClientLogger(.debug)
        var headers = HTTPHeaders([.accept: "application/json"])
        headers["MyCustomHeader"] = "SecretValue"
        let req = PipelineRequest(method: .get, url: "http://www.example.com", headers: headers, logger: logger)
        policy.on(request: req) { _, _ in }
        LoggingPolicy.queue.sync {}
        XCTAssertEqual(
            logger.messages.first { $0.text.starts(with: HTTPHeader.accept.requestString) }?.text,
            "Accept: REDACTED"
        )
        XCTAssertEqual(
            logger.messages.first { $0.text.starts(with: "MyCustomHeader") }?.text,
            "MyCustomHeader: SecretValue"
        )
    }

    /// Test that the logging policy redacts all query string params when the allowQueryParams parameter is empty and
    /// the params are provided as part of the URL
    func test_LoggingPolicy_OnRequestWithQueryParamsInURLAndNoAllowedQueryParams_RedactsAllQueryParams() {
        let policy = LoggingPolicy()
        let logger = TestClientLogger(.debug)
        let req = PipelineRequest(method: .get, url: "http://www.example.com?id=123&test=secret", logger: logger)
        policy.on(request: req) { _, _ in }
        LoggingPolicy.queue.sync {}
        let msg = logger.messages.first { $0.text.starts(with: "GET http://www.example.com") }
        XCTAssertEqual(msg?.text, "GET http://www.example.com?id=REDACTED&test=REDACTED")
    }

    /// Test that the logging policy redacts query string params not included in the supplied allowQueryParams parameter
    /// when the params are provided as part of the URL
    func test_LoggingPolicy_OnRequestWithQueryParamsInURLAndAllowedQueryParams_RedactsQueryParams() {
        let policy = LoggingPolicy(allowQueryParams: ["id"])
        let logger = TestClientLogger(.debug)
        let req = PipelineRequest(method: .get, url: "http://www.example.com?id=123&test=secret", logger: logger)
        policy.on(request: req) { _, _ in }
        LoggingPolicy.queue.sync {}
        let msg = logger.messages.first { $0.text.starts(with: "GET http://www.example.com") }
        XCTAssertEqual(msg?.text, "GET http://www.example.com?id=123&test=REDACTED")
    }

    /// Test that the logging policy redacts all query string params when the allowQueryParams parameter is empty and
    /// the params are provided via HttpRequest's queryParams argument
    func test_LoggingPolicy_OnRequestWithAddedQueryParamsAndNoAllowedQueryParams_RedactsAllQueryParams() {
        let policy = LoggingPolicy()
        let logger = TestClientLogger(.debug)
        let req = PipelineRequest(method: .get, url: "http://www.example.com", logger: logger)
        req.httpRequest.url = req.httpRequest.url
            .appendingQueryParameters(RequestParameters(
                (.query, "id", "123", .encode),
                (.query, "test", "secret", .encode)
            ))!
        policy.on(request: req) { _, _ in }
        LoggingPolicy.queue.sync {}
        let msg = logger.messages.first { $0.text.starts(with: "GET http://www.example.com") }
        XCTAssertEqual(msg?.text, "GET http://www.example.com?id=REDACTED&test=REDACTED")
    }

    /// Test that the logging policy redacts query string params not included in the supplied allowQueryParams parameter
    /// when the params are provided via HttpRequest's queryParams argument
    func test_LoggingPolicy_OnRequestWithAddedQueryParamsAndAllowedQueryParams_RedactsQueryParams() {
        let policy = LoggingPolicy(allowQueryParams: ["id"])
        let logger = TestClientLogger(.debug)
        let req = PipelineRequest(method: .get, url: "http://www.example.com", logger: logger)
        req.httpRequest.url = req.httpRequest.url
            .appendingQueryParameters(RequestParameters(
                (.query, "id", "123", .encode),
                (.query, "test", "secret", .encode)
            ))!
        policy.on(request: req) { _, _ in }
        LoggingPolicy.queue.sync {}
        let msg = logger.messages.first { $0.text.starts(with: "GET http://www.example.com") }
        XCTAssertEqual(msg?.text, "GET http://www.example.com?id=123&test=REDACTED")
    }

    /// Test that the logging policy redacts all query string params when the allowQueryParams parameter is empty and
    /// some params are provided as part of the URL and others are provided via HttpRequest's queryParams argument
    func test_LoggingPolicy_OnRequestWithBothFormsOfQueryParamsAndNoAllowedQueryParams_RedactsAllQueryParams() {
        let policy = LoggingPolicy()
        let logger = TestClientLogger(.debug)
        let req = PipelineRequest(method: .get, url: "http://www.example.com?id=123", logger: logger)
        req.httpRequest.url = req.httpRequest.url
            .appendingQueryParameters(RequestParameters((.query, "test", "secret", .encode)))!
        policy.on(request: req) { _, _ in }
        LoggingPolicy.queue.sync {}
        let msg = logger.messages.first { $0.text.starts(with: "GET http://www.example.com") }
        XCTAssertEqual(msg?.text, "GET http://www.example.com?id=REDACTED&test=REDACTED")
    }

    /// Test that the logging policy redacts query string params not included in the supplied allowQueryParams parameter
    /// when some params are provided as part of the URL and others are provided via HttpRequest's queryParams argument
    func test_LoggingPolicy_OnRequestWithBothFormsOfQueryParamsAndAllowedQueryParams_RedactsQueryParams() {
        let policy = LoggingPolicy(allowQueryParams: ["id"])
        let logger = TestClientLogger(.debug)
        let req = PipelineRequest(method: .get, url: "http://www.example.com?id=123", logger: logger)
        req.httpRequest.url = req.httpRequest.url
            .appendingQueryParameters(RequestParameters((.query, "test", "secret", .encode)))!
        policy.on(request: req) { _, _ in }
        LoggingPolicy.queue.sync {}
        let msg = logger.messages.first { $0.text.starts(with: "GET http://www.example.com") }
        XCTAssertEqual(msg?.text, "GET http://www.example.com?id=123&test=REDACTED")
    }

    /// Test that the logging policy logs the request line in the correct format at the correct level
    func test_LoggingPolicy_OnRequest_LogsRFC2616FormattedRequestLineAtInfoLevel() {
        let policy = LoggingPolicy()
        let logger = TestClientLogger(.info)
        let req = PipelineRequest(method: .get, url: "http://www.example.com", logger: logger)
        policy.on(request: req) { _, _ in }
        LoggingPolicy.queue.sync {}
        let msg = logger.messages.first { $0.text == "GET http://www.example.com" }
        XCTAssertNotNil(msg)
        XCTAssertEqual(msg?.level, .info)
    }

    /// Test that the logging policy doesn't log request headers if the log level is not low enough
    func test_LoggingPolicy_OnRequest_LogsNoHeadersAtInfoLevel() {
        let policy = LoggingPolicy()
        let logger = TestClientLogger(.info)
        let headers = HTTPHeaders([.accept: "application/json"])
        let req = PipelineRequest(method: .get, url: "http://www.example.com", headers: headers, logger: logger)
        policy.on(request: req) { _, _ in }
        LoggingPolicy.queue.sync {}
        XCTAssertEqual(logger.messages.count, 3)
        XCTAssertNil(logger.messages.first { $0.text.contains("application/json") })
    }

    /// Test that the logging policy doesn't log the request body if the log level is not low enough
    func test_LoggingPolicy_OnRequest_LogsNoBodyAtInfoLevel() {
        let policy = LoggingPolicy()
        let logger = TestClientLogger(.info)
        let headers = HTTPHeaders([.contentLength: "7"])
        let req = PipelineRequest(
            method: .get,
            url: "http://www.example.com",
            headers: headers,
            body: "Testing",
            logger: logger
        )
        policy.on(request: req) { _, _ in }
        LoggingPolicy.queue.sync {}
        XCTAssertEqual(logger.messages.count, 3)
        XCTAssertNil(logger.messages.first { $0.text.contains("Testing") })
    }

    /// Test that the logging policy logs a placeholder message when the request body is encoded
    func test_LoggingPolicy_OnRequestWithEncodedBody_LogsOmittedMessageAtDebugLevel() {
        let policy = LoggingPolicy()
        let logger = TestClientLogger(.debug)
        let headers = HTTPHeaders([.contentEncoding: "gzip", .contentLength: "7"])
        let req = PipelineRequest(
            method: .get,
            url: "http://www.example.com",
            headers: headers,
            body: "Testing",
            logger: logger
        )
        policy.on(request: req) { _, _ in }
        LoggingPolicy.queue.sync {}
        XCTAssertNotNil(logger.messages.first { $0.text.contains("(encoded body omitted)") })
        XCTAssertNil(logger.messages.first { $0.text.contains("Testing") })
    }

    /// Test that the logging policy logs the request body when its encoding is identity
    func test_LoggingPolicy_OnRequestWithIdentityEncodedBody_LogsBodyTextAtDebugLevel() {
        let policy = LoggingPolicy()
        let logger = TestClientLogger(.debug)
        let headers = HTTPHeaders([.contentEncoding: "identity", .contentLength: "7"])
        let req = PipelineRequest(
            method: .get,
            url: "http://www.example.com",
            headers: headers,
            body: "Testing",
            logger: logger
        )
        policy.on(request: req) { _, _ in }
        LoggingPolicy.queue.sync {}
        XCTAssertNil(logger.messages.first { $0.text.contains("(encoded body omitted)") })
        XCTAssertNotNil(logger.messages.first { $0.text.contains("Testing") })
    }

    /// Test that the logging policy logs a placeholder message when the request body is attached
    func test_LoggingPolicy_OnRequestWithAttachedBody_LogsOmittedMessageAtDebugLevel() {
        let policy = LoggingPolicy()
        let logger = TestClientLogger(.debug)
        let headers = HTTPHeaders([.contentDisposition: "attached", .contentLength: "7"])
        let req = PipelineRequest(
            method: .get,
            url: "http://www.example.com",
            headers: headers,
            body: "Testing",
            logger: logger
        )
        policy.on(request: req) { _, _ in }
        LoggingPolicy.queue.sync {}
        XCTAssertNotNil(logger.messages.first { $0.text.contains("(non-inline body omitted)") })
        XCTAssertNil(logger.messages.first { $0.text.contains("Testing") })
    }

    /// Test that the logging policy logs the request body when it is inline
    func test_LoggingPolicy_OnRequestWithInlineBody_LogsBodyTextAtDebugLevel() {
        let policy = LoggingPolicy()
        let logger = TestClientLogger(.debug)
        let headers = HTTPHeaders([.contentDisposition: "inline", .contentLength: "7"])
        let req = PipelineRequest(
            method: .get,
            url: "http://www.example.com",
            headers: headers,
            body: "Testing",
            logger: logger
        )
        policy.on(request: req) { _, _ in }
        LoggingPolicy.queue.sync {}
        XCTAssertNil(logger.messages.first { $0.text.contains("(non-inline body omitted)") })
        XCTAssertNotNil(logger.messages.first { $0.text.contains("Testing") })
    }

    /// Test that the logging policy logs a placeholder message when the request body content is binary
    func test_LoggingPolicy_OnRequestWithBinaryBody_LogsOmittedMessageAtDebugLevel() {
        let policy = LoggingPolicy()
        let logger = TestClientLogger(.debug)
        let headers = HTTPHeaders([
            .contentType: "application/octet-stream",
            .contentLength: "7"
        ])
        let req = PipelineRequest(
            method: .get,
            url: "http://www.example.com",
            headers: headers,
            body: "Testing",
            logger: logger
        )
        policy.on(request: req) { _, _ in }
        LoggingPolicy.queue.sync {}
        XCTAssertNotNil(logger.messages.first { $0.text.contains("(binary body omitted)") })
        XCTAssertNil(logger.messages.first { $0.text.contains("Testing") })
    }

    /// Test that the logging policy logs the request body when its content is text
    func test_LoggingPolicy_OnRequestWithTextBody_LogsBodyTextAtDebugLevel() {
        let policy = LoggingPolicy()
        let logger = TestClientLogger(.debug)
        let headers = HTTPHeaders([.contentType: "text/plain", .contentLength: "7"])
        let req = PipelineRequest(
            method: .get,
            url: "http://www.example.com",
            headers: headers,
            body: "Testing",
            logger: logger
        )
        policy.on(request: req) { _, _ in }
        LoggingPolicy.queue.sync {}
        XCTAssertNil(logger.messages.first { $0.text.contains("(binary body omitted)") })
        XCTAssertNotNil(logger.messages.first { $0.text.contains("Testing") })
    }

    /// Test that the logging policy logs a placeholder message when the request body is too large to log
    func test_LoggingPolicy_OnRequestWithLargeTextBody_LogsOmittedMessageAtDebugLevel() {
        let length = (1024 * 16) + 1
        let policy = LoggingPolicy()
        let logger = TestClientLogger(.debug)
        let headers = HTTPHeaders([.contentLength: String(length)])
        let req = PipelineRequest(
            method: .get,
            url: "http://www.example.com",
            headers: headers,
            body: "Testing",
            logger: logger
        )
        policy.on(request: req) { _, _ in }
        LoggingPolicy.queue.sync {}
        XCTAssertNotNil(logger.messages.first { $0.text.contains("(\(length)-byte body omitted)") })
        XCTAssertNil(logger.messages.first { $0.text.contains("Testing") })
    }

    /// Test that the logging policy logs a placeholder message when the request body is empty
    func test_LoggingPolicy_OnRequestWithContentLengthAndEmptyBody_LogsEmptyBodyMessageAtDebugLevel() {
        let policy = LoggingPolicy()
        let logger = TestClientLogger(.debug)
        let headers = HTTPHeaders([.contentLength: "7"])
        let req = PipelineRequest(
            method: .get,
            url: "http://www.example.com",
            headers: headers,
            body: "",
            logger: logger
        )
        policy.on(request: req) { _, _ in }
        LoggingPolicy.queue.sync {}
        XCTAssertNotNil(logger.messages.first { $0.text.contains("(empty body)") })
    }

    /// Test that the logging policy logs a placeholder message when the request doesn't specify a content length
    func test_LoggingPolicy_OnRequestWithNoContentLength_LogsEmptyBodyMessageAtDebugLevel() {
        let policy = LoggingPolicy()
        let logger = TestClientLogger(.debug)
        let headers = HTTPHeaders()
        let req = PipelineRequest(
            method: .get,
            url: "http://www.example.com",
            headers: headers,
            body: "Testing",
            logger: logger
        )
        policy.on(request: req) { _, _ in }
        LoggingPolicy.queue.sync {}
        XCTAssertNotNil(logger.messages.first { $0.text.contains("(empty body)") })
        XCTAssertNil(logger.messages.first { $0.text.contains("Testing") })
    }

    /// Test that the logging policy logs a placeholder message when the request content length is zero
    func test_LoggingPolicy_OnRequestWithZeroContentLength_LogsEmptyBodyMessageAtDebugLevel() {
        let policy = LoggingPolicy()
        let logger = TestClientLogger(.debug)
        let headers = HTTPHeaders([.contentLength: "0"])
        let req = PipelineRequest(
            method: .get,
            url: "http://www.example.com",
            headers: headers,
            body: "Testing",
            logger: logger
        )
        policy.on(request: req) { _, _ in }
        LoggingPolicy.queue.sync {}
        XCTAssertNotNil(logger.messages.first { $0.text.contains("(empty body)") })
        XCTAssertNil(logger.messages.first { $0.text.contains("Testing") })
    }

    /// Test that the logging policy adds the request start time to the context
    func test_LoggingPolicy_OnRequest_AddsStartTimeToContext() {
        let policy = LoggingPolicy()
        let logger = TestClientLogger(.info)
        let headers = HTTPHeaders()
        let context = PipelineContext()
        let req = PipelineRequest(
            method: .get,
            url: "http://www.example.com",
            headers: headers,
            context: context,
            logger: logger
        )
        policy.on(request: req) { _, _ in }
        LoggingPolicy.queue.sync {}
        XCTAssertNotNil(context.value(forKey: .requestStartTime))
    }

    // MARK: onResponse

    /// Test that the logging policy redacts all response headers when the allowHeaders parameter is empty
    func test_LoggingPolicy_OnResponseWithNoAllowedHeaders_RedactsAllHeaders() {
        let policy = LoggingPolicy(allowHeaders: [])
        let logger = TestClientLogger(.debug)
        var headers = HTTPHeaders([.contentType: "application/json"])
        headers["MyCustomHeader"] = "SecretValue"
        let req = PipelineRequest(method: .get, url: "http://www.example.com")
        let res = PipelineResponse(request: req, responseCode: 404, headers: headers, logger: logger)
        policy.on(response: res) { _, _ in }
        LoggingPolicy.queue.sync {}
        XCTAssertEqual(
            logger.messages.first { $0.text.starts(with: HTTPHeader.contentType.requestString) }?.text,
            "Content-Type: REDACTED"
        )
        XCTAssertEqual(
            logger.messages.first { $0.text.starts(with: "MyCustomHeader") }?.text,
            "MyCustomHeader: REDACTED"
        )
    }

    /// Test that the logging policy redacts response headers not included in the defaultAllowHeaders property
    func test_LoggingPolicy_OnResponseWithDefaultAllowedHeaders_RedactsHeaders() {
        let policy = LoggingPolicy()
        let logger = TestClientLogger(.debug)
        var headers = HTTPHeaders([.contentType: "application/json"])
        headers["MyCustomHeader"] = "SecretValue"
        let req = PipelineRequest(method: .get, url: "http://www.example.com")
        let res = PipelineResponse(request: req, responseCode: 404, headers: headers, logger: logger)
        policy.on(response: res) { _, _ in }
        LoggingPolicy.queue.sync {}
        XCTAssertEqual(
            logger.messages.first { $0.text.starts(with: HTTPHeader.contentType.requestString) }?.text,
            "Content-Type: application/json"
        )
        XCTAssertEqual(
            logger.messages.first { $0.text.starts(with: "MyCustomHeader") }?.text,
            "MyCustomHeader: REDACTED"
        )
    }

    /// Test that the logging policy redacts response headers not included in the supplied allowHeaders parameter
    func test_LoggingPolicy_OnResponseWithCustomAllowedHeaders_RedactsHeaders() {
        let policy = LoggingPolicy(allowHeaders: ["MyCustomHeader"])
        let logger = TestClientLogger(.debug)
        var headers = HTTPHeaders([.contentType: "application/json"])
        headers["MyCustomHeader"] = "SecretValue"
        let req = PipelineRequest(method: .get, url: "http://www.example.com")
        let res = PipelineResponse(request: req, responseCode: 404, headers: headers, logger: logger)
        policy.on(response: res) { _, _ in }
        LoggingPolicy.queue.sync {}
        XCTAssertEqual(
            logger.messages.first { $0.text.starts(with: HTTPHeader.contentType.requestString) }?.text,
            "Content-Type: REDACTED"
        )
        XCTAssertEqual(
            logger.messages.first { $0.text.starts(with: "MyCustomHeader") }?.text,
            "MyCustomHeader: SecretValue"
        )
    }

    /// Test that the logging policy starts the response log with the request ID
    func test_LoggingPolicy_OnResponseWithRequestId_LogsRequestIdFirstAtInfoLevel() {
        let policy = LoggingPolicy()
        let logger = TestClientLogger(.info)
        let headers = HTTPHeaders([.clientRequestId: "123"])
        let req = PipelineRequest(method: .get, url: "http://www.example.com", headers: headers)
        let res = PipelineResponse(request: req, logger: logger)
        policy.on(response: res) { _, _ in }
        LoggingPolicy.queue.sync {}
        let msg = logger.messages.first
        XCTAssertEqual(msg?.level, .info)
        XCTAssertEqual(msg?.text, "<-- [123]")
    }

    /// Test that the logging policy ends the response log with the request ID
    func test_LoggingPolicy_OnResponseWithRequestId_LogsRequestIdLast() {
        let policy = LoggingPolicy()
        let logger = TestClientLogger(.info)
        let headers = HTTPHeaders([.clientRequestId: "123"])
        let req = PipelineRequest(method: .get, url: "http://www.example.com", headers: headers)
        let res = PipelineResponse(request: req, logger: logger)
        policy.on(response: res) { _, _ in }
        LoggingPolicy.queue.sync {}
        let msg = logger.messages.last
        XCTAssertEqual(msg?.level, .info)
        XCTAssertEqual(msg?.text, "<-- [END 123]")
    }

    /// Test that the logging policy starting line includes the duration
    func test_LoggingPolicy_OnResponseWithRequestId_LogsDuration() {
        let policy = LoggingPolicy()
        let logger = TestClientLogger(.info)
        let context = PipelineContext()
        let req = PipelineRequest(method: .get, url: "http://www.example.com", context: context)
        policy.on(request: req) { afterRequest, _ in
            let res = PipelineResponse(request: afterRequest, logger: logger)
            policy.on(response: res) { _, _ in }
        }
        LoggingPolicy.queue.sync {}
        XCTAssert(logger.messages.first!.text.contains("ms)"))
    }

    /// Test that the logging policy logs the status line of a successful response in the correct format at the correct
    /// level
    func test_LoggingPolicy_OnSuccessfulResponse_LogsRFC2616FormattedStatusLineAtInfoLevel() {
        let policy = LoggingPolicy()
        let logger = TestClientLogger(.info)
        let req = PipelineRequest(method: .get, url: "http://www.example.com")
        let res = PipelineResponse(request: req, responseCode: 304, logger: logger)
        policy.on(response: res) { _, _ in }
        LoggingPolicy.queue.sync {}
        let msg = logger.messages.first { $0.text == "304 Not Modified" }
        XCTAssertNotNil(msg)
        XCTAssertEqual(msg?.level, .info)
    }

    /// Test that the logging policy logs the status line of a failure response in the correct format at the correct
    /// level
    func test_LoggingPolicy_OnFailureResponse_LogsRFC2616FormattedStatusLineAtWarningLevel() {
        let policy = LoggingPolicy()
        let logger = TestClientLogger(.info)
        let req = PipelineRequest(method: .get, url: "http://www.example.com")
        let res = PipelineResponse(request: req, responseCode: 404, logger: logger)
        policy.on(response: res) { _, _ in }
        LoggingPolicy.queue.sync {}
        let msg = logger.messages.first { $0.text == "404 Not Found" }
        XCTAssertNotNil(msg)
        XCTAssertEqual(msg?.level, .warning)
    }

    /// Test that the logging policy doesn't log response headers if the log level is not low enough
    func test_LoggingPolicy_OnResponse_LogsNoHeadersAtInfoLevel() {
        let policy = LoggingPolicy()
        let logger = TestClientLogger(.info)
        let headers = HTTPHeaders([.etag: "123"])
        let req = PipelineRequest(method: .get, url: "http://www.example.com")
        let res = PipelineResponse(request: req, headers: headers, logger: logger)
        policy.on(response: res) { _, _ in }
        LoggingPolicy.queue.sync {}
        XCTAssertEqual(logger.messages.count, 3)
        XCTAssertNil(logger.messages.first { $0.text.contains("123") })
    }

    /// Test that the logging policy doesn't log the response body if the log level is not low enough
    func test_LoggingPolicy_OnResponse_LogsNoBodyAtInfoLevel() {
        let policy = LoggingPolicy()
        let logger = TestClientLogger(.info)
        let headers = HTTPHeaders([.contentLength: "7"])
        let req = PipelineRequest(method: .get, url: "http://www.example.com")
        let res = PipelineResponse(request: req, headers: headers, body: "Testing", logger: logger)
        policy.on(response: res) { _, _ in }
        LoggingPolicy.queue.sync {}
        XCTAssertEqual(logger.messages.count, 3)
        XCTAssertNil(logger.messages.first { $0.text.contains("Testing") })
    }

    /// Test that the logging policy logs a placeholder message when the response body is encoded
    func test_LoggingPolicy_OnResponseWithEncodedBody_LogsOmittedMessageAtDebugLevel() {
        let policy = LoggingPolicy()
        let logger = TestClientLogger(.debug)
        let headers = HTTPHeaders([.contentEncoding: "gzip", .contentLength: "7"])
        let req = PipelineRequest(method: .get, url: "http://www.example.com")
        let res = PipelineResponse(request: req, headers: headers, body: "Testing", logger: logger)
        policy.on(response: res) { _, _ in }
        LoggingPolicy.queue.sync {}
        XCTAssertNotNil(logger.messages.first { $0.text.contains("(encoded body omitted)") })
        XCTAssertNil(logger.messages.first { $0.text.contains("Testing") })
    }

    /// Test that the logging policy logs the response body when its encoding is identity
    func test_LoggingPolicy_OnResponseWithIdentityEncodedBody_LogsBodyTextAtDebugLevel() {
        let policy = LoggingPolicy()
        let logger = TestClientLogger(.debug)
        let headers = HTTPHeaders([.contentEncoding: "identity", .contentLength: "7"])
        let req = PipelineRequest(method: .get, url: "http://www.example.com")
        let res = PipelineResponse(request: req, headers: headers, body: "Testing", logger: logger)
        policy.on(response: res) { _, _ in }
        LoggingPolicy.queue.sync {}
        XCTAssertNil(logger.messages.first { $0.text.contains("(encoded body omitted)") })
        XCTAssertNotNil(logger.messages.first { $0.text.contains("Testing") })
    }

    /// Test that the logging policy logs a placeholder message when the response body is attached
    func test_LoggingPolicy_OnResponseWithAttachedBody_LogsOmittedMessageAtDebugLevel() {
        let policy = LoggingPolicy()
        let logger = TestClientLogger(.debug)
        let headers = HTTPHeaders([.contentDisposition: "attached", .contentLength: "7"])
        let req = PipelineRequest(method: .get, url: "http://www.example.com")
        let res = PipelineResponse(request: req, headers: headers, body: "Testing", logger: logger)
        policy.on(response: res) { _, _ in }
        LoggingPolicy.queue.sync {}
        XCTAssertNotNil(logger.messages.first { $0.text.contains("(non-inline body omitted)") })
        XCTAssertNil(logger.messages.first { $0.text.contains("Testing") })
    }

    /// Test that the logging policy logs the response body when it is inline
    func test_LoggingPolicy_OnResponseWithInlineBody_LogsBodyTextAtDebugLevel() {
        let policy = LoggingPolicy()
        let logger = TestClientLogger(.debug)
        let headers = HTTPHeaders([.contentDisposition: "inline", .contentLength: "7"])
        let req = PipelineRequest(method: .get, url: "http://www.example.com")
        let res = PipelineResponse(request: req, headers: headers, body: "Testing", logger: logger)
        policy.on(response: res) { _, _ in }
        LoggingPolicy.queue.sync {}
        XCTAssertNil(logger.messages.first { $0.text.contains("(non-inline body omitted)") })
        XCTAssertNotNil(logger.messages.first { $0.text.contains("Testing") })
    }

    /// Test that the logging policy logs a placeholder message when the response body content is binary
    func test_LoggingPolicy_OnResponseWithBinaryBody_LogsOmittedMessageAtDebugLevel() {
        let policy = LoggingPolicy()
        let logger = TestClientLogger(.debug)
        let headers = HTTPHeaders([
            .contentType: "application/octet-stream",
            .contentLength: "7"
        ])
        let req = PipelineRequest(method: .get, url: "http://www.example.com")
        let res = PipelineResponse(request: req, headers: headers, body: "Testing", logger: logger)
        policy.on(response: res) { _, _ in }
        LoggingPolicy.queue.sync {}
        XCTAssertNotNil(logger.messages.first { $0.text.contains("(binary body omitted)") })
        XCTAssertNil(logger.messages.first { $0.text.contains("Testing") })
    }

    /// Test that the logging policy logs the response body when its content is text
    func test_LoggingPolicy_OnResponseWithTextBody_LogsBodyTextAtDebugLevel() {
        let policy = LoggingPolicy()
        let logger = TestClientLogger(.debug)
        let headers = HTTPHeaders([.contentType: "text/plain", .contentLength: "7"])
        let req = PipelineRequest(method: .get, url: "http://www.example.com")
        let res = PipelineResponse(request: req, headers: headers, body: "Testing", logger: logger)
        policy.on(response: res) { _, _ in }
        LoggingPolicy.queue.sync {}
        XCTAssertNil(logger.messages.first { $0.text.contains("(binary body omitted)") })
        XCTAssertNotNil(logger.messages.first { $0.text.contains("Testing") })
    }

    /// Test that the logging policy logs a placeholder message when the response body is too large to log
    func test_LoggingPolicy_OnResponseWithLargeTextBody_LogsOmittedMessageAtDebugLevel() {
        let length = (1024 * 16) + 1
        let policy = LoggingPolicy()
        let logger = TestClientLogger(.debug)
        let headers = HTTPHeaders([.contentLength: String(length)])
        let req = PipelineRequest(method: .get, url: "http://www.example.com")
        let res = PipelineResponse(request: req, headers: headers, body: "Testing", logger: logger)
        policy.on(response: res) { _, _ in }
        LoggingPolicy.queue.sync {}
        XCTAssertNotNil(logger.messages.first { $0.text.contains("(\(length)-byte body omitted)") })
        XCTAssertNil(logger.messages.first { $0.text.contains("Testing") })
    }

    /// Test that the logging policy logs a placeholder message when the response body is empty
    func test_LoggingPolicy_OnResponseWithContentLengthAndEmptyBody_LogsEmptyBodyMessageAtDebugLevel() {
        let policy = LoggingPolicy()
        let logger = TestClientLogger(.debug)
        let headers = HTTPHeaders([.contentLength: "7"])
        let req = PipelineRequest(method: .get, url: "http://www.example.com")
        let res = PipelineResponse(request: req, headers: headers, body: "", logger: logger)
        policy.on(response: res) { _, _ in }
        LoggingPolicy.queue.sync {}
        XCTAssertNotNil(logger.messages.first { $0.text.contains("(empty body)") })
    }

    /// Test that the logging policy logs a placeholder message when the response doesn't specify a content length
    func test_LoggingPolicy_OnResponseWithNoContentLength_LogsEmptyBodyMessageAtDebugLevel() {
        let policy = LoggingPolicy()
        let logger = TestClientLogger(.debug)
        let headers = HTTPHeaders()
        let req = PipelineRequest(method: .get, url: "http://www.example.com")
        let res = PipelineResponse(request: req, headers: headers, body: "Testing", logger: logger)
        policy.on(response: res) { _, _ in }
        LoggingPolicy.queue.sync {}
        XCTAssertNotNil(logger.messages.first { $0.text.contains("(empty body)") })
        XCTAssertNil(logger.messages.first { $0.text.contains("Testing") })
    }

    /// Test that the logging policy logs a placeholder message when the response content length is zero
    func test_LoggingPolicy_OnResponseWithZeroContentLength_LogsEmptyBodyMessageAtDebugLevel() {
        let policy = LoggingPolicy()
        let logger = TestClientLogger(.debug)
        let headers = HTTPHeaders([.contentLength: "0"])
        let req = PipelineRequest(method: .get, url: "http://www.example.com")
        let res = PipelineResponse(request: req, headers: headers, body: "Testing", logger: logger)
        policy.on(response: res) { _, _ in }
        LoggingPolicy.queue.sync {}
        XCTAssertNotNil(logger.messages.first { $0.text.contains("(empty body)") })
        XCTAssertNil(logger.messages.first { $0.text.contains("Testing") })
    }

    /// Test that the logging policy logs a placeholder message when the response content length is present but empty
    func test_LoggingPolicy_OnResponseWithEmptyContentLength_LogsEmptyBodyMessageAtDebugLevel() {
        let policy = LoggingPolicy()
        let logger = TestClientLogger(.debug)
        let headers = HTTPHeaders([.contentLength: ""])
        let req = PipelineRequest(method: .get, url: "http://www.example.com")
        let res = PipelineResponse(request: req, headers: headers, body: "Testing", logger: logger)
        policy.on(response: res) { _, _ in }
        LoggingPolicy.queue.sync {}
        XCTAssertNotNil(logger.messages.first { $0.text.contains("(empty body)") })
        XCTAssertNil(logger.messages.first { $0.text.contains("Testing") })
    }

    // MARK: onError

    /// Test that the logging policy logs the error's localized description when an error object is present
    func test_LoggingPolicy_OnError_LogsErrorDescriptionAtWarningLevel() {
        let policy = LoggingPolicy()
        let logger = TestClientLogger(.info)
        let headers = HTTPHeaders([.clientRequestId: "123"])
        let req = PipelineRequest(method: .get, url: "http://www.example.com", headers: headers)
        let res = PipelineResponse(request: req, logger: logger)
        let innerError = AzureError.client("Inner Error", nil)
        let error = AzureError.client("Test Error", innerError)
        policy.on(error: error, pipelineResponse: res) { _, _ in }
        LoggingPolicy.queue.sync {}
        let msg = logger.messages
            .first { $0.text == "Test Error: (Inner Error (AzureCore.AzureError.client))" }
        XCTAssertNotNil(msg)
        XCTAssertEqual(msg?.level, .warning)
    }

    // MARK: CurlFormattedRequestLoggingPolicy

    /// Test that the cURL-formatted logging policy only logs at debug level
    func test_CurlFormattedRequestLoggingPolicy_OnRequest_LogsNothingAtInfoLevel() {
        let policy = CurlFormattedRequestLoggingPolicy()
        let logger = TestClientLogger(.info)
        let req = PipelineRequest(method: .get, url: "http://www.example.com", logger: logger)
        policy.on(request: req) { _, _ in }
        LoggingPolicy.queue.sync {}
        XCTAssertEqual(logger.messages.count, 0)
    }

    /// Test that the cURL-formatted logging policy does not redact headers or query string params
    func test_CurlFormattedRequestLoggingPolicy_OnRequest_LogsAllHeadersAndQueryStringParams() {
        let policy = CurlFormattedRequestLoggingPolicy()
        let logger = TestClientLogger(.debug)
        let headers = HTTPHeaders([.custom("TestHeader"): "123"])
        let req = PipelineRequest(method: .get, url: "http://www.example.com?foo=bar", headers: headers, logger: logger)
        policy.on(request: req) { _, _ in }
        LoggingPolicy.queue.sync {}
        let msg = logger.messages[1]
        XCTAssert(msg.text.contains("http://www.example.com?foo=bar"))
        XCTAssert(msg.text.contains("-H \"TestHeader: 123\""))
    }

    /// Test that the cURL-formatted logging policy includes the method
    func test_CurlFormattedRequestLoggingPolicy_OnRequest_LogsMethod() {
        let policy = CurlFormattedRequestLoggingPolicy()
        let logger = TestClientLogger(.debug)
        let req = PipelineRequest(method: .get, url: "http://www.example.com", logger: logger)
        policy.on(request: req) { _, _ in }
        LoggingPolicy.queue.sync {}
        let msg = logger.messages[1]
        XCTAssert(msg.text.contains("-X GET"))
    }

    /// Test that the cURL-formatted logging policy escapes quote marks in header values
    func test_CurlFormattedRequestLoggingPolicy_OnRequest_EscapesQuoteMarksInHeaderValues() {
        let policy = CurlFormattedRequestLoggingPolicy()
        let logger = TestClientLogger(.debug)
        let headers = HTTPHeaders([.custom("TestHeader"): "\"123\""])
        let req = PipelineRequest(method: .get, url: "http://www.example.com", headers: headers, logger: logger)
        policy.on(request: req) { _, _ in }
        LoggingPolicy.queue.sync {}
        let msg = logger.messages[1]
        XCTAssert(msg.text.contains("-H \"TestHeader: \\\"123\\\"\""))
    }

    /// Test that the cURL-formatted logging policy escapes backslashes in header values
    func test_CurlFormattedRequestLoggingPolicy_OnRequest_EscapesBackslashesInHeaderValues() {
        let policy = CurlFormattedRequestLoggingPolicy()
        let logger = TestClientLogger(.debug)
        let headers = HTTPHeaders([.custom("TestHeader"): "C:\\Windows"])
        let req = PipelineRequest(method: .get, url: "http://www.example.com", headers: headers, logger: logger)
        policy.on(request: req) { _, _ in }
        LoggingPolicy.queue.sync {}
        let msg = logger.messages[1]
        XCTAssert(msg.text.contains("-H \"TestHeader: C:\\\\Windows\""))
    }

    /// Test that the cURL-formatted logging policy escapes single quotes in the body
    func test_CurlFormattedRequestLoggingPolicy_OnRequest_EscapesSingleQuotesInBody() {
        let policy = CurlFormattedRequestLoggingPolicy()
        let logger = TestClientLogger(.debug)
        let body = "'Testing'"
        let req = PipelineRequest(method: .get, url: "http://www.example.com", body: body, logger: logger)
        policy.on(request: req) { _, _ in }
        LoggingPolicy.queue.sync {}
        let msg = logger.messages[1]
        XCTAssert(msg.text.contains("--data $'\\'Testing\\''"))
    }

    /// Test that the cURL-formatted logging policy escapes newlines in the body
    func test_CurlFormattedRequestLoggingPolicy_OnRequest_EscapesNewlinesInBody() {
        let policy = CurlFormattedRequestLoggingPolicy()
        let logger = TestClientLogger(.debug)
        let body = """
        Testing
        123
        """
        let req = PipelineRequest(method: .get, url: "http://www.example.com", body: body, logger: logger)
        policy.on(request: req) { _, _ in }
        LoggingPolicy.queue.sync {}
        let msg = logger.messages[1]
        XCTAssert(msg.text.contains("--data $'Testing\\n123'"))
    }

    /// Test that the cURL-formatted logging policy flags compressed requests when the accept encoding is not identity
    func test_CurlFormattedRequestLoggingPolicy_OnRequestWithAcceptEncoding_AddsCompressedFlag() {
        let policy = CurlFormattedRequestLoggingPolicy()
        let logger = TestClientLogger(.debug)
        let headers = HTTPHeaders([.acceptEncoding: "gzip"])
        let req = PipelineRequest(method: .get, url: "http://www.example.com", headers: headers, logger: logger)
        policy.on(request: req) { _, _ in }
        LoggingPolicy.queue.sync {}
        let msg = logger.messages[1]
        XCTAssert(msg.text.contains("--compressed"))
    }

    /// Test that the cURL-formatted logging policy omits the compressed flag requests when the accept encoding is
    /// identity
    func test_CurlFormattedRequestLoggingPolicy_OnRequestWithIdentityAcceptEncoding_OmitsCompressedFlag() {
        let policy = CurlFormattedRequestLoggingPolicy()
        let logger = TestClientLogger(.debug)
        let headers = HTTPHeaders([.acceptEncoding: "identity"])
        let req = PipelineRequest(method: .get, url: "http://www.example.com", headers: headers, logger: logger)
        policy.on(request: req) { _, _ in }
        LoggingPolicy.queue.sync {}
        let msg = logger.messages[1]
        XCTAssertFalse(msg.text.contains("--compressed"))
    }
}
