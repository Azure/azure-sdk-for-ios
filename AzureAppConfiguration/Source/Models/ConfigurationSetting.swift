//
//  ConfigurationSetting.swift
//  DemoAppObjC
//
//  Created by Travis Prescott on 8/8/19.
//  Copyright © 2019 Travis Prescott. All rights reserved.
//

import Foundation

public struct ConfigurationSetting: Codable {

    public let key: String
    public let value: String
    public let label: String?
    public let tags: [String: String]?
    public let contentType: String?
    public let etag: String?
    public let locked: Bool
    public let lastModified: Date?

    public static let emptyLabel = "\0"

    init(key: String, value: String, label: String?, tags: Dictionary<String, String>?, contentType: String?, locked: Bool = false) {
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
