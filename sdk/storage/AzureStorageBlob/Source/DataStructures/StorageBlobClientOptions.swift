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
public struct StorageBlobClientOptions: AzureConfigurable {
    /// The API version of the Azure Storage Blob service to invoke.
    public let apiVersion: String
    /// The `ClientLogger` to be used by this `StorageBlobClient`.
    public let logger: ClientLogger

    // Blob operations

    /// The maximum size of a single chunk in a blob upload or download.
    public let maxChunkSize: Int

    /// Initialize a `StorageBlobClientOptions` structure.
    /// - Parameters:
    ///   - apiVersion: The API version of the Azure Storage Blob service to invoke.
    ///   - logger: The `ClientLogger` to be used by this `StorageBlobClient`.
    ///   - maxChunkSize: The maximum size of a single chunk in a blob upload or download.
    public init(
        apiVersion: String = StorageBlobClient.ApiVersion.latest.rawValue,
        logger: ClientLogger = ClientLoggers.default(tag: "StorageBlobClient"),
        maxChunkSize: Int = 4 * 1024 * 1024
    ) {
        self.apiVersion = apiVersion
        self.logger = logger
        self.maxChunkSize = maxChunkSize
    }
}

/// User-configurable options for the listContainers operation.
public struct ListContainersOptions: AzureOptions {
    /// Datasets which may be included as part of the call response.
    public enum ListContainersInclude: String {
        /// Include the containers' metadata in the response.
        case metadata
    }

    /// A client-generated, opaque value with 1KB character limit that is recorded in analytics logs.
    public let clientRequestId: String?

    /// Return only containers whose names begin with the specified prefix.
    public let prefix: String?

    /// One or more datasets to include in the response.
    public let include: [ListContainersInclude]?

    /// Maximum number of containers to return, up to 5000.
    public let maxResults: Int?

    /// Request timeout in seconds.
    public let timeout: Int?

    /// Initialize a `ListContainersOptions` structure.
    /// - Parameters:
    ///   - clientRequestId: A client-generated, opaque value with 1KB character limit that is recorded in analytics
    ///     logs.
    ///   - prefix: Return only containers whose names begin with the specified prefix.
    ///   - include: One or more datasets to include in the response.
    ///   - maxResults: Maximum number of containers to return, up to 5000.
    ///   - timeout: equest timeout in seconds.
    public init(
        clientRequestId: String? = nil,
        prefix: String? = nil,
        include: [ListContainersInclude]? = nil,
        maxResults: Int? = nil,
        timeout: Int? = nil
    ) {
        self.clientRequestId = clientRequestId
        self.prefix = prefix
        self.include = include
        self.maxResults = maxResults
        self.timeout = timeout
    }
}

/// User-configurable options for the listBlobs operation.
public struct ListBlobsOptions: AzureOptions {
    /// Datasets which may be included as part of the call response.
    public enum ListBlobsInclude: String {
        /// Include blob snapshots in the response.
        case snapshots
        /// Include the blobs' metadata in the response.
        case metadata
        /// Include blobs for which blocks have been uploaded, but which have not been committed, in the response.
        case uncommittedblobs
        /// Include metadata related to any current or previous Copy Blob operation in the response.
        case copy
        /// Include soft-deleted blobs in the response.
        case deleted
    }

    /// A client-generated, opaque value with 1KB character limit that is recorded in analytics logs.
    public let clientRequestId: String?

    /// Return only blobs whose names begin with the specified prefix.
    public let prefix: String?

    /// Operation returns a BlobPrefix element in the response body that acts as a placeholder for all
    /// blobs whose names begin with the same substring up to the appearance of the delimiter character.
    /// The delimiter may be a single charcter or a string.
    public let delimiter: String?

    /// Maximum number of containers to return, up to 5000.
    public let maxResults: Int?

    /// One or more datasets to include in the response.
    public let include: [ListBlobsInclude]?

    /// Request timeout in seconds.
    public let timeout: Int?

    /// Initialize a `ListBlobsOptions` structure.
    /// - Parameters:
    ///   - clientRequestId: A client-generated, opaque value with 1KB character limit that is recorded in analytics
    ///     logs.
    ///   - prefix: Return only blobs whose names begin with the specified prefix.
    ///   - delimiter: Operation returns a BlobPrefix element in the response body that acts as a placeholder for all
    ///     blobs whose names begin with the same substring up to the appearance of the delimiter character. The
    ///     delimiter may be a single charcter or a string.
    ///   - maxResults: Maximum number of containers to return, up to 5000.
    ///   - include: One or more datasets to include in the response.
    ///   - timeout: Request timeout in seconds.
    public init(
        clientRequestId: String? = nil,
        prefix: String? = nil,
        delimiter: String? = nil,
        maxResults: Int? = nil,
        include: [ListBlobsInclude]? = nil,
        timeout: Int? = nil
    ) {
        self.clientRequestId = clientRequestId
        self.prefix = prefix
        self.delimiter = delimiter
        self.maxResults = maxResults
        self.include = include
        self.timeout = timeout
    }
}

/// User-configurable options for the blob download operations.
public struct DownloadBlobOptions: AzureOptions, Codable, Equatable {
    /// A client-generated, opaque value with 1KB character limit that is recorded in analytics logs.
    public let clientRequestId: String?

    /// Options for working on a subset of data for a blob.
    public let range: RangeOptions?

    /// Required if the blob has an active lease. If specified, download only
    /// succeeds if the blob's lease is active and matches this ID.
    public let leaseId: String?

    /// A snapshot version for the blob being downloaded.
    public let snapshot: String?

    /// Options for accessing a blob based on the condition of a lease. If specified, the operation will be performed
    /// only if both of the following conditions are met:
    /// - The blob's lease is currently active.
    /// - The specified lease ID matches that of the blob.
    public let leaseAccessConditions: LeaseAccessConditions?

    /// Options for accessing a blob based on its modification date and/or eTag. If specified, the operation will be
    /// performed only if all the specified conditions are met.
    public internal(set) var modifiedAccessConditions: ModifiedAccessConditions?

    /// Blob encryption options.
    public let encryptionOptions: EncryptionOptions?

    /// Encrypts the data on the service-side with the given key.
    /// Use of customer-provided keys must be done over HTTPS.
    /// As the encryption key itself is provided in the request,
    /// a secure connection must be established to transfer the key.
    public let customerProvidedEncryptionKey: CustomerProvidedEncryptionKey?

    /// Encoding with which to decode the downloaded bytes. If nil, no decoding occurs.
    public let encoding: String?

    /// The timeout parameter is expressed in seconds. This method may make
    /// multiple calls to the Azure service and the timeout will apply to
    /// each call individually.
    public let timeout: Int?

    /// Initialize a `DownloadBlobOptions` structure.
    /// - Parameters:
    ///   - clientRequestId: A client-generated, opaque value with 1KB character limit that is recorded in analytics
    ///     logs.
    ///   - destination: Options for overriding the default download destination behavior.
    ///   - range: Options for working on a subset of data for a blob.
    ///   - leaseId: Required if the blob has an active lease. If specified, download only succeeds if the blob's lease
    ///     is active and matches this ID.
    ///   - snapshot: A snapshot version for the blob being downloaded.
    ///   - leaseAccessConditions: Options for accessing a blob based on the condition of a lease. If specified, the
    ///     operation will be performed only if both of the following conditions are met:
    ///     - The blob's lease is currently active.
    ///     - The specified lease ID matches that of the blob.
    ///   - modifiedAccessConditions: Options for accessing a blob based on its modification date and/or eTag. If
    ///     specified, the operation will be performed only if all the specified conditions are met.
    ///   - encryptionOptions: Blob encryption options.
    ///   - customerProvidedEncryptionKey: Encrypts the data on the service-side with the given key. Use of
    ///     customer-provided keys must be done over HTTPS. As the encryption key itself is provided in the request, a
    ///     secure connection must be established to transfer the key.
    ///   - encoding: Encoding with which to decode the downloaded bytes. If nil, no decoding occurs.
    ///   - timeout: The timeout parameter is expressed in seconds. This method may make multiple calls to the Azure
    ///     service and the timeout will apply to each call individually.
    public init(
        clientRequestId: String? = nil,
        range: RangeOptions? = nil,
        leaseId: String? = nil,
        snapshot: String? = nil,
        leaseAccessConditions: LeaseAccessConditions? = nil,
        modifiedAccessConditions: ModifiedAccessConditions? = nil,
        encryptionOptions: EncryptionOptions? = nil,
        customerProvidedEncryptionKey: CustomerProvidedEncryptionKey? = nil,
        encoding: String? = nil,
        timeout: Int? = nil
    ) {
        self.clientRequestId = clientRequestId
        self.range = range
        self.leaseId = leaseId
        self.snapshot = snapshot
        self.leaseAccessConditions = leaseAccessConditions
        self.modifiedAccessConditions = modifiedAccessConditions
        self.encryptionOptions = encryptionOptions
        self.customerProvidedEncryptionKey = customerProvidedEncryptionKey
        self.encoding = encoding
        self.timeout = timeout
    }
}

/// User-configurable options for the blob upload operations.
public struct UploadBlobOptions: AzureOptions, Codable, Equatable {
    /// A client-generated, opaque value with 1KB character limit that is recorded in analytics logs.
    public let clientRequestId: String?

    /// Options for accessing a blob based on the condition of a lease. If specified, the operation will be performed
    /// only if both of the following conditions are met:
    /// - The blob's lease is currently active.
    /// - The specified lease ID matches that of the blob.
    public let leaseAccessConditions: LeaseAccessConditions?

    /// Options for accessing a blob based on its modification date and/or eTag. If specified, the operation will be
    /// performed only if all the specified conditions are met.
    public let modifiedAccessConditions: ModifiedAccessConditions?

    /// Blob encryption options.
    public let encryptionOptions: EncryptionOptions?

    /// Encrypts the data on the service-side with the given key.
    /// Use of customer-provided keys must be done over HTTPS.
    /// As the encryption key itself is provided in the request,
    /// a secure connection must be established to transfer the key.
    public let customerProvidedEncryptionKey: CustomerProvidedEncryptionKey?

    /// The name of the predefined encryption scope used to encrypt the blob contents and metadata. Note that omitting
    /// this value implies use of the default account encryption scope.
    public let customerProvidedEncryptionScope: String?

    /// Encoding with which to encode the uploaded bytes. If nil, no encoding occurs.
    public let encoding: String?

    /// The timeout parameter is expressed in seconds. This method may make
    /// multiple calls to the Azure service and the timeout will apply to
    /// each call individually.
    public let timeout: Int?

    /// Initialize an `UploadBlobOptions` structure.
    /// - Parameters:
    ///   - clientRequestId: A client-generated, opaque value with 1KB character limit that is recorded in analytics
    ///     logs.
    ///   - leaseAccessConditions: Options for accessing a blob based on the condition of a lease. If specified, the
    ///     operation will be performed only if both of the following conditions are met:
    ///     - The blob's lease is currently active.
    ///     - The specified lease ID matches that of the blob.
    ///   - modifiedAccessConditions: Options for accessing a blob based on its modification date and/or eTag. If
    ///     specified, the operation will be performed only if all the specified conditions are met.
    ///   - encryptionOptions: Blob encryption options.
    ///   - customerProvidedEncryptionKey: Encrypts the data on the service-side with the given key. Use of
    ///     customer-provided keys must be done over HTTPS. As the encryption key itself is provided in the request, a
    ///     secure connection must be established to transfer the key.
    ///   - customerProvidedEncryptionScope: The name of the predefined encryption scope used to encrypt the blob
    ///   contents and metadata. Note that omitting this value implies use of the default account encryption scope.
    ///   - encoding: Encoding with which to decode the downloaded bytes. If nil, no decoding occurs.
    ///   - timeout: The timeout parameter is expressed in seconds. This method may make multiple calls to the Azure
    ///     service and the timeout will apply to each call individually.
    public init(
        clientRequestId: String? = nil,
        leaseAccessConditions: LeaseAccessConditions? = nil,
        modifiedAccessConditions: ModifiedAccessConditions? = nil,
        encryptionOptions: EncryptionOptions? = nil,
        customerProvidedEncryptionKey: CustomerProvidedEncryptionKey? = nil,
        customerProvidedEncryptionScope: String? = nil,
        encoding: String? = nil,
        timeout: Int? = nil
    ) {
        self.clientRequestId = clientRequestId
        self.leaseAccessConditions = leaseAccessConditions
        self.modifiedAccessConditions = modifiedAccessConditions
        self.encryptionOptions = encryptionOptions
        self.customerProvidedEncryptionKey = customerProvidedEncryptionKey
        self.customerProvidedEncryptionScope = customerProvidedEncryptionScope
        self.encoding = encoding
        self.timeout = timeout
    }
}
