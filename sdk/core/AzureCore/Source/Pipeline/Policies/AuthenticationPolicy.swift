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

public typealias TokenCompletionHandler = (AccessToken?, AzureError?) -> Void

public struct AccessToken {
    // MARK: Properties

    public let token: String
    public let expiresOn: Date

    // MARK: Initializers

    public init(token: String, expiresOn: Date) {
        self.token = token
        self.expiresOn = expiresOn
    }
}

public protocol Credential {
    // MARK: Required Methods

    func validate() throws
}

public protocol TokenCredential: Credential {
    // MARK: Required Methods

    func token(forScopes scopes: [String], completionHandler: @escaping TokenCompletionHandler)
}

public protocol Authenticating: PipelineStage {
    // MARK: Required Methods

    func authenticate(request: PipelineRequest, completionHandler: @escaping OnRequestCompletionHandler)
}

public extension Authenticating {
    func on(request: PipelineRequest, completionHandler: @escaping OnRequestCompletionHandler) {
        authenticate(request: request, completionHandler: completionHandler)
    }
}

public class AnonymousAccessPolicy: Authenticating {
    public var next: PipelineStage?

    public init() {}

    public func authenticate(request: PipelineRequest, completionHandler: @escaping OnRequestCompletionHandler) {
        completionHandler(request, nil)
    }
}

public class BearerTokenCredentialPolicy: Authenticating {
    // MARK: Properties

    public var next: PipelineStage?

    private let scopes: [String]
    private let credential: TokenCredential

    // MARK: Initializers

    public init(credential: TokenCredential, scopes: [String]) {
        self.scopes = scopes
        self.credential = credential
    }

    // MARK: Public Methods

    /// Authenticates an HTTP `PipelineRequest` with an OAuth token.
    /// - Parameters:
    ///   - request: A `PipelineRequest` object.
    ///   - completionHandler: A completion handler that forwards the modified pipeline request.
    public func authenticate(request: PipelineRequest, completionHandler: @escaping OnRequestCompletionHandler) {
        credential.token(forScopes: scopes) { token, error in
            if let error = error {
                completionHandler(request, error)
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
