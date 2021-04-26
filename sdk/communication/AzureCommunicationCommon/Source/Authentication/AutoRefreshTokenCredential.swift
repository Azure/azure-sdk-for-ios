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
/**
 The Azure Communication Services User token credential. This class is used to cache/refresh the access token required by Azure Communication Services.
 */
internal class AutoRefreshTokenCredential: CommunicationTokenCredentialProviding {
    private let accessTokenCache: ThreadSafeRefreshableAccessTokenCache

    /**
     Creates a `CommunicationTokenCredential` that automatically refreshes the token using the provided `tokenRefresher`.
     - SeeAlso: `CommunicationTokenCredential.init(...)`
     */
    public init(
        tokenRefresher: @escaping (@escaping TokenRefreshHandler) -> Void,
        refreshProactively: Bool,
        initialToken: String?
    ) throws {
        if let initialToken = initialToken {
            let initialAccessToken = try JwtTokenParser.createAccessToken(initialToken)

            self.accessTokenCache = ThreadSafeRefreshableAccessTokenCache(
                refreshProactively: refreshProactively,
                initialValue: initialAccessToken,
                tokenRefresher: tokenRefresher
            )
        } else {
            self.accessTokenCache = ThreadSafeRefreshableAccessTokenCache(
                refreshProactively: refreshProactively,
                tokenRefresher: tokenRefresher
            )
        }
    }

    /**
     Retrieve an access token from the cache, or from the `tokenRefresher` if the token is not in the cache or is expired.

     - Parameter completionHandler: Closure that accepts an optional `AccessToken` or optional `Error` as parameters. `AccessToken` returns a token and an expiry date if applicable. `Error` returns `nil` if the current token can be returned.

     */
    public func token(completionHandler: @escaping CommunicationTokenCompletionHandler) {
        accessTokenCache.getValue { newAccessToken, error in
            completionHandler(newAccessToken, error)
        }
    }
}
