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
 The Azure Communication Services authentication policy.
 */
public class CommunicationTokenCredentialPolicy: Authenticating {
    public var next: PipelineStage?

    private let credential: CommunicationTokenCredential

    /**
     Creates a credential policy that authenticates requests using the provided `CommunicationTokenCredential`.
     
     - Parameter credential: The `CommunicationTokenCredential` that will be used to authenticate requests.
     
     - SeeAlso: `CommunicationTokenCredential.init(...)`
     */
    public init(credential: CommunicationTokenCredential) {
        self.credential = credential
    }

    /**
     Authenticates an HTTP `PipelineRequest` with a token retrieved from the credential.
     - Parameters:
        - request:A `PipelineRequest` object.
        - completionHandler: A completion handler that forwards the modified pipeline request.
     */
    public func authenticate(request: PipelineRequest, completionHandler: @escaping OnRequestCompletionHandler) {
        credential.token { token, error in
            if let error = error {
                completionHandler(request, AzureError.client("Error while retrieving access token", error))
                return
            }

            guard let token = token?.token else {
                completionHandler(request, AzureError.client("Token cannot be empty"))
                return
            }

            request.httpRequest.headers[.authorization] = "Bearer \(token)"
            completionHandler(request, nil)
        }
    }
}

public class CommunicationPolicyTokenCredential: TokenCredential {    
    private let credential: CommunicationTokenCredential
    var error: AzureError? = nil

    public init(_ credential: CommunicationTokenCredential) {
        self.credential = credential
    }
    
    public func token(forScopes scopes: [String], completionHandler: @escaping TokenCompletionHandler) {
        credential.token { (communicationAccessToken, error) in
            guard let communicationAccessToken = communicationAccessToken else {
                self.error = AzureError.client("Communication Token Failure", error)
                completionHandler(nil, self.error)
                return
            }
            
            let accessToken = AccessToken(token: communicationAccessToken.token,
                                          expiresOn: communicationAccessToken.expiresOn)
            
            completionHandler(accessToken, nil)
        }
    }
    
    public func validate() throws {
        if let error = error {
            throw error
        }
    }
}
