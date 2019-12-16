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

import AzureCore
import Foundation
import MSAL

public protocol MSALInteractiveDelegate: UIViewController {
    func parentForWebView() -> UIViewController
    func didCompleteMSALRequest(withResult result: MSALResult)
}

public extension MSALInteractiveDelegate {
    func parentForWebView() -> UIViewController {
        return self
    }

    func didCompleteMSALRequest(_: MSALResult) {}
}

/// An OAuth credential object.
public class StorageOAuthCredential: TokenCredential {

    internal let tenant: String

    internal let clientId: String

    internal let application: MSALPublicClientApplication

    internal let account: MSALAccount?

    internal var delegate: MSALInteractiveDelegate? {
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
    public convenience init(tenant: String, clientId: String, authority: String, redirectUri: String? = nil,
                            account: MSALAccount? = nil) throws {
        let error = AzureError.general("Unable to create MSAL credential object.")
        guard let authorityUrl = URL(string: authority) else {
            throw error
        }
        let authority = try MSALAADAuthority(url: authorityUrl)
        let config = MSALPublicClientApplicationConfig(clientId: clientId,
                                                       redirectUri: redirectUri, authority: authority)
        guard let application = try? MSALPublicClientApplication(configuration: config) else { throw error }
        self.init(tenant: tenant, clientId: clientId, application: application, account: account)
    }

    /// Create an OAuth credential.
    /// - Parameters:
    ///   - tenant: Tenant ID (a GUID) for the AAD instance.
    ///   - clientId: The service principal client or application ID (a GUID).
    ///   - application: An `MSALPublicClientApplication` object.
    ///   - account: Initial value of the `MSALAccount` object, if known.
    public init(tenant: String, clientId: String, application: MSALPublicClientApplication,
                account: MSALAccount? = nil) {
        self.tenant = tenant
        self.clientId = clientId
        self.application = application
        self.account = account
    }

    // MARK: Public Methods

    public func token(forScopes scopes: [String], then completion: @escaping (AccessToken?) -> Void) {
        let group = DispatchGroup()
        var accessToken: AccessToken?
        group.enter()
        if let account = account {
            acquireTokenSilently(forAccount: account, withScopes: scopes) { result, error in
                if let error = error {
                    print(error)
                }
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
            acquireTokenInteractively(withScopes: scopes) { (result, error) in
                if let error = error {
                    print(error)
                }
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
            completion(accessToken)
        }
    }

    /**
     Retrieve a token for the provided scope.
     - Parameter scopes: List of scopes for which to retrieve a token.
     - Returns: A valid `AccessToken`, or nil.
     */
    public func token(forScopes scopes: [String]) -> AccessToken? {
        let group = DispatchGroup()
        var accessToken: AccessToken?
        group.enter()
        if let account = account {
            acquireTokenSilently(forAccount: account, withScopes: scopes) { result, error in
                if let error = error {
                    print(error)
                }
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
            acquireTokenInteractively(withScopes: scopes) { (result, error) in
                if let error = error {
                    print(error)
                }
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
        }
        group.wait()
        return accessToken
    }

    // MARK: Internal Methods

    internal func acquireTokenInteractively(withScopes scopes: [String],
                                            then completion: @escaping (MSALResult?, Error?) -> Void) {
        guard let parent = delegate?.parentForWebView() else { return }
        let webViewParameters = MSALWebviewParameters(parentViewController: parent)
        let parameters = MSALInteractiveTokenParameters(scopes: scopes, webviewParameters: webViewParameters)
        self.application.acquireToken(with: parameters) { result, error in
            completion(result, error)
        }
    }

    internal func acquireTokenSilently(forAccount account: MSALAccount, withScopes scopes: [String],
                                       then completion: @escaping (MSALResult?, Error?) -> Void) {
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
                        return
                    }
                }
                return
            }
            completion(result, error)
        }
    }
}

public class StorageSASCredential {
    internal let blobEndpoint: String?
    internal let queueEndpoint: String?
    internal let fileEndpoint: String?
    internal let tableEndpoint: String?
    internal let sasToken: String

    /**
     Create a shared access signature credential.
     - Parameter connectionString: A valid storage connection string.
     - Returns: A `StorageSASCredential` object.
     */
    public init(connectionString: String) throws {
        // temp variables
        var blob: String?
        var queue: String?
        var file: String?
        var table: String?
        var sas: String?

        for component in connectionString.components(separatedBy: ";") {
            let compSplits = component.split(separator: "=", maxSplits: 1)
            let key = String(compSplits[0]).lowercased()
            let value = String(compSplits[1])

            switch key {
            case "blobendpoint":
                blob = value
            case "queueendpoint":
                queue = value
            case "fileendpoint":
                file = value
            case "tableendpoint":
                table = value
            case "sharedaccesssignature":
                sas = value
            case "accountkey":
                let message = """
                    Form of connection string with 'AccountKey' is not allowed. Provide a SAS-based
                    connection string.
                """
                throw HttpResponseError.clientAuthentication(message)
            default:
                continue
            }
        }
        let invalidCS = HttpResponseError.clientAuthentication("The connection string \(connectionString) is invalid.")
        guard let sasToken = sas else { throw invalidCS }
        self.sasToken = sasToken
        blobEndpoint = blob
        queueEndpoint = queue
        fileEndpoint = file
        tableEndpoint = table
    }
}

/**
 A Storage authentication policy that relies on a shared access signature.
 */
public class StorageSASAuthenticationPolicy: AuthenticationProtocol {

    /// The next stage in the HTTP pipeline.
    public var next: PipelineStageProtocol?

    /// A shared access signature credential.
    public let credential: StorageSASCredential

    // MARK: Initializers

    /**
     Create a Storage SAS-based authentication policy.
     - Parameter credential: A `StorageSASCredential` object.
     - Returns: A `StorageSASAuthenticationPolicy` object.
     */
    public init(credential: StorageSASCredential) {
        self.credential = credential
    }

    // MARK: Public Methods

    /**
     Authenticates an HTTP `PipelineRequest` by appending the SAS token as query parameters.
     - Parameter request: A `PipelineRequest` object.
     */
    public func authenticate(request: PipelineRequest) {
        let queryParams = parse(sasToken: credential.sasToken)
        request.httpRequest.format(queryParams: queryParams)
        request.httpRequest.headers["x-ms-date"] = Date().rfc1123Format
    }

    // MARK: Private Methods

    private func parse(sasToken: String) -> [String: String] {
        var queryItems = [String: String]()
        for component in sasToken.components(separatedBy: "&") {
            let splitComponent = component.split(separator: "=", maxSplits: 1).map(String.init)
            let name = splitComponent.first!
            let value = splitComponent.count == 2 ? splitComponent.last : ""
            queryItems[name] = value?.removingPercentEncoding
        }
        return queryItems
    }
}

/**
 A Storage authentication policy that uses OAuth tokens generated with AAD credentials.
 */
public class StorageOAuthAuthenticationPolicy: AuthenticationProtocol {

    /// The next stage in the HTTP pipeline.
    public var next: PipelineStageProtocol?

    /// An OAuth credential.
    public let credential: StorageOAuthCredential

    // MARK: Initializers

    /**
     Create a Storage OAuth-based authentication policy.
     - Parameter credential: A `StorageOAuthCredential` object.
     - Returns: A `StorageOAuthAuthenticationPolicy` object.
     */
    public init(credential: StorageOAuthCredential) {
        self.credential = credential
    }

    // MARK: Public Methods

    /**
     Authenticates an HTTP `PipelineRequest` by appending the SAS token as query parameters.
     - Parameter request: A `PipelineRequest` object.
     */
    public func authenticate(request: PipelineRequest) {
        let scope = "https://storage.azure.com/.default"
        guard let token = credential.token(forScopes: [scope]) else { return }
        request.httpRequest.headers[HttpHeader.authorization] = "Bearer \(token.token)"
    }

    public func onRequest(_ request: PipelineRequest, then completion: @escaping (PipelineRequest) -> Void) {
        let scope = "https://storage.azure.com/.default"
        credential.token(forScopes: [scope]) { result in
            guard let token = result else { return }
            request.httpRequest.headers[HttpHeader.authorization] = "Bearer \(token.token)"
            completion(request)
        }
    }
}
