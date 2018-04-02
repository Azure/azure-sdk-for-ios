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
}
