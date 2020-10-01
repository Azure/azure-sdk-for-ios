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
/**
 The Azure Communication Services authentication policy. Conforms to Azure Cores Authenticating protocol.
 */
public class CommunicationUserCredentialPolicy: Authenticating {
    public var next: PipelineStage?

    private let credential: CommunicationUserCredential

    /**
     Creates a CommunicationUserCredentialPolicy object from the provided user credential
     
     - Parameter credential: Users `CommunicationUserCredential` they want to authenticate with
     
     - SeeAlso: `CommunicationUserCredential.init(...)`
     */
    public init(credential: CommunicationUserCredential) {
        self.credential = credential
    }

    /**
     Authenticate method for authenticating client requests. The errors and token is validated before the closure is called.
     - Parameters:
        - request:`PipelineRequest` making the request
        - completionHandler: Closure returning  the `PipelineRequest` including the authorization token and an optional `AzureError`if applicable
     */
    public func authenticate(request: PipelineRequest, completionHandler: @escaping OnRequestCompletionHandler) {
        credential.token { token, error in
            if let error = error {
                completionHandler(request, AzureError.sdk("Error while retrieving access token", error))
                return
            }

            guard let token = token?.token else {
                completionHandler(request, AzureError.sdk("Token cannot be empty"))
                return
            }

            request.httpRequest.headers[.authorization] = "Bearer \(token)"
            completionHandler(request, nil)
        }
    }
}
