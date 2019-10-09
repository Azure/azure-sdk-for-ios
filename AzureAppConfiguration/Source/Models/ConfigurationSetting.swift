//
//  ConfigurationSetting.swift
//  DemoAppObjC
//
//  Created by Travis Prescott on 8/8/19.
//  Copyright © 2019 Travis Prescott. All rights reserved.
//

import AzureCore
import Foundation

public struct ConfigurationSetting: Codable {
    public let key: String
    public let value: String
    public let label: String?
    public let tags: [String: String]?
    public let contentType: String?
    public let etag: String?
    public let locked: Bool?
    public let lastModified: Date?

    public static let emptyLabel = "\0"

    init(key: String,
         value: String,
         label: String? = nil,
         tags: [String: String]? = nil,
         contentType: String? = nil,
         locked: Bool? = nil,
         lastModified: Date? = nil,
         eTag: String? = nil) {
        self.key = key
        self.value = value
        self.label = label
        self.tags = tags
        self.contentType = contentType
        etag = eTag
        self.lastModified = lastModified
        self.locked = locked
    }
}
