//
//  ADIndexingMode.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

@objc(ADIndexingMode)
public enum ADIndexingMode: Int {
    @objc(ADIndexingModeConsistent)
    case consistent

    @objc(ADIndexingModeLazy)
    case lazy

    @objc(ADIndexingModeNone)
    case none
}

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
