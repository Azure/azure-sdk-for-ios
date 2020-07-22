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
public typealias SASTokenResultHandler = (Result<String, Error>) -> Void

/// A closure that is called when a SAS token is needed to authenticate a request. The closure is called with the
/// URL of the request requiring authentication, and a `SASTokenResultHandler` which you must call to provide the SAS
/// token that will be used to authenticate the request, or an error if the token cannot be provided.
public typealias SASTokenProvider = (URL, SASTokenResultHandler) -> Void

internal struct SASToken {
    let sasToken: String
    let blobEndpoint: String?
    let queueEndpoint: String?
    let fileEndpoint: String?
    let tableEndpoint: String?
    let validAt: Date?
    let expiredAt: Date?

    init(
        sasToken: String,
        blobEndpoint: String? = nil,
        queueEndpoint: String? = nil,
        fileEndpoint: String? = nil,
        tableEndpoint: String? = nil
    ) {
        self.sasToken = sasToken
        self.blobEndpoint = blobEndpoint
        self.queueEndpoint = queueEndpoint
        self.fileEndpoint = fileEndpoint
        self.tableEndpoint = tableEndpoint

        let comps = URLComponents(string: "?\(sasToken)")
        self.validAt = Date(comps?.queryItems?.filter { $0.name == "st" }.first?.value, format: .iso8601)
        self.expiredAt = Date(comps?.queryItems?.filter { $0.name == "se" }.first?.value, format: .iso8601)
    }

    var valid: Bool {
        guard let validAt = validAt, let expiredAt = expiredAt else { return false }
        let now = Date()
        return now >= validAt && now < expiredAt
    }
}

/// A Storage shared access signature credential object.
public class StorageSASCredential: AzureCredential {
    internal let tokenProvider: SASTokenProvider
    private var tokenCache: [URL: SASToken] = [:]

    // MARK: Initializers

    /// Create a shared access signature credential from an closure that returns an account-level shared access
    /// signature connection string, or a container- or blob-level shared access signature URI.
    /// - Parameters:
    ///   - tokenProvider: A closure that returns an account-level shared access signature connection string, or a
    ///   container- or blob-level shared access signature URI. The closure is called with the Blob Service URL to
    ///   authenticate. The returned SAS token will be cached for that URL until it expires.
    public init(tokenProvider: @escaping SASTokenProvider) {
        self.tokenProvider = tokenProvider
    }

    // MARK: Public Methods

    public func validate() throws {
        // Since the token is provided dynamically by the tokenProvider, this credential is always valid
    }

    /// Remove all SAS tokens currently in the token cache.
    public func removeCachedTokens() {
        tokenCache.removeAll()
    }

    // MARK: Private methods

    fileprivate func cachedToken(forUrl url: URL) -> SASToken? {
        return tokenCache[url]
    }

    fileprivate func setCachedToken(_ token: SASToken, forUrl url: URL) {
        tokenCache.updateValue(token, forKey: url)
    }

    fileprivate func removeCachedToken(forUrl url: URL) {
        tokenCache.removeValue(forKey: url)
    }

    fileprivate func token(forUrl url: URL, completionHandler: (Result<SASToken, Error>) -> Void) {
        tokenProvider(url) { result in
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
                        throw AzureError.sdk("The credential \(newCredential) is invalid.")
                    }
                case let .failure(error):
                    throw error
                }
            } catch {
                completionHandler(.failure(error))
            }
        }
    }

    internal static func token(fromConnectionString connectionString: String) throws -> SASToken? {
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
                throw AzureError.sdk(message)
            default:
                continue
            }
        }

        guard let sasToken = sas else { return nil }

        return SASToken(
            sasToken: sasToken,
            blobEndpoint: blob,
            queueEndpoint: queue,
            fileEndpoint: file,
            tableEndpoint: table
        )
    }

    internal static func token(fromBlobSasUri blobSasUri: String) -> SASToken? {
        if let sasUri = URL(string: blobSasUri), let sasToken = sasUri.query, let scheme = sasUri.scheme,
            let host = sasUri.host {
            return SASToken(sasToken: sasToken, blobEndpoint: "\(scheme)://\(host)/")
        } else {
            return nil
        }
    }
}

/// A Storage account shared key credential object.
///
/// **WARNING**: Shared keys are inherently insecure in end-user facing applications such as mobile and desktop apps.
/// Shared keys provide full access to an entire storage account and should not be shared with end users. Since mobile
/// and desktop apps are inherently end-user facing, it's highly recommended that storage account shared key credentials
/// not be used in production for such applications.
public struct StorageSharedKeyCredential: AzureCredential {
    internal let accessKey: String?
    internal let accountName: String?
    internal let blobEndpoint: String?
    internal let queueEndpoint: String?
    internal let fileEndpoint: String?
    internal let tableEndpoint: String?
    internal let error: Error?

    /// Create a shared key credential from a storage account connection string.
    ///
    /// **WARNING**: Shared keys are inherently insecure in end-user facing applications such as mobile and desktop
    /// apps. Shared keys provide full access to an entire storage account and should not be shared with end users.
    /// Since mobile and desktop apps are inherently end-user facing, it's highly recommended that storage account
    /// shared key credentials not be used in production for such applications.
    /// - Parameters:
    ///   - connectionString: The storage account connection string.
    public init(connectionString: String) {
        var account: String?
        var accountKey: String?
        var scheme = "https"
        var suffix = "core.windows.net"
        var error: Error?

        for component in connectionString.components(separatedBy: ";") {
            let compSplits = component.split(separator: "=", maxSplits: 1)
            let key = String(compSplits[0]).lowercased()
            let value = String(compSplits[1])

            switch key {
            case "defaultendpointsprotocol":
                scheme = value
            case "accountname":
                account = value
            case "accountkey":
                accountKey = value
            case "endpointsuffix":
                suffix = value
            case "sharedaccesssignature":
                let message = """
                    Form of connection string with 'AccountKey' is expected - 'SharedAccessSignature' is not allowed.
                    You must provide a storage account connection string with a shared key.
                """
                error = AzureError.sdk(message)
            default:
                continue
            }
        }

        var blob: String?
        var queue: String?
        var file: String?
        var table: String?

        if accountKey == nil, error == nil {
            error = AzureError.sdk("The connection string \(connectionString) is invalid.")
        }

        if let account = account {
            let blobEndpoint = StorageBlobClient.endpoint(
                forAccount: account,
                withProtocol: scheme,
                withSuffix: suffix
            )
            blob = blobEndpoint
            queue = blobEndpoint.replacingOccurrences(of: "blob.\(suffix)", with: "queue.\(suffix)")
            file = blobEndpoint.replacingOccurrences(of: "blob.\(suffix)", with: "file.\(suffix)")
            table = blobEndpoint.replacingOccurrences(of: "blob.\(suffix)", with: "table.\(suffix)")
        } else if error == nil {
            error = AzureError.sdk("The connection string \(connectionString) is invalid.")
        }

        self.accountName = account
        self.accessKey = accountKey
        self.blobEndpoint = blob
        self.queueEndpoint = queue
        self.fileEndpoint = file
        self.tableEndpoint = table
        self.error = error
    }

    /// Create a shared key credential from a storage account name and access key.
    ///
    /// **WARNING**: Shared keys are inherently insecure in end-user facing applications such as mobile and desktop
    /// apps. Shared keys provide full access to an entire storage account and should not be shared with end users.
    /// Since mobile and desktop apps are inherently end-user facing, it's highly recommended that storage account
    /// shared key credentials not be used in production for such applications.
    /// - Parameters:
    ///   - accountName: The storage account name.
    ///   - accessKey: The storage account access key.
    ///   - endpointProtocol: The storage account endpoint protocol.
    ///   - endpointSuffix: The storage account endpoint suffix.
    public init(
        accountName: String,
        accessKey: String,
        endpointProtocol: String = "https",
        endpointSuffix: String = "core.windows.net"
    ) {
        var blob: String?
        var queue: String?
        var file: String?
        var table: String?
        var error: Error?

        if accessKey != "", accountName != "", endpointProtocol != "", endpointSuffix != "" {
            let blobEndpoint = StorageBlobClient.endpoint(
                forAccount: accountName,
                withProtocol: endpointProtocol,
                withSuffix: endpointSuffix
            )
            blob = blobEndpoint
            queue = blobEndpoint.replacingOccurrences(of: "blob.\(endpointSuffix)", with: "queue.\(endpointSuffix)")
            file = blobEndpoint.replacingOccurrences(of: "blob.\(endpointSuffix)", with: "file.\(endpointSuffix)")
            table = blobEndpoint.replacingOccurrences(of: "blob.\(endpointSuffix)", with: "table.\(endpointSuffix)")
        } else {
            error = AzureError.sdk("The provided parameters are invalid.")
        }

        self.accountName = accountName
        self.accessKey = accessKey
        self.blobEndpoint = blob
        self.queueEndpoint = queue
        self.fileEndpoint = file
        self.tableEndpoint = table
        self.error = error
    }

    // MARK: Public Methods

    public func validate() throws {
        if let error = error {
            throw error
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
            completionHandler(request, AzureError.sdk("The request could not be authenticated."))
            return
        }

        if let token = credential.cachedToken(forUrl: urlToAuthorize) {
            if token.valid {
                apply(sasToken: token, toRequest: request)
                completionHandler(request, nil)
                return
            } else {
                credential.removeCachedToken(forUrl: urlToAuthorize)
            }
        }

        credential.token(forUrl: request.httpRequest.url) { result in
            switch result {
            case let .success(token):
                apply(sasToken: token, toRequest: request)
                request.context?.add(value: token as AnyObject, forKey: .sasToken)
                completionHandler(request, nil)
            case let .failure(error):
                completionHandler(request, AzureError.sdk("Authentication error.", error))
            }
        }
    }

    public func on(response: PipelineResponse, completionHandler: @escaping OnResponseCompletionHandler) {
        if let sasToken = response.context?.value(forKey: .sasToken) as? SASToken,
            let urlToAuthorize = response.httpRequest.url.deletingQueryParameters() {
            credential.setCachedToken(sasToken, forUrl: urlToAuthorize)
        }
        completionHandler(response, nil)
    }

    public func on(
        error: AzureError,
        pipelineResponse: PipelineResponse,
        completionHandler: @escaping OnErrorCompletionHandler
    ) {
        if let statusCode = pipelineResponse.httpResponse?.statusCode, statusCode >= 400, statusCode < 500,
            let urlToAuthorize = pipelineResponse.httpRequest.url.deletingQueryParameters() {
            credential.removeCachedToken(forUrl: urlToAuthorize)
        }
        completionHandler(error, false)
    }

    // MARK: Private Methods

    private func apply(sasToken: SASToken, toRequest request: PipelineRequest) {
        let queryParams = parse(sasToken: sasToken.sasToken)
        if let requestUrl = request.httpRequest.url.appendingQueryParameters(queryParams) {
            request.httpRequest.url = requestUrl
        }
        request.httpRequest.headers[.xmsDate] = String(describing: Date(), format: .rfc1123)
    }

    private func parse(sasToken: String) -> [QueryParameter] {
        var queryItems = [QueryParameter]()
        for component in sasToken.components(separatedBy: "&") {
            let splitComponent = component.split(separator: "=", maxSplits: 1).map(String.init)
            let name = splitComponent.first!
            let value = splitComponent.count == 2 ? splitComponent.last : ""
            queryItems.append(name, value?.removingPercentEncoding)
        }
        return queryItems
    }
}

/// A Storage authentication policy that relies on a shared key.
internal class StorageSharedKeyAuthenticationPolicy: Authenticating {
    /// The next stage in the HTTP pipeline.
    public var next: PipelineStage?

    /// A shared access signature credential.
    public let credential: StorageSharedKeyCredential

    // MARK: Initializers

    /// Create a Storage shared key authentication policy.
    /// - Parameter credential: A `StorageSharedKeyCredential` object.
    public init(credential: StorageSharedKeyCredential) {
        self.credential = credential
    }

    // MARK: Public Methods

    /// Authenticates an HTTP `PipelineRequest` with a shared key.
    /// - Parameters:
    ///   - request: A `PipelineRequest` object.
    ///   - completionHandler: A completion handler that forwards the modified pipeline request.
    public func authenticate(request: PipelineRequest, completionHandler: @escaping OnRequestCompletionHandler) {
        do {
            try credential.validate()
        } catch {
            completionHandler(request, AzureError.sdk("Authentication error.", error))
            return
        }

        let httpRequest = request.httpRequest
        guard let accountName = credential.accountName else { return }
        guard let accessKey = credential.accessKey else { return }
        guard let signingString = try? stringToSign(forRequest: httpRequest) else { return }
        guard let signatureValue = try? signature(forString: signingString, withKey: accessKey) else { return }

        request.httpRequest.headers[.authorization] = "SharedKey \(accountName):\(signatureValue)"
        completionHandler(request, nil)
    }

    // MARK: Private Methods

    /// Generate the string to sign for Blob, Queue, and File Services.
    internal func stringToSign(forRequest request: HTTPRequest) throws -> String {
        let headers = request.headers
        var stringToSign = request.httpMethod.rawValue + "\n"
        stringToSign += (headers[.contentEncoding] ?? "") + "\n"
        stringToSign += (headers[.contentLanguage] ?? "") + "\n"

        // This will need to change to support API version 2014-02-14 and earlier.
        stringToSign += (headers[.contentLength] == "0" ? "" : (headers[.contentLength] ?? "")) + "\n"

        stringToSign += (headers[.contentMD5] ?? "") + "\n"
        stringToSign += (headers[.contentType] ?? "") + "\n"
        stringToSign += (headers[.xmsDate] != nil ? "" : (headers[.date] ?? "")) + "\n"
        stringToSign += (headers[.ifModifiedSince] ?? "") + "\n"
        stringToSign += (headers[.ifMatch] ?? "") + "\n"
        stringToSign += (headers[.ifNoneMatch] ?? "") + "\n"
        stringToSign += (headers[.ifUnmodifiedSince] ?? "") + "\n"
        stringToSign += (headers[.range] ?? "") + "\n"

        stringToSign += canonicalized(headers: headers)
        stringToSign += try canonicalized(resource: request.url)
        return stringToSign
    }

    /// Generate the canonicalized headers string for all services.
    private func canonicalized(headers: HTTPHeaders) -> String {
        // 1. Retrieve all headers for the resource that begin with `x-ms-`.
        // 2. Convert each HTTP header name to lowercase.
        var subset = [String: String]()
        for key in headers.keys {
            let lowerKey = key.lowercased()
            if lowerKey.starts(with: "x-ms-") {
                subset[lowerKey] = headers[key] ?? ""
            }
        }

        // 3. Sort the headers lexicographically by header name, in ascending order.
        let headerNames = subset.keys.sorted()

        var canonicalizedHeaders = ""
        // This will need to filter out lines with empty values to support API versions prior to 2016-05-31.
        for name in headerNames {
            // 4. Replace any linear whitespace in the header value with a single space.
            let value = canonicalized(headerValue: subset[name]!)

            // 5. Trim any whitespace around the colon in the header.
            // 6. Append a new-line character to each canonicalized header in the resulting list. Construct the
            //    CanonicalizedHeaders string by concatenating all headers in this list into a single string.
            canonicalizedHeaders += name.trimmingCharacters(in: .whitespacesAndNewlines) + ":"
            canonicalizedHeaders += value.trimmingCharacters(in: .whitespacesAndNewlines) + "\n"
        }

        return canonicalizedHeaders
    }

    /// Generate a canonicalized header value.
    private func canonicalized(headerValue: String) -> String {
        // Replace any linear whitespace in the header value with a single space. Linear whitespace includes carriage
        // return/line feed (CRLF), spaces, and tabs. See RFC 2616, section 4.2 for details. Do not replace any
        // whitespace inside a quoted string.

        // NB: Other Azure SDKs do not appear to perform the described replacement, so we are punting on this for now.
        return headerValue
    }

    /// Generate the canonicalized resource string in Shared Key format for 2009-09-19 and later
    private func canonicalized(resource: URL) throws -> String {
        guard let comps = URLComponents(url: resource, resolvingAgainstBaseURL: true),
            let accountName = comps.host?.split(separator: ".", maxSplits: 1).first
        else {
            throw AzureError.sdk("Resource URL could not be parsed.")
        }

        // 1. Beginning with an empty string (""), append a forward slash (/), followed by the name of the account that
        //    owns the resource being accessed.
        var canonicalizedResource = "/\(accountName)"

        // 2. Append the resource's encoded URI path, without any query parameters.
        // We're using `urlQueryAllowed` here because that's what the `HTTPRequest` initializer does.
        let path = comps.path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        canonicalizedResource += comps.path == "" ? "/" : path

        // 3. Retrieve all query parameters on the resource URI.
        let params = (comps.queryItems ?? []).reduce(into: [String: [String]]()) { acc, item in
            // 4. Convert all parameter names to lowercase.
            let lowerName = item.name.lowercased()
            if acc[lowerName] == nil { acc[lowerName] = [] }
            acc[lowerName]!.append(item.value ?? "")
        }

        // 5. Sort the query parameters lexicographically by parameter name, in ascending order.
        let paramNames = params.keys.sorted()

        for name in paramNames {
            // 6. URL-decode each query parameter name and value.
            guard let decodedName = name.removingPercentEncoding else {
                throw AzureError.sdk("Parameter name \(name) contains an invalid percent-encoding sequence.")
            }

            let decodedValues: [String] = try params[name]!.map { value in
                guard let decoded = value.removingPercentEncoding else {
                    throw AzureError.sdk("Parameter value \(value) contains an invalid percent-encoding sequence.")
                }
                return decoded
            }

            // 7. Include a new-line character (\n) before each name-value pair.
            // 8. Append each query parameter name and value to the string, separated by a colon (:).
            // 9. If a query parameter has more than one value, sort all values lexicographically, then include them in
            //    a comma-separated list.
            canonicalizedResource += "\n" + decodedName + ":" + decodedValues.sorted().joined(separator: ",")
        }

        return canonicalizedResource
    }

    // Generate the signature for the string to sign.
    private func signature(forString signingString: String, withKey accessKey: String) throws -> String {
        guard let keyData = Data(base64Encoded: accessKey) else {
            throw AzureError.sdk("Unable to decode access key.")
        }
        let hmac = signingString.hmac(algorithm: .sha256, key: keyData)
        return hmac.base64EncodedString()
    }
}
