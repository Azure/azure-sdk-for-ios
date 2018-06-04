//
//  ADIndexingPolicy.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Represents the indexing policy configuration for a collection in the Azure Cosmos DB service.
@objc(ADIndexingPolicy)
public class ADIndexingPolicy: NSObject, ADCodable {
    private enum CodingKeys: String, CodingKey {
        case automatic
        case excludedPaths
        case includedPaths
        case indexingMode
    }

    private typealias SwiftType = DocumentCollection.IndexingPolicy

    /// A value that indicates whether automatic indexing is enabled for a collection in
    /// the Azure Cosmos DB service.
    @objc
    public let automatic: Bool

    /// The collection containing `ADExcludedPath` objects in the Azure Cosmos DB service.
    @objc
    public let excludedPaths: [ADExcludedPath]

    /// The collection containing `ADIncludedPath` objects in the Azure Cosmos DB service.
    @objc
    public let includedPaths: [ADIncludedPath]

    /// The indexing mode in the Azure Cosmos DB service.
    @objc
    public let indexingMode: ADIndexingMode

    @objc
    public init(automatic: Bool, excludedPaths: [ADExcludedPath], includedPaths: [ADIncludedPath], indexingMode: ADIndexingMode) {
        self.automatic = automatic
        self.excludedPaths = excludedPaths
        self.includedPaths = includedPaths
        self.indexingMode = indexingMode
    }

    // MARK: - ADCodable

    public required init?(from dictionary: NSDictionary) {
        self.automatic = dictionary[CodingKeys.automatic] as? Bool ?? false
        self.excludedPaths = (dictionary[CodingKeys.excludedPaths] as? [NSDictionary])?.compactMap { ADExcludedPath(from: $0) } ?? []
        self.includedPaths = (dictionary[CodingKeys.includedPaths] as? [NSDictionary])?.compactMap { ADIncludedPath(from: $0) } ?? []

        if let indexingMode = dictionary[CodingKeys.indexingMode] as? String {
            self.indexingMode = SwiftType.IndexingMode(rawValue: indexingMode)?.bridgedToObjectiveC ?? .none
        } else {
            self.indexingMode = .none
        }
    }

    public func encode() -> NSDictionary {
        let dictionary = NSMutableDictionary()

        dictionary[CodingKeys.automatic] = automatic
        dictionary[CodingKeys.includedPaths] = includedPaths.map { $0.encode() }
        dictionary[CodingKeys.excludedPaths] = excludedPaths.map { $0.encode() }
        dictionary[CodingKeys.indexingMode] = SwiftType.IndexingMode(bridgedFromObjectiveC: indexingMode).rawValue

        return dictionary
    }
}

// MARK: - Objective-C Bridging

extension DocumentCollection.IndexingPolicy: ObjectiveCBridgeable {
    typealias ObjectiveCType = ADIndexingPolicy
    typealias SwiftType = DocumentCollection.IndexingPolicy

    func bridgeToObjectiveC() -> ADIndexingPolicy {
        return ADIndexingPolicy(
            automatic: self.automatic ?? false,
            excludedPaths: self.excludedPaths.map { $0.bridgeToObjectiveC() },
            includedPaths: self.includedPaths.map { $0.bridgeToObjectiveC() },
            indexingMode: (self.indexingMode?.bridgedToObjectiveC) ?? .none
        )
    }

    init(bridgedFromObjectiveC: ADIndexingPolicy) {
        let automatic = bridgedFromObjectiveC.automatic
        let excludedPaths = bridgedFromObjectiveC.excludedPaths.compactMap { SwiftType.ExcludedPath(bridgedFromObjectiveC: $0) }
        let includedPaths = bridgedFromObjectiveC.includedPaths.compactMap { SwiftType.IncludedPath(bridgedFromObjectiveC: $0) }
        let indexingMode = SwiftType.IndexingMode(bridgedFromObjectiveC: bridgedFromObjectiveC.indexingMode)

        self.init(automatic: automatic, excludedPaths: excludedPaths, includedPaths: includedPaths, indexingMode: indexingMode)
    }
}
