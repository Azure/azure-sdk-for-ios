//
//  ADIndexKind.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// These are the indexing types available for indexing a path in the Azure Cosmos DB service.
///
/// - ADIndexKindHash:     The index entries are hashed to serve point look up queries.
/// - ADIndexKindRange:    The index entries are ordered. Range indexes are optimized for
///                        inequality predicate queries with efficient range scans.
/// - ADIndexKindSpatial:  The index entries are indexed to serve spatial queries.
@objc(ADIndexKind)
public enum ADIndexKind: Int {
    @objc(ADIndexKindHash)
    case hash

    @objc(ADIndexKindRange)
    case range

    @objc(ADIndexKindSpatial)
    case spatial
}

// MARK: - Objective-C Bridging

extension DocumentCollection.IndexingPolicy.IncludedPath.Index.IndexKind {
    var bridgedToObjectiveC: ADIndexKind {
        switch self {
        case .hash:    return .hash
        case .range:   return .range
        case .spatial: return .spatial
        }
    }

    init(bridgedFromObjectiveC: ADIndexKind) {
        switch bridgedFromObjectiveC {
        case .hash:    self = .hash
        case .range:   self = .range
        case .spatial: self = .spatial
        }
    }
}
