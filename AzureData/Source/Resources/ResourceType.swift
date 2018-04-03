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
    
    var path: String {
        return self.rawValue
    }
    
    func isDecendent(of rt: ResourceType) -> Bool {
        switch self {
        case .database,
             .offer:            return false
        case .user,
             .collection:       return rt == .database
        case .document,
             .storedProcedure,
             .trigger,
             .udf:              return rt == .collection || rt == .database
        case .permission:       return rt == .user       || rt == .database
        case .attachment:       return rt == .document   || rt == .collection || rt == .database
        }
    }
    
    func isAncestor(of rt: ResourceType) -> Bool {
        return rt.isDecendent(of: self)
    }
    
    var supportsPermissionToken: Bool {
        switch self {
        case .database, .offer, .user, .permission: return false
        case .collection, .document, .storedProcedure, .trigger, .udf, .attachment: return true
        }
    }
    
    static var ancestors: [ResourceType] {
        return [ .database, .user, .collection, .document ]
    }
}
