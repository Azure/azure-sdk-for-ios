//
//  User.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Represents a user in the Azure Cosmos DB service.
public struct User : CodableResource {
    
    public static var type = "users"
    public static var list = "Users"

    public internal(set) var id:         String
    public internal(set) var resourceId: String
    public internal(set) var selfLink:   String?
    public internal(set) var etag:       String?
    public internal(set) var timestamp:  Date?
    public internal(set) var altLink:    String? = nil
    
    public mutating func setAltLink(to link: String) {
        self.altLink = link
    }
    public mutating func setEtag(to tag: String) {
        self.etag = tag
    }

    /// Gets the self-link of the permissions associated with the user for the Azure Cosmos DB service.
    public internal(set) var permissionsLink:String?
    
    public init (_ id: String) { self.id = id; resourceId = "" }
}


extension User {
    
    enum CodingKeys: String, CodingKey {
        case id
        case resourceId         = "_rid"
        case selfLink           = "_self"
        case etag               = "_etag"
        case timestamp          = "_ts"
        case permissionsLink    = "_permissions"
    }
}
