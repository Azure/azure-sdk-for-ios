//
//  ADAttachment.swift
//  AzureData ObjC
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Represents a document attachment in the Azure Cosmos DB service.
@objc(ADAttachment)
public class ADAttachment: NSObject, ADResource, ADSupportsPermissionToken {
    private typealias CodingKeys = Attachment.CodingKeys

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

    /// The MIME content type of the attachment in the
    /// Azure Cosmos DB service.
    @objc
    public let contentType: String?

    /// The media link associated with the attachment content
    /// in the Azure Cosmos DB service.
    @objc
    public let mediaLink: String?

    @objc
    public convenience init(id: String, contentType: String, url: String) {
        self.init(id: id, resourceId: "", selfLink: nil, etag: nil, timestamp: nil, altLink: nil, contentType: contentType, mediaLink: url)
    }

    internal init(id: String, resourceId: String, selfLink: String?, etag: String?, timestamp: Date?, altLink: String?, contentType: String?, mediaLink: String?) {
        self.id = id
        self.resourceId = resourceId
        self.selfLink = selfLink
        self.etag = etag
        self.timestamp = timestamp
        self.altLink = altLink
        self.contentType = contentType
        self.mediaLink = mediaLink
    }

    // MARK: - ADCodable

    public required init?(from dictionary: NSDictionary) {
        guard let id = dictionary[CodingKeys.id] as? String else { return nil }
        guard let resourceId = dictionary[CodingKeys.resourceId] as? String else { return nil }

        self.id = id
        self.resourceId = resourceId
        self.selfLink = dictionary[CodingKeys.selfLink] as? String
        self.etag = dictionary[CodingKeys.etag] as? String
        self.timestamp = ADDateEncoders.decodeTimestamp(from: dictionary[CodingKeys.timestamp])
        self.altLink = nil
        self.contentType = dictionary[CodingKeys.contentType] as? String
        self.mediaLink = dictionary[CodingKeys.mediaLink] as? String
    }

    public func encode() -> NSDictionary {
        let dictionary = NSMutableDictionary()

        dictionary[CodingKeys.id] = id
        dictionary[CodingKeys.resourceId] = resourceId
        dictionary[CodingKeys.selfLink] = selfLink
        dictionary[CodingKeys.etag] = etag
        dictionary[CodingKeys.timestamp] = ADDateEncoders.encodeTimestamp(timestamp)
        dictionary[CodingKeys.contentType] = contentType
        dictionary[CodingKeys.mediaLink] = mediaLink

        return dictionary
    }
}

// MARK: - Objective-C Bridging

extension Attachment: ObjectiveCBridgeable {
    typealias ObjectiveCType = ADAttachment

    func bridgeToObjectiveC() -> ADAttachment {
        return ADAttachment(
            id: self.id,
            resourceId: self.resourceId,
            selfLink: self.selfLink,
            etag: self.etag,
            timestamp: self.timestamp,
            altLink: self.altLink,
            contentType: self.contentType,
            mediaLink: self.mediaLink
        )
    }

    init(bridgedFromObjectiveC: ObjectiveCType) {
        self.init(
            id: bridgedFromObjectiveC.id,
            resourceId: bridgedFromObjectiveC.resourceId,
            selfLink: bridgedFromObjectiveC.selfLink,
            etag: bridgedFromObjectiveC.etag,
            timestamp: bridgedFromObjectiveC.timestamp,
            altLink: bridgedFromObjectiveC.altLink,
            contentType: bridgedFromObjectiveC.contentType,
            mediaLink: bridgedFromObjectiveC.mediaLink
        )
    }
}
