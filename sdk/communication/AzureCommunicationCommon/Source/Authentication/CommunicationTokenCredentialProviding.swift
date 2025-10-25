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
 A protocol indicating that an operation supports cancellation.
 */
public protocol Cancellable {
    /// Cancel the operation and also stops side effects such as timers, schedulers, network access.
    func cancel()
}

/**
 Protocol defining the shape of credentials used with Azure Communication Services.
 */
public protocol CommunicationTokenCredentialProviding: Cancellable {
    /**
     Retrieve an access token from the credential.
     - Parameter completionHandler: Closure that accepts an optional `AccessToken` or optional `Error` as parameters. `AccessToken` returns a token and an expiry date if applicable.
     `Error` returns `nil` if the current token can be returned.
     */
    func token(completionHandler: @escaping CommunicationTokenCompletionHandler)
}
