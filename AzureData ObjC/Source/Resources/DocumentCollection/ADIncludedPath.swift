//
//  ADIncludedPath.swift
//  AzureData ObjC
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Specifies a path within a JSON document to be included while indexing data in the Azure Cosmos DB service.
@objc(ADIncludedPath)
public class ADIncludedPath: NSObject, ADCodable {
    private enum CodingKeys: String, CodingKey {
        case path
        case indexes
    }

    /// The path to be indexed in the Azure Cosmos DB service.
    @objc
    public let path: String?

    /// The collection of `ADIndex` objects to be applied for this included path in
    /// the Azure Cosmos DB service.
    @objc
    public let indexes: [ADIndex]

    @objc
    public init(path: String?, indexes: [ADIndex]) {
        self.path = path
        self.indexes = indexes
    }

    // MARK: - ADCodable

    public required init?(from dictionary: NSDictionary) {
        self.path = dictionary[CodingKeys.path] as? String

        if let indexes = dictionary[CodingKeys.indexes] as? [NSDictionary] {
            self.indexes = indexes.compactMap { ADIndex(from: $0) }
        } else {
            self.indexes = []
        }
    }

    public func encode() -> NSDictionary {
        let dictionary = NSMutableDictionary()

        dictionary[CodingKeys.path] = path
        dictionary[CodingKeys.indexes] = indexes.map { $0.encode() }

        return dictionary
    }
}

// MARK: - Objective-C Bridging

extension DocumentCollection.IndexingPolicy.IncludedPath: ObjectiveCBridgeable {
    typealias ObjectiveCType = ADIncludedPath
    typealias SwiftType = DocumentCollection.IndexingPolicy.IncludedPath

    func bridgeToObjectiveC() -> ADIncludedPath {
        return ADIncludedPath(path: self.path, indexes: self.indexes.map { $0.bridgeToObjectiveC() })
    }

    init(bridgedFromObjectiveC: ADIncludedPath) {
        self.init(
            path: bridgedFromObjectiveC.path,
            indexes: bridgedFromObjectiveC.indexes.compactMap { SwiftType.Index(bridgedFromObjectiveC: $0) }
        )
    }
}
