//
//  DocumentClientExtensions.swift
//  AzureData iOS
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCore

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
    static let defaultHTTPHeaders: HttpHeaders = {
        
        var headers = Bundle(for: DocumentClient.self).defaultHttpHeaders
        
        // https://docs.microsoft.com/en-us/rest/api/documentdb/#supported-rest-api-versions
        headers[.msVersion] = "2017-02-22"
        
        return headers
    }()
}
