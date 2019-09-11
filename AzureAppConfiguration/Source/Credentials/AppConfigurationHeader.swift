//
//  AppConfigurationHeader.swift
//  AzureAppConfiguration
//
//  Created by Travis Prescott on 9/6/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

@objc public enum AppConfigurationHeader: Int, RawRepresentable {
    case date
    case contentHash
    
    public typealias RawValue = String
    
    public var rawValue: RawValue {
        switch self {
        case .date:
            return "x-ms-date"
        case .contentHash:
            return "x-ms-content-sha256"
        }
    }
    
    public init?(rawValue: RawValue) {
        switch rawValue.lowercased() {
        case "x-ms-date":
            self = .date
        case "x-ms-content-sha256":
            self = .contentHash
        default:
            fatalError("Unrecognized enum value: \(rawValue)")
        }
    }
}
