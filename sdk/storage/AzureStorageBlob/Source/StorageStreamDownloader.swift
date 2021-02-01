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

/// Class used to download an individual data chunk.
internal class ChunkDownloader {
    // MARK: Properties

    internal let client: StorageBlobClient

    internal let options: DownloadBlobOptions

    internal let downloadSource: URL

    internal let downloadDestination: URL

    internal var streamStart: UInt64?

    internal var startRange: Int

    internal var endRange: Int

    internal var isEncrypted: Bool {
        return options.encryptionOptions?.key != nil || options.encryptionOptions?.keyResolver != nil
    }

    // MARK: Initializers

    /// Creates a `ChunkDownloader` object.
    /// - Parameters:
    ///   - client: The `StorageBlobClient` that initiated the request.
    ///   - source: The location in Blob Storage of the file to download.
    ///   - destination: The location on the device of the file being downloaded.
    ///   - startRange: The start point, in bytes, of the download request.
    ///   - endRange: The end point, in bytes, of the download request.
    ///   - options: A `DownloadBlobOptions` object with which to control the download.
    public init(
        client: StorageBlobClient,
        source: URL,
        destination: URL,
        startRange: Int,
        endRange: Int,
        options: DownloadBlobOptions
    ) {
        self.client = client
        self.options = options
        self.downloadSource = source
        self.downloadDestination = destination
        self.startRange = startRange
        self.endRange = endRange
    }

    // MARK: Public Methods

    /// Begin the download process.
    /// - Parameters:
    ///   - requestId: Unique request ID (GUID) for the operation.
    ///   - completionHandler: A completion handler that forwards the downloaded data.
    public func download(requestId: String? = nil, completionHandler: @escaping HTTPResultHandler<Data>) {
        // Construct parameters & headers
        let queryParams = RequestParameters(
            (.query, "snapshot", options.snapshot, .encode),
            (.query, "timeout", options.timeout, .encode)
        )

        let headers = downloadHeadersForRequest(withId: requestId)

        // Construct and send request
        guard let requestUrl = downloadSource.appendingQueryParameters(queryParams) else { return }
        guard let request = try? HTTPRequest(method: .get, url: requestUrl, headers: headers) else { return }
        let context = PipelineContext.of(keyValues: [
            ContextKey.allowedStatusCodes.rawValue: [200, 206] as AnyObject
        ])
        context.add(cancellationToken: options.cancellationToken, applying: client.options)
        context.merge(with: options.context)
        client.request(request, context: context) { result, httpResponse in
            switch result {
            case let .failure(error):
                completionHandler(.failure(error), httpResponse)
            case let .success(data):
                guard let data = data else {
                    completionHandler(
                        .failure(AzureError.client("Blob unexpectedly contained no data.")),
                        httpResponse
                    )
                    return
                }
                guard let headers = httpResponse?.headers else {
                    completionHandler(.failure(AzureError.client("No response headers found.")), httpResponse)
                    return
                }
                if let contentMD5 = headers[.contentMD5] {
                    let dataHash = data.hash(algorithm: .md5).base64EncodedString()
                    guard contentMD5 == dataHash else {
                        let error = AzureError
                            .client("Block MD5 \(dataHash) did not match \(contentMD5).")
                        completionHandler(.failure(error), httpResponse)
                        return
                    }
                }
                if let contentCRC64 = headers[.contentCRC64] {
                    // TODO: Implement CRC64. Currently no iOS library supports this!
                    let dataHash = ""
                    guard contentCRC64 == dataHash else {
                        let error = AzureError
                            .client("Block CRC64 \(dataHash) did not match \(contentCRC64).")
                        completionHandler(.failure(error), httpResponse)
                        return
                    }
                }
                let decryptedData = self.decrypt(data)
                do {
                    let handle = try self.openFileForWriting()
                    defer { handle.closeFile() }
                    let fileOffset = UInt64(self.startRange)
                    if #available(iOS 13.0, *) {
                        try handle.seek(toOffset: fileOffset)
                    } else {
                        // Fallback on earlier versions
                        handle.seek(toFileOffset: fileOffset)
                    }
                    handle.write(decryptedData)

                    completionHandler(.success(decryptedData), httpResponse)
                } catch {
                    completionHandler(.failure(AzureError.client("File error.", error)), httpResponse)
                }
            }
        }
    }

    // MARK: Private Methods

    // swiftlint:disable:next cyclomatic_complexity
    private func downloadHeadersForRequest(withId requestId: String?) -> HTTPHeaders {
        let leaseAccessConditions = options.leaseAccessConditions
        let modifiedAccessConditions = options.modifiedAccessConditions
        let cpk = options.customerProvidedEncryptionKey

        let headers = RequestParameters(
            (.header, HTTPHeader.accept, "application/xml", .encode),
            (.header, HTTPHeader.apiVersion, client.options.apiVersion, .encode),
            (.header, HTTPHeader.range, "bytes=\(startRange)-\(endRange)", .encode),
            (.header, HTTPHeader.clientRequestId, requestId, .encode),
            (.header, HTTPHeader.ifModifiedSince, modifiedAccessConditions?.ifModifiedSince, .encode),
            (.header, HTTPHeader.ifUnmodifiedSince, modifiedAccessConditions?.ifUnmodifiedSince, .encode),
            (.header, HTTPHeader.ifMatch, modifiedAccessConditions?.ifMatch, .encode),
            (.header, HTTPHeader.ifNoneMatch, modifiedAccessConditions?.ifNoneMatch, .encode),
            (.header, StorageHTTPHeader.rangeGetContentMD5, options.range?.calculateMD5, .encode),
            (.header, StorageHTTPHeader.rangeGetContentCRC64, options.range?.calculateCRC64, .encode),
            (.header, StorageHTTPHeader.leaseId, leaseAccessConditions?.leaseId, .encode),
            (.header, StorageHTTPHeader.encryptionKey, cpk?.keyData, .encode),
            (.header, StorageHTTPHeader.encryptionKeySHA256, cpk?.hash, .encode),
            (.header, StorageHTTPHeader.encryptionAlgorithm, cpk?.algorithm, .encode)
        )
        return headers.headers
    }

    private func decrypt(_ data: Data) -> Data {
        guard isEncrypted else { return data }
        // TODO: Implement client-side decryption.
        fatalError("Client-side encryption is not currently supported!")
    }

    private func openFileForWriting() throws -> FileHandle {
        let dirPath = downloadDestination.deletingLastPathComponent()
        let manager = FileManager.default
        try manager.createDirectory(atPath: dirPath.path, withIntermediateDirectories: true, attributes: nil)
        if !manager.fileExists(atPath: downloadDestination.path) {
            manager.createFile(atPath: downloadDestination.path, contents: nil, attributes: nil)
        }
        return try FileHandle(forWritingTo: downloadDestination)
    }
}

/// A delegate to receive notifications about state changes from `BlobDownloader` objects.
public protocol BlobDownloadDelegate: AnyObject {
    /// A download's progress has updated.
    func downloader(_: BlobDownloader, didUpdateWithProgress: TransferProgress)
    /// A download has failed.
    func downloader(_: BlobDownloader, didFailWithError: Error)
    /// A download has completed.
    func downloaderDidComplete(_: BlobDownloader)
}

/// An object that contains details about a download operation.
public protocol BlobDownloader {
    /// The `BlobDownloadDelegate` to inform about download events.
    var delegate: BlobDownloadDelegate? { get set }

    /// Location in Blob Storage of the file to download.
    var downloadSource: URL { get }

    /// Location on the device of the file being downloaded.
    var downloadDestination: URL { get }

    /// Properties applied to the source blob.
    var blobProperties: BlobProperties? { get }

    /// Size, in bytes, of the portion of the source blob being downloaded. If the `DownloadBlobOptions.range` option
    /// was not used, this will be the same as the total size of the blob.
    var requestedSize: Int? { get }

    /// Total size, in bytes, of the source blob.
    var totalSize: Int { get }

    /// The total bytes downloaded.
    var progress: Int { get }

    /// Indicates if the download is complete.
    var isComplete: Bool { get }

    /// Indicates if the download is encrypted.
    var isEncrypted: Bool { get }
}

/// Class used to download streaming blobs.
internal class BlobStreamDownloader: BlobDownloader {
    // MARK: Properties

    public weak var delegate: BlobDownloadDelegate?

    /// Location in Blob Storage of the file to download.
    public let downloadSource: URL

    /// Location on the device of the file being downloaded.
    public let downloadDestination: URL

    /// Properties applied to the source blob.
    public var blobProperties: BlobProperties?

    /// Size, in bytes, of the portion of the source blob being downloaded. If the `DownloadBlobOptions.range` option
    /// was not used, this will be the same as the total size of the blob.
    public var requestedSize: Int?

    /// Total size, in bytes, of the source blob.
    public var totalSize: Int

    /// The total bytes downloaded.
    public var progress = 0

    /// The list of blocks for the blob download.
    public var blockList = [Range<Int>]()

    /// Indicates if the download is complete.
    public var isComplete: Bool {
        guard let requested = requestedSize else { return false }
        return progress == requested
    }

    /// Indicates if the download is encrypted.
    public var isEncrypted: Bool {
        return options.encryptionOptions?.key != nil || options.encryptionOptions?.keyResolver != nil
    }

    internal let client: StorageBlobClient

    internal var options: DownloadBlobOptions

    // MARK: Initializers

    /// Create a `BlobStreamDownloader` object.
    /// - Parameters:
    ///   - client: A`StorageBlobClient` reference.
    ///   - delegate: A `BlobDownloadDelegate` to notify about the progress of the download.
    ///   - source: The location in Blob Storage of the file to download.
    ///   - destination: The location on the device of the file being downloaded.
    ///   - options: A `DownloadBlobOptions` object to control the download process.
    public init(
        client: StorageBlobClient,
        delegate: BlobDownloadDelegate? = nil,
        source: URL,
        destination: LocalURL,
        options: DownloadBlobOptions
    ) throws {
        guard let downloadDestination = destination.resolvedUrl else {
            throw AzureError.client("Unable to determine download destination: \(destination)")
        }

        self.downloadDestination = downloadDestination
        self.client = client
        self.delegate = delegate
        self.options = options
        self.downloadSource = source
        self.requestedSize = self.options.range?.lengthInBytes
        self.blobProperties = nil
        self.totalSize = -1
        self.blockList = computeBlockList()
    }

    // MARK: Public Methods

    /// Read and return the content of the downloaded file.
    public func contents() throws -> Data {
        let handle = try FileHandle(forReadingFrom: downloadDestination)
        defer { handle.closeFile() }
        return handle.readDataToEndOfFile()
    }

    /// Downloads the entire blob in a parallel fashion.
    /// - Parameters:
    ///   - group: An optional `DispatchGroup` to wait for the download to complete.
    ///   - completionHandler: A completion handler called when the download completes.
    public func complete(inGroup group: DispatchGroup? = nil, completionHandler: @escaping () -> Void) throws {
        guard !isComplete else {
            if let delegate = self.delegate {
                delegate.downloaderDidComplete(self)
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
                    let progress = TransferProgress(bytes: self.progress, totalBytes: self.requestedSize!)
                    delegate.downloader(self, didUpdateWithProgress: progress)
                }
            }
        }
        dispatchGroup.notify(queue: DispatchQueue.main) {
            if let delegate = self.delegate {
                delegate.downloaderDidComplete(self)
            } else {
                completionHandler()
            }
        }
    }

    /// Download the contents of this file to a stream.
    /// - Parameters:
    ///   - group: An optional `DispatchGroup` to wait for the download to complete.
    ///   - completionHandler: A completion handler with which to process the downloaded chunk.
    public func next(inGroup group: DispatchGroup? = nil, completionHandler: @escaping HTTPResultHandler<Data>) {
        guard !isComplete else { return }
        let range = blockList.removeFirst()
        let downloader = ChunkDownloader(
            client: client,
            source: downloadSource,
            destination: downloadDestination,
            startRange: range.startIndex,
            endRange: range.endIndex,
            options: options
        )
        downloader.download { result, httpResponse in
            switch result {
            case .success:
                guard let responseHeaders = httpResponse?.headers else {
                    completionHandler(.failure(AzureError.client("No response headers found.")), httpResponse)
                    return
                }
                let blobProperties = BlobProperties(from: responseHeaders)
                let contentLength = blobProperties.contentLength ?? 0
                self.progress += contentLength
            case let .failure(error):
                self.client.options.logger.debug(String(describing: error))
            }
            completionHandler(result, httpResponse)
            group?.leave()
        }
    }

    /// Make the initial request for blob data.
    /// - Parameter completionHandler: A completion handler with which to process the downloaded chunk.
    public func initialRequest(completionHandler: @escaping HTTPResultHandler<Data>) {
        let firstRange = blockList.remove(at: 0)
        let downloader = ChunkDownloader(
            client: client,
            source: downloadSource,
            destination: downloadDestination,
            startRange: firstRange.startIndex,
            endRange: firstRange.endIndex,
            options: options
        )
        downloader.download { result, httpResponse in
            switch result {
            case let .success(data):
                // Parse the total file size and adjust the download size if ranges
                // were specified
                guard let responseHeaders = httpResponse?.headers else {
                    completionHandler(.failure(AzureError.client("No response headers found.")), httpResponse)
                    return
                }
                let contentRange = responseHeaders[.contentRange]
                let blobProperties = BlobProperties(from: responseHeaders)

                // Only block blobs are currently supported
                guard blobProperties.blobType == BlobType.block else {
                    let error = AzureError.client("Page and Append blobs are not currently supported by this library.")
                    completionHandler(.failure(error), httpResponse)
                    return
                }

                do {
                    // extract the file size from the content range. If a specific size request was
                    // not made, then the request is for the entire file.
                    let blobSize = try self.parseLength(fromContentRange: contentRange)
                    self.totalSize = blobSize - 1
                    self.progress += blobProperties.contentLength ?? 0
                    self.blobProperties = blobProperties

                    // if the requestedSize was not specfied, the block list will need to be recomputed
                    // based on the actual file size.
                    var recomputeBlockList = self.requestedSize == nil
                    self.requestedSize = (self.requestedSize ?? blobSize) - (self.options.range?.offsetBytes ?? 0)

                    // If the file is small, the download is complete at this point.
                    // If file size is large, download the rest of the file in chunks.
                    if !self.isComplete {
                        // Lock on the etag. This can be overriden by the user by specifying '*'
                        let accessConditions = self.options.modifiedAccessConditions
                        self.options.modifiedAccessConditions?.ifMatch = accessConditions?.ifMatch
                            ?? blobProperties.eTag
                    } else {
                        // if the download is done, there's no need to recompute the block list, even if
                        // the file size was not initially known
                        recomputeBlockList = false
                    }

                    // Set the content length to the download size instead of the size of
                    // the last range.
                    let chunkSize = blobProperties.contentLength
                    self.blobProperties?.contentLength = self.requestedSize

                    if recomputeBlockList, let contentLength = chunkSize {
                        self.blockList = self.computeBlockList(withOffset: contentLength)
                    }
                    completionHandler(.success(data), httpResponse)
                } catch {
                    completionHandler(.failure(AzureError.client("Parse error.", error)), httpResponse)
                }
            case let .failure(error):
                completionHandler(.failure(error), httpResponse)
            }
        }
    }

    // MARK: Private Methods

    private func computeBlockList(withOffset offset: Int = 0) -> [Range<Int>] {
        var blockList = [Range<Int>]()
        let alignForCrypto = isEncrypted
        let chunkLength = client.options.maxChunkSizeInBytes
        let start = (options.range?.offsetBytes ?? 0) + offset
        let length = (requestedSize ?? options.range?.lengthInBytes ?? chunkLength) - start
        let end = start + length

        if alignForCrypto {
            fatalError("Client-side encryption is not yet supported!")
        } else {
            for index in stride(from: start, to: end, by: chunkLength) {
                var blockEnd = index + chunkLength
                if totalSize < 0 {
                    blockEnd = chunkLength
                } else if blockEnd > totalSize {
                    blockEnd = totalSize
                }
                blockList.append(index ..< blockEnd)
            }
        }
        return blockList
    }

    /// Parses the blob length from the content range header: bytes 1-3/65537
    private func parseLength(fromContentRange contentRange: String?) throws -> Int {
        let error = AzureError.client("Unable to parse content range: \(contentRange ?? "nil")")
        guard let contentRange = contentRange else { throw error }
        // First, split in space and take the second half: "1-3/65537"
        guard let byteString = contentRange.split(separator: " ", maxSplits: 1).last else { throw error }
        // Next, split on slash and take the second half: "65537"
        guard let lengthString = String(byteString).split(separator: "/", maxSplits: 1).last else { throw error }
        // Finally, convert to an Int: 65537
        guard let intVal = Int(String(lengthString)) else { throw error }
        return intVal
    }
}
