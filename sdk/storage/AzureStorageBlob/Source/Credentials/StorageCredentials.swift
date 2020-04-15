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
public struct StorageSASCredential {
    internal let blobEndpoint: String?
    internal let queueEndpoint: String?
    internal let fileEndpoint: String?
    internal let tableEndpoint: String?
    internal let sasToken: String

    /// Create a shared access signature credential from an account-level shared access signature.
    /// - Parameters:
    ///   - connectionString: An account-level shared access signature connection string.
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
                    Form of connection string with 'SharedAccessSignature' is expected - 'AccountKey' is not allowed.
                    You must provide a Shared Access Signature connection string.
                """
                throw HTTPResponseError.clientAuthentication(message)
            default:
                continue
            }
        }
        guard let sasToken = sas else {
            throw HTTPResponseError.clientAuthentication("The connection string \(connectionString) is invalid.")
        }
        self.sasToken = sasToken
        self.blobEndpoint = blob
        self.queueEndpoint = queue
        self.fileEndpoint = file
        self.tableEndpoint = table
    }

    /// Create a shared access signature credential from a container- or blob-level shared access signature.
    /// - Parameters:
    ///   - blobSasUri: A container- or blob-level shared access signature URI.
    public init(blobSasUri: String) throws {
        let invalidUri = HTTPResponseError.clientAuthentication("The URI \(blobSasUri) is invalid.")
        guard let sasUri = URL(string: blobSasUri) else { throw invalidUri }
        guard let sasToken = sasUri.query else { throw invalidUri }
        guard let scheme = sasUri.scheme else { throw invalidUri }
        guard let host = sasUri.host else { throw invalidUri }

        self.sasToken = sasToken
        self.blobEndpoint = "\(scheme)://\(host)/"
        self.queueEndpoint = nil
        self.fileEndpoint = nil
        self.tableEndpoint = nil
    }
}

/// A Storage account shared key credential object.
///
/// **WARNING**: Shared keys are inherently insecure in end-user facing applications such as mobile and desktop apps.
/// Shared keys provide full access to an entire storage account and should not be shared with end users. Since mobile
/// and desktop apps are inherently end-user facing, it's highly recommended that storage account shared key credentials
/// not be used in production for such applications.
public struct StorageSharedKeyCredential {
    internal let accessKey: String?
    internal let accountName: String?
    internal let blobEndpoint: String?
    internal let queueEndpoint: String?
    internal let fileEndpoint: String?
    internal let tableEndpoint: String?

    /// Create a shared key credential from a storage account connection string.
    ///
    /// **WARNING**: Shared keys are inherently insecure in end-user facing applications such as mobile and desktop
    /// apps. Shared keys provide full access to an entire storage account and should not be shared with end users.
    /// Since mobile and desktop apps are inherently end-user facing, it's highly recommended that storage account
    /// shared key credentials not be used in production for such applications.
    /// - Parameters:
    ///   - connectionString: The storage account connection string.
    public init(connectionString: String) throws {
        // temp variables
        var accountKey: String?
        var accountName: String?
        var suffix = "core.windows.net"
        var scheme = "https"

        for component in connectionString.components(separatedBy: ";") {
            let compSplits = component.split(separator: "=", maxSplits: 1)
            let key = String(compSplits[0]).lowercased()
            let value = String(compSplits[1])

            switch key {
            case "defaultendpointsprotocol":
                scheme = value
            case "accountname":
                accountName = value
            case "accountkey":
                accountKey = value
            case "endpointsuffix":
                suffix = value
            case "sharedaccesssignature":
                let message = """
                    Form of connection string with 'AccountKey' is expected - 'SharedAccessSignature' is not allowed.
                    You must provide a storage account connection string with a shared key.
                """
                throw HTTPResponseError.clientAuthentication(message)
            default:
                continue
            }
        }
        guard let key = accountKey, let name = accountName else {
            throw HTTPResponseError.clientAuthentication("The connection string \(connectionString) is invalid.")
        }
        try self.init(accountName: name, accessKey: key, endpointProtocol: scheme, endpointSuffix: suffix)
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
    ) throws {
        guard accessKey != "", accountName != "", endpointProtocol != "", endpointSuffix != "" else {
            throw HTTPResponseError.clientAuthentication("The provided parameters are invalid.")
        }
        let blob = StorageBlobClient.endpoint(
            forAccount: accountName,
            withProtocol: endpointProtocol,
            withSuffix: endpointSuffix
        )
        self.accessKey = accessKey
        self.accountName = accountName
        self.blobEndpoint = blob
        self.queueEndpoint = blob.replacingOccurrences(of: "blob.\(endpointSuffix)", with: "queue.\(endpointSuffix)")
        self.fileEndpoint = blob.replacingOccurrences(of: "blob.\(endpointSuffix)", with: "file.\(endpointSuffix)")
        self.tableEndpoint = blob.replacingOccurrences(of: "blob.\(endpointSuffix)", with: "table.\(endpointSuffix)")
    }
}

/// A Storage authentication policy that relies on a shared access signature.
internal class StorageSASAuthenticationPolicy: Authenticating {
    /// The next stage in the HTTP pipeline.
    public var next: PipelineStage?

    /// A shared access signature credential.
    public let credential: StorageSASCredential

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
    ///   - completion: A completion handler that forwards the modified pipeline request.
    public func authenticate(request: PipelineRequest, then completion: @escaping OnRequestCompletionHandler) {
        let queryParams = parse(sasToken: credential.sasToken)
        request.httpRequest.add(queryParams: queryParams)
        request.httpRequest.headers[.xmsDate] = String(describing: Date(), format: .rfc1123)
        completion(request, nil)
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
    ///   - completion: A completion handler that forwards the modified pipeline request.
    public func authenticate(request: PipelineRequest, then completion: @escaping OnRequestCompletionHandler) {
        // TODO: Implement SharedKey authentication.
        completion(request, nil)
    }
}
