//
//  Conflict.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// This is the conflicting resource resulting from a concurrent async operation in the Azure Cosmos DB service.
///
/// - Remark:
///   On rare occasions, during an async operation (insert, replace and delete),
///   a version conflict may occur on a resource. The conflicting resource is persisted as a `Conflict` resource.
///   Inspecting `Conflict` resources will allow you to determine which operations and resources resulted in conflicts.
public struct Conflict : CodableResource {

    public static var type = "conflict"
    public static var list = "Conflicts"
    
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

    /// Gets the operation that resulted in the conflict in the Azure Cosmos DB service.
    public private(set) var operationKind: OperationKind?
    
    /// Gets the type of the conflicting resource in the Azure Cosmos DB service.
    public private(set) var resourceType: String?
    
    /// Gets the resource ID for the conflict in the Azure Cosmos DB service.
    public private(set) var sourceResourceId: String?

    
    /// These are the operation types resulted in a version conflict on a resource.
    ///
    /// - create:   A create operation.
    /// - delete:   A delete operation.
    /// - invalid:  An invalid operation.
    /// - read:     This operation does not apply to Conflict.
    /// - replace:  An replace operation.
    ///
    /// - Remark:
    ///   When a version conflict occurs during an async operation, retrieving the Conflict instance will
    ///   allow you to determine which resource and operation caause the conflict.
    public enum OperationKind : String, Codable {
        case create     = "Create"
        case delete     = "Delete"
        case invalid    = "Invalid"
        case read       = "Read"
        case replace    = "Replace"
    }
    
    public init (_ id: String) { self.id = id; resourceId = "" }
}

private extension Conflict {
    
    private enum CodingKeys: String, CodingKey {
        case id
        case resourceId         = "_rid"
        case selfLink           = "_self"
        case etag               = "_etag"
        case timestamp          = "_ts"
        case operationKind
        case resourceType
        case sourceResourceId
    }
}
