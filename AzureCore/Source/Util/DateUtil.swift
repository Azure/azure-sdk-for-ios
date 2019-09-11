//
//  DateUtil.swift
//  AzureCore
//
//  Created by Travis Prescott on 9/6/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

extension Date {
    public var httpFormat: String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "MMM, dd yyyy HH:mm:ss z" // EEE for day
        dateFormat.timeZone = TimeZone(abbreviation: "UTC")
        return dateFormat.string(from: self)
    }
}
