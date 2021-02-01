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

public class HTTPResponse: DataStringConvertible {
    // MARK: Properties

    public var httpRequest: HTTPRequest?
    public var statusCode: Int?
    public var headers = HTTPHeaders()
    public var data: Data?

    // Pulled from the IANA HTTP Status Code Registry on 28 Jan 2020
    // http://www.iana.org/assignments/http-status-codes/http-status-codes-1.csv
    public var statusMessage: String? {
        guard let status = statusCode else { return nil }
        switch status {
        case 100:
            return "Continue"
        case 101:
            return "Switching Protocols"
        case 102:
            return "Processing"
        case 103:
            return "Early Hints"
        case 200:
            return "OK"
        case 201:
            return "Created"
        case 202:
            return "Accepted"
        case 203:
            return "Non-Authoritative Information"
        case 204:
            return "No Content"
        case 205:
            return "Reset Content"
        case 206:
            return "Partial Content"
        case 207:
            return "Multi-Status"
        case 208:
            return "Already Reported"
        case 226:
            return "IM Used"
        case 300:
            return "Multiple Choices"
        case 301:
            return "Moved Permanently"
        case 302:
            return "Found"
        case 303:
            return "See Other"
        case 304:
            return "Not Modified"
        case 305:
            return "Use Proxy"
        case 306:
            return "(Unused)"
        case 307:
            return "Temporary Redirect"
        case 308:
            return "Permanent Redirect"
        case 400:
            return "Bad Request"
        case 401:
            return "Unauthorized"
        case 402:
            return "Payment Required"
        case 403:
            return "Forbidden"
        case 404:
            return "Not Found"
        case 405:
            return "Method Not Allowed"
        case 406:
            return "Not Acceptable"
        case 407:
            return "Proxy Authentication Required"
        case 408:
            return "Request Timeout"
        case 409:
            return "Conflict"
        case 410:
            return "Gone"
        case 411:
            return "Length Required"
        case 412:
            return "Precondition Failed"
        case 413:
            return "Payload Too Large"
        case 414:
            return "URI Too Long"
        case 415:
            return "Unsupported Media Type"
        case 416:
            return "Range Not Satisfiable"
        case 417:
            return "Expectation Failed"
        case 421:
            return "Misdirected Request"
        case 422:
            return "Unprocessable Entity"
        case 423:
            return "Locked"
        case 424:
            return "Failed Dependency"
        case 425:
            return "Too Early"
        case 426:
            return "Upgrade Required"
        case 428:
            return "Precondition Required"
        case 429:
            return "Too Many Requests"
        case 431:
            return "Request Header Fields Too Large"
        case 451:
            return "Unavailable For Legal Reasons"
        case 500:
            return "Internal Server Error"
        case 501:
            return "Not Implemented"
        case 502:
            return "Bad Gateway"
        case 503:
            return "Service Unavailable"
        case 504:
            return "Gateway Timeout"
        case 505:
            return "HTTP Version Not Supported"
        case 506:
            return "Variant Also Negotiates"
        case 507:
            return "Insufficient Storage"
        case 508:
            return "Loop Detected"
        case 510:
            return "Not Extended"
        case 511:
            return "Network Authentication Required"
        default:
            return "(Unassigned)"
        }
    }

    public var contentTypes: [String]? {
        guard let contentTypes = headers["Content-Type"]?.components(separatedBy: ";") else { return nil }
        return contentTypes.map { $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) }
    }

    // MARK: Initializers

    public init(request: HTTPRequest?, statusCode: Int?) {
        self.httpRequest = request
        self.statusCode = statusCode
    }
}
