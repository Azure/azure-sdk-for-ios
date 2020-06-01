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

/// A dictionary of `HTTPHeader` values.
public typealias HTTPHeaders = [String: String]

/// Common HTTP headers.
public enum HTTPHeader: String {
    /// Accept
    case accept = "Accept"
    /// Accept-Charset
    case acceptCharset = "Accept-Charset"
    /// Accept-Encoding
    case acceptEncoding = "Accept-Encoding"
    /// Accept-Language
    case acceptLanguage = "Accept-Language"
    /// Accept-Ranges
    case acceptRanges = "Accept-Ranges"
    /// Access-Control-Allow-Origin
    case accessControlAllowOrigin = "Access-Control-Allow-Origin"
    /// Age
    case age = "Age"
    /// Allow
    case allow = "Allow"
    /// x-ms-version
    case apiVersion = "x-ms-version"
    /// Authorization
    case authorization = "Authorization"
    /// Cache-Control
    case cacheControl = "Cache-Control"
    /// x-ms-client-request-id
    case clientRequestId = "x-ms-client-request-id"
    /// Connection
    case connection = "Connection"
    /// Content-Disposition
    case contentDisposition = "Content-Disposition"
    /// Content-Encoding
    case contentEncoding = "Content-Encoding"
    /// Content-Language
    case contentLanguage = "Content-Language"
    /// Content-Length
    case contentLength = "Content-Length"
    /// Content-Location
    case contentLocation = "Content-Location"
    /// Content-MD5
    case contentMD5 = "Content-MD5"
    /// Content-Range
    case contentRange = "Content-Range"
    /// Content-Type
    case contentType = "Content-Type"
    /// Date
    case date = "Date"
    /// x-ms-date
    case xmsDate = "x-ms-date"
    /// Etag
    case etag = "Etag"
    /// Expect
    case expect = "Expect"
    /// Expires
    case expires = "Expires"
    /// From
    case from = "From"
    /// Host
    case host = "Host"
    /// If-Match
    case ifMatch = "If-Match"
    /// If-Modified-Since
    case ifModifiedSince = "If-Modified-Since"
    /// If-None-Match
    case ifNoneMatch = "If-None-Match"
    /// If-Unmodified-Since
    case ifUnmodifiedSince = "If-Unmodified-Since"
    /// Last-Modified
    case lastModified = "Last-Modified"
    /// Location
    case location = "Location"
    /// Pragma
    case pragma = "Pragma"
    /// Range
    case range = "Range"
    /// Referer
    case referer = "Referer"
    /// Request-Id
    case requestId = "Request-Id"
    /// Retry-After
    case retryAfter = "Retry-After"
    /// x-ms-return-client-request-id
    case returnClientRequestId = "x-ms-return-client-request-id"
    /// Server
    case server = "Server"
    /// Slug
    case slug = "Slug"
    /// traceparent
    case traceparent = "traceparent"
    /// Trailer
    case trailer = "Trailer"
    /// Transfer-Encoding
    case transferEncoding = "Transfer-Encoding"
    /// User-Agent
    case userAgent = "User-Agent"
    /// Vary
    case vary = "Vary"
    /// Via
    case via = "Via"
    /// Warning
    case warning = "Warning"
    /// WWW-Authenticate
    case wwwAuthenticate = "WWW-Authenticate"
}

/// Extensions to work with `HTTPHeader` values within a collection of `HTTPHeaders`.
extension HTTPHeaders {
    /// Access the value of an `HTTPHeader` within a collection of `HTTPHeaders`.
    /// - Parameters:
    ///   - index: The `HTTPHeader` value to access.
    public subscript(index: HTTPHeader) -> String? {
        get {
            return self[index.rawValue]
        }

        set(newValue) {
            self[index.rawValue] = newValue
        }
    }

    /// Remove an `HTTPHeader` value from a collection of `HTTPHeaders`.
    /// - Parameters:
    ///   - index: The `HTTPHeader` value to remove.
    public mutating func removeValue(forKey key: HTTPHeader) -> Value? {
        return removeValue(forKey: key.rawValue)
    }

    /// Initialize a collection of `HTTPHeader` values.
    /// - Parameters:
    ///   - values: A dictionary of `HTTPHeader` values to populate the `HTTPHeaders` instance.
    public init(_ values: [HTTPHeader: String]) {
        self.init(minimumCapacity: values.underestimatedCount)
        for (key, value) in values {
            self[key.rawValue] = value
        }
    }

    public init(_ values: [String: String]) {
        self.init(minimumCapacity: values.underestimatedCount)
        for (key, value) in values {
            self[key] = value
        }
    }
}
