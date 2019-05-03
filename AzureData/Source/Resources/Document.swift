//
//  Document.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Represents a document in the Azure Cosmos DB service.
///
/// - Remark:
///   A document is a structured JSON document. There is no set schema for the JSON documents,
///   and a document may contain any number of custom properties as well as an optional list of attachments.
///   Document is an application resource and can be authorized using the master key or resource keys.
public protocol Document: AnyObject, Codable {
    typealias PartitionKey = KeyPath<Self, String>

    /// Gets the partition key used to automatically partition data
    /// among servers for scalability. Use a property that has a wide
    /// range of values and is likely to have evenly distributed access
    /// patterns. The partition key is required to be non-nil if the collection
    /// associated with this document has a partition key definition.
    static var partitionKey: PartitionKey? { get }

    /// Gets the Id of the document in the Azure Cosmos DB service.
    var id: String { get }
}

extension Document {
    /// Gets the Resource Id associated with the resource in the Azure Cosmos DB service.
    public var resourceId: String { return metadata?.resourceId ?? "" }

    /// Gets the self-link associated with the resource from the Azure Cosmos DB service.
    public var selfLink: String? { return metadata?.selfLink }

    /// Gets the entity tag associated with the resource from the Azure Cosmos DB service.
    public var etag: String? { return metadata?.etag }

    /// Gets the last modified timestamp associated with the resource from the Azure Cosmos DB service.
    public var timestamp: Date? { return metadata?.timestamp }

    /// Gets the alt-link associated with the resource from the Azure Cosmos DB service.
    public var altLink: String? { return metadata?.altLink }

    /// Gets the self-link corresponding to attachments of the document from the Azure Cosmos DB service.
    public var attachmentsLink: String? { return metadata?.attachmentsLink }
}

extension Document {
    internal var metadata: DocumentMetadata? {
        get { return objc_getAssociatedObject(self, &documentMetadataKey) as? DocumentMetadata }
        set { newValue.flatMap { objc_setAssociatedObject(self, &documentMetadataKey, $0, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN) } }
    }

    internal var container: DocumentContainer<Self>? {
        guard let metadata = self.metadata else { return nil }
        let container = DocumentContainer(self)
        container.metadata = metadata
        return container
    }
}

fileprivate var documentMetadataKey: UInt8 = 0

final class AnyDocument: Document {
    static var partitionKey: PartitionKey? { return nil }
    let id: String
}
