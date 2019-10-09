//
//  HttpHeader.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/22/19.
//

import Foundation

public typealias HttpHeaders = [String: String]

extension HttpHeaders {
    public subscript(index: HttpHeader) -> String? {
        get {
            return self[index.rawValue]
        }

        set(newValue) {
            self[index.rawValue] = newValue
        }
    }

    public mutating func removeValue(forKey key: HttpHeader) -> String? {
        return removeValue(forKey: key.rawValue)
    }
}

public enum HttpHeader: String {
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
    case retryAfter = "Retry-After"
    case server = "Server"
    case slug = "Slug"
    case trailer = "Trailer"
    case transferEncoding = "Transfer-Encoding"
    case userAgent = "User-Agent"
    case vary = "Vary"
    case via = "Via"
    case warning = "Warning"
    case wwwAuthenticate = "WWW-Authenticate"
}
