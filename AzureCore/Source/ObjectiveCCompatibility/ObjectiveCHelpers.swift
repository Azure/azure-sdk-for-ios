//
//  ObjectiveCHelpers.swift
//  AzureCore
//
//  Created by Travis Prescott on 9/19/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

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
