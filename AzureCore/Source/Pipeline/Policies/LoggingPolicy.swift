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
        guard logger.level.rawValue >= ClientLogLevel.debug.rawValue else { return }

        let req = request.httpRequest
        logger.debug("Request URL: \(req.url)")
        logger.debug("Request method: \(req.httpMethod.rawValue)")
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
        let logger = response.logger
        guard logger.level.rawValue >= ClientLogLevel.debug.rawValue else { return }

        guard let res = response.httpResponse else {
            logger.debug("Failed to log response")
            return
        }

        if let statusCode = res.statusCode {
            logger.debug("Response status: \(statusCode)")
        }
        logger.debug("Response headers:")
        for (header, value) in res.headers {
            logger.debug("    \(header): \(value)")
        }
        if let bodyText = humanReadable(body: res.text(), headers: res.headers) {
            logger.debug("Response content:")
            logger.debug(bodyText)
        }
    }

    public func onError(_ error: PipelineError) -> Bool {
        let logger = error.pipelineResponse.logger
        let err = error.innerError
        let request = error.pipelineResponse.httpRequest

        logger.error("Error performing \(request.httpMethod.rawValue) to \(request.url)")
        logger.error(err.localizedDescription)

        guard logger.level.rawValue >= ClientLogLevel.info.rawValue else { return false }
        guard let response = error.pipelineResponse.httpResponse else {
            logger.info("No response data available")
            return false
        }

        if let statusCode = response.statusCode {
            logger.info("Response status: \(statusCode)")
        }
        if let bodyText = humanReadable(body: response.text(), headers: response.headers) {
            logger.info("Response content:")
            logger.info(bodyText)
        }
        return false
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
