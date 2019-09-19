//
//  KeychainUtil.swift
//  AzureCore
//
//  Created by Travis Prescott on 9/3/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation
import Security

@objc(AZCoreKeychainUtilError)
public enum KeychainUtilError: Int, Error {
    case invalidContent
    case failure
}

@objc(AZCoreKeychainUtil)
public class KeychainUtil: NSObject {

    let keychainErrorDomain = "com.azure.core"
    let keychainSecurityService = "com.azure.core"

    private func setupQueryDictionary(forKey key: String) -> [String: Any] {
        var queryDictionary: [String: Any] = [kSecClass as String: kSecClassGenericPassword]
        queryDictionary[kSecAttrAccount as String] = key.data(using: .utf8)
        return queryDictionary
    }

    @objc public func store(string: String, forKey key: String) throws {
        guard !string.isEmpty else {
            throw KeychainUtilError.invalidContent
        }
        try self.store(secret: string.data(using: .utf8)!, forKey: key)
    }

    @objc public func store(secret: Data, forKey key: String) throws {
        guard !key.isEmpty else {
            throw KeychainUtilError.invalidContent
        }
        do {
            try deleteSecret(forKey: key)
        } catch {
            throw error
        }
        var queryDictionary = setupQueryDictionary(forKey: key)
        queryDictionary[kSecValueData as String] = secret
        let status = SecItemAdd(queryDictionary as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainUtilError.failure
        }
    }

    @objc public func secret(forKey key: String) throws -> Data {
        guard !key.isEmpty else {
            throw KeychainUtilError.invalidContent
        }
        var queryDictionary = setupQueryDictionary(forKey: key)
        queryDictionary[kSecReturnData as String] = kCFBooleanTrue
        queryDictionary[kSecMatchLimit as String] = kSecMatchLimitOne
        var data: AnyObject?
        let status = SecItemCopyMatching(queryDictionary as CFDictionary, &data)
        guard status == errSecSuccess else {
            throw KeychainUtilError.failure
        }
        if let result = data as? Data {
            return result
        } else {
            throw KeychainUtilError.invalidContent
        }
    }

    @objc public func string(forKey key: String) throws -> String {
        do {
            let data = try secret(forKey: key)
            if let result = String(data: data, encoding: .utf8) {
                return result
            } else {
                throw KeychainUtilError.invalidContent
            }
        } catch {
            throw error
        }
    }

    @objc public func deleteSecret(forKey key: String) throws {
        guard !key.isEmpty else {
            throw KeychainUtilError.invalidContent
        }
        let queryDictionary = setupQueryDictionary(forKey: key)
        let status = SecItemDelete(queryDictionary as CFDictionary)
        guard status == errSecSuccess else {
            throw KeychainUtilError.failure
        }
    }
}
