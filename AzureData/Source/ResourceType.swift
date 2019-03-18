//
//  ResourceType.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

public enum ResourceType : String {
    case database           = "dbs"
    case user               = "users"
    case permission         = "permissions"
    case collection         = "colls"
    case storedProcedure    = "sprocs"
    case trigger            = "triggers"
    case udf                = "udfs"
    case document           = "docs"
    case attachment         = "attachments"
    case offer              = "offers"
    case partitionKeyRange  = "pkranges"

    var path: String {
        return self.rawValue
    }
    
    func isDecendent(of rt: ResourceType) -> Bool {
        switch self {
        case .database,
             .offer:             return false
        case .user,
             .collection:        return rt == .database
        case .document,
             .storedProcedure,
             .trigger,
             .udf:               return rt == .collection || rt == .database
        case .permission:        return rt == .user       || rt == .database
        case .attachment:        return rt == .document   || rt == .collection || rt == .database
        case .partitionKeyRange: return rt == .collection || rt == .database
        }
    }
    
    func isAncestor(of rt: ResourceType) -> Bool {
        return rt.isDecendent(of: self)
    }
    
    var supportsPermissionToken: Bool {
        switch self {
        case .database, .offer, .user, .permission, .partitionKeyRange: return false
        case .collection, .document, .storedProcedure, .trigger, .udf, .attachment: return true
        }
    }

    var children: [ResourceType] {
        switch self {
        case .database:          return [.collection, .user]
        case .user:              return [.permission]
        case .permission:        return []
        case .collection:        return [.document, .storedProcedure, .trigger, .udf, .partitionKeyRange]
        case .document:          return [.attachment]
        case .storedProcedure:   return []
        case .trigger:           return []
        case .udf:               return []
        case .attachment:        return []
        case .offer:             return []
        case .partitionKeyRange: return []
        }
    }

    static var ancestors: [ResourceType] {
        return [ .database, .user, .collection, .document ]
    }
}
