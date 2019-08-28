//
//  ConfigurationSetting.swift
//  DemoAppObjC
//
//  Created by Travis Prescott on 8/8/19.
//  Copyright © 2019 Travis Prescott. All rights reserved.
//

import Foundation

@objc
class ConfigurationSetting: NSObject, Codable {
    @objc var key: String
    @objc var value: String
    @objc var label: String?
    @objc var tags: [String: String]?
    @objc var contentType: String?
    @objc var etag: String?
    @objc var locked: Bool = false
    @objc var lastModified: Date?
    
    @objc static let emptyLabel = "\0"
    
    @objc init(key: String, value: String, label: String?, tags: Dictionary<String, String>?, contentType: String?, locked: Bool = false) {
        self.key = key
        self.value = value
        self.label = label
        self.tags = tags
        self.contentType = contentType
        self.etag = nil
        self.lastModified = nil
        self.locked = locked
    }
}
