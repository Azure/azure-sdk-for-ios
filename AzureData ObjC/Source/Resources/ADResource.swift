//
//  ADResource.swift
//  AzureData ObjC
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Represents a resource type in the Azure Cosmos DB service.
/// All Azure Cosmos DB resources, such as `ADDatabase`, `ADDocumentCollection`,
/// and `ADDocument` implement this protocol.
@objc(ADResource)
public protocol ADResource: ADCodable {
    /// The Id of the resource in the Azure Cosmos DB service.
    var id: String { get }

    /// The system-generated Resource Id associated with
    /// the resource in the Azure Cosmos DB service.
    var resourceId: String { get }

    /// The self-link associated with the resource from
    /// the Azure Cosmos DB service. The self-link is a
    /// logical path to the resource in the Azure Cosmos DB
    /// service made of system-generated ids (`resourceId`s).
    var selfLink: String? { get }

    /// The entity tag associated with the resource from
    /// the Azure Cosmos DB service.
    var etag: String? { get }

    /// The last modified timestamp associated with the resource
    /// in the Azure Cosmos DB service.
    var timestamp: Date? { get }

    /// The alt-link associated with the resource in the
    /// Azure Cosmos DB service. The alt-link is a logical
    /// path to the resource in the Azure Cosmos DB service
    /// made of user-generated ids (`id`s).
    var altLink: String? { get }
}
