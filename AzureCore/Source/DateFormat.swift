//
//  DateFormat.swift
//  AzureCore
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

public struct DateFormat {
    
    public static let httpDateFormat    = "E, dd MMM yyyy HH:mm:ss zzz"         // https://tools.ietf.org/html/rfc7231#section-7.1.1.1
    public static let iso8601Format     = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSXXXXX"   // http://www.iso.org/iso/catalogue_detail?csnumber=40874
    public static let rfc1123Format     = "EEE, dd MMM yyyy HH:mm:ss z"

    public static let calendar  = Calendar(identifier: .iso8601)
    
    public static let locale    = Locale(identifier: "en_US_POSIX")
    
    public static let timeZone  = TimeZone(secondsFromGMT: 0)
    
    
    public static let httpDateFormatter = getHttpDateFormatter()
    
    public static let roundTripIso8601Formatter = getRoundTripIso8601Formatter()
    
    
    public static func getHttpDateFormatter() -> DateFormatter {
        
        let formatter = DateFormatter()
        
        formatter.calendar      = calendar
        formatter.locale        = locale
        formatter.timeZone      = timeZone
        formatter.dateFormat    = httpDateFormat
        
        return formatter
    }
    
    public static func getRoundTripIso8601Formatter() -> DateFormatter {
        
        let formatter = DateFormatter()
        
        formatter.calendar      = calendar
        formatter.locale        = locale
        formatter.timeZone      = timeZone
        formatter.dateFormat    = iso8601Format
        
        return formatter
    }

    public static func getRFC1123Formatter() -> DateFormatter {

        let formatter = DateFormatter()

        formatter.calendar = calendar
        formatter.locale = locale
        formatter.timeZone = timeZone
        formatter.dateFormat = rfc1123Format

        return formatter
    }
}

extension DateFormatter {
    
    public func roundTripIso8601StringWithMicroseconds(from date: Date) -> String {
        
        var data = self.string(from: date)
        
        if let fractionStart = data.range(of: "."),
            let fractionEnd = data.index(fractionStart.lowerBound, offsetBy: 7, limitedBy: data.endIndex) {
            
            let fractionRange = fractionStart.lowerBound..<fractionEnd
            let intVal = Int64(1000000 * date.timeIntervalSince1970)
            let newFraction = String(format: ".%06d", intVal % 1000000)
            data.replaceSubrange(fractionRange, with: newFraction)
        }

        return data
    }
    
    public func roundTripIso8601DateWithMicroseconds(from dateString: String) -> Date? {
        
        guard let parsedDate = self.date(from: dateString) else {
            return nil
        }
        
        var preliminaryDate = Date(timeIntervalSinceReferenceDate: floor(parsedDate.timeIntervalSinceReferenceDate))
        
        if let fractionStart = dateString.range(of: "."),
            let fractionEnd = dateString.index(fractionStart.lowerBound, offsetBy: 7, limitedBy: dateString.endIndex) {
            let fractionRange = fractionStart.lowerBound..<fractionEnd
            let fractionStr = String(dateString[fractionRange])
            
            if var fraction = Double(fractionStr) {
                fraction = Double(ceil(1000000*fraction)/1000000)
                preliminaryDate.addTimeInterval(fraction)
            }
        }
        
        return preliminaryDate
    }
}

