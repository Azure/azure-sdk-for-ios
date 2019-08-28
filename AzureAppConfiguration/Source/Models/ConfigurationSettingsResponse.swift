//
//  ConfigurationSettingsResponse.swift
//  DemoAppObjC
//
//  Created by Travis Prescott on 8/19/19.
//  Copyright © 2019 Travis Prescott. All rights reserved.
//

import Foundation

@objc
class ConfigurationSettingsResponse: NSObject, Codable {
    var items: [ConfigurationSetting]
}
