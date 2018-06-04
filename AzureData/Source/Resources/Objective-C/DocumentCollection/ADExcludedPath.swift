//
//  ADExcludedPath.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Specifies a path within a JSON document to be excluded while indexing data for the Azure Cosmos DB service.
@objc(ADExcludedPath)
public class ADExcludedPath: NSObject, ADCodable {
    private enum CodingKeys: String, CodingKey {
        case path
    }

    /// The path to be excluded from indexing in the Azure Cosmos DB service.
    @objc
    public let path: String?

    @objc
    public init(path: String?) {
        self.path = path
    }

    // MARK: - ADCodable

    public required init?(from dictionary: NSDictionary) {
        self.path = dictionary[CodingKeys.path] as? String
    }

    public func encode() -> NSDictionary {
        let dictionary = NSMutableDictionary()
        dictionary[CodingKeys.path] = path

        return dictionary
    }
}

// MARK: - Objective-C Bridging

extension DocumentCollection.IndexingPolicy.ExcludedPath: ObjectiveCBridgeable {
    typealias ObjectiveCType = ADExcludedPath

    func bridgeToObjectiveC() -> ADExcludedPath {
        return ADExcludedPath(path: self.path)
    }

    init(bridgedFromObjectiveC: ADExcludedPath) {
        self.init(path: bridgedFromObjectiveC.path)
    }
}
