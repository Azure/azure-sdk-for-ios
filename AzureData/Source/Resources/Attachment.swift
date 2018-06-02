//
//  Attachment.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Represents a document attachment in the Azure Cosmos DB service.
public struct Attachment : CodableResource, SupportsPermissionToken {
    
    public static var type = "attachments"
    public static var list = "Attachments"
    
    public private(set) var id:         String
    public private(set) var resourceId: String
    public private(set) var selfLink:   String?
    public private(set) var etag:       String?
    public private(set) var timestamp:  Date?
    public private(set) var altLink:    String? = nil
    
    public mutating func setAltLink(to link: String) {
        self.altLink = link
    }
    public mutating func setEtag(to tag: String) {
        self.etag = tag
    }
    
    /// Gets or sets the MIME content type of the attachment in the Azure Cosmos DB service.
    public private(set) var contentType: String?
    
    /// Gets or sets the media link associated with the attachment content in the Azure Cosmos DB service.
    public private(set) var mediaLink: String?

    
    init(_ id: String, contentType: String, url: String) {
        self.id = id
        self.resourceId = ""
        self.contentType = contentType
        self.mediaLink = url
    }
}


extension Attachment {
    enum CodingKeys: String, CodingKey {
        case id
        case resourceId         = "_rid"
        case selfLink           = "_self"
        case etag               = "_etag"
        case timestamp          = "_ts"
        case contentType
        case mediaLink          = "media"
    }

    init(id: String, resourceId: String, selfLink: String?, etag: String?, timestamp: Date?, altLink: String?, contentType: String?, mediaLink: String?) {
        self.id = id
        self.resourceId = resourceId
        self.selfLink = selfLink
        self.etag = etag
        self.timestamp = timestamp
        self.altLink = altLink
        self.contentType = contentType
        self.mediaLink = mediaLink
    }
}
