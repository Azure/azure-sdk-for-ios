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

    init(bridgedFromObjectiveC: ObjectiveCType)
}
