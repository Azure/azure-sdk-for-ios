//
//  Trigger.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Represents a trigger in the Azure Cosmos DB service.
///
/// - Remark:
///   Azure Cosmos DB supports pre and post triggers written in JavaScript to be executed on creates, updates and deletes.
///   For additional details, refer to the server-side JavaScript API documentation.
public struct Trigger : CodableResource, SupportsPermissionToken {
    
    public static var type = "triggers"
    public static var list = "Triggers"

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

    /// Gets or sets the body of the trigger for the Azure Cosmos DB service.
    public private(set) var body: String?
    
    /// Gets or sets the operation the trigger is associated with for the Azure Cosmos DB service.
    public private(set) var triggerOperation: TriggerOperation?
    
    /// Get or set the type of the trigger for the Azure Cosmos DB service.
    public private(set) var triggerType: TriggerType?


    /// Specifies the operations on which a trigger should be executed in the Azure Cosmos DB service.
    ///
    /// - all:      Specifies all operations.
    /// - insert:   Specifies insert operations only.
    /// - replace:  Specifies replace operations only.
    /// - delete:   Specifies delete operations only.
    public enum TriggerOperation: String, Codable {
        case all        = "All"
        case insert     = "Insert"
        case replace    = "Replace"
        case delete     = "Delete"
    }
    
    
    /// Specifies the type of the trigger in the Azure Cosmos DB service.
    ///
    /// - pre:  Trigger should be executed after the associated operation(s).
    /// - post: Trigger should be executed before the associated operation(s).
    public enum TriggerType: String, Codable {
        case pre  = "Pre"
        case post = "Post"
    }

    init(_ id: String, body: String, operation: TriggerOperation, type: TriggerType) {
        self.id = id
        self.resourceId = ""
        self.body = body
        self.triggerOperation = operation
        self.triggerType = type
    }
}


extension Trigger {
    enum CodingKeys: String, CodingKey {
        case id
        case resourceId         = "_rid"
        case selfLink           = "_self"
        case etag               = "_etag"
        case timestamp          = "_ts"
        case body
        case triggerOperation
        case triggerType
    }

    init(id: String, resourceId: String, selfLink: String?, etag: String?, timestamp: Date?, altLink: String?, body: String?, triggerOperation: TriggerOperation?, triggerType: TriggerType?) {
        self.id = id
        self.resourceId = resourceId
        self.selfLink = selfLink
        self.etag = etag
        self.timestamp = timestamp
        self.altLink = altLink
        self.triggerOperation = triggerOperation
        self.triggerType = triggerType
    }
}
