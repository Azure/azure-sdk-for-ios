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
    private let log: PipelineLogger
    private lazy var attachmentRegex = NSRegularExpression("attachment; ?filename=([\"\\w.]+)",
                                                           options: .caseInsensitive)

    public init(logger: PipelineLogger? = nil) {
        if let logger = logger {
            self.log = logger
        } else if #available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *) {
            self.log = PipelineOSLogAdapter()
        } else {
            self.log = PipelineNSLogger()
        }
    }

    public func onRequest(_ request: inout PipelineRequest) {
        let req = request.httpRequest
        log.debug("Request URL: \(req.url)")
        log.debug("Request method: \(req.httpMethod.rawValue)")
        log.debug("Request headers:")
        for (header, value) in req.headers {
            if header == HttpHeader.authorization.rawValue {
                log.debug("    \(header): *****")
            } else {
                log.debug("    \(header): \(value)")
            }
        }
        if let bodyText = humanReadable(body: req.text(), headers: req.headers) {
            log.debug("Request body:")
            log.debug(bodyText)
        }
    }

    public func onResponse(_ response: inout PipelineResponse) {
        guard let res = response.httpResponse else {
            log.debug("Failed to log response")
            return
        }

        if let statusCode = res.statusCode {
            log.debug("Response status: \(statusCode)")
        }
        log.debug("Response headers:")
        for (header, value) in res.headers {
            log.debug("    \(header): \(value)")
        }
        if let bodyText = humanReadable(body: res.text(), headers: res.headers) {
            log.debug("Response content:")
            log.debug(bodyText)
        }
    }

    public func onError(_ error: Error) -> Bool {
        log.error(error.localizedDescription)
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
        return bodyText(.utf8) ?? "(empty)"
    }

    private func filenameFrom(header: String?) -> Substring? {
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
    private let log: PipelineLogger

    public init(logger: PipelineLogger? = nil) {
        if let logger = logger {
            self.log = logger
        } else if #available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *) {
            self.log = PipelineOSLogAdapter()
        } else {
            self.log = PipelineNSLogger()
        }
    }

    public func onRequest(_ request: inout PipelineRequest) {
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

        log.debug("╭--- cURL (\(req.url))")
        log.debug(parts.joined(separator: " "))
        log.debug("╰--- (copy and paste the above line to a terminal)")
    }
}
