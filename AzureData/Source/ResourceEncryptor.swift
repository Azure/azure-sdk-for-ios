//
//  ResourceEncryptor.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

@objc(ADResourceEncryptor)
public protocol ResourceEncryptor {
    func encrypt(_ data: Data) -> Data
    func decrypt(_ data: Data) -> Data
}
