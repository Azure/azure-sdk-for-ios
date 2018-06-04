//
//  StoredProcedure.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Represents a stored procedure in the Azure Cosmos DB service.
///
/// - Remark:
///   Azure Cosmos DB allows application logic written entirely in JavaScript to be executed directly inside
///   the database engine under the database transaction.
///   For additional details, refer to the server-side JavaScript API documentation.
public struct StoredProcedure : CodableResource, SupportsPermissionToken {
    
    public static var type = "sprocs"
    public static var list = "StoredProcedures"

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

    /// Gets or sets the body of the Azure Cosmos DB stored procedure.
    ///
    /// - Remark:
    ///   Must be a valid JavaScript function.
    ///
    /// - Example:
    ///   `"function () { getContext().getResponse().setBody('Hello World!'); }`
    public private(set) var body:       String?
    
    public init (_ id: String, body: String) {
        self.id = id
        self.resourceId = ""
        self.body = body
    }
}


extension StoredProcedure {
    enum CodingKeys: String, CodingKey {
        case id
        case resourceId         = "_rid"
        case selfLink           = "_self"
        case etag               = "_etag"
        case timestamp          = "_ts"
        case body
    }

    init(id: String, resourceId: String, selfLink: String?, etag: String?, timestamp: Date?, altLink: String?, body: String?) {
        self.id = id
        self.resourceId = resourceId
        self.selfLink = selfLink
        self.etag = etag
        self.timestamp = timestamp
        self.altLink = altLink
        self.body = body
    }
}
