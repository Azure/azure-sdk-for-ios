//
//  PermissionMode.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// These are the access permissions for creating or replacing a Permission resource in the Azure Cosmos DB service.
///
/// - read: All permission mode will provide the user with full access(read, insert, replace and delete)
///         to a resource.
/// - all:  Read permission mode will provide the user with Read only access to a resource.
public enum PermissionMode: String, Codable {
    case read   = "Read"
    case all    = "All"
}
