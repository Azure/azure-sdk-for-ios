//
//  ADIndexingMode.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Specifies the supported indexing modes in the Azure Cosmos DB service.
///
/// - ADIndexingModeConsistent:   Index is updated synchronously with a create, update or delete operation.
/// - ADIndexingModeLazy:         Index is updated asynchronously with respect to a create, update or delete operation.
/// - ADIndexingModeNone:         No index is provided.
@objc(ADIndexingMode)
public enum ADIndexingMode: Int {
    @objc(ADIndexingModeConsistent)
    case consistent

    @objc(ADIndexingModeLazy)
    case lazy

    @objc(ADIndexingModeNone)
    case none
}

// MARK: - Objective-C Bridging

extension DocumentCollection.IndexingPolicy.IndexingMode {
    var bridgedToObjectiveC: ADIndexingMode {
        switch self {
        case .consistent: return .consistent
        case .lazy:       return .lazy
        case .none:       return .none
        }
    }

    init(bridgedFromObjectiveC: ADIndexingMode) {
        switch bridgedFromObjectiveC {
        case .consistent: self = .consistent
        case .lazy:       self = .lazy
        case .none:       self = .none
        }
    }
}
