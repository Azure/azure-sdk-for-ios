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

import AzureCommunicationCommon
import AzureCore
import Foundation
/**
 The Azure Communication Services token credential used to authenticate pipeline requests.
 */
class TokenCredentialAdapter: TokenCredential {
    private let credential: CommunicationTokenCredential
    var error: AzureError?
    /**
     Creates a token credential  that authenticates requests using the provided `CommunicationTokenCredential`.

     - Parameter credential: The token credential to authenticate with.
     */
    public init(_ credential: CommunicationTokenCredential) {
        self.credential = credential
    }

    /**
     Retrieve a token for the provided scope.

     - Parameters:
     - scopes: A list of a scope strings for which to retrieve the token.
     - completionHandler: A completion handler which forwards the access token.
     */
    public func token(forScopes _: [String] = [], completionHandler: @escaping TokenCompletionHandler) {
        credential.token { communicationAccessToken, error in
            guard let communicationAccessToken = communicationAccessToken else {
                self.error = AzureError.client("Communication Token Failure", error)
                completionHandler(nil, self.error)
                return
            }

            let accessToken = AccessToken(
                token: communicationAccessToken.token,
                expiresOn: communicationAccessToken.expiresOn
            )

            completionHandler(accessToken, nil)
        }
    }

    /**
     Validates throws an error if token creating had any errors
     - Throws: Azure error with the error from the get token call.
     */
    public func validate() throws {
        if let error = error {
            throw error
        }
    }
}
