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

/// Can be string-formatted for use by AzureCore.
public protocol RequestStringConvertible {
    var requestString: String { get }
}

extension RequestStringConvertible {
    public static func == (lhs: RequestStringConvertible, rhs: RequestStringConvertible) -> Bool {
        return lhs.requestString == rhs.requestString
    }
}

extension Int: RequestStringConvertible {
    public var requestString: String {
        return String(self)
    }
}

extension String: RequestStringConvertible {
    public var requestString: String {
        return self
    }
}

extension Bool: RequestStringConvertible {
    public var requestString: String {
        return String(self)
    }
}

extension Data: RequestStringConvertible {
    public var requestString: String {
        guard let dataString = String(bytes: self, encoding: .utf8) else {
            assertionFailure("Unable to encode bytes")
            return ""
        }
        return dataString
    }
}

extension Array: RequestStringConvertible {
    public var requestString: String {
        var strings = [String]()
        for value in self {
            if let val = value as? RequestStringConvertible {
                strings.append(val.requestString)
            } else {
                strings.append("")
            }
        }
        return strings.joined(separator: ",")
    }
}
