//
//  ObjectiveCBridgeable.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

protocol ObjectiveCBridgeable {
    associatedtype ObjectiveCType: AnyObject

    func bridgeToObjectiveC() -> ObjectiveCType

    init?(bridgedFromObjectiveC: ObjectiveCType)
}

extension ObjectiveCBridgeable {
    init?(bridgedFromObjectiveC: ObjectiveCType) {
        return nil
    }

    init(unconditionallyBridgedFromObjectiveC bridgedFromObjectiveC: ObjectiveCType) {
        self.init(bridgedFromObjectiveC: bridgedFromObjectiveC)!
    }
}
