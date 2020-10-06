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

#if canImport(AzureCore)
import AzureCore
#endif
import Foundation

public typealias AccessTokenRefreshOnCompletion = (AccessToken?, Error?) -> Void
public typealias TokenRefreshOnCompletion = (String?, Error?) -> Void

/**
 The Azure Communication Services User token credential. This class is used to cache/refresh the access token required by Azure Communication Services.
*/
@objcMembers public class CommunicationUserCredential: NSObject {
    private let userTokenCredential: CommunicationTokenCredential
    
    /**
     Creates a static `CommunicationUserCredential` object from the provided token.
        
     - Parameter token: The static token to use for authenticating all requests.
     
     - Throws: `AzureError` if the provided token is not a valid user token.
     */
    public init(token: String) throws {
        self.userTokenCredential = try StaticUserCredential(token: token)
    }
    /**
     Creates a CommunicationUserCredential that automatically refreshes the token.
     The cached token is updated if `token(completionHandler: )` is called and if the difference between the current time
     and token expiry time is less than 120s.
     If `refreshProactively` parameter  is `true`:
        - The cached token will be updated in the background when the difference between the current time
            and token expiry time is less than 600s.
        - The cached token will be updated immediately when the constructor is invoked and `initialToken` is expired
        
     - Parameters:
        - initialToken: The initial value of the token.
        - refreshProactively: Whether the token should be proactively refreshed in the background.
        - tokenRefresher: Closure to call when a new token value is needed.
     - Throws: `AzureError` if the provided token is not a valid user token.
     */
    public init(
        initialToken: String? = nil,
        refreshProactively: Bool = false,
        tokenRefresher: @escaping (@escaping TokenRefreshOnCompletion) -> Void
    ) throws {
        self.userTokenCredential = try AutoRefreshUserCredential(
            tokenRefresher: tokenRefresher,
            refreshProactively: refreshProactively,
            initialToken: initialToken
        )
    }

    /**
     Retrieve an access token from the credential.
     - Parameter completionHandler: Closure that acepts an optional `AccessToken` or optional `Error` as parameters.
     `AccessToken` returns  a token and an expiry date if applicable. `Error` returns `nil` if the current token can be returned.
     */
    public func token(completionHandler: @escaping AccessTokenRefreshOnCompletion) {
        userTokenCredential.token(completionHandler: completionHandler)
    }
}
