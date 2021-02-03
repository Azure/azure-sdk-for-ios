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

// swiftlint:disable file_length

// MARK: Container Options

/// User-configurable options for the `ContainersOperations.list` operation.
public struct ListContainersOptions: RequestOptions {
    /// Datasets which may be included as part of the call response.
    public enum ListContainersInclude: String, CustomStringConvertible {
        /// Include the containers' metadata in the response.
        case metadata

        public var description: String {
            return rawValue
        }
    }

    /// A client-generated, opaque value with 1KB character limit that is recorded in analytics logs.
    public let clientRequestId: String?

    /// A token used to make a best-effort attempt at canceling a request.
    public let cancellationToken: CancellationToken?

    /// A dispatch queue on which to call the completion handler. Defaults to `DispatchQueue.main`.
    public let dispatchQueue: DispatchQueue?

    /// A `PipelineContext` object to associate with the request.
    public var context: PipelineContext?

    /// Return only containers whose names begin with the specified prefix.
    public let prefix: String?

    /// One or more datasets to include in the response.
    public let include: [ListContainersInclude]?

    /// Maximum number of containers to return, up to 5000.
    public let maxResults: Int?

    /// Request timeout in seconds.
    public let timeout: TimeInterval?

    /// Initialize a `ListContainersOptions` structure.
    /// - Parameters:
    ///   - clientRequestId: A client-generated, opaque value with 1KB character limit that is recorded in analytics
    ///     logs.
    ///   - cancellationToken: A token used to make a best-effort attempt at canceling a request.
    ///   - dispatchQueue: A dispatch queue on which to call the completion handler. Defaults to `DispatchQueue.main`.
    ///   - context: A `PipelineContext` object to associate with the request.
    ///   - prefix: Return only containers whose names begin with the specified prefix.
    ///   - include: One or more datasets to include in the response.
    ///   - maxResults: Maximum number of containers to return, up to 5000.
    ///   - timeout: Request timeout in seconds.
    public init(
        clientRequestId: String? = nil,
        cancellationToken: CancellationToken? = nil,
        dispatchQueue: DispatchQueue? = nil,
        context: PipelineContext? = nil,
        prefix: String? = nil,
        include: [ListContainersInclude]? = nil,
        maxResults: Int? = nil,
        timeout: TimeInterval? = nil
    ) {
        self.clientRequestId = clientRequestId
        self.cancellationToken = cancellationToken
        self.dispatchQueue = dispatchQueue
        self.context = context
        self.prefix = prefix
        self.include = include
        self.maxResults = maxResults
        self.timeout = timeout
    }
}

/// User-configurable options for the `ContainersOperations.delete` operation.
public struct DeleteContainerOptions: RequestOptions {
    /// A client-generated, opaque value with 1KB character limit that is recorded in analytics logs.
    public let clientRequestId: String?

    /// A token used to make a best-effort attempt at canceling a request.
    public let cancellationToken: CancellationToken?

    /// A dispatch queue on which to call the completion handler. Defaults to `DispatchQueue.main`.
    public let dispatchQueue: DispatchQueue?

    /// A `PipelineContext` object to associate with the request.
    public var context: PipelineContext?

    /// Request timeout in seconds.
    public let timeout: TimeInterval?

    /// Options for accessing a container based on the condition of a lease. If specified, the operation will
    /// be performed only if both of the following conditions are met:
    /// - The container's lease is currently active.
    /// - The specified lease ID matches that of the container.
    public let leaseAccessConditions: LeaseAccessConditions?

    /// Options for accessing a container based on its modification date and/or eTag. If specified, the operation will be
    /// performed only if all the specified conditions are met.
    public internal(set) var modifiedAccessConditions: ModifiedAccessConditions?

    /// Initialize a `DeleteContainerOptions` structure.
    /// - Parameters:
    ///   - clientRequestId: A client-generated, opaque value with 1KB character limit that is recorded in analytics
    ///     logs.
    ///   - cancellationToken: A token used to make a best-effort attempt at canceling a request.
    ///   - dispatchQueue: A dispatch queue on which to call the completion handler. Defaults to `DispatchQueue.main`.
    ///   - context: A `PipelineContext` object to associate with the request.
    ///   - timeout: Request timeout in seconds.
    ///   - leaseAccessConditions: Options for accessing a container based on the condition of a lease. If specified, the
    ///     operation will be performed only if both of the following conditions are met:
    ///     - The container's lease is currently active.
    ///     - The specified lease ID matches that of the container.
    ///   - modifiedAccessConditions: Options for accessing a container based on its modification date and/or eTag. If
    ///     specified, the operation will be performed only if all the specified conditions are met.
    public init(
        clientRequestId: String? = nil,
        cancellationToken: CancellationToken? = nil,
        dispatchQueue: DispatchQueue? = nil,
        context: PipelineContext? = nil,
        timeout: TimeInterval? = nil,
        leaseAccessConditions: LeaseAccessConditions? = nil,
        modifiedAccessConditions: ModifiedAccessConditions? = nil
    ) {
        self.clientRequestId = clientRequestId
        self.cancellationToken = cancellationToken
        self.dispatchQueue = dispatchQueue
        self.context = context
        self.timeout = timeout
        self.leaseAccessConditions = leaseAccessConditions
        self.modifiedAccessConditions = modifiedAccessConditions
    }
}

/// User-configurable options for the `ContainersOperations.get(container:)` operation.
public struct GetContainerOptions: RequestOptions {
    /// A client-generated, opaque value with 1KB character limit that is recorded in analytics logs.
    public let clientRequestId: String?

    /// A token used to make a best-effort attempt at canceling a request.
    public let cancellationToken: CancellationToken?

    /// A dispatch queue on which to call the completion handler. Defaults to `DispatchQueue.main`.
    public let dispatchQueue: DispatchQueue?

    /// A `PipelineContext` object to associate with the request.
    public var context: PipelineContext?

    /// Request timeout in seconds.
    public let timeout: TimeInterval?

    /// Options for accessing a container based on the condition of a lease. If specified, the operation will be performed
    /// only if both of the following conditions are met:
    /// - The container's lease is currently active.
    /// - The specified lease ID matches that of the container.
    public let leaseAccessConditions: LeaseAccessConditions?

    /// Initialize a `GetConainerOptions` structure.
    /// - Parameters:
    ///   - clientRequestId: A client-generated, opaque value with 1KB character limit that is recorded in analytics logs.
    ///   - cancellationToken: A token used to make a best-effort attempt at canceling a request.
    ///   - dispatchQueue: A dispatch queue on which to call the completion handler. Defaults to `DispatchQueue.main`.
    ///   - context: A `PipelineContext` object to associate with the request.
    ///   - timeout: Request timeout in seconds.
    ///   - leaseAccessConditions: Options for accessing a container based on the condition of a lease.
    public init(
        clientRequestId: String? = nil,
        cancellationToken: CancellationToken? = nil,
        dispatchQueue: DispatchQueue? = nil,
        context: PipelineContext? = nil,
        timeout: TimeInterval? = nil,
        leaseAccessConditions: LeaseAccessConditions? = nil
    ) {
        self.clientRequestId = clientRequestId
        self.cancellationToken = cancellationToken
        self.dispatchQueue = dispatchQueue
        self.context = context
        self.timeout = timeout
        self.leaseAccessConditions = leaseAccessConditions
    }
}

/// User-configurable options for the `ContainersOperations.create(container:)` operation.
public struct CreateContainerOptions: RequestOptions {
    /// A client-generated, opaque value with 1KB character limit that is recorded in analytics logs.
    public let clientRequestId: String?

    /// A token used to make a best-effort attempt at canceling a request.
    public let cancellationToken: CancellationToken?

    /// A dispatch queue on which to call the completion handler. Defaults to `DispatchQueue.main`.
    public let dispatchQueue: DispatchQueue?

    /// A `PipelineContext` object to associate with the request.
    public var context: PipelineContext?

    /// Request timeout in seconds.
    public let timeout: TimeInterval?

    /// Specifies user-defined name-value pairs associated with the container. Note that beginning with version 2009-09-19, metadata names must
    /// adhere to the naming rules for C# identifiers.
    public let metadata: [String: String]?

    /// Specifies whether data in the container may be accessed publicly and the level of access.
    public let access: PublicAccessType?

    /// Specifies the default encryption scope policy for the container
    public let containerCpkScopeInfo: ContainerCpkScopeInfo?

    /// Initialize an `CreateConainerOptions` structure.
    /// - Parameters:
    ///   - clientRequestId: A client-generated, opaque value with 1KB character limit that is recorded in analytics logs.
    ///   - cancellationToken: A token used to make a best-effort attempt at canceling a request.
    ///   - dispatchQueue: A dispatch queue on which to call the completion handler. Defaults to `DispatchQueue.main`.
    ///   - context: A `PipelineContext` object to associate with the request.
    ///   - timeout: Request timeout in seconds.
    ///   - metadata: Specifies user-defined name-value pairs associated with the container. Note that beginning with version
    ///   2009-09-19, metadata names must adhere to the naming rules for C# identifiers.
    ///   - access: Specifies whether data in the container may be accessed publicly and the level of access.
    ///   - containerCpkScopeInfo: Specifies the default encryption scope policy for the container
    public init(
        clientRequestId: String? = nil,
        cancellationToken: CancellationToken? = nil,
        dispatchQueue: DispatchQueue? = nil,
        context: PipelineContext? = nil,
        timeout: TimeInterval? = nil,
        metadata: [String: String]? = nil,
        access: PublicAccessType? = nil,
        containerCpkScopeInfo: ContainerCpkScopeInfo? = nil
    ) {
        self.clientRequestId = clientRequestId
        self.cancellationToken = cancellationToken
        self.dispatchQueue = dispatchQueue
        self.context = context
        self.timeout = timeout
        self.metadata = metadata
        self.access = access
        self.containerCpkScopeInfo = containerCpkScopeInfo
    }
}

// MARK: Blob Options

/// User-configurable options for the `BlobsOperations.list` operation.
public struct ListBlobsOptions: RequestOptions {
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

    /// A token used to make a best-effort attempt at canceling a request.
    public let cancellationToken: CancellationToken?

    /// A dispatch queue on which to call the completion handler. Defaults to `DispatchQueue.main`.
    public let dispatchQueue: DispatchQueue?

    /// A `PipelineContext` object to associate with the request.
    public var context: PipelineContext?

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
    public let timeout: TimeInterval?

    /// Initialize a `ListBlobsOptions` structure.
    /// - Parameters:
    ///   - clientRequestId: A client-generated, opaque value with 1KB character limit that is recorded in analytics
    ///     logs.
    ///   - cancellationToken: A token used to make a best-effort attempt at canceling a request.
    ///   - dispatchQueue: A dispatch queue on which to call the completion handler. Defaults to `DispatchQueue.main`.
    ///   - context: A `PipelineContext` object to associate with the request.
    ///   - prefix: Return only blobs whose names begin with the specified prefix.
    ///   - delimiter: Operation returns a BlobPrefix element in the response body that acts as a placeholder for all
    ///     blobs whose names begin with the same substring up to the appearance of the delimiter character. The
    ///     delimiter may be a single charcter or a string.
    ///   - maxResults: Maximum number of containers to return, up to 5000.
    ///   - include: One or more datasets to include in the response.
    ///   - timeout: Request timeout in seconds.
    public init(
        clientRequestId: String? = nil,
        cancellationToken: CancellationToken? = nil,
        dispatchQueue: DispatchQueue? = nil,
        context: PipelineContext? = nil,
        prefix: String? = nil,
        delimiter: String? = nil,
        maxResults: Int? = nil,
        include: [ListBlobsInclude]? = nil,
        timeout: TimeInterval? = nil
    ) {
        self.clientRequestId = clientRequestId
        self.cancellationToken = cancellationToken
        self.dispatchQueue = dispatchQueue
        self.context = context
        self.prefix = prefix
        self.delimiter = delimiter
        self.maxResults = maxResults
        self.include = include
        self.timeout = timeout
    }
}

/// User-configurable options for the `BlobsOperations.delete` operation.
public struct DeleteBlobOptions: RequestOptions {
    /// This header should be specified only for a request against the base blob resource.
    /// If this header is specified on a request to delete an individual snapshot, the Blob
    /// service returns status code 400 (Bad Request).
    /// If this header is not specified on the request and the blob has associated snapshots,
    /// the Blob service returns status code 409 (Conflict).
    public enum DeleteBlobSnapshot: String, RequestStringConvertible {
        /// Delete the base blob and all of its snapshots.
        case include
        /// Delete only the blob's snapshots and not the blob itself.
        case only

        public var requestString: String {
            return rawValue
        }
    }

    /// A client-generated, opaque value with 1KB character limit that is recorded in analytics logs.
    public let clientRequestId: String?

    /// A token used to make a best-effort attempt at canceling a request.
    public let cancellationToken: CancellationToken?

    /// A dispatch queue on which to call the completion handler. Defaults to `DispatchQueue.main`.
    public let dispatchQueue: DispatchQueue?

    /// A `PipelineContext` object to associate with the request.
    public var context: PipelineContext?

    /// Specify how blob snapshots should be handled. Required if the blob has associated snapshots.
    public let deleteSnapshots: DeleteBlobSnapshot?

    /// A `Date` specifying the snapshot you wish to delete.
    public let snapshot: Rfc1123Date?

    /// Request timeout in seconds.
    public let timeout: TimeInterval?
}

/// User-configurable options for the `BlobsOperations.download` and `BlobsOperations.rawDownload` operations.
public struct DownloadBlobOptions: RequestOptions, Codable, Equatable {
    /// A client-generated, opaque value with 1KB character limit that is recorded in analytics logs.
    public let clientRequestId: String?

    /// A token used to make a best-effort attempt at canceling a request.
    public let cancellationToken: CancellationToken?

    /// A dispatch queue on which to call the completion handler. Defaults to `DispatchQueue.main`.
    public var dispatchQueue: DispatchQueue?

    /// A `PipelineContext` object to associate with the request.
    public var context: PipelineContext?

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
    public let timeout: TimeInterval?

    /// Initialize a `DownloadBlobOptions` structure.
    /// - Parameters:
    ///   - clientRequestId: A client-generated, opaque value with 1KB character limit that is recorded in analytics
    ///     logs.
    ///   - cancellationToken: A token used to make a best-effort attempt at canceling a request.
    ///   - dispatchQueue: A dispatch queue on which to call the completion handler. Defaults to `DispatchQueue.main`.
    ///   - context: A `PipelineContext` object to associate with the request.
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
    ///   - timeout: The timeout parameter is expressed in seconds. This method may make multiple calls to the
    ///     Azure service and the timeout will apply to each call individually.
    public init(
        clientRequestId: String? = nil,
        cancellationToken: CancellationToken? = nil,
        dispatchQueue: DispatchQueue? = nil,
        context: PipelineContext? = nil,
        range: RangeOptions? = nil,
        leaseId: String? = nil,
        snapshot: String? = nil,
        leaseAccessConditions: LeaseAccessConditions? = nil,
        modifiedAccessConditions: ModifiedAccessConditions? = nil,
        encryptionOptions: EncryptionOptions? = nil,
        customerProvidedEncryptionKey: CustomerProvidedEncryptionKey? = nil,
        encoding: String? = nil,
        timeout: TimeInterval? = nil
    ) {
        self.clientRequestId = clientRequestId
        self.cancellationToken = cancellationToken
        self.dispatchQueue = dispatchQueue
        self.context = context
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

    // TODO: Evalute whether serializing/deserializing dispatchQueue is necessary
    enum CodingKeys: CodingKey {
        case clientRequestId, cancellationToken, range, leaseId, snapshot,
            leaseAccessConditions, modifiedAccessConditions, encryptionOptions, customerProvidedEncryptionKey,
            encoding, timeout
    }
}

/// User-configurable options for the `BlobsOperations.upload` and `BlobsOperations.rawUpload` operations.
public struct UploadBlobOptions: RequestOptions, Codable, Equatable {
    /// A client-generated, opaque value with 1KB character limit that is recorded in analytics logs.
    public let clientRequestId: String?

    /// A token used to make a best-effort attempt at canceling a request.
    public let cancellationToken: CancellationToken?

    /// A dispatch queue on which to call the completion handler. Defaults to `DispatchQueue.main`.
    public var dispatchQueue: DispatchQueue?

    /// A `PipelineContext` object to associate with the request.
    public var context: PipelineContext?

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
    public let timeout: TimeInterval?

    /// Initialize an `UploadBlobOptions` structure.
    /// - Parameters:
    ///   - clientRequestId: A client-generated, opaque value with 1KB character limit that is recorded in analytics
    ///     logs.
    ///   - cancellationToken: A token used to make a best-effort attempt at canceling a request.
    ///   - dispatchQueue: A dispatch queue on which to call the completion handler. Defaults to `DispatchQueue.main`.
    ///   - context: A `PipelineContext` object to associate with the request.
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
    ///   - timeout: The timeout parameter is expressed in seconds. This method may make multiple calls to the
    ///     Azure service and the timeout will apply to each call individually.
    public init(
        clientRequestId: String? = nil,
        cancellationToken: CancellationToken? = nil,
        dispatchQueue: DispatchQueue? = nil,
        context: PipelineContext? = nil,
        leaseAccessConditions: LeaseAccessConditions? = nil,
        modifiedAccessConditions: ModifiedAccessConditions? = nil,
        encryptionOptions: EncryptionOptions? = nil,
        customerProvidedEncryptionKey: CustomerProvidedEncryptionKey? = nil,
        customerProvidedEncryptionScope: String? = nil,
        encoding: String? = nil,
        timeout: TimeInterval? = nil
    ) {
        self.clientRequestId = clientRequestId
        self.cancellationToken = cancellationToken
        self.dispatchQueue = dispatchQueue
        self.context = context
        self.leaseAccessConditions = leaseAccessConditions
        self.modifiedAccessConditions = modifiedAccessConditions
        self.encryptionOptions = encryptionOptions
        self.customerProvidedEncryptionKey = customerProvidedEncryptionKey
        self.customerProvidedEncryptionScope = customerProvidedEncryptionScope
        self.encoding = encoding
        self.timeout = timeout
    }

    // TODO: Evalute whether serializing/deserializing dispatchQueue is necessary
    enum CodingKeys: CodingKey {
        case clientRequestId, cancellationToken, leaseAccessConditions, modifiedAccessConditions,
            encryptionOptions, customerProvidedEncryptionKey, customerProvidedEncryptionScope,
            encoding, timeout
    }
}

/// User-configurable options for the `BlobsOperations.getMetadata` operation.
public struct GetBlobMetadataOptions: RequestOptions {
    /// A client-generated, opaque value with 1KB character limit that is recorded in analytics logs.
    public let clientRequestId: String?

    /// A token used to make a best-effort attempt at canceling a request.
    public let cancellationToken: CancellationToken?

    /// A dispatch queue on which to call the completion handler. Defaults to `DispatchQueue.main`.
    public var dispatchQueue: DispatchQueue?

    /// A `PipelineContext` object to associate with the request.
    public var context: PipelineContext?

    /// An `Rfc1123Date` specifying the snapshot you wish to query.
    public let snapshot: Rfc1123Date?

    /// A n`Rfc1123Date` specifying the version of the blob to query.
    public let versionId: Rfc1123Date?

    /// The timeout parameter is expressed in seconds.
    public let timeout: TimeInterval?

    /// Initialize a `GetBlobMetadataOptions` structure.
    /// - Parameters:
    ///   - clientRequestId: A client-generated, opaque value with 1KB character limit that is recorded in analytics
    ///     logs.
    ///   - cancellationToken: A token used to make a best-effort attempt at canceling a request.
    ///   - dispatchQueue: A dispatch queue on which to call the completion handler. Defaults to `DispatchQueue.main`.
    ///   - context: A `PipelineContext` object to associate with the request.
    ///   - snapshot: The snapshot parameter is a value that, when present, specifies the blob snapshot to retrieve.
    ///   - versionId:The version id parameter is a value that, when present, specifies the version of the blob to operate on.
    ///   - timeout: The timeout parameter is expressed in seconds.
    public init(
        clientRequestId: String? = nil,
        cancellationToken: CancellationToken? = nil,
        dispatchQueue: DispatchQueue? = nil,
        context: PipelineContext? = nil,
        snapshot: Rfc1123Date? = nil,
        versionId: Rfc1123Date? = nil,
        timeout: TimeInterval? = nil
    ) {
        self.clientRequestId = clientRequestId
        self.cancellationToken = cancellationToken
        self.dispatchQueue = dispatchQueue
        self.context = context
        self.snapshot = snapshot
        self.versionId = versionId
        self.timeout = timeout
    }
}

/// User-configurable options for the `BlobsOperations.set(metadata:)` operation.
public struct SetBlobMetadataOptions: RequestOptions {
    /// A client-generated, opaque value with 1KB character limit that is recorded in analytics logs.
    public let clientRequestId: String?

    /// A token used to make a best-effort attempt at canceling a request.
    public let cancellationToken: CancellationToken?

    /// A dispatch queue on which to call the completion handler. Defaults to `DispatchQueue.main`.
    public var dispatchQueue: DispatchQueue?

    /// A `PipelineContext` object to associate with the request.
    public var context: PipelineContext?

    /// The timeout parameter is expressed in seconds.
    public let timeout: TimeInterval?

    /// Initialize a `SetBlobMetadataOptions` structure.
    /// - Parameters:
    ///   - clientRequestId: A client-generated, opaque value with 1KB character limit that is recorded in analytics
    ///     logs.
    ///   - cancellationToken: A token used to make a best-effort attempt at canceling a request.
    ///   - dispatchQueue: A dispatch queue on which to call the completion handler. Defaults to `DispatchQueue.main`.
    ///   - context: A `PipelineContext` object to associate with the request.
    ///   - timeout: The timeout parameter is expressed in seconds.
    public init(
        clientRequestId: String? = nil,
        cancellationToken: CancellationToken? = nil,
        dispatchQueue: DispatchQueue? = nil,
        context: PipelineContext? = nil,
        timeout: TimeInterval? = nil
    ) {
        self.clientRequestId = clientRequestId
        self.cancellationToken = cancellationToken
        self.dispatchQueue = dispatchQueue
        self.context = context
        self.timeout = timeout
    }
}
