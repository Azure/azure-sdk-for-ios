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

/// Class used to upload an individual data chunk.
internal class ChunkUploader {
    // MARK: Properties

    internal let blockId: UUID

    internal let client: StorageBlobClient

    internal let options: UploadBlobOptions

    internal let uploadSource: URL

    internal let uploadDestination: URL

    internal var streamStart: UInt64?

    internal var startRange: Int

    internal var endRange: Int

    internal var isEncrypted: Bool {
        return options.encryptionOptions?.key != nil || options.encryptionOptions?.keyResolver != nil
    }

    // MARK: Initializers

    /// Creates a `ChunkUploader` object.
    /// - Parameters:
    ///   - blockId: A unique block identifer.
    ///   - client: The `StorageBlobClient` that initiated the request.
    ///   - source: The location on the device of the file being uploaded.
    ///   - destination: The location in Blob Storage to upload the file to.
    ///   - startRange: The start point, in bytes, of the upload request.
    ///   - endRange: The end point, in bytes, of the upload request.
    ///   - options: An `UploadBlobOptions` object with which to control the upload.
    public init(
        blockId: UUID,
        client: StorageBlobClient,
        source: URL,
        destination: URL,
        startRange: Int,
        endRange: Int,
        options: UploadBlobOptions
    ) {
        self.blockId = blockId
        self.client = client
        self.options = options
        self.uploadSource = source
        self.uploadDestination = destination
        self.startRange = startRange
        self.endRange = endRange
    }

    // MARK: Public Methods

    /// Begin the upload process.
    /// - Parameters:
    ///   - requestId: Unique request ID (GUID) for the operation.
    ///   - completionHandler: A completion handler that forwards the downloaded data.
    public func upload(
        requestId: String? = nil,
        transactionalContentMd5: Data? = nil,
        transactionalContentCrc64: Data? = nil,
        completionHandler: @escaping HTTPResultHandler<Data>
    ) {
        let chunkSize = endRange - startRange
        var buffer = Data(capacity: chunkSize)
        do {
            let fileHandle = try FileHandle(forReadingFrom: uploadSource)
            if #available(iOS 13.0, *) {
                try? fileHandle.seek(toOffset: UInt64(startRange))
            } else {
                // Fallback on earlier versions
                fileHandle.seek(toFileOffset: UInt64(startRange))
            }
            let tempData = fileHandle.readData(ofLength: chunkSize)
            buffer.append(tempData)
        } catch {
            let request = try? HTTPRequest(method: .put, url: uploadDestination, headers: HeaderParameters())
            completionHandler(
                .failure(AzureError.client("File error.", error)),
                HTTPResponse(request: request, statusCode: nil)
            )
            return
        }

        // Construct parameters
        let queryParams = QueryParameters(
            ("comp", "block"),
            ("blockid", blockId.uuidString.base64EncodedString()),
            ("timeout", options.timeoutInSeconds)
        )

        // Construct headers
        let leaseAccessConditions = options.leaseAccessConditions
        let cpk = options.customerProvidedEncryptionKey
        var headers = HeaderParameters(
            (HTTPHeader.contentType, "application/octet-stream"),
            (HTTPHeader.contentLength, String(chunkSize)),
            (HTTPHeader.apiVersion, client.options.apiVersion),
            (HTTPHeader.contentMD5, String(data: transactionalContentMd5, encoding: .utf8)),
            (StorageHTTPHeader.contentCRC64, String(data: transactionalContentCrc64, encoding: .utf8)),
            (HTTPHeader.clientRequestId, requestId),
            (StorageHTTPHeader.leaseId, leaseAccessConditions?.leaseId),
            (StorageHTTPHeader.encryptionKey, String(data: cpk?.keyData, encoding: .utf8)),
            (StorageHTTPHeader.encryptionScope, options.customerProvidedEncryptionScope),
            (StorageHTTPHeader.encryptionKeySHA256, cpk?.hash),
            (StorageHTTPHeader.encryptionAlgorithm, cpk?.algorithm)
        )

        // Construct and send request
        guard let requestUrl = uploadDestination.appending(queryParameters: queryParams) else { return }
        guard let request = try? HTTPRequest(method: .put, url: requestUrl, headers: headers, data: buffer)
        else { return }
        let context = options.context ?? PipelineContext.of(keyValues: [
            ContextKey.allowedStatusCodes.rawValue: [201] as AnyObject
        ])
        context.merge(with: options.context)
        client.request(request, context: context) { result, httpResponse in
            switch result {
            case let .failure(error):
                completionHandler(.failure(error), httpResponse)
            case let .success(data):
                let data = data ?? Data()
                completionHandler(.success(data), httpResponse)
            }
        }
    }

    // MARK: Private Methods

    private func decrypt(_ data: Data) -> Data {
        guard isEncrypted else { return data }
        // TODO: Implement client-side decryption.
        fatalError("Client-side encryption is not currently supported!")
    }
}

/// A delegate to receive notifications about state changes from `BlobUploader` objects.
public protocol BlobUploadDelegate: AnyObject {
    /// An upload's progress has updated.
    func uploader(_: BlobUploader, didUpdateWithProgress: TransferProgress)
    /// An upload has failed.
    func uploader(_: BlobUploader, didFailWithError: Error)
    /// An upload has completed.
    func uploaderDidComplete(_: BlobUploader)
}

/// An object that contains details about an upload operation.
public protocol BlobUploader {
    /// The `BlobUploadDelegate` to inform about upload events.
    var delegate: BlobUploadDelegate? { get set }

    /// Location on the device of the file being uploaded.
    var uploadSource: URL { get }

    /// Location in Blob Storage to upload the file to.
    var uploadDestination: URL { get }

    /// Properties applied to the destination blob.
    var blobProperties: BlobProperties? { get }

    /// Size, in bytes, of the file being uploaded.
    var fileSize: Int { get }

    /// The total bytes uploaded.
    var progress: Int { get }

    /// Indicates if the upload is complete.
    var isComplete: Bool { get }

    /// Indicates if the upload is encrypted.
    var isEncrypted: Bool { get }
}

/// Class used to upload block blobs.
internal class BlobStreamUploader: BlobUploader {
    // MARK: Properties

    public weak var delegate: BlobUploadDelegate?

    /// Location on the device of the file being uploaded.
    public let uploadSource: URL

    /// Location in Blob Storage to upload the file to.
    public let uploadDestination: URL

    /// Properties applied to the destination blob.
    public var blobProperties: BlobProperties?

    /// Size, in bytes, of the file being uploaded.
    public let fileSize: Int

    /// The total bytes uploaded.
    public var progress = 0

    /// The list of blocks for the blob upload.
    internal var blockList = [(range: Range<Int>, blockId: UUID)]()

    /// Internal list that maps the order of block IDs.
    internal var blockIdMap = [UUID: Int]()

    /// Logs completed block IDs and the order they *should* be in.
    internal var completedBlockMap = [UUID: Int]()

    /// Indicates if the upload is complete.
    public var isComplete: Bool {
        return progress == fileSize
    }

    /// Indicates if the upload is encrypted.
    public var isEncrypted: Bool {
        return options.encryptionOptions?.key != nil || options.encryptionOptions?.keyResolver != nil
    }

    internal let client: StorageBlobClient

    internal let options: UploadBlobOptions

    // MARK: Initializers

    /// Create a `BlobStreamUploader` object.
    /// - Parameters:
    ///   - client: A`StorageBlobClient` reference.
    ///   - delegate: A `BlobUploadDelegate` to notify about the progress of the upload.
    ///   - source: The location on the device of the file being uploaded.
    ///   - destination: The location in Blob Storage to upload the file to.
    ///   - properties: Properties to set on the resulting blob.
    ///   - options: An `UploadBlobOptions` object to control the upload process.
    public init(
        client: StorageBlobClient,
        delegate: BlobUploadDelegate? = nil,
        source: LocalURL,
        destination: URL,
        properties: BlobProperties? = nil,
        options: UploadBlobOptions
    ) throws {
        guard let uploadSource = source.resolvedUrl else {
            throw AzureError.client("Unable to determine upload source: \(source)")
        }

        let attributes = try FileManager.default.attributesOfItem(atPath: uploadSource.path)
        guard let fileSize = attributes[FileAttributeKey.size] as? Int else {
            throw AzureError.client("Unable to determine file size: \(uploadSource.path)")
        }

        self.uploadSource = uploadSource
        self.fileSize = fileSize
        self.client = client
        self.delegate = delegate
        self.options = options
        self.uploadDestination = destination
        self.blobProperties = properties
        self.blockList = computeBlockList()
    }

    // MARK: Public Methods

    /// Read and return the content of the downloaded file.
    public func contents() throws -> Data {
        let handle = try FileHandle(forReadingFrom: uploadSource)
        defer { handle.closeFile() }
        return handle.readDataToEndOfFile()
    }

    /// Uploads the entire blob in a parallel fashion.
    /// - Parameters:
    ///   - group: An optional `DispatchGroup` to wait for the download to complete.
    ///   - completionHandler: A completion handler called when the download completes.
    public func complete(inGroup group: DispatchGroup? = nil, completionHandler: @escaping () -> Void) throws {
        guard !isComplete else {
            if let delegate = self.delegate {
                delegate.uploaderDidComplete(self)
            } else {
                completionHandler()
            }
            return
        }
        let defaultGroup = DispatchGroup()
        let dispatchGroup = group ?? defaultGroup
        for _ in blockList {
            dispatchGroup.enter()
            next(inGroup: dispatchGroup) { _, _ in
                if let delegate = self.delegate {
                    let progress = TransferProgress(bytes: self.progress, totalBytes: self.fileSize)
                    delegate.uploader(self, didUpdateWithProgress: progress)
                }
            }
        }
        dispatchGroup.notify(queue: DispatchQueue.main) {
            // Once all blocks are done, commit block list
            self.commit { result, _ in
                switch result {
                case .success:
                    if let delegate = self.delegate {
                        delegate.uploaderDidComplete(self)
                    } else {
                        completionHandler()
                    }
                case let .failure(error):
                    if let delegate = self.delegate {
                        delegate.uploader(self, didFailWithError: error)
                    }
                }
            }
        }
    }

    public func commit(
        requestId: String? = nil,
        transactionalContentMd5: Data? = nil,
        transactionalContentCrc64: Data? = nil,
        inGroup _: DispatchGroup? = nil,
        completionHandler: @escaping HTTPResultHandler<BlobProperties>
    ) {
        // Construct parameters & headers
        let queryParams = QueryParameters(
            ("comp", "blocklist"),
            ("timeout", options.timeoutInSeconds)
        )
        let headers = commitHeadersForRequest(
            withId: requestId,
            withContentMD5: transactionalContentMd5,
            withContentCRC64: transactionalContentCrc64
        )

        // Construct and send request
        let lookupList = buildLookupList()
        let encoding = String.Encoding.utf8
        guard let xmlString = try? lookupList.asXmlString(encoding: encoding) else {
            fatalError("Unable to serialize block list as XML string.")
        }
        let xmlData = xmlString.data(using: encoding)

        guard let requestUrl = uploadDestination.appending(queryParameters: queryParams) else { return }
        guard let request = try? HTTPRequest(method: .put, url: requestUrl, headers: headers, data: xmlData)
        else { return }
        let context = options.context ?? PipelineContext.of(keyValues: [
            ContextKey.allowedStatusCodes.rawValue: [201] as AnyObject
        ])
        context.add(cancellationToken: options.cancellationToken, applying: client.options)
        context.merge(with: options.context)
        client.request(request, context: context) { result, httpResponse in
            switch result {
            case let .failure(error):
                completionHandler(.failure(error), httpResponse)
            case .success:
                guard let responseHeaders = httpResponse?.headers else {
                    let error = AzureError.client("No response received.")
                    completionHandler(.failure(error), httpResponse)
                    return
                }
                let blobProperties = BlobProperties(from: responseHeaders)
                completionHandler(.success(blobProperties), httpResponse)
            }
        }
    }

    /// Download the contents of this file to a stream.
    /// - Parameters:
    ///   - group: An optional `DispatchGroup` to wait for the download to complete.
    ///   - completionHandler: A completion handler with which to process the downloaded chunk.
    public func next(inGroup group: DispatchGroup? = nil, completionHandler: @escaping HTTPResultHandler<Data>) {
        guard !isComplete else { return }
        let metadata = blockList.removeFirst()
        let range = metadata.range
        let blockId = metadata.blockId
        let uploader = ChunkUploader(
            blockId: blockId,
            client: client,
            source: uploadSource,
            destination: uploadDestination,
            startRange: range.startIndex,
            endRange: range.endIndex,
            options: options
        )
        uploader.upload { result, httpResponse in
            switch result {
            case .success:
                // Add block ID to the completed list and lookup where its final
                // placement should be
                self.progress += uploader.endRange - uploader.startRange
                let blockId = uploader.blockId
                self.completedBlockMap[blockId] = self.blockIdMap[blockId]
            case let .failure(error):
                self.client.options.logger.debug(String(describing: error))
            }
            completionHandler(result, httpResponse)
            group?.leave()
        }
    }

    // MARK: Private Methods

    // swiftlint:disable:next cyclomatic_complexity
    private func commitHeadersForRequest(
        withId requestId: String?,
        withContentMD5 md5: Data?,
        withContentCRC64 crc64: Data?
    ) -> HeaderParameters {
        let leaseAccessConditions = options.leaseAccessConditions
        let modifiedAccessConditions = options.modifiedAccessConditions
        let cpk = options.customerProvidedEncryptionKey

        // Construct headers
        var headers = HeaderParameters(
            (HTTPHeader.contentType, "application/xml; charset=utf-8"),
            (HTTPHeader.apiVersion, client.options.apiVersion),
            (HTTPHeader.contentMD5, String(data: md5, encoding: .utf8)),
            (StorageHTTPHeader.contentCRC64, String(data: crc64, encoding: .utf8)),
            (HTTPHeader.clientRequestId, requestId),
            (StorageHTTPHeader.leaseId, leaseAccessConditions?.leaseId),
            (StorageHTTPHeader.encryptionKey, cpk?.keyData),
            (StorageHTTPHeader.encryptionScope, options.customerProvidedEncryptionScope),
            (StorageHTTPHeader.encryptionKeySHA256, cpk?.hash),
            (StorageHTTPHeader.encryptionAlgorithm, cpk?.algorithm),
            (HTTPHeader.ifModifiedSince, modifiedAccessConditions?.ifModifiedSince),
            (HTTPHeader.ifUnmodifiedSince, modifiedAccessConditions?.ifUnmodifiedSince),
            (HTTPHeader.ifMatch, modifiedAccessConditions?.ifMatch),
            (HTTPHeader.ifNoneMatch, modifiedAccessConditions?.ifNoneMatch),
            (StorageHTTPHeader.accessTier, blobProperties?.accessTier),
            (StorageHTTPHeader.blobCacheControl, blobProperties?.cacheControl),
            (StorageHTTPHeader.blobContentType, blobProperties?.contentType),
            (StorageHTTPHeader.blobContentEncoding, blobProperties?.contentEncoding),
            (StorageHTTPHeader.blobContentLanguage, blobProperties?.contentLanguage),
            (StorageHTTPHeader.blobContentMD5, blobProperties?.contentMD5),
            (StorageHTTPHeader.blobContentDisposition, blobProperties?.contentDisposition)
        )
        return headers
    }

    private func buildLookupList() -> BlobLookupList {
        let sortedIds = completedBlockMap.sorted(by: { $0.value < $1.value })
        let lookupList = BlobLookupList(latest: sortedIds.compactMap { $0.key.uuidString.base64EncodedString() })
        return lookupList
    }

    private func computeBlockList(withOffset offset: Int = 0) -> [(Range<Int>, UUID)] {
        var blockList = [(Range<Int>, UUID)]()
        let alignForCrypto = isEncrypted
        let chunkLength = client.options.maxChunkSizeInBytes

        if alignForCrypto {
            fatalError("Client-side encryption is not yet supported!")
        } else {
            for index in stride(from: offset, to: fileSize, by: chunkLength) {
                var blockEnd = index + chunkLength
                if fileSize < 0 {
                    blockEnd = chunkLength
                }
                if blockEnd > fileSize {
                    blockEnd = fileSize
                }
                let range = index ..< blockEnd
                let blockId = UUID()
                blockList.append((range: range, blockId: blockId))
                blockIdMap[blockId] = blockList.count - 1
            }
        }
        return blockList
    }

    /// Parses the blob length from the content range header: bytes 1-3/65537
    private func parseLength(fromContentRange contentRange: String?) throws -> Int {
        let error = AzureError.client("Unable to parse content range: \(contentRange ?? "nil")")
        guard let contentRange = contentRange else { throw error }
        // split on slash and take the second half: "65537"
        guard let lengthString = contentRange.split(separator: "/", maxSplits: 1).last else { throw error }
        // Finally, convert to an Int: 65537
        guard let intVal = Int(String(lengthString)) else { throw error }
        return intVal
    }
}
