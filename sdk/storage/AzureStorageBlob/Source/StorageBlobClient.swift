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
        case v20190202 = "2019-02-02"

        /// The most recent API version of the Azure Storage Blob service
        public static var latest: ApiVersion {
            return .v20190202
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

    /// List storage containers in a storage account.
    /// - Parameters:
    ///   - options: A `ListContainersOptions` object to control the list operation.
    ///   - completionHandler: A completion handler that receives a `PagedCollection` of `ContainerItem` objects on
    ///     success.
    public func listContainers(
        withOptions options: ListContainersOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<PagedCollection<ContainerItem>>
    ) {
        // Construct URL
        let urlTemplate = ""
        guard let url = self.url(forTemplate: urlTemplate) else { return }

        // Construct query
        let queryParams = QueryParameters(
            ("comp", "list"),
            ("prefix", options?.prefix),
            ("include", options?.include),
            ("maxResults", options?.maxResults),
            ("timeout", options?.timeoutInSeconds)
        )

        // Construct headers
        let headers = HeaderParameters(
            (HTTPHeader.accept, "application/xml"),
            (HTTPHeader.apiVersion, self.options.apiVersion),
            (HTTPHeader.clientRequestId, options?.clientRequestId)
        )

        // Construct and send request
        let codingKeys = PagedCodingKeys(
            items: "EnumerationResults.Containers",
            continuationToken: "EnumerationResults.NextMarker",
            xmlItemName: "Container"
        )
        let xmlMap = XMLMap(withPagedCodingKeys: codingKeys, innerType: ContainerItem.self)
        let context = PipelineContext.of(keyValues: [
            ContextKey.xmlMap.rawValue: xmlMap as AnyObject
        ])
        context.add(cancellationToken: options?.cancellationToken, applying: self.options)
        context.merge(with: options?.context)
        guard let requestUrl = url.appending(queryParameters: queryParams) else { return }
        guard let request = try? HTTPRequest(method: .get, url: requestUrl, headers: headers) else { return }

        self.request(request, context: context) { result, httpResponse in
            switch result {
            case let .success(data):
                guard let data = data else {
                    let noDataError = AzureError.client("Response data expected but not found.")
                    DispatchQueue.main.async {
                        completionHandler(.failure(noDataError), httpResponse)
                    }
                    return
                }
                do {
                    let decoder = StorageJSONDecoder()
                    let paged = try PagedCollection<ContainerItem>(
                        client: self,
                        request: request,
                        context: context,
                        data: data,
                        codingKeys: codingKeys,
                        decoder: decoder
                    )
                    DispatchQueue.main.async {
                        completionHandler(.success(paged), httpResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completionHandler(.failure(AzureError.client("Decoding error.", error)), httpResponse)
                    }
                }
            case let .failure(error):
                DispatchQueue.main.async {
                    completionHandler(.failure(error), httpResponse)
                }
            }
        }
    }

    /// List blobs within a storage container.
    /// - Parameters:
    ///   - container: The container name containing the blobs to list.
    ///   - options: A `ListBlobsOptions` object to control the list operation.
    ///   - completionHandler: A completion handler that receives a `PagedCollection` of `BlobItem` objects on success.
    public func listBlobs(
        inContainer container: String,
        withOptions options: ListBlobsOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<PagedCollection<BlobItem>>
    ) {
        // Construct URL
        let urlTemplate = "{container}"
        let pathParams = [
            "container": container
        ]
        guard let url = self.url(forTemplate: urlTemplate, withKwargs: pathParams) else { return }

        // Construct query
        let queryParams = QueryParameters(
            ("comp", "list"),
            ("resType", "container"),
            ("prefix", options?.prefix),
            ("delimiter", options?.delimiter),
            ("include", options?.include),
            ("maxResults", options?.maxResults),
            ("timeout", options?.timeoutInSeconds)
        )

        // Construct headers
        var headers = HeaderParameters(
            (HTTPHeader.accept, "application/xml"),
            (HTTPHeader.transferEncoding, "chunked"),
            (HTTPHeader.apiVersion, self.options.apiVersion)
        )

        // Header options
        if let clientRequestId = options?.clientRequestId {
            headers[.clientRequestId] = clientRequestId
        }

        // Construct and send request
        guard let requestUrl = url.appending(queryParameters: queryParams) else { return }
        guard let request = try? HTTPRequest(method: .get, url: requestUrl, headers: headers) else { return }
        let codingKeys = PagedCodingKeys(
            items: "EnumerationResults.Blobs",
            continuationToken: "EnumerationResults.NextMarker",
            xmlItemName: "Blob"
        )
        let xmlMap = XMLMap(withPagedCodingKeys: codingKeys, innerType: BlobItem.self)
        let context = PipelineContext.of(keyValues: [
            ContextKey.xmlMap.rawValue: xmlMap as AnyObject
        ])
        context.add(cancellationToken: options?.cancellationToken, applying: self.options)
        context.merge(with: options?.context)
        self.request(request, context: context) { result, httpResponse in
            switch result {
            case let .success(data):
                guard let data = data else {
                    let noDataError = AzureError.client("Response data expected but not found.")

                    DispatchQueue.main.async {
                        completionHandler(.failure(noDataError), httpResponse)
                    }
                    return
                }
                do {
                    let decoder = StorageJSONDecoder()
                    let paged = try PagedCollection<BlobItem>(
                        client: self,
                        request: request,
                        context: context,
                        data: data,
                        codingKeys: codingKeys,
                        decoder: decoder
                    )
                    DispatchQueue.main.async {
                        completionHandler(.success(paged), httpResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completionHandler(.failure(AzureError.client("Decoding error.", error)), httpResponse)
                    }
                }
            case let .failure(error):
                DispatchQueue.main.async {
                    completionHandler(.failure(error), httpResponse)
                }
            }
        }
    }

    /// Delete a blob within a storage container.
    /// - Parameters:
    ///   - blob: The blob name to delete.
    ///   - container: The container name containing the blob to delete.
    ///   - options: A `DeleteBlobOptions` object to control the delete operation.
    ///   - completionHandler: A completion handler to notify about success or failure.
    public func delete(
        blob: String,
        inContainer container: String,
        withOptions options: DeleteBlobOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<Void>
    ) {
        // Construct URL
        let urlTemplate = "{container}/{blob}"
        let pathParams = RequestParameters(
            ("container", container),
            ("blob", blob)
        )
        guard let url = self.url(forTemplate: urlTemplate, withKwargs: pathParams.toDict()) else { return }

        // Construct query
        let queryParams = QueryParameters(
            ("snapshot", options?.snapshot),
            ("timeout", options?.timeoutInSeconds)
        )

        // Construct headers
        let headers = HeaderParameters(
            (HTTPHeader.apiVersion, self.options.apiVersion),
            (StorageHTTPHeader.deleteSnapshots, options?.deleteSnapshots),
            (HTTPHeader.clientRequestId, options?.clientRequestId)
        )

        // Construct and send request
        let context = PipelineContext.of(keyValues: [
            ContextKey.allowedStatusCodes.rawValue: [202] as AnyObject
        ])
        context.add(cancellationToken: options?.cancellationToken, applying: self.options)
        context.merge(with: options?.context)
        guard let requestUrl = url.appending(queryParameters: queryParams) else { return }
        guard let request = try? HTTPRequest(method: .delete, url: requestUrl, headers: headers) else { return }
        self.request(request, context: context) { result, httpResponse in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    completionHandler(.success(()), httpResponse)
                }
            case let .failure(error):
                DispatchQueue.main.async {
                    completionHandler(.failure(error), httpResponse)
                }
            }
        }
    }

    /// Download a blob from a storage container.
    ///
    /// This method will execute a raw HTTP GET in order to download a single blob to the destination. It is
    /// **STRONGLY** recommended that you use the `download()` method instead - that method will manage the transfer in
    /// the face of changing network conditions, and is able to transfer multiple blocks in parallel.
    /// - Parameters:
    ///   - blob: The name of the blob.
    ///   - container: The name of the container.
    ///   - destinationUrl: The URL to a file path on this device.
    ///   - options: A `DownloadBlobOptions` object to control the download operation.
    ///   - completionHandler: A completion handler that receives a `BlobDownloader` object on success.
    public func rawDownload(
        blob: String,
        fromContainer container: String,
        toFile destinationUrl: LocalURL,
        withOptions options: DownloadBlobOptions = DownloadBlobOptions(),
        completionHandler: @escaping HTTPResultHandler<BlobDownloader>
    ) throws {
        // Construct URL
        let urlTemplate = "/{container}/{blob}"
        let pathParams = [
            "container": container,
            "blob": blob
        ]
        // Construct and send request
        guard let url = self.url(forTemplate: urlTemplate, withKwargs: pathParams) else { return }

        let context = PipelineContext()
        context.add(cancellationToken: options.cancellationToken, applying: self.options)

        let downloader = try BlobStreamDownloader(
            client: self,
            source: url,
            destination: destinationUrl,
            options: options
        )
        downloader.initialRequest { result, httpResponse in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    completionHandler(.success(downloader), httpResponse)
                }
            case let .failure(error):
                DispatchQueue.main.async {
                    completionHandler(.failure(error), httpResponse)
                }
            }
        }
    }

    /// Upload a blob to a storage container.
    ///
    /// This method will execute a raw HTTP PUT in order to upload a single file to the destination. It is **STRONGLY**
    /// recommended that you use the `upload()` method instead - that method will manage the transfer in the face of
    /// changing network conditions, and is able to transfer multiple blocks in parallel.
    /// - Parameters:
    ///   - sourceUrl: The URL to a file on this device
    ///   - container: The name of the container.
    ///   - blob: The name of the blob.
    ///   - properties: Properties to set on the resulting blob.
    ///   - options: An `UploadBlobOptions` object to control the upload operation.
    ///   - completionHandler: A completion handler that receives a `BlobUploader` object on success.
    public func rawUpload(
        file sourceUrl: LocalURL,
        toContainer container: String,
        asBlob blob: String,
        properties: BlobProperties? = nil,
        withOptions options: UploadBlobOptions = UploadBlobOptions(),
        completionHandler: @escaping HTTPResultHandler<BlobUploader>
    ) throws {
        // Construct URL
        let urlTemplate = "/{container}/{blob}"
        let pathParams = [
            "container": container,
            "blob": blob
        ]
        guard let url = self.url(forTemplate: urlTemplate, withKwargs: pathParams) else { return }

        let context = PipelineContext()
        context.add(cancellationToken: options.cancellationToken, applying: self.options)

        let uploader = try BlobStreamUploader(
            client: self,
            source: sourceUrl,
            destination: url,
            properties: properties,
            options: options
        )
        uploader.next { result, httpResponse in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    completionHandler(.success(uploader), httpResponse)
                }
            case let .failure(error):
                DispatchQueue.main.async {
                    completionHandler(.failure(error), httpResponse)
                }
            }
        }
    }

    /// Create a managed download to reliably download a blob from a storage container.
    ///
    /// This method performs a managed download, during which the client will reliably manage the transfer of the blob
    /// from the cloud service to this device. When called, the download will be queued and a `BlobTransfer` object will
    /// be returned that allows you to control the download. This client's `transferDelegate` will be notified about
    /// state changes for all managed uploads and downloads the client creates.
    /// - Parameters:
    ///   - blob: The name of the blob.
    ///   - container: The name of the container.
    ///   - destinationUrl: The URL to a file path on this device.
    ///   - options: A `DownloadBlobOptions` object to control the download operation.
    @discardableResult public func download(
        blob: String,
        fromContainer container: String,
        toFile destinationUrl: LocalURL,
        withOptions options: DownloadBlobOptions = DownloadBlobOptions(),
        progressHandler: ((BlobTransfer) -> Void)? = nil
    ) throws -> BlobTransfer? {
        // Construct URL
        let urlTemplate = "/{container}/{blob}"
        let pathParams = [
            "container": container,
            "blob": blob
        ]
        guard let url = self.url(forTemplate: urlTemplate, withKwargs: pathParams) else { return nil }

        let context = PipelineContext()
        context.add(cancellationToken: options.cancellationToken, applying: self.options)

        let start = Int64(options.range?.offsetBytes ?? 0)
        let end = Int64(options.range?.lengthInBytes ?? 0)
        let downloader = try BlobStreamDownloader(
            client: self,
            source: url,
            destination: destinationUrl,
            options: options
        )
        let blobTransfer = BlobTransfer.with(
            viewContext: StorageBlobClient.viewContext,
            clientRestorationId: self.options.restorationId,
            localUrl: destinationUrl,
            remoteUrl: url,
            type: .download,
            startRange: start,
            endRange: end,
            parent: nil,
            progressHandler: progressHandler
        )
        blobTransfer.downloader = downloader
        blobTransfer.downloadOptions = options
        StorageBlobClient.manager.add(transfer: blobTransfer)
        return blobTransfer
    }

    /// Create a managed upload to reliably upload a file to a storage container.
    ///
    /// This method performs a managed upload, during which the client will reliably manage the transfer of the blob
    /// from this device to the cloud service. When called, the upload will be queued and a `BlobTransfer` object will
    /// be returned that allows you to control the upload. This client's `transferDelegate` will be notified about state
    /// changes for all managed uploads and downloads the client creates.
    /// - Parameters:
    ///   - sourceUrl: The URL to a file on this device.
    ///   - container: The name of the container.
    ///   - blob: The name of the blob.
    ///   - properties: Properties to set on the resulting blob.
    ///   - options: An `UploadBlobOptions` object to control the upload operation.
    @discardableResult public func upload(
        file sourceUrl: LocalURL,
        toContainer container: String,
        asBlob blob: String,
        properties: BlobProperties,
        withOptions options: UploadBlobOptions = UploadBlobOptions(),
        progressHandler: ((BlobTransfer) -> Void)? = nil
    ) throws -> BlobTransfer? {
        // Construct URL
        let urlTemplate = "/{container}/{blob}"
        let pathParams = [
            "container": container,
            "blob": blob
        ]
        guard let url = self.url(forTemplate: urlTemplate, withKwargs: pathParams) else { return nil }

        let context = PipelineContext()
        context.add(cancellationToken: options.cancellationToken, applying: self.options)

        let uploader = try BlobStreamUploader(
            client: self,
            source: sourceUrl,
            destination: url,
            properties: properties,
            options: options
        )
        let blobTransfer = BlobTransfer.with(
            viewContext: StorageBlobClient.viewContext,
            clientRestorationId: self.options.restorationId,
            localUrl: sourceUrl,
            remoteUrl: url,
            type: .upload,
            startRange: 0,
            endRange: Int64(uploader.fileSize),
            parent: nil,
            progressHandler: progressHandler
        )
        blobTransfer.uploader = uploader
        blobTransfer.uploadOptions = options
        blobTransfer.properties = properties
        StorageBlobClient.manager.add(transfer: blobTransfer)
        return blobTransfer
    }
}
