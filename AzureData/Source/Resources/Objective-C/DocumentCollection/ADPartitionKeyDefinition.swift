//
//  ADPartitionKeyDefinition.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

@objc(ADPartitionKeyDefinition)
public class ADPartitionKeyDefinition: NSObject, ADCodable {
    private enum CodingKeys: String, CodingKey {
        case paths
    }

    @objc
    public let paths: [String]

    @objc
    public init(paths: [String]) {
        self.paths = paths
    }

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

extension DocumentCollection.PartitionKeyDefinition: ObjectiveCBridgeable {
    typealias ObjectiveCType = ADPartitionKeyDefinition

    func bridgeToObjectiveC() -> ADPartitionKeyDefinition {
        return ADPartitionKeyDefinition(paths: self.paths)
    }
}
