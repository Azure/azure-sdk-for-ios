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

/// A Storage shared access signature credential object.
public struct StorageSASCredential: AzureCredential {
    internal let blobSasUriProvider: (() -> String)?
    internal let connectionStringProvider: (() -> String)?
    internal var blobEndpoint: String?
    internal var queueEndpoint: String?
    internal var fileEndpoint: String?
    internal var tableEndpoint: String?
    internal var error: Error?
    internal var sasToken: String? {
        didSet { expirationDate = StorageSASCredential.expiration(forToken: sasToken) }
    }


    // Treat tokens that expire in <= 2 minutes as expired
    private static let expirationOffset: TimeInterval = 2 * 60

    public var expirationDate: Date?
    public var expired: Bool {
        guard let expirationDate = expirationDate else { return true }
        return (expirationDate - StorageSASCredential.expirationOffset) >= Date()
    }

    // MARK: Static methods

    private static func expiration(forToken sasToken: String?) -> Date? {
        guard let token = sasToken else { return nil }
        guard let comps = URLComponents(string: "?\(token)") else { return nil }
        guard let expiration = comps.queryItems?.filter({ $0.name == "se" }).first?.value else { return nil }
        return Date(expiration, format: .iso8601)
    }

    // MARK: Initializers

    /// Create a shared access signature credential from an account-level shared access signature.
    /// - Parameters:
    ///   - connectionStringProvider: A closure that returns an account-level shared access signature connection string.
    public init(connectionStringProvider: @escaping () -> String) {
        self.blobSasUriProvider = nil
        self.connectionStringProvider = connectionStringProvider
        clear()
    }

    /// Create a shared access signature credential from a container- or blob-level shared access signature.
    /// - Parameters:
    ///   - blobSasUriProvider: A closure that returns a container- or blob-level shared access signature URI.
    public init(blobSasUriProvider: @escaping () -> String) {
        self.blobSasUriProvider = blobSasUriProvider
        self.connectionStringProvider = nil
        clear()
    }

    /// Create a shared access signature credential from an account-level shared access signature.
    /// - Parameters:
    ///   - connectionString: The initial account-level shared access signature connection string.
    ///   - connectionStringProvider: A closure that returns an account-level shared access signature connection string.
    public init(connectionString: String, connectionStringProvider: (() -> String)? = nil) {
        self.blobSasUriProvider = nil
        self.connectionStringProvider = connectionStringProvider
        self.error = configureFrom(connectionString: connectionString)
    }

    /// Create a shared access signature credential from a container- or blob-level shared access signature.
    /// - Parameters:
    ///   - blobSasUri: The initial container- or blob-level shared access signature URI.
    ///   - blobSasUriProvider: A closure that returns a container- or blob-level shared access signature URI.
    public init(blobSasUri: String, blobSasUriProvider: (() -> String)? = nil) {
        self.blobSasUriProvider = blobSasUriProvider
        self.connectionStringProvider = nil
        self.error = configureFrom(blobSasUri: blobSasUri)
    }

    // MARK: Public Methods

    public func validate() throws {
        if let error = error {
            throw error
        }
    }

    internal mutating func refresh() throws {
        clear()
        if let provider = connectionStringProvider {
            error = configureFrom(connectionString: provider())
        } else if let provider = blobSasUriProvider {
            error = configureFrom(blobSasUri: provider())
        }
        try validate()
    }

    // MARK: Private methods

    private mutating func configureFrom(connectionString: String) -> Error? {
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
                return HTTPResponseError.clientAuthentication(message)
            default:
                continue
            }
        }

        if sas == nil {
            return HTTPResponseError.clientAuthentication("The connection string \(connectionString) is invalid.")
        }

        sasToken = sas
        blobEndpoint = blob
        queueEndpoint = queue
        fileEndpoint = file
        tableEndpoint = table
        return nil
    }

    private mutating func configureFrom(blobSasUri: String) -> Error? {
        var blob: String?
        var sas: String?

        if let sasUri = URL(string: blobSasUri), let sasToken = sasUri.query, let scheme = sasUri.scheme,
            let host = sasUri.host {
            sas = sasToken
            blob = "\(scheme)://\(host)/"
        } else {
            return HTTPResponseError.clientAuthentication("The URI \(blobSasUri) is invalid.")
        }

        sasToken = sas
        blobEndpoint = blob
        queueEndpoint = nil
        fileEndpoint = nil
        tableEndpoint = nil
        return nil
    }

    private mutating func clear() {
        sasToken = nil
        expirationDate = nil
        blobEndpoint = nil
        queueEndpoint = nil
        fileEndpoint = nil
        tableEndpoint = nil
        error = nil
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
                error = HTTPResponseError.clientAuthentication(message)
            default:
                continue
            }
        }

        var blob: String?
        var queue: String?
        var file: String?
        var table: String?

        if accountKey == nil, error == nil {
            error = HTTPResponseError.clientAuthentication("The connection string \(connectionString) is invalid.")
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
            error = HTTPResponseError.clientAuthentication("The connection string \(connectionString) is invalid.")
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
            error = HTTPResponseError.clientAuthentication("The provided parameters are invalid.")
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
        if credential.expired {
            do {
                try credential.refresh()
            } catch {
                completionHandler(request, error)
                return
            }
        }

        let queryParams = parse(sasToken: credential.sasToken ?? "")
        if let requestUrl = request.httpRequest.url.appendingQueryParameters(queryParams) {
            request.httpRequest.url = requestUrl
        }
        request.httpRequest.headers[.xmsDate] = String(describing: Date(), format: .rfc1123)
        completionHandler(request, nil)
    }

    // MARK: Private Methods

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
            let accountName = comps.host?.split(separator: ".", maxSplits: 1).first else {
            throw AzureError.general("Resource URL could not be parsed.")
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
                throw AzureError.general("Parameter name \(name) contains an invalid percent-encoding sequence.")
            }

            let decodedValues: [String] = try params[name]!.map { value in
                guard let decoded = value.removingPercentEncoding else {
                    throw AzureError.general("Parameter value \(value) contains an invalid percent-encoding sequence.")
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
            throw AzureError.general("Unable to decode access key.")
        }
        let hmac = signingString.hmac(algorithm: .sha256, key: keyData)
        return hmac.base64EncodedString()
    }
}
