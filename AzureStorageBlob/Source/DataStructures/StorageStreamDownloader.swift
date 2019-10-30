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
                startRange: Int,endRange: Int, options: DownloadBlobOptions) {
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
        guard let encryption = options.encryptionOptions else { return data }
        // TODO: Implement blob decryption
        //        try:
        //            content = b"".join(list(data))
        //        except Exception as error:
        //            raise HttpResponseError(message="Download stream interrupted.", response=data.response, error=error)

        //            try:
        //                return decrypt_blob(
        //                    encryption.get("required"),
        //                    encryption.get("key"),
        //                    encryption.get("resolver"),
        //                    content,
        //                    start_offset,
        //                    end_offset,
        //                    data.response.headers,
        //                )
        //            except Exception as error:
        //                raise HttpResponseError(message="Decryption failed.", response=data.response, error=error)
        return data
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

    /// Determine whether the download is to a temporary or permanent file.
    public let isTemporary: Bool = false

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

        // Determine the destination URL of the downloaded blob
        if isTemporary {
            guard let temporaryUrl = FileManager.default.urls(for: .itemReplacementDirectory, in: .userDomainMask).first else {
                throw AzureError.general("Unable to find user temp directory.")
            }
            self.downloadDestination = temporaryUrl.appendingPathComponent(container).appendingPathComponent(name)
        } else {
            guard let documentsUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
                throw AzureError.general("Unable to find user cache directory.")
            }
            self.downloadDestination = documentsUrl.appendingPathComponent(container).appendingPathComponent(name)
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
    public func readContents() throws -> Data {
        let handle = try FileHandle(forReadingFrom: downloadDestination)
        return handle.readDataToEndOfFile()
    }

    /**
     Download the entire blob in blocking fashion.
     - Returns: Downloaded data.
     */
    public func readAll() throws -> Data {
        if isComplete {
            let handle = try FileHandle(forReadingFrom: downloadDestination)
            defer { handle.closeFile() }
            return handle.readDataToEndOfFile()
        }

        let group = DispatchGroup()
        for range in blockList {
            group.enter()
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
                case let .success(data):
                    let responseHeaders = httpResponse.headers
                    let contentRange = responseHeaders[.contentRange]
                    let blobProperties = BlobProperties(from: responseHeaders)
                    self.progress += blobProperties.contentLength ?? 0
                case let .failure(error):
                    let test = "best"
                }
                group.leave()
            }
        }
        group.wait()
        let handle = try FileHandle(forReadingFrom: downloadDestination)
        defer { handle.closeFile() }
        return handle.readDataToEndOfFile()
    }

    /**
     Download the contents of this file to a stream.
     - Parameter stream: The stream to download to.
     - Returns: The number of bytes read.
    */
//    public func read(into handle: FileHandle) -> Int {
//        // The stream must be seekable if parallel download is required
//        let maxConcurrency = options.maxConcurrency ?? 1
//        let parallel = maxConcurrency > 1
//
//        // Write the content to the user stream
//        guard let data = currentContent else { return 0 }
//        handle.write(data)
//        // if download is complete, we're done
//        if isComplete {
//            return size ?? 0
//        }
//        // otherwise, set up to download the next chunk
//        var dataEnd = size ?? 0
//        if let endRange = endRange {
//            // Use the length unless it is over the end of the file
//            dataEnd = min(size ?? 0, endRange + 1)
//        }
//        let test = "best"
//        let downloader = ChunkDownloader(
//            client: client,
//            totalSize: size ?? 0,
//            chunkSize: client.options.maxChunkGetSize,
//            currentProgress: firstGetSize,
//            startRange: (downloadRange.upper ?? 0) + 1,
//            endRange: dataEnd,
//            handle: handle,
//            parallel: parallel
//            //            non_empty_ranges=self._non_empty_ranges,
//            //            use_location=self._location_mode,
//            //            **self._request_options
//        )
//        if parallel {
//            let test = "best"
////            executor = concurrent.futures.ThreadPoolExecutor(self._max_concurrency)
////            list(executor.map(
////                    with_current_context(downloader.process_chunk),
////                    downloader.get_chunk_offsets()
////                ))
//        } else {
//            for offset in downloader.chunkOffsets {
//                downloader.execute(fromOffset: offset)
//            }
//        }
//        return size ?? 0
//    }

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

                    // Overwrite the content MD5 as it is the MD5 for the last range instead
                    // of the stored MD5
                    // TODO: Set to the stored MD5 when the service returns this
                    // self.blobProperties?.contentMD5 = nil
                    completion(.success(data), httpResponse)
                } catch {
                    completion(.failure(error), httpResponse)
                }
            case let .failure(error as HttpResponseError):
                if httpResponse.statusCode == 416 {
                    // Get range will fail on an empty file. If the user did not
                    // request a range, do a regular get request in order to get
                    // any properties.
//                    do {
//                        self.download(
//                            range: nil,
//                            rangeGetContentMD5: false
//                            // TODO: Resolve
//                            // dataStreamTotal: 0,
//                            // downloadStreamCurrent: 0
//                        ) { result, response in
//                            let test = "best"
//                        }
//                    } catch let error as HttpResponseError {
//                        self.process(storageError: error)
//                    }
//                    // Set the download size to empty
//                    self.size = 0
//                    self.fileSize = 0
                } else {
                    self.process(storageError: error)
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
        let chunkLength = alignForCrypto || validateContent ? client.options.maxChunkGetSize : client.options.maxSingleGetSize
        let start = (options.range?.offset ?? 0) + offset
        let length = (requestedSize ?? options.range?.length ?? chunkLength) - start
        let end = start + length

        if alignForCrypto {
            //                // Align the start of the range along a 16 byte block
            //                offsetRange.lower = downloadRange.from! % 16
            //                downloadRange.from! -= offsetRange.lower
            //
            //                    // Include an extra 16 bytes for the IV if necessary
            //                    // Because of the previous offsetting, startRange will always
            //                    // be a multiple of 16.
            //                    if downloadRange.from! > 0 {
            //                        offsetRange.lower += 16
            //                        downloadRange.from! -= 16
            //                    }
            //                }
            //                let length = downloadRange.to - downloadRange.from
            //                if length != nil, downloadRange.upper != nil {
            //                    // Align the end of the range along a 16 byte block
            //                    downloadRange.upper = 15 - (downloadRange.upper! % 16)
            //                    downloadRange.upper! += offsetRange.upper
            //                }
            for index in stride(from: start, to: end, by: chunkLength) {
                let end = index + chunkLength
                blockList.append(index..<end)
            }
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

    /// Process errors returned by the Azure Storage service.
    private func process(storageError error: HttpResponseError) {
        // TODO: Convert from Python...
    //    raise_error = HttpResponseError
    //    error_code = storage_error.response.headers.get('x-ms-error-code')
    //    error_message = storage_error.message
    //    additional_data = {}
    //    try:
    //        error_body = ContentDecodePolicy.deserialize_from_http_generics(storage_error.response)
    //        if error_body:
    //            for info in error_body.iter():
    //                if info.tag.lower() == 'code':
    //                    error_code = info.text
    //                elif info.tag.lower() == 'message':
    //                    error_message = info.text
    //                else:
    //                    additional_data[info.tag] = info.text
    //    except DecodeError:
    //        pass
    //
    //    try:
    //        if error_code:
    //            error_code = StorageErrorCode(error_code)
    //            if error_code in [StorageErrorCode.condition_not_met,
    //                              StorageErrorCode.blob_overwritten]:
    //                raise_error = ResourceModifiedError
    //            if error_code in [StorageErrorCode.invalid_authentication_info,
    //                              StorageErrorCode.authentication_failed]:
    //                raise_error = ClientAuthenticationError
    //            if error_code in [StorageErrorCode.resource_not_found,
    //                              StorageErrorCode.cannot_verify_copy_source,
    //                              StorageErrorCode.blob_not_found,
    //                              StorageErrorCode.queue_not_found,
    //                              StorageErrorCode.container_not_found,
    //                              StorageErrorCode.parent_not_found,
    //                              StorageErrorCode.share_not_found]:
    //                raise_error = ResourceNotFoundError
    //            if error_code in [StorageErrorCode.account_already_exists,
    //                              StorageErrorCode.account_being_created,
    //                              StorageErrorCode.resource_already_exists,
    //                              StorageErrorCode.resource_type_mismatch,
    //                              StorageErrorCode.blob_already_exists,
    //                              StorageErrorCode.queue_already_exists,
    //                              StorageErrorCode.container_already_exists,
    //                              StorageErrorCode.container_being_deleted,
    //                              StorageErrorCode.queue_being_deleted,
    //                              StorageErrorCode.share_already_exists,
    //                              StorageErrorCode.share_being_deleted]:
    //                raise_error = ResourceExistsError
    //    except ValueError:
    //        # Got an unknown error code
    //        pass
    //
    //    try:
    //        error_message += "\nErrorCode:{}".format(error_code.value)
    //    except AttributeError:
    //        error_message += "\nErrorCode:{}".format(error_code)
    //    for name, info in additional_data.items():
    //        error_message += "\n{}:{}".format(name, info)
    //
    //    error = raise_error(message=error_message, response=storage_error.response)
    //    error.error_code = error_code
    //    error.additional_info = additional_data
    //    raise error
    }
}
