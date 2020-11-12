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

/// A result handler to call when you have completed the process of acquiring a SAS token. Call the handler with an
/// account-level shared access signature connection string, or a container- or blob-level shared access signature URI.
/// If the process failed, call the handler with the error instead.
public typealias StorageSASTokenResultHandler = (Result<String, Error>) -> Void

/// A closure that is called when a SAS token is needed to authenticate a request. The closure is called with the
/// URL of the request requiring authentication, the permissions needed to complete the operation, and a
/// `StorageSASTokenResultHandler` which you must call to provide the SAS token that will be used to authenticate the
/// request, or an error if the token cannot be provided.
public typealias StorageSASTokenProvider = (URL, StorageSASTokenPermissions, @escaping StorageSASTokenResultHandler)
    -> Void

/// A Storage shared access signature credential object.
public class StorageSASCredential: Credential {
    internal let tokenProvider: StorageSASTokenProvider
    public let tokenCache: StorageSASTokenCache?

    // MARK: Initializers

    /// Create a shared access signature credential from an closure that returns an account-level shared access
    /// signature connection string, or a container- or blob-level shared access signature URI.
    /// - Parameters:
    ///   - tokenProvider: A closure that generates an account-level shared access signature connection string, or a
    ///     container- or blob-level shared access signature URI. The closure is called with the Blob Service URL to
    ///     authenticate, the permissions required for the operation, and a result handler that you must call to provide
    ///     the generated SAS token. The SAS token will be cached until it expires if a `tokenCache` is provided.
    ///   - tokenCache: A `TokenCache` object that this `StorageSASCredential` will use to cache tokens that are
    ///     returned from the `tokenProvider`.
    public init(
        tokenProvider: @escaping StorageSASTokenProvider,
        tokenCache: StorageSASTokenCache? = DefaultStorageSASTokenCache()
    ) {
        self.tokenProvider = tokenProvider
        self.tokenCache = tokenCache
    }

    /// Create a shared access signature credential from a static account-level shared access signature connection
    /// string, or a container- or blob-level shared access signature URI.
    /// - Parameters:
    ///   - staticCredential: An account-level shared access signature connection string, or a container- or blob-level
    ///     shared access signature URI. **WARNING**: Static credentials are inherently insecure in end-user facing
    ///     applications such as mobile and desktop apps. Static credentials should be treated as secrets and should not
    ///     be shared with end users, and cannot be rotated once compiled into an application. Since mobile and desktop
    ///     apps are inherently end-user facing, it's highly recommended that static credentials not be used in
    ///     production for such applications.
    public init(staticCredential: String) {
        self.tokenProvider = { _, _, resultHandler in
            resultHandler(.success(staticCredential))
        }
        self.tokenCache = nil
    }

    // MARK: Public Methods

    /// :nodoc:
    public func validate() throws {
        // Since the token is provided dynamically by the tokenProvider, this credential is always valid
    }

    // MARK: Private methods

    fileprivate func token(
        forUrl url: URL,
        withPermissions permissions: StorageSASTokenPermissions,
        completionHandler: @escaping (Result<StorageSASToken, Error>) -> Void
    ) {
        tokenProvider(url, permissions) { result in
            do {
                switch result {
                case let .success(newCredential):
                    if let token = try StorageSASCredential.token(fromConnectionString: newCredential) {
                        completionHandler(.success(token))
                        return
                    } else if let token = StorageSASCredential.token(fromBlobSasUri: newCredential) {
                        completionHandler(.success(token))
                        return
                    } else {
                        throw AzureError.client("The credential \(newCredential) is invalid.")
                    }
                case let .failure(error):
                    throw error
                }
            } catch {
                completionHandler(.failure(error))
            }
        }
    }

    internal static func token(fromConnectionString connectionString: String) throws -> StorageSASToken? {
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
                    Form of connection string with 'SharedAccessSignature' is expected - 'AccountKey' is not allowed.
                    You must provide a Shared Access Signature connection string.
                """
                throw AzureError.client(message)
            default:
                continue
            }
        }

        guard let sasToken = sas else { return nil }

        return StorageSASToken(
            sasToken: sasToken,
            blobEndpoint: blob,
            queueEndpoint: queue,
            fileEndpoint: file,
            tableEndpoint: table
        )
    }

    internal static func token(fromBlobSasUri blobSasUri: String) -> StorageSASToken? {
        if let sasUri = URL(string: blobSasUri), let sasToken = sasUri.query, let scheme = sasUri.scheme,
            let host = sasUri.host {
            return StorageSASToken(sasToken: sasToken, blobEndpoint: "\(scheme)://\(host)/")
        } else {
            return nil
        }
    }
}

/// A Storage authentication policy that relies on a shared access signature.
internal class StorageSASAuthenticationPolicy: Authenticating {
    /// The next stage in the HTTP pipeline.
    public var next: PipelineStage?

    /// A shared access signature credential.
    public internal(set) var credential: StorageSASCredential

    // MARK: Initializers

    /// Create a Storage SAS-based authentication policy.
    /// - Parameter credential: A `StorageSASCredential` object.
    public init(credential: StorageSASCredential) {
        self.credential = credential
    }

    // MARK: Public Methods

    /// Authenticates an HTTP `PipelineRequest` by appending the SAS token as query parameters.
    /// - Parameters:
    ///   - request: A `PipelineRequest` object.
    ///   - completionHandler: A completion handler that forwards the modified pipeline request.
    public func authenticate(request: PipelineRequest, completionHandler: @escaping OnRequestCompletionHandler) {
        guard let urlToAuthorize = request.httpRequest.url.deletingQueryParameters() else {
            completionHandler(request, AzureError.client("The request could not be authenticated."))
            return
        }

        if let cache = credential.tokenCache, let token = cache.getToken(
            forUrl: urlToAuthorize,
            withPermissions: StorageSASTokenPermissions.all
        ) {
            if token.valid {
                apply(sasToken: token, toRequest: request)
                completionHandler(request, nil)
                return
            } else {
                cache.removeToken(forUrl: urlToAuthorize)
            }
        }

        credential.token(forUrl: request.httpRequest.url, withPermissions: StorageSASTokenPermissions.all) { result in
            switch result {
            case let .success(token):
                self.apply(sasToken: token, toRequest: request)
                if self.credential.tokenCache != nil {
                    request.context?.add(value: token as AnyObject, forKey: "sasToken")
                }
                completionHandler(request, nil)
            case let .failure(error):
                completionHandler(request, AzureError.client("Authentication error.", error))
            }
        }
    }

    public func on(response: PipelineResponse, completionHandler: @escaping OnResponseCompletionHandler) {
        if let sasToken = response.context?.value(forKey: "sasToken") as? StorageSASToken,
            let cache = credential.tokenCache,
            let urlToAuthorize = response.httpRequest.url.deletingQueryParameters() {
            cache.add(token: sasToken, forUrl: urlToAuthorize)
        }
        completionHandler(response, nil)
    }

    public func on(
        error: AzureError,
        pipelineResponse: PipelineResponse,
        completionHandler: @escaping OnErrorCompletionHandler
    ) {
        if let statusCode = pipelineResponse.httpResponse?.statusCode, statusCode >= 400, statusCode < 500,
            let cache = credential.tokenCache,
            let urlToAuthorize = pipelineResponse.httpRequest.url.deletingQueryParameters() {
            cache.removeToken(forUrl: urlToAuthorize)
        }
        completionHandler(error, false)
    }

    // MARK: Private Methods

    private func apply(sasToken: StorageSASToken, toRequest request: PipelineRequest) {
        let queryParams = parse(sasToken: sasToken.sasToken)
        if let requestUrl = request.httpRequest.url.appendingQueryParameters(queryParams) {
            request.httpRequest.url = requestUrl
        }
        request.httpRequest.headers[.xmsDate] = Rfc1123Date(Date())?.requestString
    }

    private func parse(sasToken: String) -> RequestParameters {
        var queryItems = RequestParameters()
        for component in sasToken.components(separatedBy: "&") {
            let splitComponent = component.split(separator: "=", maxSplits: 1).map(String.init)
            let name = splitComponent.first!
            let value = splitComponent.count == 2 ? splitComponent.last : ""
            queryItems.add((.query, name, value, .skipEncoding))
        }
        return queryItems
    }
}
