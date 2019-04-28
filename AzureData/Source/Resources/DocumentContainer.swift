//
//  Document.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

final class DocumentContainer<DocumentType: Document>: CodableResource, SupportsPermissionToken, CustomDebugStringConvertible {
    static var type: String { return "docs" }
    static var list: String { return "Documents" }

    var id: String { return document.id }
    var resourceId: String { return metadata?.resourceId ?? "" }
    var selfLink: String? { return metadata?.selfLink }
    var etag: String? { return metadata?.etag }
    var timestamp: Date? { return metadata?.timestamp }
    var altLink: String? { return metadata?.altLink }
    var attachmentsLink: String? { return metadata?.attachmentsLink }

    var metadata: DocumentMetadata?
    var document: DocumentType

    func setAltLink(to link: String) {
        metadata?.altLink = link
    }

    func setEtag(to tag: String) {
        metadata?.etag = tag
    }

    internal init(_ document: DocumentType) {
        self.metadata = DocumentMetadata(resourceId: "")
        self.document = document
    }

    var debugDescription: String {
        return "DocumentContainer :\n\tid : \(self.id)\n\tresourceId : \(self.resourceId)\n\tselfLink : \(self.selfLink.valueOrNilString)\n\tetag : \(self.etag.valueOrNilString)\n\ttimestamp : \(self.timestamp.valueOrNilString)\n\taltLink : \(self.altLink.valueOrNilString)\n\tattachmentsLink : \(self.attachmentsLink.valueOrNilString)\n--"
    }

    required init(from decoder: Decoder) throws {
        self.metadata = try? DocumentMetadata(from: decoder)
        self.document = try DocumentType(from: decoder)
        if let metadata = self.metadata {
            self.document.metadata = metadata
        }
    }

    func encode(to encoder: Encoder) throws {
        try metadata?.encode(to: encoder)
        try document.encode(to: encoder)
    }
}

final class DocumentMetadata: Codable {
    enum CodingKeys: String, CodingKey {
        case resourceId         = "_rid"
        case selfLink           = "_self"
        case etag               = "_etag"
        case timestamp          = "_ts"
        case attachmentsLink    = "_attachments"
    }

    let resourceId: String
    let selfLink:   String?
    var etag:       String?
    let timestamp:  Date?
    var altLink:    String? = nil
    let attachmentsLink: String?

    func setAltLink(to link: String) {
        altLink = link
    }

    func setEtag(to tag: String) {
        etag = tag
    }

    init(resourceId: String, selfLink: String? = nil, etag: String? = nil, timestamp: Date? = nil, altLink: String? = nil, attachmentsLink: String? = nil) {
        self.resourceId = resourceId
        self.selfLink = selfLink
        self.etag = etag
        self.timestamp = timestamp
        self.altLink = altLink
        self.attachmentsLink = attachmentsLink
    }
}
