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

// swiftlint:disable function_body_length type_body_length cyclomatic_complexity

/// Type alias for HTTP header dictionary
public typealias HTTPHeaders = [String: String]
/// Extensions to work with `HTTPHeader` values within a collection of `HTTPHeaders`.

/// Common HTTP headers.
public enum HTTPHeader: RequestStringConvertible, Equatable, Hashable {
    /// Use when the header value you want is not in the list.
    case custom(String)
    /// Accept
    case accept
    /// Accept-Charset
    case acceptCharset
    /// Accept-Encoding
    case acceptEncoding
    /// Accept-Language
    case acceptLanguage
    /// Accept-Ranges
    case acceptRanges
    /// Access-Control-Allow-Origin
    case accessControlAllowOrigin
    /// Age
    case age
    /// Allow
    case allow
    /// x-ms-version
    case apiVersion
    /// Authorization
    case authorization
    /// Cache-Control
    case cacheControl
    /// x-ms-client-request-id
    case clientRequestId
    /// Connection
    case connection
    /// Content-Disposition
    case contentDisposition
    /// Content-Encoding
    case contentEncoding
    /// Content-Language
    case contentLanguage
    /// Content-Length
    case contentLength
    /// Content-Location
    case contentLocation
    /// Content-MD5
    case contentMD5
    /// Content-Range
    case contentRange
    /// Content-Type
    case contentType
    /// Date
    case date
    /// x-ms-date
    case xmsDate
    /// Etag
    case etag
    /// Expect
    case expect
    /// Expires
    case expires
    /// From
    case from
    /// Host
    case host
    /// If-Match
    case ifMatch
    /// If-Modified-Since
    case ifModifiedSince
    /// If-None-Match
    case ifNoneMatch
    /// If-Unmodified-Since
    case ifUnmodifiedSince
    /// Last-Modified
    case lastModified
    /// Location
    case location
    /// Pragma
    case pragma
    /// Range
    case range
    /// Referer
    case referer
    /// Request-Id
    case requestId
    /// Retry-After
    case retryAfter
    /// x-ms-return-client-request-id
    case returnClientRequestId
    /// Server
    case server
    /// Slug
    case slug
    /// traceparent
    case traceparent
    /// Trailer
    case trailer
    /// Transfer-Encoding
    case transferEncoding
    /// User-Agent
    case userAgent
    /// Vary
    case vary
    /// Via
    case via
    /// Warning
    case warning
    /// WWW-Authenticate
    case wwwAuthenticate

    public var requestString: String {
        switch self {
        case let .custom(val):
            return val
        case .accept:
            return "Accept"
        case .acceptCharset:
            return "Accept-Charset"
        case .acceptEncoding:
            return "Accept-Encoding"
        case .acceptLanguage:
            return "Accept-Language"
        case .acceptRanges:
            return "Accept-Ranges"
        case .accessControlAllowOrigin:
            return "Access-Control-Allow-Origin"
        case .age:
            return "Age"
        case .allow:
            return "Allow"
        case .apiVersion:
            return "x-ms-version"
        case .authorization:
            return "Authorization"
        case .cacheControl:
            return "Cache-Control"
        case .clientRequestId:
            return "x-ms-client-request-id"
        case .connection:
            return "Connection"
        case .contentDisposition:
            return "Content-Disposition"
        case .contentEncoding:
            return "Content-Encoding"
        case .contentLanguage:
            return "Content-Language"
        case .contentLength:
            return "Content-Length"
        case .contentLocation:
            return "Content-Location"
        case .contentMD5:
            return "Content-MD5"
        case .contentRange:
            return "Content-Range"
        case .contentType:
            return "Content-Type"
        case .date:
            return "Date"
        case .xmsDate:
            return "x-ms-date"
        case .etag:
            return "Etag"
        case .expect:
            return "Expect"
        case .expires:
            return "Expires"
        case .from:
            return "From"
        case .host:
            return "Host"
        case .ifMatch:
            return "If-Match"
        case .ifModifiedSince:
            return "If-Modified-Since"
        case .ifNoneMatch:
            return "If-None-Match"
        case .ifUnmodifiedSince:
            return "If-Unmodified-Since"
        case .lastModified:
            return "Last-Modified"
        case .location:
            return "Location"
        case .pragma:
            return "Pragma"
        case .range:
            return "Range"
        case .referer:
            return "Referer"
        case .requestId:
            return "Request-Id"
        case .retryAfter:
            return "Retry-After"
        case .returnClientRequestId:
            return "x-ms-return-client-request-id"
        case .server:
            return "Server"
        case .slug:
            return "Slug"
        case .traceparent:
            return "traceparent"
        case .trailer:
            return "Trailer"
        case .transferEncoding:
            return "Transfer-Encoding"
        case .userAgent:
            return "User-Agent"
        case .vary:
            return "Vary"
        case .via:
            return "Via"
        case .warning:
            return "Warning"
        case .wwwAuthenticate:
            return "WWW-Authenticate"
        }
    }

    public init(_ val: String) {
        switch val.lowercased() {
        case "accept":
            self = .accept
        case "accept-charset":
            self = .acceptCharset
        case "accept-encoding":
            self = .acceptEncoding
        case "accept-language":
            self = .acceptLanguage
        case "accept-ranges":
            self = .acceptRanges
        case "access-control-allow-origin":
            self = .accessControlAllowOrigin
        case "age":
            self = .age
        case "allow":
            self = .allow
        case "x-ms-version":
            self = .apiVersion
        case "authorization":
            self = .authorization
        case "cache-control":
            self = .cacheControl
        case "x-ms-client-request-id":
            self = .clientRequestId
        case "connection":
            self = .connection
        case "content-disposition":
            self = .contentDisposition
        case "content-encoding":
            self = .contentEncoding
        case "content-language":
            self = .contentLanguage
        case "content-length":
            self = .contentLength
        case "content-location":
            self = .contentLocation
        case "content-md5":
            self = .contentMD5
        case "content-range":
            self = .contentRange
        case "content-type":
            self = .contentType
        case "date":
            self = .date
        case "x-ms-date":
            self = .xmsDate
        case "etag":
            self = .etag
        case "expect":
            self = .expect
        case "expires":
            self = .expires
        case "from":
            self = .from
        case "host":
            self = .host
        case "if-match":
            self = .ifMatch
        case "if-modified-since":
            self = .ifModifiedSince
        case "if-none-match":
            self = .ifNoneMatch
        case "if-unmodified-since":
            self = .ifUnmodifiedSince
        case "last-modified":
            self = .lastModified
        case "location":
            self = .location
        case "pragma":
            self = .pragma
        case "range":
            self = .range
        case "referer":
            self = .referer
        case "request-id":
            self = .requestId
        case "retry-after":
            self = .retryAfter
        case "x-ms-return-client-request-id":
            self = .returnClientRequestId
        case "server":
            self = .server
        case "slug":
            self = .slug
        case "traceparent":
            self = .traceparent
        case "trailer":
            self = .trailer
        case "transfer-encoding":
            self = .transferEncoding
        case "user-agent":
            self = .userAgent
        case "vary":
            self = .vary
        case "via":
            self = .via
        case "warning":
            self = .warning
        case "www-authenticate":
            self = .wwwAuthenticate
        default:
            self = .custom(val)
        }
    }
}

public extension HTTPHeaders {
    /// Access the value of an `HTTPHeader` within a collection of `HTTPHeaders`.
    /// - Parameters:
    ///   - index: The `HTTPHeader` value to access.
    subscript(index: HTTPHeader) -> String? {
        get {
            return self[index.requestString]
        }

        set(newValue) {
            self[index.requestString] = newValue
        }
    }

    /// Remove an `HTTPHeader` value from a collection of `HTTPHeaders`.
    /// - Parameters:
    ///   - index: The `HTTPHeader` value to remove.
    mutating func removeValue(forKey key: HTTPHeader) -> Value? {
        return removeValue(forKey: key.requestString)
    }
}
