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

extension String {
    public init?(describing value: Date?, format: AzureDateFormat) {
        guard let unwrapped = value else { return nil }
        self = format.formatter.string(from: unwrapped)
    }

    public init?(data: Data?, encoding: Encoding) {
        guard let unwrapped = data else { return nil }
        self.init(data: unwrapped, encoding: encoding)
    }

    public init?(describing: Any?) {
        guard let unwrapped = describing else { return nil }
        self.init(describing: unwrapped)
    }
}

extension RawRepresentable {
    public init?(rawValue: RawValue?) {
        guard let value = rawValue else { return nil }
        self.init(rawValue: value)
    }
}

extension Data {
    public init?(hexString: String) {
        self.init(capacity: hexString.count / 2)
        if let regex = try? NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive) {
            regex.enumerateMatches(
                in: hexString,
                range: NSRange(hexString.startIndex..., in: hexString)
            ) { match, _, _ in
                let byteString = (hexString as NSString).substring(with: match!.range)
                let num = UInt8(byteString, radix: 16)!
                append(num)
            }
        }
        guard count > 0 else { return nil }
    }
}
