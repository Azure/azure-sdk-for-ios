//
//  Document.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Represents a document in the Azure Cosmos DB service.
///
/// - Remark:
///   A document is a structured JSON document. There is no set schema for the JSON documents,
///   and a document may contain any number of custom properties as well as an optional list of attachments.
///   Document is an application resource and can be authorized using the master key or resource keys.
open class Document : CodableResource, SupportsPermissionToken, CustomDebugStringConvertible {

    public static var type = "docs"
    public static var list = "Documents"
    
    public internal(set) var id:         String
    public internal(set) var resourceId: String
    public internal(set) var selfLink:   String?
    public internal(set) var etag:       String?
    public internal(set) var timestamp:  Date?
    public internal(set) var altLink:    String? = nil
    
    public func setAltLink(to link: String) {
        self.altLink = link
    }
    public func setEtag(to tag: String) {
        self.etag = tag
    }

    /// Gets the self-link corresponding to attachments of the document from the Azure Cosmos DB service.
    public internal(set) var attachmentsLink: String?
    
    /// Gets or sets the time to live in seconds of the document in the Azure Cosmos DB service.
    public var timeToLive: Int? = nil
    
    
    public init () { id = UUID().uuidString; resourceId = "" }
    public init (_ id: String) { self.id = id; resourceId = "" }
    
    
    open var debugDescription: String {
        return "Document :\n\tid : \(self.id)\n\tresourceId : \(self.resourceId)\n\tselfLink : \(self.selfLink.valueOrNilString)\n\tetag : \(self.etag.valueOrNilString)\n\ttimestamp : \(self.timestamp.valueOrNilString)\n\taltLink : \(self.altLink.valueOrNilString)\n\tattachmentsLink : \(self.attachmentsLink.valueOrNilString)\n--"
    }
}


extension Document {
    
    enum CodingKeys: String, CodingKey {
        case id
        case resourceId         = "_rid"
        case selfLink           = "_self"
        case etag               = "_etag"
        case timestamp          = "_ts"
        case attachmentsLink    = "_attachments"
    }
}

public extension Document {
    
    public static var testDocument: Document {
        let document = Document()
        document.resourceId = "TC1AAMDvwgB4AAAAAAAAAA=="
        document.selfLink = "dbs/TC1AAA==/colls/TC1AAMDvwgA=/docs/TC1AAMDvwgB4AAAAAAAAAA=="
        document.etag = "\"88005b65-0000-0000-0000-5a0dfabb0000\""
        document.attachmentsLink = "attachments/"
        document.timestamp = Date(timeIntervalSince1970: 1510865595)
        document.altLink = "dbs/MyDatabase/colls/MyCollection/docs/MyDocument"
        return document
    }
}

