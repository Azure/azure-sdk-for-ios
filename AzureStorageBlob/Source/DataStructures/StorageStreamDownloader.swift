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

    public init(blob: String, container: String, client: StorageBlobClient, url: URL,
                startRange: Int, endRange: Int, options: DownloadBlobOptions) {
        self.blobName = blob
        self.containerName = container
        self.client = client
        self.options = options
        self.downloadDestination = url
        self.startRange = startRange
        self.endRange = endRange
    }

    // MARK: Public Methods

    public func download(requestId: String? = nil, completion: @escaping (Result<Data, Error>, HttpResponse) -> Void) {
        // Construct URL
        let urlTemplate = "/{container}/{blob}"
        let pathParams = [
            "container": containerName,
            "blob": blobName,
        ]
        let url = client.format(urlTemplate: urlTemplate, withKwargs: pathParams)

        // Construct parameters
        var queryParams = [String: String]()
        if let snapshot = options.snapshot { queryParams["snapshot"] = snapshot }
        if let timeout = options.timeout { queryParams["timeout"] = String(timeout) }

        // Construct headers
        var headerParams = HttpHeaders()
        headerParams[.apiVersion] = client.options.apiVersion
        headerParams[.accept] = "application/xml"
        let leaseAccessConditions = options.leaseAccessConditions
        let modifiedAccessConditions = options.modifiedAccessConditions
        let cpk = options.cpk

        headerParams["x-ms-range"] = "bytes=\(startRange)-\(endRange)"
        if let rangeGetContentMD5 = options.range?.calculateMD5 { headerParams["x-ms-range-get-content-md5"] = String(rangeGetContentMD5) }
        if let rangeGetContentCRC64 = options.range?.calculateCRC64 { headerParams["x-ms-range-get-content-crc64"] = String(rangeGetContentCRC64) }

        if let requestId = requestId { headerParams["x-ms-client-request-id"] = requestId }
        if let leaseId = leaseAccessConditions?.leaseId { headerParams["x-ms-lease-id"] = leaseId }
        if let encryptionKey = cpk?.value { headerParams["x-ms-encryption-key"] = String(data: encryptionKey, encoding: .utf8) }
        if let encryptionKeySHA256 = cpk?.hash { headerParams["x-ms-encryption-key-sha256"] = encryptionKeySHA256 }
        if let encryptionAlgorithm = cpk?.algorithm { headerParams["x-ms-encryption-algorithm"] = encryptionAlgorithm }
        if let ifModifiedSince = modifiedAccessConditions?.ifModifiedSince { headerParams[.ifModifiedSince] = ifModifiedSince.rfc1123Format }
        if let ifUnmodifiedSince = modifiedAccessConditions?.ifUnmodifiedSince { headerParams[.ifUnmodifiedSince] = ifUnmodifiedSince.rfc1123Format }
        if let ifMatch = modifiedAccessConditions?.ifMatch { headerParams[.ifMatch] = ifMatch }
        if let ifNoneMatch = modifiedAccessConditions?.ifNoneMatch { headerParams[.ifNoneMatch] = ifNoneMatch }

        // Construct and send request
        let request = client.request(method: HttpMethod.GET,
                                   url: url,
                                   queryParams: queryParams,
                                   headerParams: headerParams)
        let context: [String: AnyObject] = [
            ContextKey.allowedStatusCodes.rawValue: [200, 206] as AnyObject,
        ]
        client.run(request: request, context: context) { result, httpResponse in
            switch result {
            case let .failure(error):
                completion(.failure(error), httpResponse)
            case let .success(data):
                guard let data = data else {
                    completion(.failure(AzureError.general("Blob unexpectedly contained no data.")), httpResponse)
                    return
                }
                let headers = httpResponse.headers
                if let contentMD5 = headers["Content-MD5"] {
                    let dataHash = data.md5
                    guard contentMD5 == dataHash else {
                        let error = AzureError.general("Block MD5 \(dataHash) did not match \(contentMD5).")
                        completion(.failure(error), httpResponse)
                        return
                    }
                }
                if let contentCRC64 = headers["Content-CRC64"] {
                    let dataHash = data.crc64
                    guard contentCRC64 == dataHash else {
                        let error = AzureError.general("Block CRC64 \(dataHash) did not match \(contentCRC64).")
                        completion(.failure(error), httpResponse)
                        return
                    }
                }
                let decryptedData = self.decrypt(data)
                do {
                    let handle = try self.openFileForWriting()
                    let fileOffset = UInt64(self.startRange)
                    if #available(iOSApplicationExtension 13.0, *) {
                        try handle.seek(toOffset: fileOffset)
                    } else {
                        // Fallback on earlier versions
                        handle.seek(toFileOffset: fileOffset)
                    }
                    handle.write(decryptedData)
                    handle.closeFile()
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
public class StorageStreamDownloader {

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

    public var blockList = [Range<Int>]()

    public var isComplete: Bool {
        guard let total = self.requestedSize else { return false }
        return progress == total
    }

    public var isEncrypted: Bool {
        return options.encryptionOptions?.key != nil || options.encryptionOptions?.keyResolver != nil
    }

    // MARK: Internal Properties

    internal let client: StorageBlobClient

    internal let options: DownloadBlobOptions

    /// Size, in bytes, of the file to be downloaded.
    internal var fileSize: Int?

    // MARK: Initializers

    public init(client: StorageBlobClient, name: String, container: String, options: DownloadBlobOptions? = nil) throws {

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
        guard let defaultUrl = URL(string: "\(container)/\(name)", relativeTo: baseUrl) else {
            throw AzureError.general("Unable to determine URL.")
        }
        let defaultSubfolder = defaultUrl.deletingLastPathComponent().relativePath
        let defaultFilename = defaultUrl.lastPathComponent
        let customSubfolder = options?.destination?.subfolder
        let customFilename = options?.destination?.filename

        self.downloadDestination = baseUrl.appendingPathComponent(customSubfolder ?? defaultSubfolder).appendingPathComponent(customFilename ?? defaultFilename)
        if FileManager.default.fileExists(atPath: self.downloadDestination.path) {
            try? FileManager.default.removeItem(at: self.downloadDestination)
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

    /**
     Read and return the content of the downloaded file.
     - Returns: Downloaded data.
     */
    public func contents() throws -> Data {
        let handle = try FileHandle(forReadingFrom: downloadDestination)
        defer { handle.closeFile() }
        return handle.readDataToEndOfFile()
    }

    /**
     Downloads the entire blob in a parallel fashion.
     - Returns: Downloaded data.
     */
    public func complete(inGroup group: DispatchGroup? = nil) throws {
        guard !isComplete else { return }
        for _ in blockList {
            group?.enter()
            next(inGroup: group) { result, httpResponse in
                // Nothing to do here.
            }
        }
        group?.wait()
    }

    /**
     Download the contents of this file to a stream.
     - Parameter into: The file handle to download into.
     - Returns: The number of bytes read.
    */
    public func next(inGroup group: DispatchGroup? = nil, then completion: (Result<Data, Error>, HttpResponse) -> ()) {
        guard !isComplete else { return }
        let range = blockList.removeFirst()
        let downloader = ChunkDownloader(
            blob: blobName,
            container: containerName,
            client: client,
            url: downloadDestination,
            startRange: range.startIndex,
            endRange: range.endIndex,
            options: options)
        downloader.download() { result, httpResponse in
            switch result {
            case .success(_):
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

    /**
        Make the initial request for blob data.
        - Parameter then: A completion handler.
     */
    public func initialRequest(then completion: @escaping (Result<Data, Error>, HttpResponse) -> Void) {

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
        downloader.download() { result, httpResponse in
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
                        self.options.modifiedAccessConditions?.ifMatch = accessConditions?.ifMatch ?? blobProperties.eTag
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
        let chunkLength = alignForCrypto || validateContent ? client.options.maxChunkGetSize - 1 : client.options.maxSingleGetSize
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
                blockList.append(index..<end)
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
