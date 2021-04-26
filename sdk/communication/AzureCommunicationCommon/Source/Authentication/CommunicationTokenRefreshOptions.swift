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

public typealias TokenRefresher = (@escaping TokenRefreshHandler) -> Void
/**
 The Communication Token Refresh Options. Used to initialize a `CommunicationTokenCredential`
 - SeeAlso: ` CommunicationTokenCredential.token(...)`
 */
@objcMembers public class CommunicationTokenRefreshOptions: NSObject {
    var initialToken: String?
    var refreshProactively: Bool
    var tokenRefresher: TokenRefresher
    /**
     Initializes a new instance of `CommunicationTokenRefreshOptions`
     The cached token is updated if `token(completionHandler: )` is called and if the difference between the current time and token expiry time is less than 120s.
     If `refreshProactively` parameter  is `true`:
     - The cached token will be updated in the background when the difference between the current time and token expiry time is less than 600s.
     - The cached token will be updated immediately when the constructor is invoked and `initialToken` is expired
     - Parameters:
     - initialToken: The initial value of the token.
     - refreshProactively: Whether the token should be proactively refreshed in the background.
     - tokenRefresher: Closure to call when a new token value is needed.
     */
    public init(
        initialToken: String? = nil,
        refreshProactively: Bool = false,
        tokenRefresher: @escaping TokenRefresher
    ) {
        self.initialToken = initialToken
        self.refreshProactively = refreshProactively
        self.tokenRefresher = tokenRefresher
    }
}
