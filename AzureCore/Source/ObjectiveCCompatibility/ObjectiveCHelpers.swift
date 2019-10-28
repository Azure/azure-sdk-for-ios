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

extension NSDictionary {
    func value(forKey key: CodingKey) -> Any? {
        return value(forKey: key.stringValue)
    }

    func setValue(_ value: Any?, forKey key: CodingKey) {
        setValue(value, forKey: key.stringValue)
    }

    subscript(key: CodingKey) -> Any? {
        get { return value(forKey: key) }
        set(newValue) { setValue(newValue, forKey: key) }
    }

    var swifty: [AnyHashable: Any] {
        var dict = [AnyHashable: Any]()

        for (key, value) in self {
            // swiftlint:disable:next force_cast
            dict[key as! String] = value
        }

        return dict
    }

    func data() throws -> Data {
        return try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
    }
}

extension Data {
    func dictionary() throws -> NSDictionary {
        // swiftlint:disable:next force_cast
        return try JSONSerialization.jsonObject(with: self, options: .allowFragments) as! NSDictionary
    }
}

extension Int {
    static let `nil`: Int = -1
}

extension Int16 {
    static let `nil`: Int16 = -1
}

extension Double {
    static let `nil`: Double = -1.0
}
