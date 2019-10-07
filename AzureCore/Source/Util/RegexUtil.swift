//
//  RegexUtil.swift
//  AzureCore
//
//  Created by Travis Prescott on 9/30/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

extension NSRegularExpression {

    convenience init(_ pattern: String) {
        do {
            try self.init(pattern: pattern)
        } catch {
            preconditionFailure("Illegal regular expression: \(pattern).")
        }
    }

    func matches(_ string: String) -> Bool {
        let range = NSRange(location: 0, length: string.utf16.count)
        return firstMatch(in: string, options: [], range: range) != nil
    }
}
