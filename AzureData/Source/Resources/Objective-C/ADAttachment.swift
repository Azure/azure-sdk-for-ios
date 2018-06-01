//
//  ADAttachment.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

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

    @objc
    public let contentType: String?

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

    public required init?(from dictionary: NSDictionary) {
        guard let id = dictionary[CodingKeys.id] as? String else { return nil }
        guard let resourceId = dictionary[CodingKeys.resourceId] as? String else { return nil }

        self.id = id
        self.resourceId = resourceId
        self.selfLink = dictionary[CodingKeys.selfLink] as? String
        self.etag = dictionary[CodingKeys.etag] as? String
        self.timestamp = dictionary[CodingKeys.timestamp] as? Date
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
        dictionary[CodingKeys.timestamp] = timestamp
        dictionary[CodingKeys.contentType] = contentType
        dictionary[CodingKeys.mediaLink] = mediaLink

        return dictionary
    }
}

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
}
