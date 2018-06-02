//
//  ADDocumentCollection.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Represents a document collection in the Azure Cosmos DB service.
/// A collection is a named logical container for documents.
///
/// - Remark:
///   A database may contain zero or more named collections and each collection consists of zero or more JSON documents.
///   Being schema-free, the documents in a collection do not need to share the same structure or fields.
///   Since collections are application resources, they can be authorized using either the master key or resource keys.
///   Refer to [collections](http://azure.microsoft.com/documentation/articles/documentdb-resources/#collections) for more details on collections.
@objc(ADDocumentCollection)
public class ADDocumentCollection: NSObject, ADResource, ADSupportsPermissionToken {
    private typealias CodingKeys = DocumentCollection.CodingKeys

    @objc
    public let id: String

    @objc
    public let resourceId: String

    @objc
    public let selfLink: String?

    @objc
    public let etag: String?

    @objc
    public let timestamp: Date?

    @objc
    public let altLink: String?

    /// The self-link for conflicts in this collection from the Azure Cosmos DB service.
    @objc
    public let conflictsLink: String?

    /// The default time to live in seconds for documents in a collection from the Azure Cosmos DB service.
    @objc
    public let defaultTimeToLive: Int

    /// The self-link for documents in a collection from the Azure Cosmos DB service.
    @objc
    public let documentsLink: String?

    /// The self-link for stored procedures in a collection from the Azure Cosmos DB service.
    @objc
    public let storedProceduresLink: String?

    /// The self-link for triggers in a collection from the Azure Cosmos DB service.
    @objc
    public let triggersLink: String?

    /// The self-link for user defined functions in a collection from the Azure Cosmos DB service.
    @objc
    public let userDefinedFunctionsLink: String?

    /// The `ADIndexingPolicy` associated with the collection from the Azure Cosmos DB service.
    @objc
    public let indexingPolicy: ADIndexingPolicy?

    /// The `PartitionKeyDefinition` object associated with the collection in the Azure Cosmos DB service.
    @objc
    public let partitionKey: ADPartitionKeyDefinition?

    @objc
    public convenience init(id: String) {
        self.init(id: id, resourceId: "", selfLink: nil, etag: nil, timestamp: nil, altLink: nil, conflictsLink: nil, defaultTimeToLive: Int.nil, documentsLink: nil, storedProceduresLink: nil, triggersLink: nil, userDefinedFunctionsLink: nil, indexingPolicy: nil, partitionKey: nil)
    }

    internal init(id: String, resourceId: String, selfLink: String?, etag: String?, timestamp: Date?, altLink: String?, conflictsLink: String?, defaultTimeToLive: Int, documentsLink: String?, storedProceduresLink: String?, triggersLink: String?, userDefinedFunctionsLink: String?, indexingPolicy: ADIndexingPolicy?, partitionKey: ADPartitionKeyDefinition?) {
        self.id = id
        self.resourceId = resourceId
        self.selfLink = selfLink
        self.etag = etag
        self.timestamp = timestamp
        self.altLink = altLink
        self.conflictsLink = conflictsLink
        self.defaultTimeToLive = defaultTimeToLive
        self.documentsLink = documentsLink
        self.storedProceduresLink = storedProceduresLink
        self.triggersLink = triggersLink
        self.userDefinedFunctionsLink = userDefinedFunctionsLink
        self.indexingPolicy = indexingPolicy
        self.partitionKey = partitionKey
    }

    // MARK: - ADCodable

    public required init?(from dictionary: NSDictionary) {
        guard let id = dictionary[CodingKeys.id] as? String else { return nil }
        guard let resourceId = dictionary[CodingKeys.resourceId] as? String else { return nil }

        self.id = id
        self.resourceId = resourceId
        self.selfLink = dictionary[CodingKeys.selfLink] as? String
        self.etag = dictionary[CodingKeys.etag] as? String
        self.timestamp = ADDateEncoders.decodeTimestamp(from: dictionary[CodingKeys.timestamp])
        self.altLink = nil
        self.conflictsLink = dictionary[CodingKeys.conflictsLink] as? String
        self.defaultTimeToLive = Int.nil
        self.documentsLink = dictionary[CodingKeys.documentsLink] as? String
        self.storedProceduresLink = dictionary[CodingKeys.storedProceduresLink] as? String
        self.triggersLink = dictionary[CodingKeys.triggersLink] as? String
        self.userDefinedFunctionsLink = dictionary[CodingKeys.userDefinedFunctionsLink] as? String

        if let indexingPolicy = dictionary[CodingKeys.indexingPolicy] as? NSDictionary {
            self.indexingPolicy = ADIndexingPolicy(from: indexingPolicy)
        } else {
            self.indexingPolicy = nil
        }

        if let partitionKey = dictionary[CodingKeys.partitionKey] as? NSDictionary {
            self.partitionKey = ADPartitionKeyDefinition(from: partitionKey)
        } else {
            self.partitionKey = nil
        }
    }

    public func encode() -> NSDictionary {
        let dictionary = NSMutableDictionary()

        dictionary[CodingKeys.id] = id
        dictionary[CodingKeys.resourceId] = resourceId
        dictionary[CodingKeys.selfLink] = selfLink
        dictionary[CodingKeys.etag] = etag
        dictionary[CodingKeys.timestamp] = ADDateEncoders.encodeTimestamp(timestamp)
        dictionary[CodingKeys.conflictsLink] = conflictsLink
        dictionary[CodingKeys.documentsLink] = documentsLink
        dictionary[CodingKeys.storedProceduresLink] = storedProceduresLink
        dictionary[CodingKeys.userDefinedFunctionsLink] = userDefinedFunctionsLink
        dictionary[CodingKeys.indexingPolicy] = indexingPolicy?.encode()

        return dictionary
    }
}

// MARK: - Objective-C Bridging

extension DocumentCollection: ObjectiveCBridgeable {
    typealias ObjectiveCType = ADDocumentCollection

    func bridgeToObjectiveC() -> ADDocumentCollection {
        return ADDocumentCollection(
            id: self.id,
            resourceId: self.resourceId,
            selfLink: self.selfLink,
            etag: self.etag,
            timestamp: self.timestamp,
            altLink: self.altLink,
            conflictsLink: self.conflictsLink,
            defaultTimeToLive: self.defaultTimeToLive ?? Int.nil,
            documentsLink: self.documentsLink,
            storedProceduresLink: self.storedProceduresLink,
            triggersLink: self.triggersLink,
            userDefinedFunctionsLink: self.userDefinedFunctionsLink,
            indexingPolicy: self.indexingPolicy?.bridgeToObjectiveC(),
            partitionKey: self.partitionKey?.bridgeToObjectiveC()
        )
    }

    init(bridgedFromObjectiveC: ObjectiveCType) {
        let indexingPolicy: DocumentCollection.IndexingPolicy? = {
            guard let policy = bridgedFromObjectiveC.indexingPolicy else { return nil }
            return DocumentCollection.IndexingPolicy(bridgedFromObjectiveC: policy)
        }()

        let partitionKey: DocumentCollection.PartitionKeyDefinition? = {
            guard let key = bridgedFromObjectiveC.partitionKey else { return nil }
            return DocumentCollection.PartitionKeyDefinition(bridgedFromObjectiveC: key)
        }()

        self.init(
            id: bridgedFromObjectiveC.id,
            resourceId: bridgedFromObjectiveC.resourceId,
            selfLink: bridgedFromObjectiveC.selfLink,
            etag: bridgedFromObjectiveC.etag,
            timestamp: bridgedFromObjectiveC.timestamp,
            conflictsLink: bridgedFromObjectiveC.conflictsLink,
            documentsLink: bridgedFromObjectiveC.documentsLink,
            indexingPolicy: indexingPolicy,
            partitionKey: partitionKey,
            storedProceduresLink: bridgedFromObjectiveC.storedProceduresLink,
            triggersLink: bridgedFromObjectiveC.triggersLink,
            userDefinedFunctionsLink: bridgedFromObjectiveC.userDefinedFunctionsLink
        )
    }
}
