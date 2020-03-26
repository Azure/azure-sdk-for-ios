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

/// User-configurable options for the Azure Storage blob client.
public class StorageBlobClientOptions: AzureConfigurable {
    public let apiVersion: String
    public let logger: ClientLogger
    public let tag: String

    // Storage settings
    public let maxSinglePutSize = 64 * 1024 * 1024
    public let copyPollingInterval = 15

    // Block blob uploads
    public let maxChunkSize = 4 * 1024 * 1024
    public let minLargeChunkUploadThreshold = 4 * 1024 * 1024 + 1
    public let useByteBuffer = false

    // Blob downloads
    // TODO: Switch back to 32 * 1024 * 1024
    public let maxSingleGetSize = 4 * 1024 * 1024
    public let maxChunkGetSize = 4 * 1024 * 1024

    // TransferManager configuration
    public var transferManager: URLSessionTransferManager?
    public weak var transferDelegate: TransferManagerDelegate?

    public init(
        apiVersion: String,
        logger: ClientLogger? = nil,
        delegate: TransferManagerDelegate? = nil,
        tag: String = "StorageBlobClient"
    ) {
        self.apiVersion = apiVersion
        self.tag = tag
        self.logger = logger ?? ClientLoggers.default(tag: tag)
        self.transferDelegate = delegate
    }
}

/// User-configurable options for the listContainers operation.
public class ListContainersOptions: AzureOptions {
    /// Datasets which may be included as part of the call response.
    public enum ListContainersInclude: String {
        case metadata
    }

    /// Return only containers whose names begin with the specified prefix.
    public var prefix: String?

    /// One or more datasets to include in the response.
    public var include: [ListContainersInclude]?

    /// Maximum number of containers to return, up to 5000.
    public var maxResults: Int?

    /// Request timeout in seconds.
    public var timeout: Int?
}

/// User-configurable options for the listBlobs operation.
public class ListBlobsOptions: AzureOptions {
    /// Datasets which may be included as part of the call response.
    public enum ListBlobsInclude: String {
        case snapshots, metadata, uncommittedblobs, copy, deleted
    }

    /// Return only blobs whose names begin with the specified prefix.
    public var prefix: String?

    /// Operation returns a BlobPrefix element in the response body that acts as a placeholder for all
    /// blobs whose names begin with the same substring up to the appearance of the delimiter character.
    /// The delimiter may be a single charcter or a string.
    public var delimiter: String?

    /// Maximum number of containers to return, up to 5000.
    public var maxResults: Int?

    /// One or more datasets to include in the response.
    public var include: [ListBlobsInclude]?

    /// Request timeout in seconds.
    public var timeout: Int?
}

/// User-configurable options for the blob download operations.
public class DownloadBlobOptions: AzureOptions {
    /// Options for overriding the default download destination behavior.
    public var destination: DestinationOptions?

    /// Options for working on a subset of data for a blob.
    public var range: RangeOptions?

    /// Required if the blob has an active lease. If specified, download only
    /// succeeds if the blob's lease is active and matches this ID. Value can be a
    /// BlobLeaseClient object or the lease ID as a string.
    public var lease: Any?

    /// A snapshot version for the blob being downloaded.
    public var snapshot: String?

    /// Options for accessing a blob based on the condition of a lease.
    public var leaseAccessConditions: LeaseAccessConditions?

    /// Options to set modifications on access according to whether the blob has/has not changed
    /// and based on the value of an eTag.
    public var modifiedAccessConditions: ModifiedAccessConditions?

    /// Blob encryption options.
    public var encryptionOptions: EncryptionOptions?

    /// Encrypts the data on the service-side with the given key.
    /// Use of customer-provided keys must be done over HTTPS.
    /// As the encryption key itself is provided in the request,
    /// a secure connection must be established to transfer the key.
    public var cpk: CustomerProvidedEncryptionKey?

    /// The number of parallel connections with which to download.
    public var maxConcurrency: Int?

    /// Encoding with which to decode the downloaded bytes. If nil, no decoding occurs.
    public var encoding: String?

    /// The timeout parameter is expressed in seconds. This method may make
    /// multiple calls to the Azure service and the timeout will apply to
    /// each call individually.
    public var timeout: Int?
}

/// User-configurable options for the blob upload operations.
public class UploadBlobOptions: AzureOptions {
    /// Options for accessing a blob based on the condition of a lease.
    public var leaseAccessConditions: LeaseAccessConditions?

    /// Options to set modifications on access according to whether the blob has/has not changed
    /// and based on the value of an eTag.
    public var modifiedAccessConditions: ModifiedAccessConditions?

    /// Blob encryption options.
    public var encryptionOptions: EncryptionOptions?

    /// Encrypts the data on the service-side with the given key.
    /// Use of customer-provided keys must be done over HTTPS.
    /// As the encryption key itself is provided in the request,
    /// a secure connection must be established to transfer the key.
    public var cpk: CustomerProvidedEncryptionKey?

    public var cpkScopeInfo: String?

    /// The number of parallel connections with which to upload.
    public var maxConcurrency: Int?

    /// Encoding with which to encode the uploaded bytes. If nil, no encoding occurs.
    public var encoding: String?

    public var stream: Stream?

    public var length: Int?

    public var overwrite: Bool?

    public var headers: HTTPHeaders?

    public var validateContent: Bool?

    public var blobSettings: BlobProperties?

    /// The timeout parameter is expressed in seconds. This method may make
    /// multiple calls to the Azure service and the timeout will apply to
    /// each call individually.
    public var timeout: Int?
}

/// User-configurable options for create blob SAS tokens.
public class BlobSasOptions {
    /// A blob snapshot ID.
    public var snapshot: String?

    /**
     The permissions associated with the shared access signature. The
     user is restricted to operations allowed by the permissions.
     Permissions must be ordered read, write, delete, list.
     Required unless an id is given referencing a stored access policy
     which contains this field. This field must be omitted if it has been
     specified in an associated stored access policy.
     */
    public var permission: String?

    /**
     The time at which the shared access signature becomes invalid.
     Required unless an id is given referencing a stored access policy
     which contains this field. This field must be omitted if it has
     been specified in an associated stored access policy. Azure will always
     convert values to UTC. If a date is passed in without timezone info, it
     is assumed to be UTC.
     */
    public var expiry: String?

    /**
     The time at which the shared access signature becomes valid. If
     omitted, start time for this call is assumed to be the time when the
     storage service receives the request. Azure will always convert values
     to UTC. If a date is passed in without timezone info, it is assumed to
     be UTC.
     */
    public var start: String?

    /**
     A unique value up to 64 characters in length that correlates to a
     stored access policy.
     */
    public var policyId: String?

    /**
     Specifies an IP address or a range of IP addresses from which to accept requests.
     If the IP address from which the request originates does not match the IP address
     or address range specified on the SAS token, the request is not authenticated.
     For example, specifying ip=168.1.5.65 or ip=168.1.5.60-168.1.5.70 on the SAS
     restricts the request to those IP addresses.
     */
    public var ipAddress: String?

    /**
     Specifies the protocol permitted for a request made. The default value is https.
     */
    public var `protocol`: String? = "https"

    /**
     Response header value for Cache-Control when resource is accessed
     using this shared access signature.
     */
    public var cacheControl: String?

    /**
     Response header value for Content-Disposition when resource is accessed
     using this shared access signature.
     */
    public var contentDisposition: String?

    /**
     Response header value for Content-Encoding when resource is accessed
     using this shared access signature.
     */
    public var contentEncoding: String?

    /**
     Response header value for Content-Language when resource is accessed
     using this shared access signature.
     */
    public var contentLanguage: String?

    /**
     Response header value for Content-Type when resource is accessed
     using this shared access signature.
     */
    public var contentType: String?
}
