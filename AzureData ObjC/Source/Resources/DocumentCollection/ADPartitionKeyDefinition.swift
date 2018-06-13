//
//  ADPartitionKeyDefinition.swift
//  AzureData ObjC
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Specifies a partition key definition for a particular path in the Azure Cosmos DB service.
@objc(ADPartitionKeyDefinition)
public class ADPartitionKeyDefinition: NSObject, ADCodable {
    private enum CodingKeys: String, CodingKey {
        case paths
    }

    /// The paths to be partitioned in the Azure Cosmos DB service.
    @objc
    public let paths: [String]

    @objc
    public init(paths: [String]) {
        self.paths = paths
    }

    // MARK: - ADCodable

    public required init?(from dictionary: NSDictionary) {
        guard let paths = dictionary[CodingKeys.paths] as? [String] else { return nil }
        self.paths = paths
    }

    public func encode() -> NSDictionary {
        let dictionary = NSMutableDictionary()
        dictionary[CodingKeys.paths] = paths

        return dictionary
    }
}

// MARK: - Objective-C Bridging

extension DocumentCollection.PartitionKeyDefinition: ObjectiveCBridgeable {
    typealias ObjectiveCType = ADPartitionKeyDefinition

    func bridgeToObjectiveC() -> ADPartitionKeyDefinition {
        return ADPartitionKeyDefinition(paths: self.paths)
    }

    init(bridgedFromObjectiveC: ObjectiveCType) {
        self.init(paths: bridgedFromObjectiveC.paths)
    }
}
