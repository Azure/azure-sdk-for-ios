//
//  ConfigurationSettingsResponse.swift
//  DemoAppObjC
//
//  Created by Travis Prescott on 8/19/19.
//  Copyright © 2019 Travis Prescott. All rights reserved.
//

import AzureCore
import Foundation

@objc class ConfigurationSettingsResponse: NSObject, Codable, Pageable {
    var items: [ConfigurationSetting]
    var nextLink: String?
    
    enum CodingKeys: String, CodingKey {
        case items
        case nextLink = "@nextLink"
    }
}
