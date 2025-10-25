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

public extension String {
    func replacing(prefix: String, with newPrefix: String) -> String {
        var mutatedString = prefix
        guard hasPrefix(prefix) else { return self }
        mutatedString = String(dropFirst(prefix.count))
        return newPrefix + mutatedString
    }

    /// Returns the base64 representation of a string.
    func base64EncodedString() -> String {
        let data = Data(bytes: self, count: count)
        return data.base64EncodedString()
    }
}

public extension Data {
    /// Returns the hexadecimal string representation of the data.
    func hexadecimalString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }

    /// Returns a Base-64 encoded string, optionally trimming ending `=` characters.
    func base64EncodedString(trimmingEquals: Bool) -> String {
        if trimmingEquals {
            return base64EncodedString().trimmingCharacters(in: ["="])
        } else {
            return base64EncodedString()
        }
    }
}
