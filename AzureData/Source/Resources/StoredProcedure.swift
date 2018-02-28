//
//  StoredProcedure.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Represents a stored procedure in the Azure Cosmos DB service.
///
/// - Remark:
///   Azure Cosmos DB allows application logic written entirely in JavaScript to be executed directly inside
///   the database engine under the database transaction.
///   For additional details, refer to the server-side JavaScript API documentation.
public struct StoredProcedure : CodableResource {
    
    public static var type = "sprocs"
    public static var list = "StoredProcedures"

    public private(set) var id:         String
    public private(set) var resourceId: String
    public private(set) var selfLink:   String?
    public private(set) var etag:       String?
    public private(set) var timestamp:  Date?
    
    /// Gets or sets the body of the Azure Cosmos DB stored procedure.
    ///
    /// - Remark:
    ///   Must be a valid JavaScript function.
    ///
    /// - Example:
    ///   `"function () { getContext().getResponse().setBody('Hello World!'); }`
    public private(set) var body:       String?
}


private extension StoredProcedure {
    
    private enum CodingKeys: String, CodingKey {
        case id
        case resourceId         = "_rid"
        case selfLink           = "_self"
        case etag               = "_etag"
        case timestamp          = "_ts"
        case body
    }
}
