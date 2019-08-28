//
//  ConfigurationSettingPut.swift
//  DemoAppObjC
//
//  Created by Travis Prescott on 8/20/19.
//  Copyright © 2019 Travis Prescott. All rights reserved.
//

import Foundation

@objc
class ConfigurationSettingPutParameters: NSObject, Codable {
    @objc var value: String
    @objc var tags: [String: String]?
    @objc var contentType: String = ""
    
    @objc init(withConfigurationSetting setting: ConfigurationSetting) {
        self.value = setting.value
        self.tags = setting.tags
        self.contentType = setting.contentType ?? ""
    }
}

