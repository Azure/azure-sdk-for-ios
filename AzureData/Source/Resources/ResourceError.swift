//
//  ResourceError.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Encapsulates error related details in the Azure Cosmos DB service.
public struct ResourceError : CodableResource {

    public static var type = "error"
    public static var list = "Errors"
    
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

    /// Gets or sets the textual description of error code in the Azure Cosmos DB service.
    public private(set) var code: String?
    
    /// Gets or sets the error message in the Azure Cosmos DB service.
    public private(set) var message: String?
    
    public init (_ id: String) { self.id = id; resourceId = "" }
}


private extension ResourceError {
    
    private enum CodingKeys: String, CodingKey {
        case id
        case resourceId = "_rid"
        case selfLink   = "_self"
        case etag       = "_etag"
        case timestamp  = "_ts"
        case code       = "code"
        case message    = "message"
    }
}
