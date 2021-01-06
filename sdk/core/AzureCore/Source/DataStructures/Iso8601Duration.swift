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

private func components(forString string: String, designatorSet: CharacterSet) -> [String: String] {
    if string.isEmpty {
        return [:]
    }

    var decimalSet = CharacterSet(charactersIn: ".,")
    decimalSet.formUnion(.decimalDigits)
    let componentValues = string.components(separatedBy: designatorSet).filter { !$0.isEmpty }
    let designatorValues = string.components(separatedBy: decimalSet).filter { !$0.isEmpty }

    guard componentValues.count == designatorValues.count else {
        return [:]
    }
    return Dictionary(uniqueKeysWithValues: zip(designatorValues, componentValues))
}

private func parse(components: [String: String], forKey key: String) -> (whole: Int?, decimal: Double?)? {
    guard let parsed = components[key],
        let double = Double(parsed.replacingOccurrences(of: ",", with: ".")) else { return nil }
    let whole = Int(double)
    let decimal = (double - Double(whole))
    return (whole, decimal)
}

private func dateComponents(from string: String) -> DateComponents? {
    guard string.starts(with: "P") else {
        return nil
    }

    let durationString = String(string.dropFirst().lowercased())
    var dateComponents = DateComponents()

    if durationString.contains("w") {
        let weekValues = components(forString: durationString, designatorSet: CharacterSet(charactersIn: "wdmysh"))
        guard weekValues.count == 1 else {
            return nil
        }

        if let weekValue = weekValues["w"], let weekValueDouble = Double(weekValue) {
            dateComponents.weekOfYear = Int(weekValueDouble)
            // TODO: Handle decimal portion
        }
        return dateComponents
    }

    // Split the duration string into time and period
    let timeRange = (durationString as NSString).range(of: "t", options: .literal)
    let periodString: String
    let timeString: String
    if timeRange.location == NSNotFound {
        periodString = durationString
        timeString = ""
    } else {
        periodString = (durationString as NSString).substring(to: timeRange.location)
        timeString = (durationString as NSString).substring(from: timeRange.location + 1)
    }

    let periodValues = components(forString: periodString, designatorSet: CharacterSet(charactersIn: "ymd"))
    let timeValues = components(forString: timeString, designatorSet: CharacterSet(charactersIn: "hms"))
    guard periodValues.count + timeValues.count > 0 else {
        return nil
    }

    // process period values
    let dayComps = parse(components: periodValues, forKey: "d")
    let monthComps = parse(components: periodValues, forKey: "m")
    let yearComps = parse(components: periodValues, forKey: "y")
    dateComponents.day = dayComps?.whole
    dateComponents.month = monthComps?.whole
    dateComponents.year = yearComps?.whole

    // process time values
    let secondComps = parse(components: timeValues, forKey: "s")
    let minuteComps = parse(components: timeValues, forKey: "m")
    let hourComps = parse(components: timeValues, forKey: "h")
    dateComponents.second = secondComps?.whole
    if let secondsDecimal = secondComps?.decimal {
        dateComponents.nanosecond = Int(round(secondsDecimal * 1_000_000))
    }
    dateComponents.minute = minuteComps?.whole
    dateComponents.hour = hourComps?.whole

    return dateComponents
}

/// Conforms to Modeler4's `Duration` with type `duration`.
public struct Iso8601Duration: RequestStringConvertible, Codable, Equatable {
    public var value: DateComponents

    // MARK: RequestStringConvertible

    public var requestString: String {
        var period = ["P"]
        if let year = value.year {
            period.append("\(year)Y")
        }
        if let month = value.month {
            period.append("\(month)M")
        }
        if let day = value.day {
            period.append("\(day)D")
        }
        if let weeks = value.weekOfYear {
            period.append("\(weeks)W")
        }
        var time = ["T"]
        if let hour = value.hour {
            time.append("\(hour)H")
        }
        if let minute = value.minute {
            time.append("\(minute)M")
        }
        if let second = value.second {
            time.append("\(second)")
            if let nanosecond = value.nanosecond, nanosecond > 0 {
                time.append(String("\(Float(nanosecond) / 1_000_000)".dropFirst()))
            }
            time.append("S")
        }
        // Don't append the time component if there are no time components
        if time.count == 1 {
            _ = time.popLast()
        }
        return "\(period.joined())\(time.joined())"
    }

    // MARK: Initializers

    public init() {
        self.value = DateComponents()
    }

    public init?(string: String?) {
        guard let durationString = string,
            let dateComponents = dateComponents(from: durationString) else {
            return nil
        }
        self.value = dateComponents
    }

    public init?(_ date: DateComponents?) {
        guard let unwrapped = date else { return nil }
        self.value = unwrapped
    }

    // MARK: Codable

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let durationString = try container.decode(String.self)
        if let dateComponents = dateComponents(from: durationString) {
            self.value = dateComponents
        } else {
            let context = DecodingError.Context(
                codingPath: [],
                debugDescription: "Invalid duration string: \(durationString)."
            )
            throw DecodingError.dataCorrupted(context)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(requestString)
    }

    // MARK: Equatable

    public static func == (lhs: Iso8601Duration, rhs: Iso8601Duration) -> Bool {
        return lhs.value == rhs.value
    }
}
