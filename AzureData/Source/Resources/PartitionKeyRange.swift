//
//  PartitionKeyRange.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

internal struct PartitionKeyRange: CodableResource {
    internal enum CodingKeys: String, CodingKey {
        case id
        case resourceId         = "_rid"
        case selfLink           = "_self"
        case etag               = "_etag"
        case timestamp          = "_ts"
    }

    internal static var type = "pkranges"
    internal static var list = "PartitionKeyRanges"

    internal private(set) var id:         String
    internal private(set) var resourceId: String
    internal private(set) var selfLink:   String?
    internal private(set) var etag:       String?
    internal private(set) var timestamp:  Date?
    internal private(set) var altLink:    String? = nil

    internal private(set) var minExclusive: String?
    internal private(set) var maxExclusive: String?

    internal mutating func setAltLink(to link: String) { self.altLink = link }
    internal mutating func setEtag(to tag: String) { self.etag = tag }
}
