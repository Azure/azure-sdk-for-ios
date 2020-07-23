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

/// A cache that a `StorageSASCredential` can use to cache tokens that are returned from its `tokenProvider`.
public protocol StorageSASTokenCache {
    /// Get a token from the cache for a given URL, granting the given permissions.
    /// - Parameters:
    ///   - forUrl: The URL the token must grant access to.
    ///   - withPermissions: The permissions the returned token must contain, at minimum.
    func getToken(forUrl: URL, withPermissions: StorageSASTokenPermissions) -> StorageSASToken?

    /// Add a token to the cache which grants access to the given URL.
    /// - Parameters:
    ///   - token: The token to cache.
    ///   - forUrl: The URL the token grants access to.
    func add(token: StorageSASToken, forUrl: URL)

    /// Remove the token granting access to the given URL from the cache.
    /// - Parameters:
    ///   - forUrl: The URL the token grants access to.
    func removeToken(forUrl: URL)

    /// Remove all tokens from the cache.
    func removeAll()
}

/// A `TokenCache` that stores tokens in a simple in-memory dictionary and which stores only a single token for a given
/// URL, regardless of the permissions associated with the token.
public class DefaultStorageSASTokenCache: StorageSASTokenCache {
    private var tokenCache: [URL: StorageSASToken] = [:]

    /// Initialize a `DefaultTokenCache`.
    public init() {}

    /// Get a token from the cache for a given URL, granting the given permissions.
    /// - Parameters:
    ///   - forUrl: The URL the token must grant access to.
    ///   - withPermissions: The permissions the returned token must contain, at minimum.
    public func getToken(forUrl url: URL, withPermissions _: StorageSASTokenPermissions) -> StorageSASToken? {
        return tokenCache[url]
    }

    /// Add a token to the cache which grants access to the given URL.
    /// - Parameters:
    ///   - token: The token to cache.
    ///   - forUrl: The URL the token grants access to.
    public func add(token: StorageSASToken, forUrl url: URL) {
        tokenCache.updateValue(token, forKey: url)
    }

    /// Remove the token granting access to the given URL from the cache.
    /// - Parameters:
    ///   - forUrl: The URL the token grants access to.
    public func removeToken(forUrl url: URL) {
        tokenCache.removeValue(forKey: url)
    }

    /// Remove all tokens from the cache.
    public func removeAll() {
        tokenCache.removeAll()
    }
}
