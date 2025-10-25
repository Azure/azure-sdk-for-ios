// --------------------------------------------------------------------------
//
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// The MIT License (MIT)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the ""Software""), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
//
// --------------------------------------------------------------------------

import Foundation
import Security

public class KeychainUtil {
    let keychainErrorDomain = "com.azure.core"
    let keychainSecurityService = "com.azure.core"

    private let contentError = AzureError.client("Invalid keychain content.")

    // MARK: Public Methods

    public func store(string: String, forKey key: String) throws {
        guard !string.isEmpty else {
            throw contentError
        }
        try store(secret: string.data(using: .utf8)!, forKey: key)
    }

    public func store(secret: Data, forKey key: String) throws {
        guard !key.isEmpty else {
            throw contentError
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
            throw AzureError.client("Failure storing keychain content.")
        }
    }

    public func secret(forKey key: String) throws -> Data {
        guard !key.isEmpty else {
            throw contentError
        }
        var queryDictionary = setupQueryDictionary(forKey: key)
        queryDictionary[kSecReturnData as String] = kCFBooleanTrue
        queryDictionary[kSecMatchLimit as String] = kSecMatchLimitOne
        var data: AnyObject?
        let status = SecItemCopyMatching(queryDictionary as CFDictionary, &data)
        guard status == errSecSuccess else {
            throw AzureError.client("Failure retrieving keychain secret.")
        }
        if let result = data as? Data {
            return result
        } else {
            throw contentError
        }
    }

    public func string(forKey key: String) throws -> String {
        do {
            let data = try secret(forKey: key)
            if let result = String(data: data, encoding: .utf8) {
                return result
            } else {
                throw contentError
            }
        } catch {
            throw error
        }
    }

    public func deleteSecret(forKey key: String) throws {
        guard !key.isEmpty else {
            throw contentError
        }
        let queryDictionary = setupQueryDictionary(forKey: key)
        let status = SecItemDelete(queryDictionary as CFDictionary)
        guard status == errSecSuccess else {
            throw AzureError.client("Failure deleting keychain secret.")
        }
    }

    // MARK: Private Methods

    private func setupQueryDictionary(forKey key: String) -> [String: Any] {
        var queryDictionary: [String: Any] = [kSecClass as String: kSecClassGenericPassword]
        queryDictionary[kSecAttrAccount as String] = key.data(using: .utf8)
        return queryDictionary
    }
}
