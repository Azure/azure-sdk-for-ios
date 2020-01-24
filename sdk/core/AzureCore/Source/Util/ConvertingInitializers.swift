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

extension Bool {
    public init?(_ description: String?) {
        guard let value = description else { return nil }
        self.init(value)
    }
}

extension Int {
    public init?(_ description: String?) {
        guard let value = description else { return nil }
        self.init(value)
    }
}

extension URL {
    public init?(string: String?) {
        guard let value = string else { return nil }
        self.init(string: value)
    }
}

extension Date {
    private struct Formatters {
        static var rfc1123: DateFormatter = {
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(abbreviation: "GMT")
            formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
            return formatter
        }()
    }

    public enum Format {
        case rfc1123

        public var formatter: DateFormatter {
            switch self {
            case .rfc1123:
                return Formatters.rfc1123
            }
        }
    }

    public init?(_ description: String?, format: Format) {
        guard let value = description else { return nil }
        guard let date = format.formatter.date(from: value) else { return nil }
        self = date
    }
}

extension String {
    public init(describing value: Date, format: Date.Format) {
        self = format.formatter.string(from: value)
    }
}

extension RawRepresentable {
    public init?(rawValue: RawValue?) {
        guard let value = rawValue else { return nil }
        self.init(rawValue: value)
    }
}
