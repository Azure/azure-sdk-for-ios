//
//  RegexUtil.swift
//  AzureCore
//
//  Created by Travis Prescott on 9/30/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

extension NSRegularExpression {

    convenience init(_ pattern: String, options: NSRegularExpression.Options = []) {
        do {
            try self.init(pattern: pattern, options: options)
        } catch {
            preconditionFailure("Illegal regular expression: \(pattern).")
        }
    }

    func firstMatch(in string: String) -> NSTextCheckingResult? {
        let range = NSRange(location: 0, length: string.utf16.count)
        return firstMatch(in: string, options: [], range: range)
    }

    func hasMatch(in string: String) -> Bool {
        return firstMatch(in: string) != nil
    }
}

extension NSTextCheckingResult {
    func capturedValues(from string: String) -> [Substring] {
        var captureList: [Substring] = []
        for rangeNum in 0..<numberOfRanges {
            if let range = Range(range(at: rangeNum), in: string) {
                captureList.append(string[range])
            }
        }
        return captureList
    }
}
