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
    public var next: PipelineStageProtocol?
    private lazy var attachmentRegex = NSRegularExpression("attachment; ?filename=([\"\\w.]+)",
                                                           options: .caseInsensitive)
    public init() {}

    public func onRequest(_ request: PipelineRequest, then completion: @escaping OnRequestCompletionHandler) {
        let logger = request.logger
        let req = request.httpRequest
        logger.info("Request: \(req.httpMethod.rawValue) \(req.url)")

        guard logger.level.rawValue >= ClientLogLevel.debug.rawValue else { return }
        logger.debug("Request headers:")
        for (header, value) in req.headers {
            if header == HttpHeader.authorization.rawValue {
                logger.debug("    \(header): *****")
            } else {
                logger.debug("    \(header): \(value)")
            }
        }
        if let bodyText = humanReadable(body: req.text(), headers: req.headers) {
            logger.debug("Request body:")
            logger.debug(bodyText)
        }
        completion(request)
    }

    public func onResponse(_ response: PipelineResponse, then completion: @escaping OnResponseCompletionHandler) {
        logResponse(response.httpResponse, fromRequest: response.httpRequest, logger: response.logger)
        completion(response)
    }

    public func onError(_ error: PipelineError, then completion: @escaping OnErrorCompletionHandler) {
        let logger = error.pipelineResponse.logger
        let request = error.pipelineResponse.httpRequest

        logger.error("Error performing \(request.httpMethod.rawValue) \(request.url)")
        logger.error(error.innerError.localizedDescription)

        logResponse(error.pipelineResponse.httpResponse, fromRequest: request, logger: logger)
        completion(error, false)
    }

    private func logResponse(_ res: HttpResponse?, fromRequest req: HttpRequest, logger: ClientLogger) {
        guard let res = res, let statusCode = res.statusCode else {
            logger.warning("No response data available from \(req.httpMethod.rawValue) \(req.url)")
            return
        }

        logger.info("Response: \(statusCode) from \(req.httpMethod.rawValue) \(req.url)")

        guard logger.level.rawValue >= ClientLogLevel.debug.rawValue else { return }
        logger.debug("Response headers:")
        for (header, value) in res.headers {
            logger.debug("    \(header): \(value)")
        }
        if let bodyText = humanReadable(body: res.text(), headers: res.headers) {
            logger.debug("Response content:")
            logger.debug(bodyText)
        }
    }

    private func humanReadable(body bodyFunc: @autoclosure () -> String?, headers: HttpHeaders) -> String? {
        if let fileName = filename(fromHeader: headers[.contentDisposition]) {
            return "File attachments: \(fileName)"
        }

        if let contentType = headers[.contentType] {
            if contentType.lowercased().hasSuffix("octet-stream") {
                return "Body contains binary data."
            } else if contentType.lowercased().hasPrefix("image") {
                return "Body contains image data."
            }
        }
        return bodyFunc()
    }

    private func filename(fromHeader header: String?) -> Substring? {
        guard let header = header else { return nil }
        guard let match = attachmentRegex.firstMatch(in: header) else { return nil }
        let captures = match.capturedValues(from: header)
        if captures.count > 1 {
            return captures[1]
        } else {
            return nil
        }
    }
}

public class CurlFormattedRequestLoggingPolicy: PipelineStageProtocol {
    public var next: PipelineStageProtocol?

    public init() {}

    public func onRequest(_ request: PipelineRequest, then completion: @escaping OnRequestCompletionHandler) {
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

            if header == HttpHeader.acceptEncoding.rawValue {
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
