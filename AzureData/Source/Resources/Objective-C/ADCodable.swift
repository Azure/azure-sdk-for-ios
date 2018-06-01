//
//  ADCodable.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

@objc(ADCodable)
public protocol ADCodable {
    init?(from dictionary: NSDictionary)
    func encode() -> NSDictionary
}
