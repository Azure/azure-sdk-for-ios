//
//  LoggingPolicy.swift
//  AzureCore
//
//  Created by Brandon Siegel on 10/2/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

public class DefaultLoggingPolicy: PipelineStageProtocol {

    public var next: PipelineStageProtocol?
    private lazy var attachmentRegex = NSRegularExpression("attachment; ?filename=([\"\\w.]+)",
                                                           options: .caseInsensitive)

    public func onRequest(_ request: inout PipelineRequest) {
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
    }

    public func onResponse(_ response: inout PipelineResponse) {
        logResponse(response.httpResponse, fromRequest: response.httpRequest, logger: response.logger)
    }

    public func onError(_ error: PipelineError) -> Bool {
        let logger = error.pipelineResponse.logger
        let request = error.pipelineResponse.httpRequest

        logger.error("Error performing \(request.httpMethod.rawValue) \(request.url)")
        logger.error(error.innerError.localizedDescription)

        logResponse(error.pipelineResponse.httpResponse, fromRequest: request, logger: logger)
        return false
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

    public func onRequest(_ request: inout PipelineRequest) {
        let logger = request.logger
        guard logger.level.rawValue >= ClientLogLevel.debug.rawValue else { return }

        let req = request.httpRequest
        var compressed = false
        var parts = ["curl"]
        parts += ["-X", req.httpMethod.rawValue]
        for (header, value) in req.headers {
            var escapedValue = value
            if value.first == "\"" && value.last == "\"" {
                escapedValue = "\\\"" + value.trimmingCharacters(in: ["\""]) + "\\\""
            }

            if header == HttpHeader.acceptEncoding.rawValue && value.caseInsensitiveCompare("gzip") == .orderedSame {
                compressed = true
            }

            parts += ["-H", "\"\(header): \(escapedValue)\""]
        }
        if let bodyText = req.text() {
            parts += ["--data", "$'\(bodyText.replacingOccurrences(of: "\n", with: "\\n"))'"]
        }
        if compressed {
            parts.append("--compressed")
        }
        parts.append(req.url)

        logger.debug("╭--- cURL (\(req.url))")
        logger.debug(parts.joined(separator: " "))
        logger.debug("╰--- (copy and paste the above line to a terminal)")
    }
}
