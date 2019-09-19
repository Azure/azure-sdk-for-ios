//
//  ObjectiveCBridgeable.swift
//  AzureCore
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// This protocol is used internally to expose a Swift
/// type to a type that is representable in Objective-C
/// as the type `ObjectiveCType` or one of its subclasses.
public protocol ObjectiveCBridgeable {
    /// The type corresponding to `Self` in Objective-C.
    associatedtype ObjectiveCType: AnyObject

    /// Converts `self` to its corresponding
    /// `ObjectiveCType`.
    func bridgeToObjectiveC() -> ObjectiveCType

    /// Reconstructs a Swift value of type `Self`
    /// from its corresponding value of type
    /// `ObjectiveCType`.
    init(bridgedFromObjectiveC: ObjectiveCType)
}
