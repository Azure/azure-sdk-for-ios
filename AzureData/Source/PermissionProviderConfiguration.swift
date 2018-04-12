//
//  PermissionProviderConfiguration.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

public struct PermissionProviderConfiguration {
    
    public static let `default`: PermissionProviderConfiguration = PermissionProviderConfiguration()
    
    // get readWrite token even for read operations to prevent scenario of
    // getting a read token for a read operation then subsequently performing
    // a write operation on the same resource requiring another round trip to
    // server to get a token with write permissions.
    //
    // if this is set to .all, should always request a readWrite token from server
    //
    // default: .read
    public var defaultPermissionMode: PermissionMode = .read
    
    // this specifies the at what level of the resource hierarchy
    // (Database/Collection/Document) to request a resource token
    //
    // for example, if this property is set to .collection and the user tries to
    // write to a document, we'd request a readWrite resource token for the
    // entire collection versus requesting a token only for the document
    //
    // default: .collection
    public var defaultResourceType: ResourceType? = .collection
    
    
    public var defaultTokenDuration: Double = 3600 // 1 hour
    
    public var tokenRefreshThreshold: Double = 600 // 10 minutes
}
