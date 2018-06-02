//
//  Permission.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Represents a per-User permission to access a specific resource in the Azure Cosmos DB service,
/// for example Document or Collection.
public struct Permission : CodableResource {
    
    public static var type = "permissions"
    public static var list = "Permissions"

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

    /// Gets or sets the permission mode in the Azure Cosmos DB service.
    public private(set) var permissionMode: PermissionMode
    
    /// Gets or sets the self-link of resource to which the permission applies in the Azure Cosmos DB service.
    public private(set) var resourceLink: String?
    
//    /// Gets or sets optional partition key value for the permission in the Azure Cosmos DB service.
//    /// A permission applies to resources when two conditions are met:
//    ///
//    /// 1. ResourceLink is prefix of resource's link. For example "/dbs/mydatabase/colls/mycollection"
//    ///    applies to "/dbs/mydatabase/colls/mycollection" and "/dbs/mydatabase/colls/mycollection/docs/mydocument"
//    /// 2. ResourcePartitionKey is superset of resource's partition key.
//    ///    For example absent/empty partition key is superset of all partition keys.
//    public private(set) var resourcePartitionKey:   String?
    
    /// Gets the access token granting the defined permission from the Azure Cosmos DB service.
    public private(set) var token: String?
    
    init(_ id: String, mode: PermissionMode, forResource resource: String) {
        self.id = id
        self.resourceId = ""
        self.permissionMode = mode
        self.resourceLink = resource
    }
}


extension Permission {
    enum CodingKeys: String, CodingKey {
        case id
        case resourceId     = "_rid"
        case selfLink       = "_self"
        case etag           = "_etag"
        case timestamp      = "_ts"
        case permissionMode
        case resourceLink   = "resource"
        case token          = "_token"
    }

    init(id: String, resourceId: String, selfLink: String?, etag: String?, timestamp: Date?, altLink: String?, permissionMode: PermissionMode, resourceLink: String?, token: String?) {
        self.id = id
        self.resourceId = resourceId
        self.selfLink = selfLink
        self.etag = etag
        self.timestamp = timestamp
        self.altLink = altLink
        self.permissionMode = permissionMode
        self.resourceLink = resourceLink
        self.token = token
    }
}
