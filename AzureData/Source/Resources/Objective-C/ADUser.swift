//
//  ADUser.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

@objc(ADUser)
public class ADUser: NSObject, ADResource {
    private typealias CodingKeys = User.CodingKeys

    @objc
    public let id: String

    @objc
    public let resourceId: String

    @objc
    public let selfLink: String?

    @objc
    public let etag: String?

    @objc
    public let timestamp: Date?

    @objc
    public let altLink: String?

    @objc
    public let permissionsLink: String?

    @objc
    public convenience init(id: String, permissionsLink: String? = nil) {
        self.init(id: id, resourceId: "", selfLink: nil, etag: nil, timestamp: nil, altLink: nil, permissionsLink: permissionsLink)
    }

    internal init(id: String, resourceId: String, selfLink: String?, etag: String?, timestamp: Date?, altLink: String?, permissionsLink: String?) {
        self.id = id
        self.resourceId = resourceId
        self.selfLink = selfLink
        self.etag = etag
        self.timestamp = timestamp
        self.altLink = altLink
        self.permissionsLink = permissionsLink
    }

    public required init?(from dictionary: NSDictionary) {
        guard let id = dictionary.value(forKey: User.CodingKeys.id.rawValue) as? String else { return nil }
        guard let resourceId = dictionary.value(forKey: User.CodingKeys.resourceId.rawValue) as? String else { return nil }

        self.id = id
        self.resourceId = resourceId
        self.selfLink = dictionary[CodingKeys.selfLink] as? String
        self.etag = dictionary[CodingKeys.etag] as? String
        self.timestamp = dictionary[CodingKeys.timestamp] as? Date
        self.altLink = nil
        self.permissionsLink = dictionary[CodingKeys.permissionsLink] as? String
    }

    public func encode() -> NSDictionary {
        let dictionary = NSMutableDictionary()

        dictionary[CodingKeys.id] = id
        dictionary[CodingKeys.resourceId] = resourceId
        dictionary[CodingKeys.selfLink] = selfLink
        dictionary[CodingKeys.etag] = etag
        dictionary[CodingKeys.timestamp] = timestamp
        dictionary[CodingKeys.permissionsLink] = permissionsLink

        return dictionary
    }
}

extension User: ObjectiveCBridgeable {
    typealias ObjectiveCType = ADUser

    func bridgeToObjectiveC() -> ADUser {
        return ADUser(
            id: self.id,
            resourceId: self.resourceId,
            selfLink: self.selfLink,
            etag: self.etag,
            timestamp: self.timestamp,
            altLink: self.altLink,
            permissionsLink: self.permissionsLink
        )
    }

    init?(bridgedFromObjectiveC: ADUser) {
        self.id = bridgedFromObjectiveC.id
        self.resourceId = bridgedFromObjectiveC.resourceId
        self.selfLink = bridgedFromObjectiveC.selfLink
        self.etag = bridgedFromObjectiveC.etag
        self.timestamp = bridgedFromObjectiveC.timestamp
        self.altLink = bridgedFromObjectiveC.altLink
        self.permissionsLink = bridgedFromObjectiveC.permissionsLink
    }
}
