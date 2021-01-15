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

// swiftlint:disable type_body_length function_body_length
public final class BlobsOperations {
    internal let client: StorageBlobClient

    public required init(_ client: StorageBlobClient) {
        self.client = client
    }

    /// List blobs within a storage container.
    /// - Parameters:
    ///   - container: The container name containing the blobs to list.
    ///   - options: A `ListBlobsOptions` object to control the list operation.
    ///   - completionHandler: A completion handler that receives a `PagedCollection` of `BlobItem` objects on success.
    public func list(
        inContainer container: String,
        withOptions options: ListBlobsOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<PagedCollection<BlobItem>>
    ) {
        let urlTemplate = "/{container}"
        let params = RequestParameters(
            (.path, "container", container, .encode),
            (.query, "comp", "list", .encode),
            (.query, "restype", "container", .encode),
            (.query, "prefix", options?.prefix, .encode),
            (.query, "delimiter", options?.delimiter, .encode),
            (.query, "include", options?.include, .encode),
            (.query, "maxresults", options?.maxResults, .encode),
            (.query, "timeout", options?.timeout, .encode),
            (.header, HTTPHeader.accept, "application/xml", .encode),
            (.header, HTTPHeader.transferEncoding, "chunked", .encode),
            (.header, HTTPHeader.apiVersion, client.options.apiVersion, .encode),
            (.header, HTTPHeader.clientRequestId, options?.clientRequestId, .encode)
        )

        // Construct and send request
        let codingKeys = PagedCodingKeys(
            items: "EnumerationResults.Blobs",
            continuationToken: "EnumerationResults.NextMarker",
            xmlItemName: "Blob"
        )
        let xmlMap = XMLMap(withPagedCodingKeys: codingKeys, innerType: BlobItem.self)
        let context = PipelineContext.of(keyValues: [
            ContextKey.xmlMap.rawValue: xmlMap as AnyObject
        ])
        context.add(cancellationToken: options?.cancellationToken, applying: client.options)
        context.merge(with: options?.context)

        guard let requestUrl = client.url(template: urlTemplate, params: params),
            let request = try? HTTPRequest(method: .get, url: requestUrl, headers: params.headers) else {
            client.options.logger.error("Failed to construct Http request")
            return
        }
        client.request(request, context: context) { result, httpResponse in
            let dispatchQueue = options?.dispatchQueue ?? self.client.commonOptions.dispatchQueue ?? DispatchQueue.main
            switch result {
            case let .success(data):
                guard let data = data else {
                    let noDataError = AzureError.client("Response data expected but not found.")
                    dispatchQueue.async {
                        completionHandler(.failure(noDataError), httpResponse)
                    }
                    return
                }
                do {
                    let decoder = StorageJSONDecoder()
                    let paged = try PagedCollection<BlobItem>(
                        client: self.client,
                        request: request,
                        context: context,
                        data: data,
                        codingKeys: codingKeys,
                        decoder: decoder
                    )
                    dispatchQueue.async {
                        completionHandler(.success(paged), httpResponse)
                    }
                } catch {
                    dispatchQueue.async {
                        completionHandler(.failure(AzureError.client("Decoding error.", error)), httpResponse)
                    }
                }
            case let .failure(error):
                dispatchQueue.async {
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
        let urlTemplate = "/{container}/{blob}"
        let params = RequestParameters(
            (.path, "container", container, .encode),
            (.path, "blob", blob, .encode),
            (.query, "snapshot", options?.snapshot, .encode),
            (.query, "timeout", options?.timeout, .encode),
            (.header, HTTPHeader.apiVersion, client.options.apiVersion, .encode),
            (.header, StorageHTTPHeader.deleteSnapshots, options?.deleteSnapshots, .encode),
            (.header, HTTPHeader.clientRequestId, options?.clientRequestId, .encode)
        )

        // Construct and send request
        let context = PipelineContext.of(keyValues: [
            ContextKey.allowedStatusCodes.rawValue: [202] as AnyObject
        ])
        context.add(cancellationToken: options?.cancellationToken, applying: client.options)
        context.merge(with: options?.context)
        guard let requestUrl = client.url(template: urlTemplate, params: params),
            let request = try? HTTPRequest(method: .delete, url: requestUrl, headers: params.headers) else {
            client.options.logger.error("Failed to construct Http request")
            return
        }
        client.request(request, context: context) { result, httpResponse in
            let dispatchQueue = options?.dispatchQueue ?? self.client.commonOptions.dispatchQueue ?? DispatchQueue.main
            switch result {
            case .success:
                dispatchQueue.async {
                    completionHandler(.success(()), httpResponse)
                }
            case let .failure(error):
                dispatchQueue.async {
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
        let params = RequestParameters(
            (.path, "container", container, .encode),
            (.path, "blob", blob, .encode)
        )

        let context = PipelineContext()
        context.add(cancellationToken: options.cancellationToken, applying: client.options)

        guard let requestUrl = client.url(template: urlTemplate, params: params) else {
            client.options.logger.error("Failed to construct Http request")
            return
        }
        let downloader = try BlobStreamDownloader(
            client: client,
            source: requestUrl,
            destination: destinationUrl,
            options: options
        )
        downloader.initialRequest { result, httpResponse in
            let dispatchQueue = options.dispatchQueue ?? self.client.commonOptions.dispatchQueue ?? DispatchQueue.main
            switch result {
            case .success:
                dispatchQueue.async {
                    completionHandler(.success(downloader), httpResponse)
                }
            case let .failure(error):
                dispatchQueue.async {
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
        let urlTemplate = "/{container}/{blob}"
        let params = RequestParameters(
            (.path, "container", container, .encode),
            (.path, "blob", blob, .encode)
        )

        let context = PipelineContext()
        context.add(cancellationToken: options.cancellationToken, applying: client.options)

        guard let requestUrl = client.url(template: urlTemplate, params: params) else { return }
        let uploader = try BlobStreamUploader(
            client: client,
            source: sourceUrl,
            destination: requestUrl,
            properties: properties,
            options: options
        )
        uploader.next { result, httpResponse in
            let dispatchQueue = options.dispatchQueue ?? self.client.commonOptions.dispatchQueue ?? DispatchQueue.main
            switch result {
            case .success:
                dispatchQueue.async {
                    completionHandler(.success(uploader), httpResponse)
                }
            case let .failure(error):
                dispatchQueue.async {
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
        let urlTemplate = "/{container}/{blob}"
        let params = RequestParameters(
            (.path, "container", container, .encode),
            (.path, "blob", blob, .encode)
        )

        let context = PipelineContext()
        context.add(cancellationToken: options.cancellationToken, applying: client.options)

        let start = Int64(options.range?.offsetBytes ?? 0)
        let end = Int64(options.range?.lengthInBytes ?? 0)
        guard let requestUrl = client.url(template: urlTemplate, params: params) else { return nil }
        let downloader = try BlobStreamDownloader(
            client: client,
            source: requestUrl,
            destination: destinationUrl,
            options: options
        )
        let blobTransfer = BlobTransfer.with(
            viewContext: StorageBlobClient.viewContext,
            clientRestorationId: client.options.restorationId,
            localUrl: destinationUrl,
            remoteUrl: requestUrl,
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
        let urlTemplate = "/{container}/{blob}"
        let params = RequestParameters(
            (.path, "container", container, .encode),
            (.path, "blob", blob, .encode)
        )

        let context = PipelineContext()
        context.add(cancellationToken: options.cancellationToken, applying: client.options)

        guard let requestUrl = client.url(template: urlTemplate, params: params) else { return nil }
        let uploader = try BlobStreamUploader(
            client: client,
            source: sourceUrl,
            destination: requestUrl,
            properties: properties,
            options: options
        )
        let blobTransfer = BlobTransfer.with(
            viewContext: StorageBlobClient.viewContext,
            clientRestorationId: client.options.restorationId,
            localUrl: sourceUrl,
            remoteUrl: requestUrl,
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

    // TODO: set/get tags

    // TODO: set/get metadata (needs tests)

//    /// Gets blob metadata.
//    /// - Parameters:
//    ///    - blob : The target blob name.
//    ///    - container: The container name containing the blob.
//    ///    - options: A list of options for the operation
//    ///    - completionHandler: A completion handler that receives a `[String: String]` dictionary of metadata on success.
//    public func getMetadata(
//        forBlob blob: String,
//        inContainer container: String,
//        withOptions options: GetBlobMetadataOptions? = nil,
//        completionHandler: @escaping HTTPResultHandler<[String: String]>
//    ) {
//        // Create request parameters
//        let params = RequestParameters(
//            (.path, "container", container, .encode),
//            (.path, "blob", blob, .encode),
//            (.uri, "endpoint", client.endpoint.absoluteString, .skipEncoding),
//            (.query, "comp", "metadata", .encode),
//            (.query, "snapshot", options?.snapshot, .encode),
//            (.query, "versionId", options?.versionId, .encode),
//            (.query, "timeout", options?.timeout, .encode),
//            (.header, HTTPHeader.accept, "application/xml", .encode),
//            (.header, HTTPHeader.apiVersion, client.options.apiVersion, .encode),
//            (.header, HTTPHeader.clientRequestId, options?.clientRequestId, .encode)
//        )
//
//        // Construct request
//        let urlTemplate = "/{container}/{blob}"
//        guard let requestUrl = client.url(host: "{endpoint}", template: urlTemplate, params: params),
//            let request = try? HTTPRequest(method: .get, url: requestUrl, headers: params.headers) else {
//            client.options.logger.error("Failed to construct HTTP request.")
//            return
//        }
//        // Send request
//        let context = PipelineContext.of(keyValues: [
//            ContextKey.allowedStatusCodes.rawValue: [200] as AnyObject
//        ])
//        context.add(cancellationToken: options?.cancellationToken, applying: client.options)
//        context.merge(with: options?.context)
//        client.request(request, context: context) { result, httpResponse in
//            let dispatchQueue = options?.dispatchQueue ?? self.client.commonOptions.dispatchQueue ?? DispatchQueue.main
//            guard let data = httpResponse?.data else {
//                let noDataError = AzureError.client("Response data expected but not found.")
//                dispatchQueue.async {
//                    completionHandler(.failure(noDataError), httpResponse)
//                }
//                return
//            }
//            switch result {
//            case .success:
//                guard let statusCode = httpResponse?.statusCode else {
//                    let noStatusCodeError = AzureError.client("Expected a status code in response but didn't find one.")
//                    dispatchQueue.async {
//                        completionHandler(.failure(noStatusCodeError), httpResponse)
//                    }
//                    return
//                }
//                if [
//                    200
//                ].contains(statusCode) {
//                    do {
//                        let decoder = JSONDecoder()
//                        let decoded = try decoder.decode([String: String].self, from: data)
//                        dispatchQueue.async {
//                            completionHandler(.success(decoded), httpResponse)
//                        }
//                    } catch {
//                        dispatchQueue.async {
//                            completionHandler(.failure(AzureError.client("Decoding error.", error)), httpResponse)
//                        }
//                    }
//                }
//            case let .failure(error):
//                dispatchQueue.async {
//                    completionHandler(.failure(error), httpResponse)
//                }
//            }
//        }
//    }
//
//    /// Sets blob metadata.
//    /// - Parameters:
//    ///    - metadata: The `[String: String]` metadata dictionary to set.
//    ///    - blob : The target blob name.
//    ///    - container: The container name containing the blob.
//    ///    - options: A list of options for the operation
//    ///    - completionHandler: A completion handler that receives a `[String: String]` dictionary of metadata on success.
//    public func set(
//        metadata: [String: String],
//        forBlob blob: String,
//        inContainer container: String,
//        withOptions options: SetBlobMetadataOptions? = nil,
//        completionHandler: @escaping HTTPResultHandler<[String: String]>
//    ) {
//        // Create request parameters
//        let params = RequestParameters(
//            (.path, "container", container, .encode),
//            (.path, "blob", blob, .encode),
//            (.uri, "endpoint", client.endpoint.absoluteString, .skipEncoding),
//            (.query, "comp", "metadata", .encode),
//            (.query, "timeout", options?.timeout, .encode),
//            (.header, StorageHTTPHeader.metadata, metadata, .encode),
//            (.header, HTTPHeader.accept, "application/xml", .encode),
//            (.header, HTTPHeader.apiVersion, client.options.apiVersion, .encode),
//            (.header, HTTPHeader.clientRequestId, options?.clientRequestId, .encode)
//        )
//
//        // Construct request
//        let urlTemplate = "/{container}/{blob}"
//        guard let requestUrl = client.url(host: "{endpoint}", template: urlTemplate, params: params),
//            let request = try? HTTPRequest(method: .put, url: requestUrl, headers: params.headers) else {
//            client.options.logger.error("Failed to construct HTTP request.")
//            return
//        }
//        // Send request
//        let context = PipelineContext.of(keyValues: [
//            ContextKey.allowedStatusCodes.rawValue: [200] as AnyObject
//        ])
//        context.add(cancellationToken: options?.cancellationToken, applying: client.options)
//        context.merge(with: options?.context)
//        client.request(request, context: context) { result, httpResponse in
//            let dispatchQueue = options?.dispatchQueue ?? self.client.commonOptions.dispatchQueue ?? DispatchQueue.main
//            guard let data = httpResponse?.data else {
//                let noDataError = AzureError.client("Response data expected but not found.")
//                dispatchQueue.async {
//                    completionHandler(.failure(noDataError), httpResponse)
//                }
//                return
//            }
//            switch result {
//            case .success:
//                guard let statusCode = httpResponse?.statusCode else {
//                    let noStatusCodeError = AzureError.client("Expected a status code in response but didn't find one.")
//                    dispatchQueue.async {
//                        completionHandler(.failure(noStatusCodeError), httpResponse)
//                    }
//                    return
//                }
//                if [
//                    200
//                ].contains(statusCode) {
//                    do {
//                        let decoder = JSONDecoder()
//                        let decoded = try decoder.decode([String: String].self, from: data)
//                        dispatchQueue.async {
//                            completionHandler(.success(decoded), httpResponse)
//                        }
//                    } catch {
//                        dispatchQueue.async {
//                            completionHandler(.failure(AzureError.client("Decoding error.", error)), httpResponse)
//                        }
//                    }
//                }
//            case let .failure(error):
//                dispatchQueue.async {
//                    completionHandler(.failure(error), httpResponse)
//                }
//            }
//        }
//    }

    // TODO: set HTTP header properties

    // TODO: set access tier
}
