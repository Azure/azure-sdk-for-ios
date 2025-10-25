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

extension NSRegularExpression {
    convenience init(_ pattern: String, options: NSRegularExpression.Options = []) {
        do {
            try self.init(pattern: pattern, options: options)
        } catch {
            preconditionFailure("Illegal regular expression: \(pattern).")
        }
    }

    func matches(in string: String) -> [String]? {
        let range = NSRange(location: 0, length: string.utf16.count)
        let results = matches(in: string, options: [], range: range)
        let substrings = results.flatMap { $0.capturedValues(from: string) }
        return substrings.map { String($0) }
    }

    func firstMatch(in string: String) -> String? {
        let range = NSRange(location: 0, length: string.utf16.count)
        guard let substring = firstMatch(in: string, options: [], range: range)?.capturedValues(from: string).first
        else { return nil }
        return String(substring)
    }

    func hasMatch(in string: String) -> Bool {
        return firstMatch(in: string) != nil
    }
}

extension NSTextCheckingResult {
    func capturedValues(from string: String) -> [Substring] {
        var captureList: [Substring] = []
        for rangeNum in 0 ..< numberOfRanges {
            if let range = Range(range(at: rangeNum), in: string) {
                captureList.append(string[range])
            }
        }
        return captureList
    }
}
