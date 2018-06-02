//
//  ADPermission.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

@objc(ADPermission)
public class ADPermission: NSObject, ADResource {
    private typealias CodingKeys = Permission.CodingKeys

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
    public let permissionMode: ADPermissionMode

    @objc
    public let resourceLink: String?

    @objc
    public let token: String?

    @objc
    public convenience init(id: String, mode: ADPermissionMode) {
        self.init(id: id, resourceId: "", selfLink: nil, etag: nil, timestamp: nil, altLink: nil, permissionMode: mode, resourceLink: nil, token: nil)
    }

    internal init(id: String, resourceId: String, selfLink: String?, etag: String?, timestamp: Date?, altLink: String?, permissionMode: ADPermissionMode, resourceLink: String?, token: String?) {
        self.id = id
        self.resourceId = resourceId
        self.selfLink = selfLink
        self.etag = etag
        self.timestamp = timestamp
        self.altLink = altLink
        self.permissionMode = permissionMode
        self.resourceLink = resourceLink
        self.token = token
    }

    public required init?(from dictionary: NSDictionary) {
        guard let id = dictionary[CodingKeys.id] as? String else { return nil }
        guard let resourceId = dictionary[CodingKeys.resourceId] as? String else { return nil }
        guard let permissionMode = dictionary[CodingKeys.permissionMode] as? String else { return nil }

        self.id = id
        self.resourceId = resourceId
        self.selfLink = dictionary[CodingKeys.selfLink] as? String
        self.etag = dictionary[CodingKeys.etag] as? String
        self.timestamp = ADDateEncoders.decodeTimestamp(from: dictionary[CodingKeys.timestamp])
        self.altLink = nil
        self.permissionMode = ADPermissionMode(PermissionMode(rawValue: permissionMode)!)
        self.resourceLink = dictionary[CodingKeys.resourceLink] as? String
        self.token = dictionary[CodingKeys.token] as? String
    }

    public func encode() -> NSDictionary {
        let dictionary = NSMutableDictionary()

        dictionary[CodingKeys.id] = id
        dictionary[CodingKeys.resourceId] = resourceId
        dictionary[CodingKeys.selfLink] = selfLink
        dictionary[CodingKeys.etag] = etag
        dictionary[CodingKeys.timestamp] = ADDateEncoders.encodeTimestamp(timestamp)
        dictionary[CodingKeys.permissionMode] = permissionMode.permissionMode.rawValue
        dictionary[CodingKeys.resourceLink] = resourceLink
        dictionary[CodingKeys.token] = token

        return dictionary
    }
}

extension Permission: ObjectiveCBridgeable {
    typealias ObjectiveCType = ADPermission

    func bridgeToObjectiveC() -> ADPermission {
        return ADPermission(
            id: self.id,
            resourceId: self.resourceId,
            selfLink: self.selfLink,
            etag: self.etag,
            timestamp: self.timestamp,
            altLink: self.altLink,
            permissionMode: ADPermissionMode(self.permissionMode),
            resourceLink: self.resourceLink,
            token: self.token
        )
    }

    init(bridgedFromObjectiveC: ADPermission) {
        self.init(
            id: bridgedFromObjectiveC.id,
            resourceId: bridgedFromObjectiveC.resourceId,
            selfLink: bridgedFromObjectiveC.selfLink,
            etag: bridgedFromObjectiveC.etag,
            timestamp: bridgedFromObjectiveC.timestamp,
            altLink: bridgedFromObjectiveC.altLink,
            permissionMode: bridgedFromObjectiveC.permissionMode.permissionMode,
            resourceLink: bridgedFromObjectiveC.resourceLink,
            token: bridgedFromObjectiveC.token
        )
    }
}
