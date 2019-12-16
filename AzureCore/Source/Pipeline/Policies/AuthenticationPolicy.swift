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

public class AccessToken {
    public let token: String
    public let expiresOn: Int

    public init(token: String, expiresOn: Int) {
        self.token = token
        self.expiresOn = expiresOn
    }
}

public protocol TokenCredential {
    func token(forScopes scopes: [String]) -> AccessToken?
}

public protocol AuthenticationProtocol: PipelineStageProtocol {
    func authenticate(request: PipelineRequest)
}

extension AuthenticationProtocol {
    public func onRequest(_ request: PipelineRequest) {
        authenticate(request: request)
    }
}

public class BearerTokenCredentialPolicy: AuthenticationProtocol {
    public var next: PipelineStageProtocol?

    public let scopes: [String]
    public let credential: TokenCredential
    public var needNewToken: Bool {
        // TODO: Also if token expires within 300... ms?
        return (token == nil)
    }

    private var token: AccessToken?

    public init(credential: TokenCredential, scopes: [String]) {
        self.scopes = scopes
        self.credential = credential
        token = nil
    }

    public func authenticate(request: PipelineRequest) {
        if let token = self.token?.token {
            request.httpRequest.headers[.authorization] = "Bearer \(token)"
        }
    }

    public func onRequest(_ request: PipelineRequest) {
        if needNewToken {
            token = credential.token(forScopes: scopes)
        }
        authenticate(request: request)
    }
}
