//
//  CodableResources.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Represents a collection of resources in the Azure Cosmos DB service.
public protocol CodableResources: Decodable {
    associatedtype Item: CodableResource

    var count: Int { get }

    var items: [Item]  { get }

    mutating func setAltLinks(withContentPath path: String?)
}
