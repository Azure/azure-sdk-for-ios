//
//  ADStoredProcedure.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

@objc(ADStoredProcedure)
public class ADStoredProcedure: NSObject, ADResource, ADSupportsPermissionToken {
    private typealias CodingKeys = StoredProcedure.CodingKeys

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
    public let body: String?

    @objc
    public convenience init(id: String, body: String) {
        self.init(id: id, resourceId: "", selfLink: nil, etag: nil, timestamp: nil, altLink: nil, body: body)
    }

    internal init(id: String, resourceId: String, selfLink: String?, etag: String?, timestamp: Date?, altLink: String?, body: String?) {
        self.id = id
        self.resourceId = resourceId
        self.selfLink = selfLink
        self.etag = etag
        self.timestamp = timestamp
        self.altLink = altLink
        self.body = body
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
        self.body = dictionary[CodingKeys.body] as? String
    }

    public func encode() -> NSDictionary {
        let dictionary = NSMutableDictionary()

        dictionary[CodingKeys.id] = id
        dictionary[CodingKeys.resourceId] = resourceId
        dictionary[CodingKeys.selfLink] = selfLink
        dictionary[CodingKeys.etag] = etag
        dictionary[CodingKeys.timestamp] = ADDateEncoders.encodeTimestamp(timestamp)
        dictionary[CodingKeys.body] = body

        return dictionary
    }
}

extension StoredProcedure: ObjectiveCBridgeable {
    typealias ObjectiveCType = ADStoredProcedure

    func bridgeToObjectiveC() -> ADStoredProcedure {
        return ADStoredProcedure(
            id: self.id,
            resourceId: self.resourceId,
            selfLink: self.selfLink,
            etag: self.etag,
            timestamp: self.timestamp,
            altLink: self.altLink,
            body: self.body
        )
    }

    init(bridgedFromObjectiveC: ADStoredProcedure) {
        self.init(
            id: bridgedFromObjectiveC.id,
            resourceId: bridgedFromObjectiveC.resourceId,
            selfLink: bridgedFromObjectiveC.selfLink,
            etag: bridgedFromObjectiveC.etag,
            timestamp: bridgedFromObjectiveC.timestamp,
            altLink: bridgedFromObjectiveC.altLink,
            body: bridgedFromObjectiveC.body
        )
    }
}
