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

// swiftlint:disable file_length
// swiftlint:disable function_body_length
// swiftlint:disable cyclomatic_complexity

import AzureCore
import Foundation

/// Class used to upload an individual data chunk.
internal class ChunkUploader {
    // MARK: Properties

    internal let blockId: UUID

    internal let blobName: String

    internal let containerName: String

    internal let client: StorageBlobClient

    internal let options: UploadBlobOptions

    internal let uploadSource: URL

    internal var streamStart: UInt64?

    internal var startRange: Int

    internal var endRange: Int

    internal var isEncrypted: Bool {
        return options.encryptionOptions?.key != nil || options.encryptionOptions?.keyResolver != nil
    }

    // MARK: Initializers

    /// Creates a `ChunkUploader` object.
    /// - Parameters:
    ///   - blob: The name of the blob.
    ///   - container: The name of the stoarge container in which to upload the blob.
    ///   - client: The `StorageBlobClient` that initiated the request.
    ///   - url: The source URL of the blob object.
    ///   - blockId: A unique block identifer.
    ///   - startRange: The start point, in bytes, of the upload request.
    ///   - endRange: The end point, in bytes, of the upload request.
    ///   - options: An `UploadBlobOptions` object with which to control the upload.
    public init(
        blob: String,
        container: String,
        blockId: UUID,
        client: StorageBlobClient,
        url: URL,
        startRange: Int,
        endRange: Int,
        options: UploadBlobOptions
    ) {
        self.blockId = blockId
        self.blobName = blob
        self.containerName = container
        self.client = client
        self.options = options
        self.uploadSource = url
        self.startRange = startRange
        self.endRange = endRange
    }

    // MARK: Public Methods

    /// Begin the upload process.
    /// - Parameters:
    ///   - requestId: Unique request ID (GUID) for the operation.
    ///   - completion: A completion handler that forwards the downloaded data.
    public func upload(
        requestId: String? = nil,
        transactionalContentMd5: Data? = nil,
        transactionalContentCrc64: Data? = nil,
        then completion: @escaping HTTPResultHandler<Data>
    ) {
        // Construct URL
        let urlTemplate = "/{container}/{blob}"
        let pathParams = [
            "container": containerName,
            "blob": blobName
        ]
        guard let url = client.url(forTemplate: urlTemplate, withKwargs: pathParams) else { return }
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
            let request = try? HTTPRequest(method: .put, url: url, headers: HTTPHeaders())
            completion(.failure(error), HTTPResponse(request: request, statusCode: nil))
            return
        }

        // Construct parameters
        var queryParams = [
            ("comp", "block"),
            ("blockid", blockId.uuidString.base64String)
        ]
        if let timeout = options.timeout { queryParams.append(("timeout", String(timeout))) }

        // Construct headers
        var headers = HTTPHeaders([
            .contentType: "application/octet-stream",
            .contentLength: String(chunkSize),
            .apiVersion: client.options.apiVersion
        ])
        let leaseAccessConditions = options.leaseAccessConditions
        let cpk = options.customerProvidedEncryptionKey

        if let transactionalContentMd5 = transactionalContentMd5 {
            headers[.contentMD5] = String(data: transactionalContentMd5, encoding: .utf8)
        }

        if let transactionalContentCrc64 = transactionalContentCrc64 {
            headers[.contentCRC64] = String(data: transactionalContentCrc64, encoding: .utf8)
        }

        if let requestId = requestId { headers[.clientRequestId] = requestId }
        if let leaseId = leaseAccessConditions?.leaseId { headers[.leaseId] = leaseId }
        if let encryptionKey = cpk?.keyData {
            headers[.encryptionKey] = String(data: encryptionKey, encoding: .utf8)
        }
        if let encryptionScope = options.customerProvidedEncryptionScope {
            headers[.encryptionScope] = encryptionScope
        }

        if let encryptionKeySHA256 = cpk?.hash { headers[.encryptionKeySHA256] = encryptionKeySHA256 }
        if let encryptionAlgorithm = cpk?.algorithm { headers[.encryptionAlgorithm] = encryptionAlgorithm }

        // Construct and send request
        guard let request = try? HTTPRequest(method: .put, url: url, headers: headers, data: buffer) else { return }
        request.add(queryParams: queryParams)
        let context = PipelineContext.of(keyValues: [
            ContextKey.allowedStatusCodes.rawValue: [201] as AnyObject
        ])

        client.request(request, context: context) { result, httpResponse in
            switch result {
            case let .failure(error):
                completion(.failure(error), httpResponse)
            case let .success(data):
                let data = data ?? Data()
                completion(.success(data), httpResponse)
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

    /// Name of the destination blob.
    var blobName: String { get }

    /// Name of the container containing the destination blob.
    var containerName: String { get }

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

    /// Name of the destination blob.
    public let blobName: String

    /// Name of the container containing the destination blob.
    public let containerName: String

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
    ///   - name: The name of the blob to upload.
    ///   - container: The name of the container the blob is contained in.
    ///   - options: An `UploadBlobOptions` object to control the upload process.
    public init(
        client: StorageBlobClient,
        delegate: BlobUploadDelegate? = nil,
        source: URL,
        name: String,
        container: String,
        properties: BlobProperties? = nil,
        options: UploadBlobOptions? = nil
    ) throws {
        let manager = FileManager.default
        guard manager.fileExists(atPath: source.path) else {
            throw AzureError.fileSystem("File not found: \(source.path)")
        }
        let attributes = try manager.attributesOfItem(atPath: source.path)
        guard let fileSize = attributes[FileAttributeKey.size] as? Int else {
            throw AzureError.fileSystem("Unable to determine file size: \(source.path)")
        }
        self.fileSize = fileSize

        self.client = client
        self.delegate = delegate
        self.options = options ?? UploadBlobOptions()
        self.blobName = name
        self.containerName = container
        self.uploadSource = source
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
    ///   - completion: A completion handler called when the download completes.
    public func complete(inGroup group: DispatchGroup? = nil, then completion: @escaping () -> Void) throws {
        guard !isComplete else {
            if let delegate = self.delegate {
                delegate.uploaderDidComplete(self)
            } else {
                completion()
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
                        completion()
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
        then completion: @escaping HTTPResultHandler<BlobProperties>
    ) {
        // Construct URL
        let urlTemplate = "/{container}/{blob}"
        let pathParams = [
            "container": containerName,
            "blob": blobName
        ]
        guard let url = client.url(forTemplate: urlTemplate, withKwargs: pathParams) else { return }

        // Construct parameters
        var queryParams = [
            ("comp", "blocklist")
        ]
        if let timeout = options.timeout { queryParams.append(("timeout", String(timeout))) }

        // Construct headers
        var headers = HTTPHeaders([
            .contentType: "application/xml; charset=utf-8",
            .apiVersion: client.options.apiVersion
        ])
        let leaseAccessConditions = options.leaseAccessConditions
        let modifiedAccessConditions = options.modifiedAccessConditions
        let cpk = options.customerProvidedEncryptionKey

        if let transactionalContentMd5 = transactionalContentMd5 {
            headers[.contentMD5] = String(data: transactionalContentMd5, encoding: .utf8)
        }

        if let transactionalContentCrc64 = transactionalContentCrc64 {
            headers[.contentCRC64] = String(data: transactionalContentCrc64, encoding: .utf8)
        }

        if let requestId = requestId { headers[.clientRequestId] = requestId }
        if let leaseId = leaseAccessConditions?.leaseId { headers[.leaseId] = leaseId }
        if let encryptionKey = cpk?.keyData {
            headers[.encryptionKey] = String(data: encryptionKey, encoding: .utf8)
        }
        if let encryptionScope = options.customerProvidedEncryptionScope {
            headers[.encryptionScope] = encryptionScope
        }

        if let encryptionKeySHA256 = cpk?.hash { headers[.encryptionKeySHA256] = encryptionKeySHA256 }
        if let encryptionAlgorithm = cpk?.algorithm { headers[.encryptionAlgorithm] = encryptionAlgorithm }
        if let ifModifiedSince = modifiedAccessConditions?.ifModifiedSince {
            headers[.ifModifiedSince] = String(describing: ifModifiedSince, format: .rfc1123)
        }
        if let ifUnmodifiedSince = modifiedAccessConditions?.ifUnmodifiedSince {
            headers[.ifUnmodifiedSince] = String(describing: ifUnmodifiedSince, format: .rfc1123)
        }
        if let ifMatch = modifiedAccessConditions?.ifMatch { headers[.ifMatch] = ifMatch }
        if let ifNoneMatch = modifiedAccessConditions?.ifNoneMatch { headers[.ifNoneMatch] = ifNoneMatch }

        if let accessTier = blobProperties?.accessTier {
            headers[.accessTier] = accessTier.rawValue
        }
        if let cacheControl = blobProperties?.cacheControl {
            headers[.blobCacheControl] = cacheControl
        }
        if let contentType = blobProperties?.contentType {
            headers[.blobContentType] = contentType
        }
        if let contentEncoding = blobProperties?.contentEncoding {
            headers[.blobContentEncoding] = contentEncoding
        }
        if let contentLanguage = blobProperties?.contentLanguage {
            headers[.blobContentLanguage] = contentLanguage
        }
        if let contentMD5 = blobProperties?.contentMD5 {
            headers[.blobContentMD5] = contentMD5
        }
        if let contentDisposition = blobProperties?.contentDisposition {
            headers[.blobContentDisposition] = contentDisposition
        }

        // Construct and send request
        let lookupList = buildLookupList()
        let encoding = String.Encoding.utf8
        guard let xmlString = try? lookupList.asXmlString(encoding: encoding) else {
            fatalError("Unable to serialize block list as XML string.")
        }
        let xmlData = xmlString.data(using: encoding)
        guard let request = try? HTTPRequest(method: .put, url: url, headers: headers, data: xmlData) else { return }
        request.add(queryParams: queryParams)
        let context = PipelineContext.of(keyValues: [
            ContextKey.allowedStatusCodes.rawValue: [201] as AnyObject
        ])

        client.request(request, context: context) { result, httpResponse in
            switch result {
            case let .failure(error):
                completion(.failure(error), httpResponse)
            case .success:
                guard let responseHeaders = httpResponse?.headers else {
                    let error = HTTPResponseError.general("No response received.")
                    completion(.failure(error), httpResponse)
                    return
                }
                let blobProperties = BlobProperties(from: responseHeaders)
                completion(.success(blobProperties), httpResponse)
            }
        }
    }

    /// Download the contents of this file to a stream.
    /// - Parameters:
    ///   - group: An optional `DispatchGroup` to wait for the download to complete.
    ///   - completion: A completion handler with which to process the downloaded chunk.
    public func next(inGroup group: DispatchGroup? = nil, then completion: @escaping HTTPResultHandler<Data>) {
        guard !isComplete else { return }
        let metadata = blockList.removeFirst()
        let range = metadata.range
        let blockId = metadata.blockId
        let uploader = ChunkUploader(
            blob: blobName,
            container: containerName,
            blockId: blockId,
            client: client,
            url: uploadSource,
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
            completion(result, httpResponse)
            group?.leave()
        }
    }

    // MARK: Private Methods

    private func buildLookupList() -> BlobLookupList {
        let sortedIds = completedBlockMap.sorted(by: { $0.value < $1.value })
        let lookupList = BlobLookupList(latest: sortedIds.compactMap { $0.key.uuidString.base64String })
        return lookupList
    }

    private func computeBlockList(withOffset offset: Int = 0) -> [(Range<Int>, UUID)] {
        var blockList = [(Range<Int>, UUID)]()
        let alignForCrypto = isEncrypted
        let chunkLength = client.options.maxChunkSize

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
        let error = HTTPResponseError.decode("Unable to parse content range: \(contentRange ?? "nil")")
        guard let contentRange = contentRange else { throw error }
        // split on slash and take the second half: "65537"
        guard let lengthString = contentRange.split(separator: "/", maxSplits: 1).last else { throw error }
        // Finally, convert to an Int: 65537
        guard let intVal = Int(String(lengthString)) else { throw error }
        return intVal
    }
}
