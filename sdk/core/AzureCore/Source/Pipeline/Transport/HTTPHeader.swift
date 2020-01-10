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

public typealias HTTPHeaders = [String: String]

public enum HTTPHeader: String {
    case accept = "Accept"
    case acceptCharset = "Accept-Charset"
    case acceptEncoding = "Accept-Encoding"
    case acceptLanguage = "Accept-Language"
    case acceptRanges = "Accept-Ranges"
    case age = "Age"
    case allow = "Allow"
    case apiVersion = "x-ms-version"
    case authorization = "Authorization"
    case cacheControl = "Cache-Control"
    case clientRequestId = "x-ms-client-request-id"
    case connection = "Connection"
    case contentDisposition = "Content-Disposition"
    case contentEncoding = "Content-Encoding"
    case contentLanguage = "Content-Language"
    case contentLength = "Content-Length"
    case contentLocation = "Content-Location"
    case contentRange = "Content-Range"
    case contentType = "Content-Type"
    case date = "Date"
    case xmsDate = "x-ms-date"
    case etag = "Etag"
    case expect = "Expect"
    case expires = "Expires"
    case from = "From"
    case host = "Host"
    case ifMatch = "If-Match"
    case ifModifiedSince = "If-Modified-Since"
    case ifNoneMatch = "If-None-Match"
    case ifUnmodifiedSince = "If-Unmodified-Since"
    case lastModified = "Last-Modified"
    case location = "Location"
    case pragma = "Pragma"
    case range = "Range"
    case referer = "Referer"
    case requestId = "Request-Id"
    case retryAfter = "Retry-After"
    case returnClientRequestId = "x-ms-return-client-request-id"
    case server = "Server"
    case slug = "Slug"
    case traceparent = "traceparent"
    case trailer = "Trailer"
    case transferEncoding = "Transfer-Encoding"
    case userAgent = "User-Agent"
    case vary = "Vary"
    case via = "Via"
    case warning = "Warning"
    case wwwAuthenticate = "WWW-Authenticate"
}

extension HTTPHeaders {
    public subscript(index: HTTPHeader) -> String? {
        get {
            return self[index.rawValue]
        }

        set(newValue) {
            self[index.rawValue] = newValue
        }
    }

    public mutating func removeValue(forKey key: HttpHeader) -> Value? {
        return removeValue(forKey: key.rawValue)
    }
}
