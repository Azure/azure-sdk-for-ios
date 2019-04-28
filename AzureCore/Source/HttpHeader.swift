//
//  HttpHeader.swift
//  AzureCore
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

public typealias HttpHeaders = [String: String]


public enum HttpHeader : String {
    case accept             = "Accept"
    case acceptCharset      = "Accept-Charset"
    case acceptEncoding     = "Accept-Encoding"
    case acceptLanguage     = "Accept-Language"
    case acceptRanges       = "Accept-Ranges"
    case age                = "Age"
    case allow              = "Allow"
    case authorization      = "Authorization"
    case cacheControl       = "Cache-Control"
    case connection         = "Connection"
    case contentEncoding    = "Content-Encoding"
    case contentLanguage    = "Content-Language"
    case contentLength      = "Content-Length"
    case contentLocation    = "Content-Location"
    case contentRange       = "Content-Range"
    case contentType        = "Content-Type"
    case date               = "Date"
    case etag               = "Etag"
    case expect             = "Expect"
    case expires            = "Expires"
    case from               = "From"
    case host               = "Host"
    case ifMatch            = "If-Match"
    case ifModifiedSince    = "If-Modified-Since"
    case ifNoneMatch        = "If-None-Match"
    case ifUnmodifiedSince  = "If-Unmodified-Since"
    case lastModified       = "Last-Modified"
    case location           = "Location"
    case pragma             = "Pragma"
    case range              = "Range"
    case referer            = "Referer"
    case server             = "Server"
    case slug               = "Slug"
    case trailer            = "Trailer"
    case transferEncoding   = "Transfer-Encoding"
    case userAgent          = "User-Agent"
    case vary               = "Vary"
    case via                = "Via"
    case warning            = "Warning"
    case wwwAuthenticate    = "WWW-Authenticate"
}


extension Dictionary where Key == HttpHeader, Value == String  {
    public var strings: [String:String] {
        return Dictionary<String, String>.init(uniqueKeysWithValues: self.map{ (k, v) in
            (k.rawValue, v)
        })
    }
}


extension Dictionary where Key == String, Value == String {
    public subscript (index: HttpHeader) -> String? {
        get {
            return self[index.rawValue]
        }
        set {
            self[index.rawValue] = newValue
        }
    }
}

extension Dictionary where Key == String, Value == Any {
    public subscript (index: HttpHeader) -> Any? {
        get {
            return self[index.rawValue]
        }
        set {
            self[index.rawValue] = newValue
        }
    }
}

extension URLRequest {
    public mutating func addValue(_ value: String, forHTTPHeaderField: HttpHeader) {
        self.addValue(value, forHTTPHeaderField: forHTTPHeaderField.rawValue)
    }
}

extension Bundle {
    
    /// Creates default values for the "Accept-Encoding", "Accept-Language", and "User-Agent" headers.
    public var defaultHttpHeaders: HttpHeaders {
        
        var headers = HttpHeaders()
        
        // Accept-Encoding HTTP Header; see https://tools.ietf.org/html/rfc7230#section-4.2.3
        let acceptEncoding: String = "gzip;q=1.0, compress;q=0.5"
        
        // Accept-Language HTTP Header; see https://tools.ietf.org/html/rfc7231#section-5.3.5
        let acceptLanguage = Locale.preferredLanguages.prefix(6).enumerated().map { index, languageCode in
            let quality = 1.0 - (Double(index) * 0.1)
            return "\(languageCode);q=\(quality)"
            }.joined(separator: ", ")
        
        // User-Agent Header; see https://tools.ietf.org/html/rfc7231#section-5.5.3
        // Example: `iOS Example/1.1.0 (com.azure.data; build:23; iOS 10.0.0) AzureData/2.0.0`
        let userAgent = self.userAgentString
        
        headers[.acceptEncoding] = acceptEncoding
        headers[.acceptLanguage] = acceptLanguage
        headers[.userAgent] = userAgent

        return headers
    }
    
    
    // User-Agent Header; see https://tools.ietf.org/html/rfc7231#section-5.5.3
    // Example: `iOS Example/1.1.0 (com.azure.data; build:23; iOS 10.0.0) AzureData/2.0.0`
    public var userAgentString: String {
        
        if let info = Bundle.main.infoDictionary {
            
            let executable =    info[kCFBundleExecutableKey as String]  as? String ?? "Unknown" // iOS Example
            let bundle =        info[kCFBundleIdentifierKey as String]  as? String ?? "Unknown" // com.azure.data
            let appVersion =    info["CFBundleShortVersionString"]      as? String ?? "Unknown" // 1.1.0
            let appBuild =      info[kCFBundleVersionKey as String]     as? String ?? "Unknown" // 23
            
            let osNameVersion: String = {
                
                let version = ProcessInfo.processInfo.operatingSystemVersion
                let versionString = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)" // 10.0.0
                
                let osName: String = {
                    #if os(iOS)
                        return "iOS"
                    #elseif os(watchOS)
                        return "watchOS"
                    #elseif os(tvOS)
                        return "tvOS"
                    #elseif os(macOS)
                        return "macOS"
                    #elseif os(Linux)
                        return "Linux"
                    #else
                        return "Unknown"
                    #endif
                }()
                
                return "\(osName) \(versionString)" // iOS 10.0.0
            }()
            
            let fmwkNameVersion: String = {
                guard
                    let fmwkInfo =      self.infoDictionary,
                    let fmwkName =      fmwkInfo[kCFBundleNameKey as String],
                    let fmwkVersion =   fmwkInfo["CFBundleShortVersionString"]
                    else { return "Unknown" }
                
                return "\(fmwkName)/\(fmwkVersion)" // AzureData/2.0.0
            }()
            
            Log.debug("\nUserAgent: \(executable)/\(appVersion) (\(bundle); build:\(appBuild); \(osNameVersion)) \(fmwkNameVersion)")
            
            return "\(executable)/\(appVersion) (\(bundle); build:\(appBuild); \(osNameVersion)) \(fmwkNameVersion)"
        }
        
        return "Unknown"
    }
}

