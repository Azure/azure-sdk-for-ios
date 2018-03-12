//
//  DocumentClientExtensions.swift
//  AzureData iOS
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

extension DocumentClient {
    
    fileprivate static let timestamp = "_ts"
    
    
    fileprivate static let roundTripIso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSXXXXX"
        return formatter
    }()
    
    
    static func roundTripIso8601Encoder(date: Date, encoder: Encoder) throws -> Void {
        
        var container = encoder.singleValueContainer()
        
        if container.codingPath.last?.stringValue == timestamp {
        
            try container.encode(date.timeIntervalSince1970)

        } else {
            
            var data = roundTripIso8601.string(from: date)
            
            if let fractionStart = data.range(of: "."),
                let fractionEnd = data.index(fractionStart.lowerBound, offsetBy: 7, limitedBy: data.endIndex) {
                let fractionRange = fractionStart.lowerBound..<fractionEnd
                let intVal = Int64(1000000 * date.timeIntervalSince1970)
                let newFraction = String(format: ".%06d", intVal % 1000000)
                data.replaceSubrange(fractionRange, with: newFraction)
            }
            
            try container.encode(data)
        }
    }
    
    
    static func roundTripIso8601Decoder(decoder: Decoder) throws -> Date {
        
        let container = try decoder.singleValueContainer()
        
        if container.codingPath.last?.stringValue == timestamp {
            
            let dateDouble = try container.decode(Double.self)
            
            return Date.init(timeIntervalSince1970: dateDouble)
        
        } else {
            
            let dateString = try container.decode(String.self)
            
            guard let parsedDate = roundTripIso8601.date(from: dateString) else {
                throw DecodingError.dataCorrupted(.init(codingPath: container.codingPath, debugDescription: "unable to parse string (\(dateString)) into date"))
            }
            
            var preliminaryDate = Date(timeIntervalSinceReferenceDate: floor(parsedDate.timeIntervalSinceReferenceDate))
            
            if let fractionStart = dateString.range(of: "."),
                let fractionEnd = dateString.index(fractionStart.lowerBound, offsetBy: 7, limitedBy: dateString.endIndex) {
                let fractionRange = fractionStart.lowerBound..<fractionEnd
                let fractionStr = String(dateString[fractionRange])
                
                if var fraction = Double(fractionStr) {
                    fraction = Double(floor(1000000*fraction)/1000000)
                    preliminaryDate.addTimeInterval(fraction)
                }
            }
            
            return preliminaryDate
        }
    }
}



extension DocumentClient {
    
    /// Creates default values for the "Accept-Encoding", "Accept-Language", "User-Agent", and "x-ms-version" headers.
    static let defaultHTTPHeaders: HTTPHeaders = {
        
        // https://docs.microsoft.com/en-us/rest/api/documentdb/#supported-rest-api-versions
        let apiVersion = "2017-02-22"
        
        // Accept-Encoding HTTP Header; see https://tools.ietf.org/html/rfc7230#section-4.2.3
        let acceptEncoding: String = "gzip;q=1.0, compress;q=0.5"
        
        // Accept-Language HTTP Header; see https://tools.ietf.org/html/rfc7231#section-5.3.5
        let acceptLanguage = Locale.preferredLanguages.prefix(6).enumerated().map { index, languageCode in
            let quality = 1.0 - (Double(index) * 0.1)
            return "\(languageCode);q=\(quality)"
            }.joined(separator: ", ")
        
        // User-Agent Header; see https://tools.ietf.org/html/rfc7231#section-5.5.3
        // Example: `iOS Example/1.1.0 (com.azure.data; build:23; iOS 10.0.0) AzureData/2.0.0`
        let userAgent: String = {
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
                        let fmwkInfo =      Bundle(for: DocumentClient.self).infoDictionary,
                        let fmwkName =      fmwkInfo[kCFBundleNameKey as String],
                        let fmwkVersion =   fmwkInfo["CFBundleShortVersionString"]
                    else { return "Unknown" }
                    
                    return "\(fmwkName)/\(fmwkVersion)" // AzureData/2.0.0
                }()
                
                print("\(executable)/\(appVersion) (\(bundle); build:\(appBuild); \(osNameVersion)) \(fmwkNameVersion)\n");
                return "\(executable)/\(appVersion) (\(bundle); build:\(appBuild); \(osNameVersion)) \(fmwkNameVersion)"
            }

            return "Unknown"
        }()
        
        let dict: [HttpRequestHeader:String] = [
            .acceptEncoding: acceptEncoding,
            .acceptLanguage: acceptLanguage,
            .userAgent: userAgent,
            .xMSVersion: apiVersion
        ]
        
        return dict.strings
    }()
}
