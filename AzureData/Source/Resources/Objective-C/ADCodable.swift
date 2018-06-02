//
//  ADCodable.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// A type that can convert itself in and out of a `NSDictionary`.
/// Used for JSON serialization.
@objc(ADCodable)
public protocol ADCodable {
    /// Constructs `self` from a `NSDictionary`.
    init?(from dictionary: NSDictionary)

    /// Converts `self` to a `NSDictionary`.
    func encode() -> NSDictionary
}
