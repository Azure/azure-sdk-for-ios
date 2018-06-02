//
//  ADDatabase.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

@objc(ADDatabase)
public class ADDatabase: NSObject, ADResource {
    private typealias CodingKeys = Database.CodingKeys

    @objc
    public let id: String

    @objc
    public let resourceId: String

    @objc
    public let selfLink: String?

    @objc
    public let etag: String?

    @objc
    public let altLink: String?

    @objc
    public let timestamp: Date?

    @objc
    public let collectionsLink: String?

    @objc
    public let usersLink: String?

    @objc
    public convenience init(_ id: String) {
        self.init(id: id, resourceId: "", selfLink: nil, etag: nil, altLink: nil, timestamp: nil, collectionsLink: nil, usersLink: nil)
    }

    internal init(id: String, resourceId: String, selfLink: String?, etag: String?, altLink: String?, timestamp: Date?, collectionsLink: String?, usersLink: String?) {
        self.id = id
        self.resourceId = resourceId
        self.selfLink = selfLink
        self.etag = etag
        self.altLink = altLink
        self.timestamp = timestamp
        self.collectionsLink = collectionsLink
        self.usersLink = usersLink
    }

    public required init?(from dictionary: NSDictionary) {
        guard let id = dictionary[CodingKeys.id] as? String else { return nil }
        guard let resourceId = dictionary[CodingKeys.resourceId] as? String else { return nil }

        self.id = id
        self.resourceId = resourceId
        self.selfLink = dictionary[CodingKeys.selfLink] as? String
        self.etag = dictionary[CodingKeys.etag] as? String
        self.timestamp = ADDateEncoders.decodeTimestamp(from: dictionary[CodingKeys.timestamp])
        self.altLink = nil
        self.collectionsLink = dictionary[CodingKeys.collectionsLink] as? String
        self.usersLink = dictionary[CodingKeys.usersLink] as? String
    }

    public func encode() -> NSDictionary {
        let dictionary = NSMutableDictionary()

        dictionary[CodingKeys.id] = id
        dictionary[CodingKeys.resourceId] = resourceId
        dictionary[CodingKeys.selfLink] = selfLink
        dictionary[CodingKeys.etag] = etag
        dictionary[CodingKeys.timestamp] = ADDateEncoders.encodeTimestamp(timestamp)
        dictionary[CodingKeys.collectionsLink] = collectionsLink
        dictionary[CodingKeys.usersLink] = usersLink

        return dictionary
    }
}

extension Database: ObjectiveCBridgeable {
    typealias ObjectiveCType = ADDatabase

    func bridgeToObjectiveC() -> ADDatabase {
        return ADDatabase(
            id: id,
            resourceId: resourceId,
            selfLink: selfLink,
            etag: etag,
            altLink: altLink,
            timestamp: timestamp,
            collectionsLink: collectionsLink,
            usersLink: usersLink
        )
    }

    init(bridgedFromObjectiveC: ADDatabase) {
        self.init(
            id: bridgedFromObjectiveC.id,
            resourceId: bridgedFromObjectiveC.resourceId,
            selfLink: bridgedFromObjectiveC.selfLink,
            etag: bridgedFromObjectiveC.etag,
            timestamp: bridgedFromObjectiveC.timestamp,
            altLink: bridgedFromObjectiveC.altLink,
            collectionsLink: bridgedFromObjectiveC.collectionsLink,
            usersLink: bridgedFromObjectiveC.usersLink
        )
    }
}
