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

public typealias CommunicationTokenCompletionHandler = (CommunicationAccessToken?, Error?) -> Void
public typealias TokenRefreshHandler = (String?, Error?) -> Void

/**
 Optional delegate protocol for classes to conform
 */
@objc public protocol TokenCredentialDelegate: AnyObject {
    /**
      Delegate method to return to the client the `AccessToken` or `Error`
     */
    func onTokenRetrieved(withToken token: CommunicationAccessToken?, error: Error?)
}

/**
 The Azure Communication Services User token credential. This class is used to cache/refresh the access token required by Azure Communication Services.
 */
@objcMembers public class CommunicationTokenCredential: NSObject {
    weak var delegate: TokenCredentialDelegate?
    private let userTokenCredential: CommunicationTokenCredentialProviding

    /**
     Creates a static `CommunicationTokenCredential` object from the provided token.

     - Parameter token: The static token to use for authenticating all requests.

     - Throws: `AzureError` if the provided token is not a valid user token.
     */
    public init(token: String) throws {
        self.userTokenCredential = try StaticTokenCredential(token: token)
    }

    /**
     Creates a static `CommunicationTokenCredential` object from the provided token.

     - Parameter delegate: Delegate class conforming to `TokenCredentialDelegate`
     - Parameter token: The static token to use for authenticating all requests.

     - Throws: `AzureError` if the provided token is not a valid user token.
     */
    public init(withDelegate delegate: TokenCredentialDelegate, withToken token: String) throws {
        self.userTokenCredential = try StaticTokenCredential(token: token)
        self.delegate = delegate
    }

    /**
     Creates a CommunicationTokenCredential that automatically refreshes the token.
     - Parameters:
        - options: Options for how the token will be refreshed
     - Throws: `AzureError` if the provided token is not a valid user token.
     */
    public init(withOptions options: CommunicationTokenRefreshOptions) throws {
        self.userTokenCredential = try AutoRefreshTokenCredential(
            tokenRefresher: options.tokenRefresher,
            refreshProactively: options.refreshProactively,
            initialToken: options.initialToken
        )
    }

    /**
     Creates a CommunicationTokenCredential that automatically refreshes the token.
     - Parameter delegate: Delegate class conforming to `TokenCredentialDelegate`
     - Parameter options: Options for how the token will be refreshed
     - Throws: `AzureError` if the provided token is not a valid user token.
     */
    public init(
        withDelegate delegate: TokenCredentialDelegate,
        withOptions options: CommunicationTokenRefreshOptions
    ) throws {
        self.userTokenCredential = try AutoRefreshTokenCredential(
            tokenRefresher: options.tokenRefresher,
            refreshProactively: options.refreshProactively,
            initialToken: options.initialToken
        )

        self.delegate = delegate
    }

    /**
     Retrieve an access token from the credential.
     - Parameter completionHandler: Closure that accepts an optional `AccessToken` or optional `Error` as parameters.
     `AccessToken` returns a token and an expiry date if applicable. `Error` returns `nil` if the current token can be returned.
     */
    public func token(completionHandler: @escaping CommunicationTokenCompletionHandler) {
        if delegate != nil {
            let logger = ClientLoggers.default(tag: "CommunicationTokenCredential")
            logger.info("TokenCredentialDelegate assigned but will not be called.")
        }
        userTokenCredential.token(completionHandler: completionHandler)
    }

    /**
     Retrieve an access token from the credential.
     If your class assigned a delegate, this method will call the delegate method `TokenCredentialDelegate`
     */
    public func token() {
        userTokenCredential.token(completionHandler: { [weak self] token, error in
            guard let self = self else { return }
            guard let delegate = self.delegate else {
                let logger = ClientLoggers.default(tag: "CommunicationTokenCredential")
                logger.info("Client has not set TokenCredentialDelegate")
                return
            }

            delegate.onTokenRetrieved(withToken: token, error: error)
        })
    }
}
