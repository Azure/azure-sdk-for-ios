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

import Foundation

public class LoggingPolicy: PipelineStageProtocol {

    // MARK: Properties

    public static let defaultAllowHeaders: [String] = [
        HTTPHeader.traceparent.rawValue,
        HTTPHeader.accept.rawValue,
        HTTPHeader.cacheControl.rawValue,
        HTTPHeader.clientRequestId.rawValue,
        HTTPHeader.connection.rawValue,
        HTTPHeader.contentLength.rawValue,
        HTTPHeader.contentType.rawValue,
        HTTPHeader.date.rawValue,
        HTTPHeader.etag.rawValue,
        HTTPHeader.expires.rawValue,
        HTTPHeader.ifMatch.rawValue,
        HTTPHeader.ifModifiedSince.rawValue,
        HTTPHeader.ifNoneMatch.rawValue,
        HTTPHeader.ifUnmodifiedSince.rawValue,
        HTTPHeader.lastModified.rawValue,
        HTTPHeader.pragma.rawValue,
        HTTPHeader.requestId.rawValue,
        HTTPHeader.retryAfter.rawValue,
        HTTPHeader.returnClientRequestId.rawValue,
        HTTPHeader.server.rawValue,
        HTTPHeader.transferEncoding.rawValue,
        HTTPHeader.userAgent.rawValue
    ]
    private static let maxBodyLogSize = 1024 * 16

    public var next: PipelineStageProtocol?
    private let allowHeaders: Set<String>
    private let allowQueryParams: Set<String>

    // MARK: Initializers

    public init(allowHeaders: [String] = LoggingPolicy.defaultAllowHeaders, allowQueryParams: [String] = []) {
        self.allowHeaders = Set(allowHeaders.map { $0.lowercased() })
        self.allowQueryParams = Set(allowQueryParams.map { $0.lowercased() })
    }

    // MARK: Public Methods

    public func on(request: PipelineRequest, then completion: @escaping OnRequestCompletionHandler) {
        var returnRequest = request.copy()
        defer { completion(returnRequest) }
        let logger = request.logger
        let req = request.httpRequest
        let requestId = req.headers[.clientRequestId] ?? "(none)"
        guard
            let safeUrl = self.redact(url: req.url),
            let host = safeUrl.host
        else {
            logger.warning("Failed to parse URL for request \(requestId)")
            return
        }

        var fullPath = safeUrl.path
        if let query = safeUrl.query {
            fullPath += "?\(query)"
        }
        if let fragment = safeUrl.fragment {
            fullPath += "#\(fragment)"
        }

        logger.info("--> [\(requestId)]")
        logger.info("\(req.httpMethod.rawValue) \(fullPath)")
        logger.info("Host: \(host)")

        if logger.level.rawValue >= ClientLogLevel.debug.rawValue {
            logDebug(body: req.text(), headers: req.headers, logger: logger)
        }

        logger.info("--> [END \(requestId)]")

        returnRequest.add(value: DispatchTime.now() as AnyObject, forKey: .requestStartTime)
    }

    public func on(response: PipelineResponse, then completion: @escaping OnResponseCompletionHandler) {
        logResponse(response)
        completion(response)
    }

    public func on(error: PipelineError, then completion: @escaping OnErrorCompletionHandler) {
        logResponse(error.pipelineResponse, withError: error.innerError)
        completion(error, false)
    }

    // MARK: Private Methods

    private func logResponse(_ response: PipelineResponse, withError error: Error? = nil) {
        let endTime = DispatchTime.now()
        var durationMs: Double?
        if let startTime = response.value(forKey: .requestStartTime) as? DispatchTime {
            durationMs = Double(endTime.uptimeNanoseconds - startTime.uptimeNanoseconds) / 1_000_000
        }

        let logger = response.logger
        let req = response.httpRequest
        let requestId = req.headers[.clientRequestId] ?? "(none)"

        if let durationMs = durationMs {
            logger.info("<-- [\(requestId)] (\(durationMs)ms)")
        } else {
            logger.info("<-- [\(requestId)]")
        }

        if let error = error {
            logger.warning(error.localizedDescription)
        }

        guard
            let res = response.httpResponse,
            let statusCode = res.statusCode
        else {
            logger.warning("No response data available")
            logger.info("<-- [END \(requestId)]")
            return
        }

        let statusCodeString = HTTPURLResponse.localizedString(forStatusCode: statusCode)
        if statusCode >= 400 {
            logger.warning("\(statusCode) \(statusCodeString)")
        } else {
            logger.info("\(statusCode) \(statusCodeString)")
        }

        if logger.level.rawValue >= ClientLogLevel.debug.rawValue {
            logDebug(body: res.text(), headers: res.headers, logger: logger)
        }

        logger.info("<-- [END \(requestId)]")
    }

    private func logDebug(body bodyFunc: @autoclosure () -> String?, headers: HTTPHeaders, logger: ClientLoggerProtocol) {
        let safeHeaders = self.redact(headers: headers)
        for (header, value) in safeHeaders {
            logger.debug("\(header): \(value)")
        }

        let bodyText = self.humanReadable(body: bodyFunc, headers: headers)
        logger.debug("\n\(bodyText)")
    }

    private func humanReadable(body bodyFunc: () -> String?, headers: HTTPHeaders) -> String {
        if
            let encoding = headers[.contentEncoding],
            encoding != "" && encoding.caseInsensitiveCompare("identity") != .orderedSame {
            return "(encoded body omitted)"
        }

        if
            let disposition = headers[.contentDisposition],
            disposition != "" && disposition.caseInsensitiveCompare("inline") != .orderedSame {
            return "(non-inline body omitted)"
        }

        if
            let contentType = headers[.contentType],
            contentType.lowercased().hasSuffix("octet-stream") || contentType.lowercased().hasPrefix("image") {
            return "(binary body omitted)"
        }

        let length = contentLength(from: headers)
        if length > LoggingPolicy.maxBodyLogSize {
            return "(\(length)-byte body omitted)"
        }

        if length > 0 {
            if let text = bodyFunc(), text != "" {
                return text
            }
        }
        return "(empty body)"
    }

    private func redact(url: String) -> URLComponents? {
        guard var urlComps = URLComponents(string: url) else { return nil }
        guard let queryItems = urlComps.queryItems else { return urlComps }

        var redactedQueryItems = [URLQueryItem]()
        for query in queryItems {
            if !self.allowQueryParams.contains(query.name.lowercased()) {
                redactedQueryItems.append(URLQueryItem(name: query.name, value: "REDACTED"))
            } else {
                redactedQueryItems.append(query)
            }
        }

        urlComps.queryItems = redactedQueryItems
        return urlComps
    }

    private func redact(headers: HTTPHeaders) -> HTTPHeaders {
        var copy = headers
        for header in copy.keys {
            if !self.allowHeaders.contains(header.lowercased()) {
                copy.updateValue("REDACTED", forKey: header)
            }
        }
        return copy
    }

    private func contentLength(from headers: HTTPHeaders) -> Int {
        guard let length = headers[.contentLength] else { return 0 }
        guard let parsed = Int(length) else { return 0 }
        return parsed
    }
}

public class CurlFormattedRequestLoggingPolicy: PipelineStageProtocol {

    // MARK: Properties

    public var next: PipelineStageProtocol?

    // MARK: Initializers

    public init() {}

    // MARK: Public Methods

    public func on(request: PipelineRequest, then completion: @escaping OnRequestCompletionHandler) {
        let logger = request.logger
        guard logger.level.rawValue >= ClientLogLevel.debug.rawValue else { return }

        let req = request.httpRequest
        var compressed = false
        var parts = ["curl"]
        parts += ["-X", req.httpMethod.rawValue]
        for (header, value) in req.headers {
            var escapedValue: String
            if value.first == "\"" && value.last == "\"" {
                // Escape the surrounding quote marks and literal backslashes
                var innerValue = value.trimmingCharacters(in: ["\""])
                innerValue = innerValue.replacingOccurrences(of: "\\", with: "\\\\")
                escapedValue = "\\\"\(innerValue)\\\""
            } else {
                // Only escape literal backslashes
                escapedValue = value.replacingOccurrences(of: "\\", with: "\\\\")
            }

            if header == HTTPHeader.acceptEncoding.rawValue {
                compressed = true
            }

            parts += ["-H", "\"\(header): \(escapedValue)\""]
        }
        if var bodyText = req.text() {
            // Escape literal newlines and single quotes in the body
            bodyText = bodyText.replacingOccurrences(of: "\n", with: "\\n")
            bodyText = bodyText.replacingOccurrences(of: "'", with: "\\'")
            parts += ["--data", "$'\(bodyText)'"]
        }
        if compressed {
            parts.append("--compressed")
        }
        parts.append(req.url)

        logger.debug("╭--- cURL (\(req.url))")
        logger.debug(parts.joined(separator: " "))
        logger.debug("╰--- (copy and paste the above line to a terminal)")
        completion(request)
    }
}
