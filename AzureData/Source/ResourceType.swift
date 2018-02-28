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
        switch self {
        case .database:         return "dbs"
        case .user:             return "users"
        case .permission:       return "permissions"
        case .collection:       return "colls"
        case .storedProcedure:  return "sprocs"
        case .trigger:          return "triggers"
        case .udf:              return "udfs"
        case .document:         return "docs"
        case .attachment:       return "attachments"
        case .offer:            return "offers"
        }
    }
    
    var key: String {
        switch self {
        case .database:         return "Databases"
        case .user:             return "Users"
        case .permission:       return "Permissions"
        case .collection:       return "DocumentCollections"
        case .storedProcedure:  return "StoredProcedures"
        case .trigger:          return "Triggers"
        case .udf:              return "UserDefinedFunctions"
        case .document:         return "Documents"
        case .attachment:       return "Attachments"
        case .offer:            return "Offers"
        }
    }

    var name: String {
        switch self {
        case .database:         return "Database"
        case .user:             return "User"
        case .permission:       return "Permission"
        case .collection:       return "DocumentCollection"
        case .storedProcedure:  return "StoredProcedure"
        case .trigger:          return "Trigger"
        case .udf:              return "UserDefinedFunction"
        case .document:         return "Document"
        case .attachment:       return "Attachment"
        case .offer:            return "Offer"
        }
    }
}
