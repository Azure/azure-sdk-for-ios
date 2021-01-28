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
#if canImport(AzureIdentity)
    import AzureIdentity
#endif
import CoreData
import Foundation

// swiftlint:disable type_body_length

/// A StorageBlobClient represents a Client to the Azure Storage Blob service allowing you to manipulate blobs within
/// storage containers.
public final class StorageBlobClient: PipelineClient {
    /// API version of the Azure Storage Blob service to invoke. Defaults to the latest.
    public enum ApiVersion: String {
        /// API version "2019-02-02"
        case v20200210 = "2020-02-10"

        /// The most recent API version of the Azure Storage Blob service
        public static var latest: ApiVersion {
            return .v20200210
        }
    }

    /// The global maximum number of managed transfers that will be executed concurrently by all `StorageBlobClient`
    /// instances. The default value is `maxConcurrentTransfersDefaultValue`. To allow this value to be determined
    /// dynamically based on current system conditions, set it to `maxConcurrentTransfersDynamicValue`.
    public static var maxConcurrentTransfers: Int {
        get { return manager.operationQueue.maxConcurrentOperationCount }
        set { manager.operationQueue.maxConcurrentOperationCount = newValue }
    }

    /// The default value of `maxConcurrentTransfers`.
    public static let maxConcurrentTransfersDefaultValue = 4

    /// Set `maxConcurrentTransfers` equal to this value to allow the maximum number of managed transfers to be
    /// determined dynamically based on current system conditions.
    public static let maxConcurrentTransfersDynamicValue = OperationQueue.defaultMaxConcurrentOperationCount

    /// Options provided to configure this `StorageBlobClient`.
    public let options: StorageBlobClientOptions

    /// The `StorageBlobClientDelegate` to inform about events from transfers created by this `StorageBlobClient`.
    public weak var delegate: StorageBlobClientDelegate?

    private static let defaultScopes = [
        "https://storage.azure.com/.default"
    ]

    internal static let manager = URLSessionTransferManager.shared

    internal static let viewContext: NSManagedObjectContext = manager.persistentContainer.viewContext

    // MARK: Operations

    public lazy var blobs = BlobsOperations(self)

    public lazy var containers = ContainersOperations(self)

    // MARK: Initializers

    /// Create a Storage blob data client.
    /// - Parameters:
    ///   - baseUrl: Base URL for the storage account's blob service.
    ///   - authPolicy: An `Authenticating` policy to use for authenticating client requests.
    ///   - options: Options used to configure the client.
    private init(
        endpoint: URL,
        authPolicy: Authenticating,
        withOptions options: StorageBlobClientOptions
    ) throws {
        self.options = options
        super.init(
            endpoint: endpoint,
            transport: options.transportOptions.transport ?? URLSessionTransport(),
            policies: [
                UserAgentPolicy(for: StorageBlobClient.self, telemetryOptions: options.telemetryOptions),
                RequestIdPolicy(),
                AddDatePolicy(),
                authPolicy,
                ContentDecodePolicy(),
                HeadersValidationPolicy(validatingHeaders: [
                    HTTPHeader.clientRequestId.requestString,
                    StorageHTTPHeader.encryptionKeySHA256.requestString
                ]),
                LoggingPolicy(
                    allowHeaders: StorageBlobClient.allowHeaders,
                    allowQueryParams: StorageBlobClient.allowQueryParams
                ),
                NormalizeETagPolicy()
            ],
            logger: self.options.logger,
            options: options
        )
        try StorageBlobClient.manager.register(client: self)
    }

    #if canImport(AzureIdentity)
        /// Create a Storage blob data client.
        /// - Parameters:
        ///   - credential: A `MSALCredential` object used to retrieve authentication tokens.
        ///   - endpoint: The URL for the storage account's blob storage endpoint.
        ///   - options: Options used to configure the client.
        public convenience init(
            endpoint: URL,
            credential: MSALCredential,
            withOptions options: StorageBlobClientOptions = StorageBlobClientOptions()
        ) throws {
            try credential.validate()
            let authPolicy = BearerTokenCredentialPolicy(
                credential: credential,
                scopes: StorageBlobClient.defaultScopes
            )
            try self.init(endpoint: endpoint, authPolicy: authPolicy, withOptions: options)
        }
    #endif

    /// Create a Storage blob data client.
    /// - Parameters:
    ///   - credential: A `StorageSASCredential` object used to retrieve authentication tokens.
    ///   - endpoint: The URL for the storage account's blob storage endpoint.
    ///   - options: Options used to configure the client.
    public convenience init(
        endpoint: URL,
        credential: StorageSASCredential,
        withOptions options: StorageBlobClientOptions = StorageBlobClientOptions()
    ) throws {
        try credential.validate()
        let authPolicy = StorageSASAuthenticationPolicy(credential: credential)
        try self.init(endpoint: endpoint, authPolicy: authPolicy, withOptions: options)
    }

    /// Create a Storage blob data client.
    /// - Parameters:
    ///   - credential: A `StorageSharedKeyCredential` object used to retrieve the account's blob storage endpoint and
    ///     access key. **WARNING**: Shared keys are inherently insecure in end-user facing applications such as mobile
    ///     and desktop apps. Shared keys provide full access to an entire storage account and should not be shared with
    ///     end users. Since mobile and desktop apps are inherently end-user facing, it's highly recommended that
    ///     storage account shared key credentials not be used in production for such applications.
    ///   - options: Options used to configure the client.
    public convenience init(
        credential: StorageSharedKeyCredential,
        withOptions options: StorageBlobClientOptions = StorageBlobClientOptions()
    ) throws {
        try credential.validate()
        guard let baseUrl = URL(string: credential.blobEndpoint) else {
            throw AzureError.client("Unable to resolve account URL from credential.")
        }
        let authPolicy = StorageSharedKeyAuthenticationPolicy(credential: credential)
        try self.init(endpoint: baseUrl, authPolicy: authPolicy, withOptions: options)
    }

    /// Create an anonymous Storage blob data client.
    /// - Parameters:
    ///   - connectionString: A Storage SAS or Shared Key connection string used to retrieve the account's blob storage
    ///     endpoint and authentication tokens. **WARNING**: Connection strings are inherently insecure in end-user
    ///     facing applications such as mobile and desktop apps. Connection strings should be treated as secrets and
    ///     should not be shared with end users, and cannot be rotated once compiled into an application. Since mobile
    ///     and desktop apps are inherently end-user facing, it's highly recommended that connection strings not be used
    ///     in production for such applications.
    ///   - options: Options used to configure the client.
    public convenience init(
        connectionString: String,
        withOptions options: StorageBlobClientOptions = StorageBlobClientOptions()
    ) throws {
        if let sasToken = try? StorageSASCredential.token(fromConnectionString: connectionString),
            let endpoint = URL(string: sasToken.blobEndpoint) {
            let sasCredential = StorageSASCredential(staticCredential: connectionString)
            try self.init(endpoint: endpoint, credential: sasCredential, withOptions: options)
            return
        }

        let sharedKeyCredential = StorageSharedKeyCredential(connectionString: connectionString)
        if sharedKeyCredential.error == nil {
            try self.init(credential: sharedKeyCredential, withOptions: options)
            return
        }

        throw AzureError.client("The connection string \(connectionString) is invalid.")
    }

    /// Create a Storage blob data client.
    /// - Parameters:
    ///   - endpoint: The URL for the storage account's blob storage endpoint.
    ///   - options: Options used to configure the client.
    public convenience init(
        endpoint: URL,
        withOptions options: StorageBlobClientOptions = StorageBlobClientOptions()
    ) throws {
        try self.init(endpoint: endpoint, authPolicy: AnonymousAccessPolicy(), withOptions: options)
    }

    // MARK: Public Client Methods

    /// Construct a URL for a storage account's blob storage endpoint from its account name.
    /// - Parameters:
    ///   - accountName: The storage account name.
    ///   - endpointProtocol: The storage account endpoint protocol.
    ///   - endpointSuffix: The storage account endpoint suffix.
    public static func endpoint(
        forAccount accountName: String,
        withProtocol endpointProtocol: String = "https",
        withSuffix endpointSuffix: String = "core.windows.net"
    ) -> String {
        return "\(endpointProtocol)://\(accountName).blob.\(endpointSuffix)/"
    }

    // FIXME: Once decision has been made on hierarchical/flat structure, uncomment or remove these.
    // See: https://github.com/Azure/azure-sdk-for-ios/issues/659
//    /// List storage containers in a storage account.
//    /// - Parameters:
//    ///   - options: A `ListContainersOptions` object to control the list operation.
//    ///   - completionHandler: A completion handler that receives a `PagedCollection` of `ContainerItem` objects on
//    ///     success.
//    public func listContainers(
//        withOptions options: ListContainersOptions? = nil,
//        completionHandler: @escaping HTTPResultHandler<PagedCollection<ContainerItem>>
//    ) {
//        return containers.list(withOptions: options, completionHandler: completionHandler)
//    }
//
//    /// List blobs within a storage container.
//    /// - Parameters:
//    ///   - container: The container name containing the blobs to list.
//    ///   - options: A `ListBlobsOptions` object to control the list operation.
//    ///   - completionHandler: A completion handler that receives a `PagedCollection` of `BlobItem` objects on success.
//    public func listBlobs(
//        inContainer container: String,
//        withOptions options: ListBlobsOptions? = nil,
//        completionHandler: @escaping HTTPResultHandler<PagedCollection<BlobItem>>
//    ) {
//        return blobs.list(inContainer: container, withOptions: options, completionHandler: completionHandler)
//    }
//
//    /// Delete a blob within a storage container.
//    /// - Parameters:
//    ///   - blob: The blob name to delete.
//    ///   - container: The container name containing the blob to delete.
//    ///   - options: A `DeleteBlobOptions` object to control the delete operation.
//    ///   - completionHandler: A completion handler to notify about success or failure.
//    public func delete(
//        blob: String,
//        inContainer container: String,
//        withOptions options: DeleteBlobOptions? = nil,
//        completionHandler: @escaping HTTPResultHandler<Void>
//    ) {
//        return blobs.delete(
//            blob: blob,
//            inContainer: container,
//            withOptions: options,
//            completionHandler: completionHandler
//        )
//    }
//
//    /// Create a managed download to reliably download a blob from a storage container.
//    ///
//    /// This method performs a managed download, during which the client will reliably manage the transfer of the blob
//    /// from the cloud service to this device. When called, the download will be queued and a `BlobTransfer` object will
//    /// be returned that allows you to control the download. This client's `transferDelegate` will be notified about
//    /// state changes for all managed uploads and downloads the client creates.
//    /// - Parameters:
//    ///   - blob: The name of the blob.
//    ///   - container: The name of the container.
//    ///   - destinationUrl: The URL to a file path on this device.
//    ///   - options: A `DownloadBlobOptions` object to control the download operation.
//    @discardableResult public func download(
//        blob: String,
//        fromContainer container: String,
//        toFile destinationUrl: LocalURL,
//        withOptions options: DownloadBlobOptions = DownloadBlobOptions(),
//        progressHandler: ((BlobTransfer) -> Void)? = nil
//    ) throws -> BlobTransfer? {
//        return try blobs.download(
//            blob: blob,
//            fromContainer: container,
//            toFile: destinationUrl,
//            withOptions: options,
//            progressHandler: progressHandler
//        )
//    }
//
//    /// Create a managed upload to reliably upload a file to a storage container.
//    ///
//    /// This method performs a managed upload, during which the client will reliably manage the transfer of the blob
//    /// from this device to the cloud service. When called, the upload will be queued and a `BlobTransfer` object will
//    /// be returned that allows you to control the upload. This client's `transferDelegate` will be notified about state
//    /// changes for all managed uploads and downloads the client creates.
//    /// - Parameters:
//    ///   - sourceUrl: The URL to a file on this device.
//    ///   - container: The name of the container.
//    ///   - blob: The name of the blob.
//    ///   - properties: Properties to set on the resulting blob.
//    ///   - options: An `UploadBlobOptions` object to control the upload operation.
//    @discardableResult public func upload(
//        file sourceUrl: LocalURL,
//        toContainer container: String,
//        asBlob blob: String,
//        properties: BlobProperties,
//        withOptions options: UploadBlobOptions = UploadBlobOptions(),
//        progressHandler: ((BlobTransfer) -> Void)? = nil
//    ) throws -> BlobTransfer? {
//        return try blobs.upload(
//            file: sourceUrl,
//            toContainer: container,
//            asBlob: blob,
//            properties: properties,
//            withOptions: options,
//            progressHandler: progressHandler
//        )
//    }
}
