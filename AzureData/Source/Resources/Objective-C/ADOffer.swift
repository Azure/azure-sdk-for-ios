//
//  ADOffer.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

@objc(ADOffer)
public class ADOffer: NSObject, ADResource {
    private typealias CodingKeys = Offer.CodingKeys

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
    public let offerType: String?

    @objc
    public let offerVersion: String?

    @objc
    public let resourceLink: String?

    @objc
    public let offerResourceId: String?

    @objc
    public let content: ADOfferContent?

    @objc
    public convenience init(id: String) {
        self.init(id: id, resourceId: "", selfLink: nil, etag: nil, timestamp: nil, altLink: nil, offerType: nil, offerVersion: nil, resourceLink: nil, offerResourceId: nil, content: nil)
    }

    internal init(id: String, resourceId: String, selfLink: String?, etag: String?, timestamp: Date?, altLink: String?, offerType: String?, offerVersion: String?, resourceLink: String?, offerResourceId: String?, content: ADOfferContent?) {
        self.id = id
        self.resourceId = resourceId
        self.selfLink = selfLink
        self.etag = etag
        self.timestamp = timestamp
        self.altLink = altLink
        self.offerType = offerType
        self.offerVersion = offerVersion
        self.resourceLink = resourceLink
        self.offerResourceId = offerResourceId
        self.content = content
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
        self.offerType = dictionary[CodingKeys.offerType] as? String
        self.offerVersion = dictionary[CodingKeys.offerVersion] as? String
        self.resourceLink = dictionary[CodingKeys.resourceLink] as? String
        self.offerResourceId = dictionary[CodingKeys.offerResourceId] as? String

        if let content = dictionary[CodingKeys.content] as? NSDictionary {
            self.content = ADOfferContent(from: content)
        } else {
            self.content = nil
        }
    }

    public func encode() -> NSDictionary {
        let dictionary = NSMutableDictionary()

        dictionary[CodingKeys.id] = id
        dictionary[CodingKeys.resourceId] = resourceId
        dictionary[CodingKeys.selfLink] = selfLink
        dictionary[CodingKeys.etag] = etag
        dictionary[CodingKeys.timestamp] = ADDateEncoders.encodeTimestamp(timestamp)
        dictionary[CodingKeys.offerType] = offerType
        dictionary[CodingKeys.offerVersion] = offerVersion
        dictionary[CodingKeys.resourceLink] = resourceLink
        dictionary[CodingKeys.offerResourceId] = offerResourceId
        dictionary[CodingKeys.content] = content?.encode()

        return dictionary
    }
}

extension Offer: ObjectiveCBridgeable {
    typealias ObjectiveCType = ADOffer

    func bridgeToObjectiveC() -> ADOffer {
        return ADOffer(
            id: self.id,
            resourceId: self.resourceId,
            selfLink: self.selfLink,
            etag: self.etag,
            timestamp: self.timestamp,
            altLink: self.altLink,
            offerType: self.offerType,
            offerVersion: self.offerVersion,
            resourceLink: self.resourceLink,
            offerResourceId: self.offerResourceId,
            content: self.content?.bridgeToObjectiveC()
        )
    }

    init(bridgedFromObjectiveC: ADOffer) {
        let offerContent: OfferContent? = {
            guard let content = bridgedFromObjectiveC.content else { return nil }
            return OfferContent(bridgedFromObjectiveC: content)
        }()

        self.init(
            id: bridgedFromObjectiveC.id,
            resourceId: bridgedFromObjectiveC.resourceId,
            selfLink: bridgedFromObjectiveC.selfLink,
            etag: bridgedFromObjectiveC.etag,
            timestamp: bridgedFromObjectiveC.timestamp,
            altLink: bridgedFromObjectiveC.altLink,
            offerType: bridgedFromObjectiveC.offerType,
            offerVersion: bridgedFromObjectiveC.offerVersion,
            resourceLink: bridgedFromObjectiveC.resourceLink,
            offerResourceId: bridgedFromObjectiveC.offerResourceId,
            content: offerContent
        )
    }
}
