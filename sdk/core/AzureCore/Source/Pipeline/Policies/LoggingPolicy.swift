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

public class LoggingPolicy: PipelineStage {
    // MARK: Static Properties

    private static let defaultAllowHeadersEnum: [HTTPHeader] = [
        .accept,
        .cacheControl,
        .clientRequestId,
        .connection,
        .contentLength,
        .contentType,
        .date,
        .etag,
        .expires,
        .ifMatch,
        .ifModifiedSince,
        .ifNoneMatch,
        .ifUnmodifiedSince,
        .lastModified,
        .pragma,
        .requestId,
        .retryAfter,
        .returnClientRequestId,
        .server,
        .traceparent,
        .transferEncoding,
        .userAgent
    ]

    public static var defaultAllowHeaders: [String] {
        return LoggingPolicy.defaultAllowHeadersEnum.map { $0.requestString }
    }

    private static let maxBodyLogSize = 1024 * 16

    /// A serial queue used to execute logging, targeting a global queue in order to minimizing excess thread creation.
    static let queue = DispatchQueue(label: "AzureSDKLogging", target: DispatchQueue.global())

    // MARK: Properties

    public var next: PipelineStage?

    private let allowHeaders: Set<String>
    private let allowQueryParams: Set<String>

    // MARK: Initializers

    public init(allowHeaders: [String] = LoggingPolicy.defaultAllowHeaders, allowQueryParams: [String] = []) {
        self.allowHeaders = Set(allowHeaders.map { $0.lowercased() })
        self.allowQueryParams = Set(allowQueryParams.map { $0.lowercased() })
    }

    // MARK: PipelineStage Methods

    public func on(request: PipelineRequest, completionHandler: @escaping OnRequestCompletionHandler) {
        request.context?.add(value: DispatchTime.now() as AnyObject, forKey: .requestStartTime)
        request.context?.add(value: allowHeaders as AnyObject, forKey: .allowedHeaders)
        LoggingPolicy.queue.async { self.log(request: request) }
        completionHandler(request, nil)
    }

    public func on(response: PipelineResponse, completionHandler: @escaping OnResponseCompletionHandler) {
        LoggingPolicy.queue.async { self.log(response: response) }
        completionHandler(response, nil)
    }

    public func on(
        error: AzureError,
        pipelineResponse: PipelineResponse,
        completionHandler: @escaping OnErrorCompletionHandler
    ) {
        log(response: pipelineResponse, withError: error)
        completionHandler(error, false)
    }

    // MARK: Private Methods

    private func log(request: PipelineRequest) {
        let logger = request.logger
        let req = request.httpRequest
        let requestId = req.headers[.clientRequestId] ?? "(none)"
        guard let safeUrl = redact(url: req.url) else {
            logger.warning("Failed to parse URL for request \(requestId)")
            return
        }

        logger.info("--> [\(requestId)]")
        logger.info("\(req.httpMethod.rawValue) \(safeUrl)")

        if logger.level.rawValue >= ClientLogLevel.debug.rawValue {
            log(headers: req.headers, body: req.text(), withLogger: logger)
        }

        logger.info("--> [END \(requestId)]")
    }

    private func log(response: PipelineResponse, withError error: AzureError? = nil) {
        let endTime = DispatchTime.now()
        var duration: String?
        if let startTime = response.context?.value(forKey: .requestStartTime) as? DispatchTime {
            let durationMs = Double(endTime.uptimeNanoseconds - startTime.uptimeNanoseconds) / 1_000_000
            duration = String(format: "%.2f", durationMs)
        }

        let logger = response.logger
        let req = response.httpRequest
        let requestId = req.headers[.clientRequestId] ?? "(none)"

        if let duration = duration {
            logger.info("<-- [\(requestId)] (\(duration)ms)")
        } else {
            logger.info("<-- [\(requestId)]")
        }
        defer { logger.info("<-- [END \(requestId)]") }

        if let error = error {
            logger.warning(error.message)
        }

        guard
            let res = response.httpResponse,
            let statusCode = res.statusCode,
            let statusMessage = res.statusMessage
        else { return }

        if statusCode >= 400 {
            logger.warning("\(statusCode) \(statusMessage)")
        } else {
            logger.info("\(statusCode) \(statusMessage)")
        }

        if logger.level.rawValue >= ClientLogLevel.debug.rawValue {
            log(headers: res.headers, body: res.text(), withLogger: logger)
        }
    }

    private func log(
        headers: HTTPHeaders,
        body bodyFunc: @autoclosure () -> String?,
        withLogger logger: ClientLogger
    ) {
        let safeHeaders = redact(headers: headers)
        for (header, value) in safeHeaders {
            logger.debug("\(header.requestString): \(value)")
        }

        let bodyText = humanReadable(body: bodyFunc, headers: headers)
        logger.debug("\(bodyText)")
    }

    private func humanReadable(body bodyFunc: () -> String?, headers: HTTPHeaders) -> String {
        if
            let encoding = headers[.contentEncoding],
            encoding != "" && encoding.caseInsensitiveCompare("identity") != .orderedSame
        {
            return "(encoded body omitted)"
        }

        if
            let disposition = headers[.contentDisposition],
            disposition != "" && disposition.caseInsensitiveCompare("inline") != .orderedSame
        {
            return "(non-inline body omitted)"
        }

        if
            let contentType = headers[.contentType],
            contentType.lowercased().hasSuffix("octet-stream") || contentType.lowercased().hasPrefix("image")
        {
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

    private func redact(url: URL?) -> String? {
        guard let url = url else { return nil }
        guard var urlComps = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return nil }
        guard let queryItems = urlComps.queryItems else { return url.absoluteString }

        var redactedQueryItems = [URLQueryItem]()
        for query in queryItems {
            if !allowQueryParams.contains(query.name.lowercased()) {
                redactedQueryItems.append(URLQueryItem(name: query.name, value: "REDACTED"))
            } else {
                redactedQueryItems.append(query)
            }
        }
        urlComps.queryItems = redactedQueryItems
        return urlComps.string
    }

    private func redact(headers: HTTPHeaders) -> HTTPHeaders {
        var copy = headers
        for header in copy.keys {
            if !allowHeaders.contains(header.requestString.lowercased()) {
                copy[header] = "REDACTED"
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

public class CurlFormattedRequestLoggingPolicy: PipelineStage {
    // MARK: Properties

    public var next: PipelineStage?

    // MARK: Initializers

    public init() {}

    // MARK: PipelineStage Methods

    public func on(request: PipelineRequest, completionHandler: @escaping OnRequestCompletionHandler) {
        LoggingPolicy.queue.async { self.logAsCurlCommand(request: request) }
        completionHandler(request, nil)
    }

    private func logAsCurlCommand(request: PipelineRequest) {
        let logger = request.logger
        guard logger.level.rawValue >= ClientLogLevel.debug.rawValue else { return }

        let req = request.httpRequest
        var compressed = false
        var parts = ["curl"]
        parts += ["-X", req.httpMethod.rawValue]
        for (header, value) in req.headers {
            var escapedValue: String
            if value.first == "\"", value.last == "\"" {
                // Escape the surrounding quote marks and literal backslashes
                var innerValue = value.trimmingCharacters(in: ["\""])
                innerValue = innerValue.replacingOccurrences(of: "\\", with: "\\\\")
                escapedValue = "\\\"\(innerValue)\\\""
            } else {
                // Only escape literal backslashes
                escapedValue = value.replacingOccurrences(of: "\\", with: "\\\\")
            }

            if header.requestString == HTTPHeader.acceptEncoding.requestString,
               value.caseInsensitiveCompare("identity") != .orderedSame
            {
                compressed = true
            }

            parts += ["-H", "\"\(header.requestString): \(escapedValue)\""]
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
        parts.append(req.url.absoluteString)

        logger.debug("╭--- cURL (\(req.url))")
        logger.debug(parts.joined(separator: " "))
        logger.debug("╰--- (copy and paste the above line to a terminal)")
    }
}
