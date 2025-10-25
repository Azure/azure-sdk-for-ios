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

public extension KeyedDecodingContainer {
    func decodeBool(forKey key: K) throws -> Bool {
        do {
            return try decode(Bool.self, forKey: key)
        } catch let DecodingError.typeMismatch(expectedType, context) {
            let mismatchError = DecodingError.typeMismatch(expectedType, context)
            guard let stringValue = try? self.decode(String.self, forKey: key) else { throw mismatchError }
            guard let boolVal = Bool(stringValue.lowercased()) else { throw mismatchError }
            return boolVal
        }
    }

    func decodeBoolIfPresent(forKey key: K) throws -> Bool? {
        do {
            return try decodeIfPresent(Bool.self, forKey: key)
        } catch let DecodingError.typeMismatch(expectedType, context) {
            let mismatchError = DecodingError.typeMismatch(expectedType, context)
            guard let stringValue = try? self.decode(String.self, forKey: key) else { throw mismatchError }
            guard let boolVal = Bool(stringValue.lowercased()) else { throw mismatchError }
            return boolVal
        }
    }

    func decodeInt(forKey key: K) throws -> Int {
        do {
            return try decode(Int.self, forKey: key)
        } catch let DecodingError.typeMismatch(expectedType, context) {
            let mismatchError = DecodingError.typeMismatch(expectedType, context)
            guard let stringValue = try? self.decode(String.self, forKey: key) else { throw mismatchError }
            guard let intVal = Int(stringValue) else { throw mismatchError }
            return intVal
        }
    }

    func decodeIntIfPresent(forKey key: K) throws -> Int? {
        do {
            return try decodeIfPresent(Int.self, forKey: key)
        } catch let DecodingError.typeMismatch(expectedType, context) {
            let mismatchError = DecodingError.typeMismatch(expectedType, context)
            guard let stringValue = try? self.decode(String.self, forKey: key) else { throw mismatchError }
            guard let intVal = Int(stringValue) else { throw mismatchError }
            return intVal
        }
    }

    func decodeDouble(forKey key: K) throws -> Double {
        do {
            return try decode(Double.self, forKey: key)
        } catch let DecodingError.typeMismatch(expectedType, context) {
            let mismatchError = DecodingError.typeMismatch(expectedType, context)
            guard let stringValue = try? self.decode(String.self, forKey: key) else { throw mismatchError }
            guard let doubleVal = Double(stringValue) else { throw mismatchError }
            return doubleVal
        }
    }

    func decodeDoubleIfPresent(forKey key: K) throws -> Double? {
        do {
            return try decodeIfPresent(Double.self, forKey: key)
        } catch let DecodingError.typeMismatch(expectedType, context) {
            let mismatchError = DecodingError.typeMismatch(expectedType, context)
            guard let stringValue = try? self.decode(String.self, forKey: key) else { throw mismatchError }
            guard let doubleVal = Double(stringValue) else { throw mismatchError }
            return doubleVal
        }
    }
}

extension CharacterSet {
    static let azureUrlQueryAllowed = urlQueryAllowed.subtracting(.init(charactersIn: "!*'();:@&=+$,/?"))
    static let azureUrlPathAllowed = urlPathAllowed.subtracting(.init(charactersIn: "!*'()@&=+$,/:"))
}
