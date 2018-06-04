//
//  ResourceSystemProperties.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Used to extract Cosmos DB system properties from
/// a resource encoded as a `CodableResource` or a `Data` object
/// without knowing its explicit type.
struct ResourceSystemProperties: CodableResource {
    enum CodingKeys: String, CodingKey {
        case id
        case resourceId         = "_rid"
        case selfLink           = "_self"
        case etag               = "_etag"
        case timestamp          = "_ts"
    }

    static var type = ""
    static var list = ""

    var id:         String
    var resourceId: String
    var selfLink:   String?
    var etag:       String?
    var timestamp:  Date?
    var altLink:    String? = nil

    mutating func setEtag(to tag: String) { etag = tag }
    mutating func setAltLink(to link: String) { altLink = link }

    init(for resource: CodableResource) {
        self.id = resource.id
        self.resourceId = resource.resourceId
        self.selfLink = resource.selfLink
        self.etag = resource.etag
        self.timestamp = resource.timestamp
        self.altLink = resource.altLink
    }

    init?(for data: Data) {
        guard let props = try? JSONDecoder().decode(ResourceSystemProperties.self, from: data) else {
            return nil
        }

        self = props
    }
}

extension Data {
    var id: String? {
        return ResourceSystemProperties(for: self)?.id
    }

    var resourceId: String? {
        return ResourceSystemProperties(for: self)?.resourceId
    }

    var selfLink: String? {
        return ResourceSystemProperties(for: self)?.selfLink
    }

    var etag: String? {
        return ResourceSystemProperties(for: self)?.etag
    }
}
