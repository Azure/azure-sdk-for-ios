//
//  ConfigurationSettingPut.swift
//  DemoAppObjC
//
//  Created by Travis Prescott on 8/20/19.
//  Copyright © 2019 Travis Prescott. All rights reserved.
//

import Foundation

public struct ConfigurationSettingPutParameters: Codable {

    let value: String
    let tags: [String: String]?
    let contentType: String

    public init(withConfigurationSetting setting: ConfigurationSetting) {
        self.value = setting.value
        self.tags = setting.tags
        self.contentType = setting.contentType ?? ""
    }
}
