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

public protocol AzureDate: RequestStringConvertible, Codable, Comparable {
    static var dateFormat: AzureDateFormat { get }

    static var formatter: DateFormatter { get }

    var value: Date { get set }

    init?(string: String?)

    init?(_ date: Date?)
}

/// Conforms to Modeler4's `DateTimeSchema` with type `date-time`.
public struct Iso8601Date: AzureDate {
    public static var dateFormat: AzureDateFormat = .iso8601

    private let alternateFormats = [
        "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ",
        "yyyy-MM-dd'T'HH:mm:ssZZZZZ",
        "yyyy-MM-dd'T'HH:mm:ss"
    ]

    public static var formatter: DateFormatter {
        return dateFormat.formatter
    }

    public var value: Date

    // MARK: RequestStringConvertible

    public var requestString: String {
        return Self.formatter.string(from: value)
    }

    // MARK: Initializers

    public init() {
        self.value = Date()
    }

    public init?(string: String?) {
        let formatter = Self.formatter
        for format in alternateFormats {
            formatter.dateFormat = format
            if let date = formatter.date(from: string?.uppercased() ?? "") {
                self.value = date
                return
            }
        }
        return nil
    }

    public init?(_ date: Date?) {
        guard let unwrapped = date else { return nil }
        self.value = unwrapped
    }

    // MARK: Codable

    public init(from decoder: Decoder) throws {
        let formatter = Self.formatter
        var dateString = ""
        do {
            let container = try decoder.singleValueContainer()
            dateString = try container.decode(String.self)
            for format in alternateFormats {
                formatter.dateFormat = format
                (decoder as? JSONDecoder)?.dateDecodingStrategy = .formatted(formatter)
                if let decoded = formatter.date(from: dateString.uppercased()) {
                    self.value = decoded
                    return
                }
            }
        } catch {}
        let context = DecodingError.Context(codingPath: [], debugDescription: "Invalid date string: \(dateString).")
        throw DecodingError.dataCorrupted(context)
    }

    public func encode(to encoder: Encoder) throws {
        (encoder as? JSONEncoder)?.dateEncodingStrategy = .formatted(Self.formatter)
        var container = encoder.singleValueContainer()
        var stringToEncode = requestString
        if !stringToEncode.hasSuffix("Z") {
            stringToEncode += "Z"
        }
        try container.encode(stringToEncode)
    }

    // MARK: Equatable

    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.value == rhs.value
    }

    // MARK: Comparable

    public static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.value < rhs.value
    }
}

/// Conforms to Modeler4's `DateTimeSchema` with type `date-time-rfc1123`.
public struct Rfc1123Date: AzureDate {
    public static var dateFormat: AzureDateFormat = .rfc1123

    public static var formatter: DateFormatter {
        return dateFormat.formatter
    }

    public var value: Date

    // MARK: RequestStringConvertible

    public var requestString: String {
        return Self.formatter.string(from: value)
    }

    // MARK: Initializers

    public init() {
        self.value = Date()
    }

    public init?(string: String?) {
        guard let date = Rfc1123Date.formatter.date(from: string ?? "") else { return nil }
        self.value = date
    }

    public init?(_ date: Date?) {
        guard let unwrapped = date else { return nil }
        self.value = unwrapped
    }

    // MARK: Codable

    public init(from decoder: Decoder) throws {
        (decoder as? JSONDecoder)?.dateDecodingStrategy = .formatted(Self.formatter)
        let container = try decoder.singleValueContainer()
        let dateString = try container.decode(String.self)
        if let decoded = Rfc1123Date.formatter.date(from: dateString) {
            self.value = decoded
        } else {
            let context = DecodingError.Context(codingPath: [], debugDescription: "Invalid date string: \(dateString).")
            throw DecodingError.dataCorrupted(context)
        }
    }

    public func encode(to encoder: Encoder) throws {
        (encoder as? JSONEncoder)?.dateEncodingStrategy = .formatted(Self.formatter)
        var container = encoder.singleValueContainer()
        try container.encode(requestString)
    }

    // MARK: Equatable

    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.value == rhs.value
    }

    // MARK: Comparable

    public static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.value < rhs.value
    }
}

/// Conforms to Modeler4's `DateSchema`.
public struct SimpleDate: AzureDate {
    public static var dateFormat: AzureDateFormat = .custom("yyyy-MM-dd")

    public static var formatter: DateFormatter {
        return dateFormat.formatter
    }

    public var value: Date

    // MARK: RequestStringConvertible

    public var requestString: String {
        return Self.formatter.string(from: value)
    }

    // MARK: Initializers

    public init() {
        self.value = Date()
    }

    public init?(string: String?) {
        self.init(Self.formatter.date(from: string ?? ""))
    }

    public init?(_ date: Date?) {
        guard let unwrapped = date else { return nil }
        self.value = unwrapped
    }

    // MARK: Codable

    public init(from decoder: Decoder) throws {
        (decoder as? JSONDecoder)?.dateDecodingStrategy = .formatted(Self.formatter)
        let container = try decoder.singleValueContainer()
        let dateString = try container.decode(String.self)
        if let decoded = SimpleDate.formatter.date(from: dateString) {
            self.value = decoded
        } else {
            let context = DecodingError.Context(codingPath: [], debugDescription: "Invalid date string: \(dateString).")
            throw DecodingError.dataCorrupted(context)
        }
    }

    public func encode(to encoder: Encoder) throws {
        (encoder as? JSONEncoder)?.dateEncodingStrategy = .formatted(Self.formatter)
        var container = encoder.singleValueContainer()
        try container.encode(requestString)
    }

    // MARK: Equatable

    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.value == rhs.value
    }

    // MARK: Comparable

    public static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.value < rhs.value
    }
}

/// Conforms to Modeler4's `UnixTimeSchema`.
public struct UnixTime: Codable, Comparable, RequestStringConvertible {
    public var value: Date

    // MARK: RequestStringConvertible

    public var requestString: String {
        return String(Int(value.timeIntervalSince1970))
    }

    // MARK: Initializers

    public init() {
        self.value = Date()
    }

    public init(timeIntervalSince1970 double: Double) {
        self.value = Date(timeIntervalSince1970: double)
    }

    public init?(_ date: Date?) {
        guard let unwrapped = date else { return nil }
        self.value = unwrapped
    }

    // MARK: Codable

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            let timeInterval = try container.decode(Double.self)
            self.value = Date(timeIntervalSince1970: timeInterval)
            return
        } catch {
            let timeString = try container.decode(String.self)
            if let timeInterval = Double(timeString) {
                self.value = Date(timeIntervalSince1970: timeInterval)
                return
            } else {
                throw error
            }
        }
    }

    public func encode(to encoder: Encoder) throws {
        (encoder as? JSONEncoder)?.dateEncodingStrategy = .secondsSince1970
        var container = encoder.singleValueContainer()
        try container.encode(requestString)
    }

    // MARK: Equatable

    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.value == rhs.value
    }

    // MARK: Comparable

    public static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.value < rhs.value
    }
}

/// Conforms to Modeler4's `TimeSchema`.
public struct SimpleTime: Codable, Comparable, RequestStringConvertible {
    public var value: Date

    public static var dateFormat: AzureDateFormat = .custom("HH:mm:ss")

    public static var formatter: DateFormatter {
        return dateFormat.formatter
    }

    // MARK: RequestStringConvertible

    public var requestString: String {
        return Self.formatter.string(from: value)
    }

    // MARK: Initializers

    public init() {
        self.value = Date()
    }

    public init?(string: String?) {
        guard let date = SimpleTime.formatter.date(from: string ?? "") else { return nil }
        self.value = date
    }

    public init?(_ date: Date?) {
        guard let unwrapped = date else { return nil }
        self.value = unwrapped
    }

    // MARK: Codable

    public init(from decoder: Decoder) throws {
        (decoder as? JSONDecoder)?.dateDecodingStrategy = .formatted(Self.formatter)
        let container = try decoder.singleValueContainer()
        let timeString = try container.decode(String.self)
        if let decoded = SimpleTime.formatter.date(from: timeString) {
            self.value = decoded
        } else {
            let context = DecodingError.Context(codingPath: [], debugDescription: "Invalid time string: \(timeString).")
            throw DecodingError.dataCorrupted(context)
        }
    }

    public func encode(to encoder: Encoder) throws {
        (encoder as? JSONEncoder)?.dateEncodingStrategy = .formatted(Self.formatter)
        var container = encoder.singleValueContainer()
        try container.encode(requestString)
    }

    // MARK: Equatable

    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.value == rhs.value
    }

    // MARK: Comparable

    public static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.value < rhs.value
    }
}

public enum AzureDateFormat {
    /// Format a custom date format
    case custom(String)

    /// Format the `Date` as an RFC 1123-formatted string.
    case rfc1123

    /// Format the `Date` as an ISO-8601-formatted string (in RFC 3339 format).
    case iso8601

    /// Retrieve a `DateFormatter` for the given date format.
    public var formatter: DateFormatter {
        switch self {
        case let .custom(format):
            let formatter = DateFormatter()
            formatter.dateFormat = format
            return formatter
        case .rfc1123:
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(abbreviation: "GMT")
            formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
            return formatter
        case .iso8601:
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(abbreviation: "GMT")
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
            return formatter
        }
    }
}
