//
//  ObjCExtensions.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

extension NSDictionary {
    func data() throws -> Data {
        if #available(iOS 11.0, *) {
            return try JSONSerialization.data(withJSONObject: self, options: .sortedKeys)
        } else {
            return try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
        }
    }

    func value(forKey key: CodingKey) -> Any? {
        return self.value(forKey: key.stringValue)
    }

    func setValue(_ value: Any?, forKey key: CodingKey) {
        self.setValue(value, forKey: key.stringValue)
    }

    subscript(key: CodingKey) -> Any? {
        get { return self.value(forKey: key) }
        set(newValue) { self.setValue(newValue, forKey: key) }
    }

    var swifty: [AnyHashable: Any] {
        var dict = [AnyHashable: Any]()

        for (key, value) in self {
            dict[key as! String] = value
        }

        return dict
    }
}

extension Data {
    func dictionary() throws -> NSDictionary {
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
