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

/// An OAuth credential object.
public class StorageOAuthCredential: TokenCredential {

    internal let tenant: String

    internal let clientId: String

    // MARK: Initializers
    /**
     Create an OAuth credential.
     - Parameter tenant: Tenant ID (a GUID) for the AAD instance.
     - Parameter clientId: The service principal client or application ID (a GUID).
     - Returns: A `StorageOAuthCredential` object.
     */
    public init(tenant: String, clientId: String) {
        self.tenant = tenant
        self.clientId = clientId
    }

    // MARK: Public Methods

    /**
     Retrieve a token for the provided scope.
     - Parameter scopes: List of scopes for which to retrieve a token.
     - Returns: A valid `AccessToken`, or nil.
     */
    public func token(forScopes scopes: [String]) -> AccessToken? {
        let tokenLife = 15 // in minutes
        guard var authUrl = URLComponents(string: "https://login.microsoftonline.com/common/oauth2/authorize") else { return nil }
        guard let expiration = Calendar.current.date(byAdding: .minute, value: tokenLife, to: Date()) else { return nil }
        let expirationInt = Int(expiration.timeIntervalSinceReferenceDate)
        var token = ""

        authUrl.queryItems = [
            "tenant": tenant,
            "client_id": clientId,
            "response_type": "code",
            "resource": scopes.first!
        ].convertToQueryItems()

        guard let url = authUrl.url else { return nil}
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = HttpMethod.GET.rawValue

        let group = DispatchGroup()
        group.enter()
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            let test = "best"
            group.leave()
        }
        group.wait()
        return AccessToken(token: token, expiresOn: expirationInt)
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
        request.httpRequest.headers[HttpHeader.authorization] = "Bearer \(token)"
    }
}
