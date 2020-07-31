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

public protocol ExtensionStringDecodeKeys {
    var stringDecodedKeys: [String] { get }
}

public struct AnyCodable: Decodable {
    var value: Any

    struct CodingKeys: CodingKey {
        var stringValue: String
        var intValue: Int?
        init?(intValue: Int) {
            self.stringValue = "\(intValue)"
            self.intValue = intValue
        }

        init?(stringValue: String) { self.stringValue = stringValue }
    }

    // A sets of extensions key should be always decode as String type
    static var extensionStringDecodedKey: CodingUserInfoKey {
        return CodingUserInfoKey(rawValue: "stringDecoded")!
    }

    init(value: Any) {
        self.value = value
    }

    public init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: CodingKeys.self) {
            var result = [String: Any]()
            try container.allKeys.forEach { (key) throws in
                result[key.stringValue] = try container.decode(AnyCodable.self, forKey: key).value
            }
            self.value = result
        } else if var container = try? decoder.unkeyedContainer() {
            var result = [Any]()
            while !container.isAtEnd {
                result.append(try container.decode(AnyCodable.self).value)
            }
            self.value = result
        } else if let container = try? decoder.singleValueContainer() {
            let currentCodingKey = container.codingPath[container.codingPath.count - 1]

            let extensionKeys = decoder.userInfo[AnyCodable.extensionStringDecodedKey] as? ExtensionStringDecodeKeys
            let stringDecodedKeys = extensionKeys?.stringDecodedKeys

            // if the current coding key is part of the stringDecodedKeys, always decode as String. This is because
            // the values of these properties are always digits, they will be deocded as Int instead of string by default
            let shouldDecodedAsString = stringDecodedKeys?.contains(currentCodingKey.stringValue) ?? false

            if shouldDecodedAsString {
                if let stringVal = try? container.decode(String.self) {
                    self.value = stringVal
                } else {
                    throw DecodingError.dataCorruptedError(
                        in: container,
                        debugDescription: "the container contains nothing serialisable"
                    )
                }
            } else if let intVal = try? container.decode(Int.self) {
                if let stringVal = try? container.decode(String.self) {
                    // If the decode int value is only partial of the string value, use string value instead
                    if String(intVal) == stringVal {
                        self.value = intVal
                    } else {
                        self.value = stringVal
                    }
                } else {
                    self.value = intVal
                }
            } else if let doubleVal = try? container.decode(Double.self) {
                self.value = doubleVal
            } else if let boolVal = try? container.decode(Bool.self) {
                self.value = boolVal
            } else if let stringVal = try? container.decode(String.self) {
                self.value = stringVal
            } else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "the container contains nothing serialisable"
                )
            }
        } else {
            throw DecodingError
                .dataCorrupted(
                    DecodingError
                        .Context(codingPath: decoder.codingPath, debugDescription: "Could not serialise")
                )
        }
    }
}

extension AnyCodable: Encodable {
    public func encode(to encoder: Encoder) throws {
        if let array = value as? [Any] {
            var container = encoder.unkeyedContainer()
            for value in array {
                let decodable = AnyCodable(value: value)
                try container.encode(decodable)
            }
        } else if let dictionary = value as? [String: Any] {
            var container = encoder.container(keyedBy: CodingKeys.self)
            for (key, value) in dictionary {
                let codingKey = CodingKeys(stringValue: key)!
                let decodable = AnyCodable(value: value)
                try container.encode(decodable, forKey: codingKey)
            }
        } else {
            var container = encoder.singleValueContainer()
            if let intVal = value as? Int {
                try container.encode(intVal)
            } else if let doubleVal = value as? Double {
                try container.encode(doubleVal)
            } else if let boolVal = value as? Bool {
                try container.encode(boolVal)
            } else if let stringVal = value as? String {
                try container.encode(stringVal)
            } else {
                throw EncodingError.invalidValue(
                    value,
                    EncodingError.Context(codingPath: [], debugDescription: "The value is not encodable")
                )
            }
        }
    }
}
