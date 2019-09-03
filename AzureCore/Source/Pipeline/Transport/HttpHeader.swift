//
//  HttpHeader.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/22/19.
//

import Foundation

public typealias HttpHeaders = [String:String]

extension HttpHeaders {
    subscript(index: HttpHeader) -> String? {
        get {
            return self[index.rawValue]
        }
        
        set(newValue) {
            self[index.rawValue] = newValue
        }
    }
}

@objc public enum HttpHeader: Int, RawRepresentable {
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
    case retryAfter
    case server
    case slug
    case trailer
    case transferEncoding
    case userAgent
    case vary
    case via
    case warning
    case wwwAuthenticate
    
    public typealias RawValue = String
    
    public var rawValue: RawValue {
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
        case .retryAfter:
            return "Retry-After"
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
    
    public init?(rawValue: RawValue) {
        switch rawValue {
        case "Accept":
            self = .accept
        case "Accept-Charset":
            self = .acceptCharset
        case "Accept-Encoding":
            self = .acceptEncoding
        case "Accept-Language":
            self = .acceptLanguage
        case "Accept-Ranges":
            self = .acceptRanges
        case "Age":
            self = .age
        case "Allow":
            self = .allow
        case "Authorization":
            self = .authorization
        case "Cache-Control":
            self = .cacheControl
        case "Connection":
            self = .connection
        case "Content-Encoding":
            self = .contentEncoding
        case "Content-Language":
            self = .contentLanguage
        case "Content-Length":
            self = .contentLength
        case "Content-Location":
            self = .contentLocation
        case "Content-Range":
            self = .contentRange
        case "Content-Type":
            self = .contentType
        case "Date":
            self = .date
        case "Etag":
            self = .etag
        case "Expect":
            self = .expect
        case "Expires":
            self = .expires
        case "From":
            self = .from
        case "Host":
            self = .host
        case "If-Match":
            self = .ifMatch
        case "If-Modified-Since":
            self = .ifModifiedSince
        case "If-None-Match":
            self = .ifNoneMatch
        case "If-Unmodified-Since":
            self = .ifUnmodifiedSince
        case "Last-Modified":
            self = .lastModified
        case "Location":
            self = .location
        case "Pragma":
            self = .pragma
        case "Range":
            self = .range
        case "Referer":
            self = .referer
        case "Retry-After":
            self = .retryAfter
        case "Server":
            self = .server
        case "Slug":
            self = .slug
        case "Trailer":
            self = .trailer
        case "Transfer-Encoding":
            self = .transferEncoding
        case "User-Agent":
            self = .userAgent
        case "Vary":
            self = .vary
        case "Via":
            self = .via
        case "Warning":
            self = .warning
        case "WWW-Authenticate":
            self = .wwwAuthenticate
        default:
            fatalError("Unrecognized enum value: \(rawValue)")
        }
    }
}
