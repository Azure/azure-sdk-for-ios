//
//  HttpHeader.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/22/19.
//

import Foundation

public typealias HttpHeaders = [String: String]

@objc public enum HttpHeaderType: UInt {
    case accept
    case acceptCharset
    case acceptEncoding
    case acceptLanguage
    case acceptRanges
    case age
    case allow
    case authorization
    case cacheControl
    case connection
    case contentEncoding
    case contentLanguage
    case contentLength
    case contentLocation
    case contentRange
    case contentType
    case date
    case etag
    case expect
    case expires
    case from
    case host
    case ifMatch
    case ifModifiedSince
    case ifNoneMatch
    case ifUnmodifiedSince
    case lastModified
    case location
    case pragma
    case range
    case referer
    case server
    case slug
    case trailer
    case transferEncoding
    case userAgent
    case vary
    case via
    case warning
    case wwwAuthenticate
    
    func name() -> String {
        switch self {
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
        case .age:
            return "Age"
        case .allow:
            return "Allow"
        case .authorization:
            return "Authorization"
        case .cacheControl:
            return "Cache-Control"
        case .connection:
            return "Connection"
        case .contentEncoding:
            return "Content-Encoding"
        case .contentLanguage:
            return "Content-Language"
        case .contentLength:
            return "Content-Length"
        case .contentLocation:
            return "Content-Location"
        case .contentRange:
            return "Content-Range"
        case .contentType:
            return "Content-Type"
        case .date:
            return "Date"
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
        case .server:
            return "Server"
        case .slug:
            return "Slug"
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
}

@objc
public class HttpHeader: NSObject {

    private let _name: String

    @objc var name: String {
        return self._name
    }

    @objc var value: String?

    @objc var values: [String]? {
        guard let value = value else { return nil }
        return value.components(separatedBy: ",")
    }

    @objc public override var description: String {
        return "\(self.name):\(self.value ?? "")"
    }
    
    @objc public init(header: HttpHeaderType, value: String?) {
        self._name = header.name()
        self.value = value
    }

    @objc public func add(value: String) {
        guard self.value != nil else {
            self.value = value
            return
        }
        self.value! += ",\(value)"
    }
}
