//
//  ADDateEncoders.swift
//  AzureData ObjC
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCore

@objc(ADDateEncoders)
public class ADDateEncoders: NSObject {
    @objc(encodeTimestamp:)
    public static func encodeTimestamp(_ date: Date?) -> NSNumber? {
        guard let date = date else { return nil }
        return NSNumber(value: date.timeIntervalSince1970)
    }

    @objc(decodeTimestampFrom:)
    public static func decodeTimestamp(from value: Any?) -> Date? {
        if let date = value as? Date { return date }
        guard let double = (value as? NSNumber)?.doubleValue else { return nil }
        return Date(timeIntervalSince1970: double)
    }

    @objc(encodeISO8601Date:)
    public static func encodeISO8601Date(_ date: Date?) -> String? {
        guard let date = date else { return nil }
        return DateFormat.getRoundTripIso8601Formatter().roundTripIso8601StringWithMicroseconds(from: date)
    }

    @objc(decodeISO8601From:)
    public static func decodeISO8601Date(from value: Any?) -> Date? {
        if let date = value as? Date { return date }
        guard let string = value as? String else { return nil }
        return DateFormat.getRoundTripIso8601Formatter().roundTripIso8601DateWithMicroseconds(from: string)
    }
}
