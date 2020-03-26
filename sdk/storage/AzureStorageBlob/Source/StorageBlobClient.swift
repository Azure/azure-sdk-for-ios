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

// swiftlint:disable function_body_length type_body_length file_length cyclomatic_complexity identifier_name

/**
 Client object for the Storage blob service.
 */
public final class StorageBlobClient: PipelineClient {
    /// API version of the service to invoke. Defaults to the latest.
    public enum ApiVersion: String {
        case latest = "2019-02-02"
    }

    internal class StorageJSONDecoder: JSONDecoder {
        override init() {
            super.init()
            dateDecodingStrategy = .formatted(Date.Format.rfc1123.formatter)
        }
    }

    internal class StorageJSONEncoder: JSONEncoder {
        override init() {
            super.init()
            dateEncodingStrategy = .formatted(Date.Format.rfc1123.formatter)
        }
    }

    /// The options provided to initialize this StorageBlobClient
    public let options: StorageBlobClientOptions

    /// The TransferDelegate to inform about transfer events
    public weak var transferDelegate: TransferDelegate?

    private static let defaultScopes = [
        "https://storage.azure.com/.default"
    ]

    fileprivate var managing = false
    fileprivate lazy var manager: TransferManager = {
        let instance = URLSessionTransferManager(delegate: self, logger: self.logger)
        instance.loadContext()
        return instance
    }()

    // MARK: Initializers

    /// Create a Storage blob data client.
    /// - Parameters:
    ///   - baseUrl: Base URL for the storage account.
    ///   - authPolicy: An authentication policy to use for authenticating client requests.
    ///   - options: Options used to configure the client.
    private init(baseUrl: String, authPolicy: Authenticating, withOptions options: StorageBlobClientOptions? = nil) {
        self.options = options ?? StorageBlobClientOptions(apiVersion: ApiVersion.latest.rawValue)
        super.init(
            baseUrl: baseUrl,
            transport: URLSessionTransport(),
            policies: [
                UserAgentPolicy(for: StorageBlobClient.self),
                RequestIdPolicy(),
                AddDatePolicy(),
                authPolicy,
                ContentDecodePolicy(),
                LoggingPolicy(
                    allowHeaders: BlobHeadersAndQueryParameters.headers,
                    allowQueryParams: BlobHeadersAndQueryParameters.queryParameters
                )
            ],
            logger: self.options.logger
        )
    }

    /// Create a Storage blob data client.
    /// - Parameters:
    ///   - accountUrl: Base URL for the storage account.
    ///   - credential: A MSAL credential object used to retrieve authentication tokens.
    ///   - options: Options used to configure the client.
    public convenience init(
        accountUrl: String,
        credential: MSALCredential,
        withOptions options: StorageBlobClientOptions? = nil
    ) {
        let authPolicy = BearerTokenCredentialPolicy(credential: credential, scopes: StorageBlobClient.defaultScopes)
        self.init(baseUrl: accountUrl, authPolicy: authPolicy, withOptions: options)
    }

    /// Create a Storage blob data client.
    /// - Parameters:
    ///   - credential: A SAS credential object used to retrieve the base URL and authentication tokens.
    ///   - options: Options used to configure the client.
    public convenience init(
        credential: StorageSASCredential,
        withOptions options: StorageBlobClientOptions? = nil
    ) throws {
        guard let blobEndpoint = credential.blobEndpoint else {
            let message = "Invalid connection string. No blob endpoint specified."
            throw AzureError.serviceRequest(message)
        }
        let authPolicy = StorageSASAuthenticationPolicy(credential: credential)
        self.init(baseUrl: blobEndpoint, authPolicy: authPolicy, withOptions: options)
    }

    /// Create a Storage blob data client.
    /// - Parameters:
    ///   - connectionString: Storage account connection string. **WARNING**: Connection strings are inherently insecure
    ///     in a mobile app. Any connection strings used should be read-only and not have write permissions.
    ///   - options: Options used to configure the client.
    public convenience init(connectionString: String, withOptions options: StorageBlobClientOptions? = nil) throws {
        let credential = try StorageSASCredential(connectionString: connectionString)
        try self.init(credential: credential, withOptions: options)
    }

    // MARK: Public Client Methods

    /// List storage containers in a storage account.
    /// - Parameters:
    ///   - options: A `ListContainerOptions` object to control the list operation.
    ///   - completion: A completion handler that receives a `PagedCollection<ContainerItem>` object on success.
    public func listContainers(
        withOptions options: ListContainersOptions? = nil,
        then completion: @escaping HTTPResultHandler<PagedCollection<ContainerItem>>
    ) {
        // Construct URL
        let urlTemplate = ""
        guard let url = self.url(forTemplate: urlTemplate) else { return }

        // Construct query
        var queryParams: [QueryParameter] = [("comp", "list")]

        // Construct headers
        var headers = HTTPHeaders([
            .accept: "application/xml",
            .apiVersion: self.options.apiVersion
        ])

        // Process endpoint options
        if let options = options {
            // Query options
            if let prefix = options.prefix { queryParams.append("prefix", prefix) }
            if let include = options.include {
                queryParams.append("include", (include.map { $0.rawValue }).joined(separator: ","))
            }
            if let maxResults = options.maxResults { queryParams.append("maxresults", String(maxResults)) }
            if let timeout = options.timeout { queryParams.append("timeout", String(timeout)) }

            // Header options
            if let clientRequestId = options.clientRequestId {
                headers[HTTPHeader.clientRequestId] = clientRequestId
            }
        }

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
        guard let request = try? HTTPRequest(method: .get, url: url, headers: headers) else { return }
        request.add(queryParams: queryParams)

        self.request(request, context: context) { result, httpResponse in
            switch result {
            case let .success(data):
                guard let data = data else {
                    let noDataError = HTTPResponseError.decode("Response data expected but not found.")
                    completion(.failure(noDataError), httpResponse)
                    return
                }
                do {
                    let decoder = StorageJSONDecoder()
                    let paged = try PagedCollection<ContainerItem>(
                        client: self,
                        request: request,
                        data: data,
                        codingKeys: codingKeys,
                        decoder: decoder,
                        delegate: self
                    )
                    completion(.success(paged), httpResponse)
                } catch {
                    completion(.failure(error), httpResponse)
                }
            case let .failure(error):
                completion(.failure(error), httpResponse)
            }
        }
    }

    /// List storage blobs within a storage container.
    /// - Parameters:
    ///   - container: The container name containing the blobs to list.
    ///   - options: A `ListBlobsOptions` object to control the list operation.
    ///   - completion: A completion handler that receives a `PagedCollection<BlobItem>` object on success.
    public func listBlobs(
        in container: String,
        withOptions options: ListBlobsOptions? = nil,
        then completion: @escaping HTTPResultHandler<PagedCollection<BlobItem>>
    ) {
        // Construct URL
        let urlTemplate = "{container}"
        let pathParams = [
            "container": container
        ]
        guard let url = self.url(forTemplate: urlTemplate, withKwargs: pathParams) else { return }

        // Construct query
        var queryParams: [QueryParameter] = [
            ("comp", "list"),
            ("resType", "container")
        ]

        // Construct headers
        var headers = HTTPHeaders([
            .accept: "application/xml",
            .transferEncoding: "chunked",
            .apiVersion: self.options.apiVersion
        ])

        // Process endpoint options
        if let options = options {
            // Query options
            if let prefix = options.prefix { queryParams.append("prefix", prefix) }
            if let delimiter = options.delimiter { queryParams.append("delimiter", delimiter) }
            if let include = options.include {
                queryParams.append("include", (include.map { $0.rawValue }).joined(separator: ","))
            }
            if let maxResults = options.maxResults { queryParams.append("maxresults", String(maxResults)) }
            if let timeout = options.timeout { queryParams.append("timeout", String(timeout)) }

            // Header options
            if let clientRequestId = options.clientRequestId {
                headers[.clientRequestId] = clientRequestId
            }
        }

        // Construct and send request
        guard let request = try? HTTPRequest(method: .get, url: url, headers: headers) else { return }
        request.add(queryParams: queryParams)
        let codingKeys = PagedCodingKeys(
            items: "EnumerationResults.Blobs",
            continuationToken: "EnumerationResults.NextMarker",
            xmlItemName: "Blob"
        )
        let xmlMap = XMLMap(withPagedCodingKeys: codingKeys, innerType: BlobItem.self)
        let context = PipelineContext.of(keyValues: [
            ContextKey.xmlMap.rawValue: xmlMap as AnyObject
        ])
        self.request(request, context: context) { result, httpResponse in
            switch result {
            case let .success(data):
                guard let data = data else {
                    let noDataError = HTTPResponseError.decode("Response data expected but not found.")
                    completion(.failure(noDataError), httpResponse)
                    return
                }
                do {
                    let decoder = StorageJSONDecoder()
                    let paged = try PagedCollection<BlobItem>(
                        client: self,
                        request: request,
                        data: data,
                        codingKeys: codingKeys,
                        decoder: decoder,
                        delegate: self
                    )
                    completion(.success(paged), httpResponse)
                } catch {
                    completion(.failure(error), httpResponse)
                }
            case let .failure(error):
                completion(.failure(error), httpResponse)
            }
        }
    }

    /// Download a blob from a specified container.
    ///
    /// This method will execute a raw HTTP GET in order to download a single blob to the destination. It is STRONGLY
    /// recommended that you use the download() method instead - this method will manage the transfer in the face of
    /// changing network conditions, and is able to transfer multiple blocks in parallel.
    /// - Parameters:
    ///   - blob: The name of the blob.
    ///   - container: The name of the container.
    ///   - options: A `DownloadBlobOptions` object to control the download operation.
    ///   - completion: A completion handler that receives a `BlobStreamDownloader` object on success.
    public func rawDownload(
        blob: String,
        fromContainer container: String,
        withOptions options: DownloadBlobOptions? = nil,
        then completion: @escaping HTTPResultHandler<BlobStreamDownloader>
    ) throws {
        let downloader = try BlobStreamDownloader(client: self, name: blob, container: container, options: options)
        downloader.initialRequest { result, httpResponse in
            switch result {
            case .success:
                completion(.success(downloader), httpResponse)
            case let .failure(error):
                completion(.failure(error), httpResponse)
            }
        }
    }

    /// Upload a blob to a specified container.
    ///
    /// This method will execute a raw HTTP PUT in order to upload a single file to the destination. It is STRONGLY
    /// recommended that you use the upload() method instead - this method will manage the transfer in the face of
    /// changing network conditions, and is able to transfer multiple blocks in parallel.
    /// - Parameters:
    ///   - url: The URL to a file on this device
    ///   - container: The name of the container.
    ///   - blob: The name of the blob.
    ///   - properties: Properties to set on the resulting blob.
    ///   - options: An `UploadBlobOptions` object to control the upload operation.
    ///   - completion: A completion handler that receives a `BlobStreamUploader` object on success.
    public func rawUpload(
        url: URL,
        toContainer container: String,
        asBlob blob: String,
        properties: BlobProperties? = nil,
        withOptions options: UploadBlobOptions? = nil,
        then completion: @escaping HTTPResultHandler<BlobStreamUploader>
    ) throws {
        let uploader = try BlobStreamUploader(
            client: self,
            source: url,
            name: blob,
            container: container,
            properties: properties,
            options: options
        )
        uploader.next { result, httpResponse in
            switch result {
            case .success:
                completion(.success(uploader), httpResponse)
            case let .failure(error):
                completion(.failure(error), httpResponse)
            }
        }
    }

    /// Download a blob from a specified container.
    ///
    /// This method will reliably manage the transfer of the blob from the cloud service to this device. When called,
    /// a transfer will be queued and the returned Transfer object provides a handle to the transfer. The
    /// TransferDelegate provided in the StorageBlobClientOptions object will be notified about state changes for all
    /// transfers managed by this StorageBlobClient.
    ///
    /// - Parameters:
    ///   - blob: The name of the blob.
    ///   - container: The name of the container.
    ///   - options: A `DownloadBlobOptions` object to control the download operation.
    public func download(
        blob: String,
        fromContainer container: String,
        withOptions options: DownloadBlobOptions? = nil
    ) throws -> Transfer? {
        guard let transferManager = self.options.transferManager else { return nil }
        guard let context = transferManager.persistentContainer?.viewContext else { return nil }
        let start = Int64(options?.range?.offset ?? 0)
        let end = Int64(options?.range?.length ?? 0)
        let downloader = try BlobStreamDownloader(
            client: self,
            delegate: nil,
            name: blob,
            container: container,
            options: options
        )
        guard let sourceUrl = url(forBlob: blob, inContainer: container) else {
            throw AzureError.fileSystem("Unable to resolve source URL.")
        }
        let blobTransfer = BlobTransfer.with(
            context: context,
            source: sourceUrl,
            destination: downloader.downloadDestination,
            type: .download,
            startRange: start,
            endRange: end,
            parent: nil
        )
        blobTransfer.downloader = downloader
        transferManager.add(transfer: blobTransfer)
        return blobTransfer
    }

    /// Upload a blob to a specified container.
    ///
    /// This method will reliably manage the transfer of the blob from this device to the cloud service. When called,
    /// a transfer will be queued and the returned Transfer object provides a handle to the transfer. The
    /// TransferDelegate provided in the StorageBlobClientOptions object will be notified about state changes for all
    /// transfers managed by this StorageBlobClient.
    ///
    /// - Parameters:
    ///   - url: The URL to a file on this device
    ///   - container: The name of the container.
    ///   - blob: The name of the blob.
    ///   - properties: Properties to set on the resulting blob.
    ///   - options: An `UploadBlobOptions` object to control the upload operation.
    public func upload(
        url sourceUrl: URL,
        toContainer container: String,
        asBlob blob: String,
        properties: BlobProperties? = nil,
        withOptions options: UploadBlobOptions? = nil
    ) throws -> Transfer? {
        guard let transferManager = self.options.transferManager else { return nil }
        guard let context = transferManager.persistentContainer?.viewContext else { return nil }
        let uploader = try BlobStreamUploader(
            client: self,
            delegate: nil,
            source: sourceUrl,
            name: blob,
            container: container,
            properties: properties,
            options: options
        )
        guard let destinationUrl = url(forBlob: blob, inContainer: container) else {
            throw AzureError.fileSystem("Unable to resolve destination URL.")
        }
        let blobTransfer = BlobTransfer.with(
            context: context,
            source: uploader.uploadSource,
            destination: destinationUrl,
            type: .upload,
            startRange: 0,
            endRange: Int64(uploader.fileSize),
            parent: nil
        )
        blobTransfer.uploader = uploader
        transferManager.add(transfer: blobTransfer)
        return blobTransfer
    }

    // MARK: Private Methods

    /// Create a simple URL for a blob.
    /// - Parameters:
    ///   - blob: The name of the blob.
    ///   - container: The name of the container.
    private func url(forBlob blob: String, inContainer container: String) -> URL? {
        var url = URL(string: baseUrl)
        url?.appendPathComponent(container)
        url?.appendPathComponent(blob)
        return url
    }
}

// MARK: Paged Collection Delegate

extension StorageBlobClient: PagedCollectionDelegate {
    /// :nodoc:
    public func continuationUrl(
        continuationToken: String,
        queryParams: inout [QueryParameter],
        requestUrl: URL
    ) -> URL? {
        queryParams.append("marker", continuationToken)
        return requestUrl
    }
}

// MARK: Transfer Delegate

extension StorageBlobClient: TransferDelegate {
    /// :nodoc:
    public func transfer(
        _ transfer: Transfer,
        didUpdateWithState state: TransferState,
        andProgress progress: TransferProgress?
    ) {
        transferDelegate?.transfer(transfer, didUpdateWithState: state, andProgress: progress)
    }

    /// :nodoc:
    public func transfer(_ transfer: Transfer, didFailWithError error: Error) {
        transferDelegate?.transfer(transfer, didFailWithError: error)
    }

    /// :nodoc:
    public func transferDidComplete(_ transfer: Transfer) {
        transferDelegate?.transferDidComplete(transfer)
    }

    /// :nodoc:
    public func uploader(for transfer: Transfer) -> BlobStreamUploader? {
        transferDelegate?.uploader(for: transfer)
    }

    /// :nodoc:
    public func downloader(for transfer: Transfer) -> BlobStreamDownloader? {
        transferDelegate?.downloader(for: transfer)
    }
}

// MARK: Transfer Manager Methods

extension StorageBlobClient {
    /// Start the transfer management engine.
    ///
    /// Loads transfer state from disk, begins listening for network connectivity events, and resumes any incomplete
    /// transfers. This method **MUST** be called by your application in order for any managed transfers to occur.
    /// It's recommended to call this method from a background thread, at an opportune time after your app has started.
    ///
    /// Note that depending on the type of credential used by this StorageBlobClient, resuming transfers may cause a
    /// login UI to be displayed if the token for a paused transfer has expired. Because of this, it's not recommended
    /// to call this method from your AppDelegate. If you're using such a credential (e.g. the MSALCredential) you
    /// should first inspect the list of transfers to determine if any are pending. If so, you should assume that
    /// calling this method may display a login UI, and call it in a user-appropriate context (e.g. display a "pending
    /// transfers" message and wait for explicit user confirmation to start the management engine). If you're not using
    /// such a credential, or there are no paused transfers, it is safe to call this method from your AppDelegate.
    public func startManaging() {
        if managing { return }

        manager.reachability?.startListening()
        resumeAllTransfers()

        managing = true
    }

    /// Stop the transfer management engine.
    ///
    /// Pauses all incomplete transfers, stops listening for network connectivity events, and stores transfer state to
    /// disk. This method **SHOULD** be called by your application, either from your AppDelegate or from within a
    /// ViewController's lifecycle methods.
    public func stopManaging() {
        guard managing else { return }

        pauseAllTransfers()
        manager.reachability?.stopListening()
        manager.saveContext()

        managing = false
    }

    /// Cancel a currently active transfer.
    ///
    /// - Parameters:
    ///   - transfer: The transfer to cancel
    public func cancel(transfer: Transfer) {
        manager.cancel(transfer: transfer)
    }

    /// Cancel all currently active transfers.
    public func cancelAllTransfers() {
        manager.cancelAll()
    }

    /// Remove a transfer from the database. If the transfer is currently active it will be cancelled.
    ///
    /// - Parameters:
    ///   - transfer: The transfer to remove
    public func remove(transfer: Transfer) {
        manager.remove(transfer: transfer)
    }

    /// Remove all transfers from the database. All currently active transfers will be cancelled.
    public func removeAllTransfers() {
        manager.removeAll()
    }

    /// Pause a currently active transfer.
    ///
    /// - Parameters:
    ///   - transfer: The transfer to pause
    public func pause(transfer: Transfer) {
        manager.pause(transfer: transfer)
    }

    /// Pause all currently active transfers.
    public func pauseAllTransfers() {
        manager.pauseAll()
    }

    /// Resume a currently paused transfer.
    ///
    /// - Parameters:
    ///   - transfer: The transfer to resume
    public func resume(transfer: Transfer) {
        manager.resume(transfer: transfer)
    }

    /// Resume all currently paused transfers.
    public func resumeAllTransfers() {
        manager.resumeAll()
    }

    /// Retrieve a single Transfer object by its id.
    ///
    /// - Parameters:
    ///   - id: The id of the transfer to retrieve
    public func transfer(withId id: UUID) -> Transfer? {
        return manager.transfer(withId: id)
    }

    /// Retrieve the list of all currently managed transfers.
    public var transfers: [Transfer] {
        return manager.transfers
    }
}
