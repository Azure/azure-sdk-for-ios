//
//  Attachment.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Represents a document attachment in the Azure Cosmos DB service.
public struct Attachment : CodableResource {
    
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
    
    /// Gets or sets the MIME content type of the attachment in the Azure Cosmos DB service.
    public private(set) var contentType: String?
    
    /// Gets or sets the media link associated with the attachment content in the Azure Cosmos DB service.
    public private(set) var mediaLink: String?

    
    init(withId id: String, contentType: String, url: String) {
        self.id = id
        self.resourceId = ""
        self.contentType = contentType
        self.mediaLink = url
    }
}


private extension Attachment {
    
    private enum CodingKeys: String, CodingKey {
        case id
        case resourceId         = "_rid"
        case selfLink           = "_self"
        case etag               = "_etag"
        case timestamp          = "_ts"
        case contentType
        case mediaLink          = "media"
    }
}
