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
import MSAL

public struct AccessToken {
    // MARK: Properties

    public let token: String
    public let expiresOn: Int
}

public protocol TokenCredential {
    // MARK: Required Methods

    func token(forScopes scopes: [String], then completion: @escaping (AccessToken?, Error?) -> Void)
}

public protocol Authenticating: PipelineStage {
    // MARK: Required Methods

    func authenticate(request: PipelineRequest, then completion: @escaping OnRequestCompletionHandler)
}

extension Authenticating {
    public func on(request: PipelineRequest, then completion: @escaping OnRequestCompletionHandler) {
        authenticate(request: request, then: completion)
    }
}

/// Delegate protocol for view controllers to hook into the MSAL interactive flow.
public protocol MSALInteractiveDelegate: AnyObject {
    // MARK: Required Methods

    func parentForWebView() -> UIViewController
    func didCompleteMSALRequest(withResult result: MSALResult)
}

public extension MSALInteractiveDelegate where Self: UIViewController {
    func parentForWebView() -> UIViewController {
        return self
    }

    func didCompleteMSALRequest(withResult _: MSALResult) {}
}

/// An MSAL credential object.
public struct MSALCredential: TokenCredential {
    // MARK: Properties

    private let tenant: String
    private let clientId: String
    private let application: MSALPublicClientApplication
    private let account: MSALAccount?

    private weak var delegate: MSALInteractiveDelegate? {
        return ApplicationUtil.currentViewController(forParent: nil) as? MSALInteractiveDelegate
    }

    // MARK: Initializers

    /// Create an OAuth credential.
    /// - Parameters:
    ///   - tenant: Tenant ID (a GUID) for the AAD instance.
    ///   - clientId: The service principal client or application ID (a GUID).
    ///   - authority: An authority URI for the application.
    ///   - redirectUri: An optional redirect URI for the application.
    ///   - account: Initial value of the `MSALAccount` object, if known.
    public init(
        tenant: String,
        clientId: String,
        authority: String,
        redirectUri: String? = nil,
        account: MSALAccount? = nil
    ) throws {
        let error = AzureError.general("Unable to create MSAL credential object.")
        guard let authorityUrl = URL(string: authority) else {
            throw error
        }
        let authority = try MSALAADAuthority(url: authorityUrl)
        let config = MSALPublicClientApplicationConfig(
            clientId: clientId,
            redirectUri: redirectUri,
            authority: authority
        )
        guard let application = try? MSALPublicClientApplication(configuration: config) else { throw error }
        self.init(tenant: tenant, clientId: clientId, application: application, account: account)
    }

    /// Create an OAuth credential.
    /// - Parameters:
    ///   - tenant: Tenant ID (a GUID) for the AAD instance.
    ///   - clientId: The service principal client or application ID (a GUID).
    ///   - application: An `MSALPublicClientApplication` object.
    ///   - account: Initial value of the `MSALAccount` object, if known.
    public init(
        tenant: String,
        clientId: String,
        application: MSALPublicClientApplication,
        account: MSALAccount? = nil
    ) {
        self.tenant = tenant
        self.clientId = clientId
        self.application = application
        self.account = account
    }

    // MARK: Public Methods

    /// Retrieve a token for the provided scope.
    /// - Parameters:
    ///   - scopes: A list of a scope strings for which to retrieve the token.
    ///   - completion: A completion handler which forwards the access token.
    public func token(forScopes scopes: [String], then completion: @escaping (AccessToken?, Error?) -> Void) {
        let group = DispatchGroup()
        var accessToken: AccessToken?
        var returnError: Error?
        group.enter()
        if let account = account {
            acquireTokenSilently(forAccount: account, withScopes: scopes) { result, error in
                returnError = error
                if let result = result {
                    accessToken = AccessToken(
                        token: result.accessToken,
                        expiresOn: Int(result.expiresOn.timeIntervalSince1970)
                    )
                } else {
                    accessToken = nil
                }
                group.leave()
            }
        } else {
            acquireTokenInteractively(withScopes: scopes) { result, error in
                returnError = error
                if let result = result {
                    self.delegate?.didCompleteMSALRequest(withResult: result)
                    accessToken = AccessToken(
                        token: result.accessToken,
                        expiresOn: Int(result.expiresOn.timeIntervalSince1970)
                    )
                } else {
                    accessToken = nil
                }
                group.leave()
            }
        }
        group.notify(queue: DispatchQueue.main) {
            completion(accessToken, returnError)
        }
    }

    // MARK: Internal Methods

    internal func acquireTokenInteractively(
        withScopes scopes: [String],
        then completion: @escaping (MSALResult?, Error?) -> Void
    ) {
        guard let parent = delegate?.parentForWebView() else { return }
        let webViewParameters = MSALWebviewParameters(parentViewController: parent)
        let parameters = MSALInteractiveTokenParameters(scopes: scopes, webviewParameters: webViewParameters)
        application.acquireToken(with: parameters) { result, error in
            completion(result, error)
        }
    }

    internal func acquireTokenSilently(
        forAccount account: MSALAccount,
        withScopes scopes: [String],
        then completion: @escaping (MSALResult?, Error?) -> Void
    ) {
        let parameters = MSALSilentTokenParameters(scopes: scopes, account: account)
        application.acquireTokenSilent(with: parameters) { result, error in
            if let error = error {
                let nsError = error as NSError

                // interactionRequired means we need to ask the user to sign-in. This usually happens
                // when the user's Refresh Token is expired or if the user has changed their password
                // among other possible reasons.
                if nsError.domain == MSALErrorDomain {
                    if nsError.code == MSALError.interactionRequired.rawValue {
                        self.acquireTokenInteractively(withScopes: scopes) { result, error in
                            completion(result, error)
                        }
                    }
                }
            }
            completion(result, error)
        }
    }
}

public class AnonymousAccessPolicy: Authenticating {
    public var next: PipelineStage?

    public init() {}

    public func authenticate(request: PipelineRequest, then completion: @escaping OnRequestCompletionHandler) {
        completion(request, nil)
    }
}

public class BearerTokenCredentialPolicy: Authenticating {
    // MARK: Properties

    public var next: PipelineStage?

    private let scopes: [String]
    private let credential: TokenCredential
    private var token: AccessToken?

    // MARK: Initializers

    public init(credential: TokenCredential, scopes: [String]) {
        self.scopes = scopes
        self.credential = credential
        self.token = nil
    }

    // MARK: Public Methods

    /// Authenticates an HTTP `PipelineRequest` with an OAuth token.
    /// - Parameters:
    ///   - request: A `PipelineRequest` object.
    ///   - completion: A completion handler that forwards the modified pipeline request.
    public func authenticate(request: PipelineRequest, then completion: @escaping OnRequestCompletionHandler) {
        guard let token = self.token?.token else { return }
        request.httpRequest.headers[.authorization] = "Bearer \(token)"
        completion(request, nil)
    }

    /// Authenticates an HTTP `PipelineRequest` with an OAuth token.
    /// - Parameters:
    ///   - request: A `PipelineRequest` object.
    ///   - completion: A completion handler that forwards the modified pipeline request.
    public func on(request: PipelineRequest, then completion: @escaping OnRequestCompletionHandler) {
        credential.token(forScopes: scopes) { token, error in
            if let error = error {
                completion(request, error)
                return
            }
            self.token = token
            self.authenticate(request: request, then: completion)
        }
    }
}
