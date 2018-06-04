//
//  UserDefinedFunction.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Represents a user defined function in the Azure Cosmos DB service.
///
/// - Remark:
///   Azure Cosmos DB supports JavaScript user defined functions (UDFs) which are stored in
///   the database and can be used inside queries.
///   Refer to [javascript-integration](http://azure.microsoft.com/documentation/articles/documentdb-sql-query/#javascript-integration) for how to use UDFs within queries.
///   Refer to [udf](http://azure.microsoft.com/documentation/articles/documentdb-programming/#udf) for more details about implementing UDFs in JavaScript.
public struct UserDefinedFunction : CodableResource, SupportsPermissionToken {
    
    public static var type = "udfs"
    public static var list = "UserDefinedFunctions"

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

    /// Gets or sets the body of the user defined function for the Azure Cosmos DB service.
    ///
    /// - Remark:
    ///   This must be a valid JavaScript function
    ///
    /// - Example:
    ///   `"function (input) { return input.toLowerCase(); }"`
    public private(set) var body: String?
    
    public init (_ id: String, body: String) {
        self.id = id
        self.resourceId = ""
        self.body = body
    }
}


extension UserDefinedFunction {
    enum CodingKeys: String, CodingKey {
        case id
        case resourceId = "_rid"
        case selfLink   = "_self"
        case etag       = "_etag"
        case timestamp  = "_ts"
        case body
    }

    init(id: String, resourceId: String, selfLink: String?, etag: String?, timestamp: Date?, altLink: String?, body: String?) {
        self.id = id
        self.resourceId = resourceId
        self.selfLink = selfLink
        self.etag = etag
        self.timestamp = timestamp
        self.altLink = altLink
        self.body = body
    }
}
