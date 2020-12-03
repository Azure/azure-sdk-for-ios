import Foundation

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}

extension Int: LocalizedError {
    public var errorDescription: String? { return String(self) }
}

extension Int32: LocalizedError {
    public var errorDescription: String? { return String(self) }
}

extension Int64: LocalizedError {
    public var errorDescription: String? { return String(self) }
}

extension Data {
    func base64URLEncodedString() -> String {
        let base64String = base64EncodedString()
        let base64UrlString = base64String.replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "=", with: "")
        return base64UrlString
    }
}

extension Date {
    class AzureISO8601DateFormatter: DateFormatter {
        static let allFormatOptions: [ISO8601DateFormatter.Options] = [
            [.withInternetDateTime, .withFractionalSeconds],
            [.withInternetDateTime]
        ]

        override public func string(from date: Date) -> String {
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            return dateFormatter.string(from: date)
        }

        override public func date(from stringIn: String) -> Date? {
            let string = stringIn.hasSuffix("Z") ? stringIn : stringIn + "Z"
            let dateFormatter = ISO8601DateFormatter()
            for aformatOption in AzureISO8601DateFormatter.allFormatOptions {
                dateFormatter.formatOptions = aformatOption
                if let date = dateFormatter.date(from: string.capitalized) {
                    return date
                }
            }
            return nil
        }
    }

    class AzureRfc1123DateFormatter: DateFormatter {
        override public func date(from string: String) -> Date? {
            return Date.Format.rfc1123.formatter.date(from: string.capitalized)
        }

        override public func string(from date: Date) -> String {
            return Date.Format.rfc1123.formatter.string(from: date)
        }
    }
}
