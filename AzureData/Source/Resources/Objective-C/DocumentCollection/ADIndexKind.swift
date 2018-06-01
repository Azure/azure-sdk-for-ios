//
//  ADIndexKind.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

@objc(ADIndexKind)
public enum ADIndexKind: Int {
    @objc(ADIndexKindHash)
    case hash

    @objc(ADIndexKindRange)
    case range

    @objc(ADIndexKindSpatial)
    case spatial
}

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
