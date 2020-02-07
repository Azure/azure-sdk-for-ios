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

/// Class used to download an individual data chunk.
internal class ChunkDownloader {
    // MARK: Properties

    internal let blobName: String

    internal let containerName: String

    internal let client: StorageBlobClient

    internal let options: DownloadBlobOptions

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
    ///   - blob: The name of the blob.
    ///   - container: The name of the stoarge container in which the blob is located is located.
    ///   - client: The `StorageBlobClient` that initiated the request.
    ///   - url: The URL to the blob object.
    ///   - startRange: The start point, in bytes, of the download request.
    ///   - endRange: The end point, in bytes, of the download request.
    ///   - options: A `DownloadBlobOptions` object with which to control the download.
    public init(
        blob: String,
        container: String,
        client: StorageBlobClient,
        url: URL,
        startRange: Int,
        endRange: Int,
        options: DownloadBlobOptions
    ) {
        self.blobName = blob
        self.containerName = container
        self.client = client
        self.options = options
        self.downloadDestination = url
        self.startRange = startRange
        self.endRange = endRange
    }

    // MARK: Public Methods

    /// Begin the download process.
    /// - Parameters:
    ///   - requestId: Unique request ID (GUID) for the operation.
    ///   - completion: A completion handler that forwards the downloaded data.
    public func download(requestId: String? = nil, completion: @escaping HTTPResultHandler<Data>) {
        // Construct URL
        let urlTemplate = "/{container}/{blob}"
        let pathParams = [
            "container": containerName,
            "blob": blobName
        ]
        let url = client.url(forTemplate: urlTemplate, withKwargs: pathParams)

        // Construct parameters
        var queryParams = [QueryParameter]()
        if let snapshot = options.snapshot { queryParams.append("snapshot", snapshot) }
        if let timeout = options.timeout { queryParams.append("timeout", String(timeout)) }

        // Construct headers
        var headers = HTTPHeaders([
            .accept: "application/xml",
            .apiVersion: client.options.apiVersion
        ])
        let leaseAccessConditions = options.leaseAccessConditions
        let modifiedAccessConditions = options.modifiedAccessConditions
        let cpk = options.cpk

        headers["x-ms-range"] = "bytes=\(startRange)-\(endRange)"
        if let rangeGetContentMD5 = options.range?.calculateMD5 {
            headers["x-ms-range-get-content-md5"] = String(rangeGetContentMD5)
        }
        if let rangeGetContentCRC64 = options.range?.calculateCRC64 {
            headers["x-ms-range-get-content-crc64"] = String(rangeGetContentCRC64)
        }

        if let requestId = requestId { headers["x-ms-client-request-id"] = requestId }
        if let leaseId = leaseAccessConditions?.leaseId { headers["x-ms-lease-id"] = leaseId }
        if let encryptionKey = cpk?.value {
            headers["x-ms-encryption-key"] = String(data: encryptionKey, encoding: .utf8)
        }
        if let encryptionKeySHA256 = cpk?.hash { headers["x-ms-encryption-key-sha256"] = encryptionKeySHA256 }
        if let encryptionAlgorithm = cpk?.algorithm { headers["x-ms-encryption-algorithm"] = encryptionAlgorithm }
        if let ifModifiedSince = modifiedAccessConditions?.ifModifiedSince {
            headers[.ifModifiedSince] = String(describing: ifModifiedSince, format: .rfc1123)
        }
        if let ifUnmodifiedSince = modifiedAccessConditions?.ifUnmodifiedSince {
            headers[.ifUnmodifiedSince] = String(describing: ifUnmodifiedSince, format: .rfc1123)
        }
        if let ifMatch = modifiedAccessConditions?.ifMatch { headers[.ifMatch] = ifMatch }
        if let ifNoneMatch = modifiedAccessConditions?.ifNoneMatch { headers[.ifNoneMatch] = ifNoneMatch }

        // Construct and send request
        let request = HTTPRequest(method: .get, url: url, headers: headers)
        request.add(queryParams: queryParams)
        let context = PipelineContext.of(keyValues: [
            ContextKey.allowedStatusCodes.rawValue: [200, 206] as AnyObject
        ])
        client.request(request, context: context) { result, httpResponse in
            switch result {
            case let .failure(error):
                completion(.failure(error), httpResponse)
            case let .success(data):
                guard let data = data else {
                    completion(.failure(AzureError.general("Blob unexpectedly contained no data.")), httpResponse)
                    return
                }
                let headers = httpResponse.headers
                if let contentMD5 = headers[.contentMD5] {
                    let dataHash = try? data.hash(algorithm: .md5).base64String
                    guard contentMD5 == dataHash else {
                        let error = AzureError.general("Block MD5 \(dataHash ?? "ERROR") did not match \(contentMD5).")
                        completion(.failure(error), httpResponse)
                        return
                    }
                }
                if let contentCRC64 = headers[.contentCRC64] {
                    // TODO: Implement CRC64. Currently no iOS library supports this!
                    let dataHash = ""
                    guard contentCRC64 == dataHash else {
                        let error = AzureError.general("Block CRC64 \(dataHash) did not match \(contentCRC64).")
                        completion(.failure(error), httpResponse)
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
                    completion(.success(decryptedData), httpResponse)
                } catch {
                    completion(.failure(error), httpResponse)
                }
            }
        }
    }

    // MARK: Private Methods

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

/// Class used to download streaming blobs.
public class BlobStreamDownloader {
    // MARK: Public Properties

    /// Location of the downloaded blob on the device
    public let downloadDestination: URL

    /// Name of the blob being downloaded
    public let blobName: String

    /// Name of the container containing the blob
    public let containerName: String

    /// Properties of the blob being downloaded.
    public var blobProperties: BlobProperties?

    /// The size of the total data in the stream. This will be the byte range, if specified,
    /// or the total size of the blob.
    public var requestedSize: Int?

    /// The total bytes downloaded.
    public var progress = 0

    /// The list of blocks for the blob download.
    public var blockList = [Range<Int>]()

    /// Indicates if the download is complete.
    public var isComplete: Bool {
        guard let total = requestedSize else { return false }
        return progress == total
    }

    /// Indicates if the download is encrypted.
    public var isEncrypted: Bool {
        return options.encryptionOptions?.key != nil || options.encryptionOptions?.keyResolver != nil
    }

    // MARK: Internal Properties

    internal let client: StorageBlobClient

    internal let options: DownloadBlobOptions

    /// Size, in bytes, of the file to be downloaded.
    internal var fileSize: Int?

    // MARK: Initializers

    /// Create a `BlobStreamDownloader` object.
    /// - Parameters:
    ///   - client: A`StorageBlobClient` reference.
    ///   - name: The name of the blob to download.
    ///   - container: The name of the container the blob is contained in.
    ///   - options: A `DownloadBlobOptions` object to control the download process.
    public init(
        client: StorageBlobClient,
        name: String,
        container: String,
        options: DownloadBlobOptions? = nil
    ) throws {
        // determine which app folder is appropriate
        let isTemporary = options?.destination?.isTemporary ?? false
        var baseUrl: URL
        if isTemporary {
            baseUrl = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        } else {
            guard let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
                throw AzureError.general("Unable to find cache directory.")
            }
            baseUrl = cacheDir
        }

        // attribute the "meta-folder" part of the blob name to the subfolder
        var defaultUrlComps = "\(container)/\(name)".split(separator: "/").compactMap { String($0) }
        let defaultFilename = defaultUrlComps.popLast()!
        let defaultSubfolder = defaultUrlComps.joined(separator: "/")
        let customSubfolder = options?.destination?.subfolder
        let customFilename = options?.destination?.filename

        self.downloadDestination = baseUrl.appendingPathComponent(customSubfolder ?? defaultSubfolder)
            .appendingPathComponent(customFilename ?? defaultFilename)
        if FileManager.default.fileExists(atPath: downloadDestination.path) {
            try? FileManager.default.removeItem(at: downloadDestination)
        }

        self.client = client
        self.options = options ?? DownloadBlobOptions()
        self.blobName = name
        self.containerName = container
        self.requestedSize = self.options.range?.length
        self.blobProperties = nil
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
    ///   - completion: A completion handler called when the download completes.
    public func complete(inGroup group: DispatchGroup? = nil, then completion: @escaping () -> Void) throws {
        guard !isComplete else {
            completion()
            return
        }
        for _ in blockList {
            group?.enter()
            next(inGroup: group) { _, _ in
                // Nothing to do here.
            }
        }
        group?.notify(queue: DispatchQueue.main) {
            completion()
        }
    }

    /// Download the contents of this file to a stream.
    /// - Parameters:
    ///   - group: An optional `DispatchGroup` to wait for the download to complete.
    ///   - completion: A completion handler with which to process the downloaded chunk.
    public func next(inGroup group: DispatchGroup? = nil, then completion: HTTPResultHandler<Data>) {
        // TODO: Fix not calling completion handler
        guard !isComplete else { return }
        let range = blockList.removeFirst()
        let downloader = ChunkDownloader(
            blob: blobName,
            container: containerName,
            client: client,
            url: downloadDestination,
            startRange: range.startIndex,
            endRange: range.endIndex,
            options: options
        )
        downloader.download { result, httpResponse in
            switch result {
            case .success:
                let responseHeaders = httpResponse.headers
                let blobProperties = BlobProperties(from: responseHeaders)
                let contentLength = blobProperties.contentLength ?? 0
                let data = httpResponse.data ?? "".data(using: .utf8)!
                self.progress += contentLength
                self.options.progressCallback?(self.progress, self.requestedSize ?? -1, data)
            case let .failure(error):
                self.client.options.logger.debug(String(describing: error))
            }
            group?.leave()
        }
    }

    /// Make the initial request for blob data.
    /// - Parameter completion: A completion handler with which to process the downloaded chunk.
    public func initialRequest(then completion: @escaping HTTPResultHandler<Data>) {
        let firstRange = blockList.remove(at: 0)
        let downloader = ChunkDownloader(
            blob: blobName,
            container: containerName,
            client: client,
            url: downloadDestination,
            startRange: firstRange.startIndex,
            endRange: firstRange.endIndex,
            options: options
        )
        downloader.download { result, httpResponse in
            switch result {
            case let .success(data):
                // Parse the total file size and adjust the download size if ranges
                // were specified
                let responseHeaders = httpResponse.headers
                let contentRange = responseHeaders[.contentRange]
                let blobProperties = BlobProperties(from: responseHeaders)

                // Only block blobs are currently supported
                guard blobProperties.blobType == BlobType.block else {
                    let error = AzureError.general(
                        "Page and Append blobs are not currently supported by this library.")
                    completion(.failure(error), httpResponse)
                    return
                }

                do {
                    // extract the file size from the content range. If a specific size request was
                    // not made, then the request is for the entire file.
                    let fileSize = try self.parseLength(fromContentRange: contentRange)
                    self.fileSize = fileSize
                    self.progress += blobProperties.contentLength ?? 0
                    self.blobProperties = blobProperties

                    // if the requestedSize was not specfied, the block list will need to be recomputed
                    // based on the actual file size.
                    var recomputeBlockList = self.requestedSize == nil
                    self.requestedSize = (self.requestedSize ?? fileSize) - (self.options.range?.offset ?? 0)
                    self.options.progressCallback?(self.progress, self.requestedSize ?? -1, data)

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
                    completion(.success(data), httpResponse)
                } catch {
                    completion(.failure(error), httpResponse)
                }
            case let .failure(error):
                completion(.failure(error), httpResponse)
            }
        }
    }

    // MARK: Private Methods

    private func computeBlockList(withOffset offset: Int = 0) -> [Range<Int>] {
        var blockList = [Range<Int>]()
        let alignForCrypto = isEncrypted
        let validateContent = options.range?.calculateMD5 == true || options.range?.calculateCRC64 == true
        let chunkLength = alignForCrypto || validateContent
            ? client.options.maxChunkGetSize - 1
            : client.options.maxSingleGetSize
        let start = (options.range?.offset ?? 0) + offset
        let length = (requestedSize ?? options.range?.length ?? chunkLength) - start
        let end = start + length

        if alignForCrypto {
            fatalError("Client-side encryption is not yet supported!")
        } else {
            for index in stride(from: start, to: end, by: chunkLength) {
                var end = index + chunkLength
                if let fileSize = fileSize, end > fileSize {
                    end = fileSize
                }
                blockList.append(index ..< end)
            }
        }
        return blockList
    }

    /// Parses the blob length from the content range header: bytes 1-3/65537
    private func parseLength(fromContentRange contentRange: String?) throws -> Int {
        let error = AzureError.general("Unable to parse content range: \(contentRange ?? "nil")")
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
