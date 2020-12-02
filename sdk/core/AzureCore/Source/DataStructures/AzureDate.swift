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

    public static var formatter: DateFormatter {
        return Self.dateFormat.formatter
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
        guard let date = Self.formatter.date(from: string ?? "") else { return nil }
        self.value = date
    }

    public init?(_ date: Date?) {
        guard let unwrapped = date else { return nil }
        self.value = unwrapped
    }

    // MARK: Codable

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let dateString = try container.decode(String.self)
        self.value = Self.formatter.date(from: dateString) ?? Date()
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(requestString)
    }

    // MARK: Equatable

    public static func == (lhs: Iso8601Date, rhs: Iso8601Date) -> Bool {
        return lhs.value == rhs.value
    }

    // MARK: Comparable

    public static func < (lhs: Iso8601Date, rhs: Iso8601Date) -> Bool {
        return lhs.value < rhs.value
    }
}

/// Conforms to Modeler4's `DateTimeSchema` with type `date-time-rfc1123`.
public struct Rfc1123Date: AzureDate {
    public static var dateFormat: AzureDateFormat = .rfc1123

    public static var formatter: DateFormatter {
        return Self.dateFormat.formatter
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
        guard let date = Self.formatter.date(from: string ?? "") else { return nil }
        self.value = date
    }

    public init?(_ date: Date?) {
        guard let unwrapped = date else { return nil }
        self.value = unwrapped
    }

    // MARK: Codable

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let dateString = try container.decode(String.self)
        self.value = Self.formatter.date(from: dateString) ?? Date()
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(requestString)
    }

    // MARK: Equatable

    public static func == (lhs: Rfc1123Date, rhs: Rfc1123Date) -> Bool {
        return lhs.value == rhs.value
    }

    // MARK: Comparable

    public static func < (lhs: Rfc1123Date, rhs: Rfc1123Date) -> Bool {
        return lhs.value < rhs.value
    }
}

/// Conforms to Modeler4's `DateSchema`.
public struct SimpleDate: AzureDate {
    public static var dateFormat: AzureDateFormat = .custom("yyyy-MM-dd")

    public static var formatter: DateFormatter {
        return Self.dateFormat.formatter
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
        let container = try decoder.singleValueContainer()
        let dateString = try container.decode(String.self)
        self.value = Self.formatter.date(from: dateString) ?? Date()
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(requestString)
    }

    // MARK: Equatable

    public static func == (lhs: SimpleDate, rhs: SimpleDate) -> Bool {
        return lhs.value == rhs.value
    }

    // MARK: Comparable

    public static func < (lhs: SimpleDate, rhs: SimpleDate) -> Bool {
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
        let dateString = try container.decode(String.self)
        let timeInterval = Double(dateString) ?? 0.0
        self.value = Date(timeIntervalSince1970: timeInterval)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(requestString)
    }

    // MARK: Equatable

    public static func == (lhs: UnixTime, rhs: UnixTime) -> Bool {
        return lhs.value == rhs.value
    }

    // MARK: Comparable

    public static func < (lhs: UnixTime, rhs: UnixTime) -> Bool {
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
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
            return formatter
        }
    }
}
