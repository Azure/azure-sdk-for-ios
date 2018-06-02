//
//  ObjectiveCWrappers.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class CodableResourceObjectiveWrapper: ADResource {
    private typealias CodingKeys = ADResourceSystemKeys

    var id: String
    var resourceId: String
    var selfLink: String?
    var etag: String?
    var timestamp: Date?
    var altLink: String?

    init(_ resource: CodableResource) {
        self.id = resource.id
        self.resourceId = resource.resourceId
        self.selfLink = resource.selfLink
        self.etag = resource.etag
        self.timestamp = resource.timestamp
        self.altLink = resource.altLink
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
    }

    public func encode() -> NSDictionary {
        let dictionary = NSMutableDictionary()

        dictionary[CodingKeys.id] = id
        dictionary[CodingKeys.resourceId] = resourceId
        dictionary[CodingKeys.selfLink] = selfLink
        dictionary[CodingKeys.etag] = etag
        dictionary[CodingKeys.timestamp] = ADDateEncoders.encodeTimestamp(timestamp)

        return dictionary
    }
}
