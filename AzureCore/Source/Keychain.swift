//
//  Keychain.swift
//  AzureCore
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import KeychainAccess


public struct Keychain {
    
    fileprivate static let keychainServiceKey = "com.azure.core"
    
    public static func saveDataToKeychain(_ data: Data, withKey key: String) throws {
        let keychain = KeychainAccess.Keychain(service: keychainServiceKey)
        return try keychain.set(data, key: key)
    }

    public static func getDataFromKeychain(forKey key: String) throws -> Data? {
        let keychain = KeychainAccess.Keychain(service: keychainServiceKey)
        return try keychain.getData(key)
    }
}
