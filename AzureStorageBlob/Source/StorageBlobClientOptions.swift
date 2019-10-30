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

public class StorageBlobClientOptions: AzureConfigurable {

    public let apiVersion: String
    public let logger: ClientLogger

    // Storage settings
    public let maxSinglePutSize = 64 * 1024 * 1024
    public let copyPollingInterval = 15

    // Block blob uploads
    public let maxBlockSize = 4 * 1024 * 1024
    public let minLargeBlockUploadThreshold = 4 * 1024 * 1024 + 1
    public let useByteBuffer = false

    // Blob downloads
    public let maxSingleGetSize = 32 * 1024 * 1024
    public let maxChunkGetSize = 4 * 1024 * 1024

    public init(apiVersion: String, logger: ClientLogger = ClientLoggers.default()) {
        self.apiVersion = apiVersion
        self.logger = logger
    }
}

public class ListContainersOptions: AzureOptions {
    /// Datasets which may be included as part of the call response.
    public enum ListContainersInclude: String {
        case metadata
    }

    /// Return only containers whose names begin with the specified prefix.
    public var prefix: String? = nil

    /// One or more datasets to include in the response.
    public var include: [ListContainersInclude]? = nil

    /// Maximum number of containers to return, up to 5000.
    public var maxResults: Int? = nil

    /// Request timeout in seconds.
    public var timeout: Int? = nil
}

public class ListBlobsOptions: AzureOptions {
    /// Datasets which may be included as part of the call response.
    public enum ListBlobsInclude: String {
        case snapshots, metadata, uncommittedblobs, copy, deleted
    }

    /// Return only blobs whose names begin with the specified prefix.
    public var prefix: String? = nil

    /// Operation returns a BlobPrefix element in the response body that acts as a placeholder for all
    /// blobs whose names begin with the same substring up to the appearance of the delimiter character.
    /// The delimiter may be a single charcter or a string.
    public var delimiter: String? = nil

    /// Maximum number of containers to return, up to 5000.
    public var maxResults: Int? = nil

    /// One or more datasets to include in the response.
    public var include: [ListBlobsInclude]? = nil

    /// Request timeout in seconds.
    public var timeout: Int? = nil
}

public class DownloadBlobOptions: AzureOptions {

    /// Options for working on a subset of data for a blob.
    public var range: RangeOptions? = nil

    /// If true, calculates an MD5 hash for each chunk of the blob. The storage
    /// service checks the hash of the content that has arrived with the hash
    /// that was sent. This is primarily valuable for detecting bitflips on
    /// the wire if using http instead of https, as https (the default), will
    /// already validate. Note that this MD5 hash is not stored with the
    /// blob. Also note that if enabled, the memory-efficient upload algorithm
    /// will not be used because computing the MD5 hash requires buffering
    /// entire blocks, and doing so defeats the purpose of the memory-efficient algorithm.
    public var validateContent: Bool = false

    /// Required if the blob has an active lease. If specified, download only
    /// succeeds if the blob's lease is active and matches this ID. Value can be a
    /// BlobLeaseClient object or the lease ID as a string.
    public var lease: Any? = nil

    /// A snapshot version for the blob being downloaded.
    public var snapshot: String? = nil

    /// Options for accessing a blob based on the condition of a lease.
    public var leaseAccessConditions: LeaseAccessConditions? = nil

    /// Options to set modifications on access according to whether the blob has/has not changed
    /// and based on the value of an eTag.
    public var modifiedAccessConditions: ModifiedAccessConditions? = nil

    /// Blob encryption options.
    public var encryptionOptions: EncryptionOptions? = nil

    /// Encrypts the data on the service-side with the given key.
    /// Use of customer-provided keys must be done over HTTPS.
    /// As the encryption key itself is provided in the request,
    /// a secure connection must be established to transfer the key.
    public var cpk: CustomerProvidedEncryptionKey? = nil

    /// The number of parallel connections with which to download.
    public var maxConcurrency: Int? = nil

    /// Encoding with which to decode the downloaded bytes. If nil, no decoding occurs.
    public var encoding: String? = nil

    /// The timeout parameter is expressed in seconds. This method may make
    /// multiple calls to the Azure service and the timeout will apply to
    /// each call individually.
    public var timeout: Int? = nil
}
