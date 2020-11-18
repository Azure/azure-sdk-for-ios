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

/// Storage service-specific HTTP headers.
public enum StorageHTTPHeader: String, RequestStringConvertible {
    /// x-ms-access-tier
    case accessTier = "x-ms-access-tier"
    /// x-ms-access-tier-change-time
    case accessTierChangeTime = "x-ms-access-tier-change-time"
    /// x-ms-access-tier-inferred
    case accessTierInferred = "x-ms-access-tier-inferred"
    /// x-ms-account-kind
    case accountKind = "x-ms-account-kind"
    /// x-ms-archive-status
    case archiveStatus = "x-ms-archive-status"
    /// x-ms-blob-append-offset
    case blobAppendOffset = "x-ms-blob-append-offset"
    /// x-ms-blob-cache-control
    case blobCacheControl = "x-ms-blob-cache-control"
    /// x-ms-blob-committed-block-count
    case blobCommittedBlockCount = "x-ms-blob-committed-block-count"
    /// x-ms-blob-condition-appendpos
    case blobConditionAppendpos = "x-ms-blob-condition-appendpos"
    /// x-ms-blob-condition-maxsize
    case blobConditionMaxsize = "x-ms-blob-condition-maxsize"
    /// x-ms-blob-content-disposition
    case blobContentDisposition = "x-ms-blob-content-disposition"
    /// x-ms-blob-content-encoding
    case blobContentEncoding = "x-ms-blob-content-encoding"
    /// x-ms-blob-content-language
    case blobContentLanguage = "x-ms-blob-content-language"
    /// x-ms-blob-content-length
    case blobContentLength = "x-ms-blob-content-length"
    /// x-ms-blob-content-md5
    case blobContentMD5 = "x-ms-blob-content-md5"
    /// x-ms-blob-content-type
    case blobContentType = "x-ms-blob-content-type"
    /// x-ms-blob-public-access
    case blobPublicAccess = "x-ms-blob-public-access"
    /// x-ms-blob-sequence-number
    case blobSequenceNumber = "x-ms-blob-sequence-number"
    /// x-ms-blob-type
    case blobType = "x-ms-blob-type"
    /// x-ms-content-crc64
    case contentCRC64 = "x-ms-content-crc64"
    /// x-ms-copy-action
    case copyAction = "x-ms-copy-action"
    /// x-ms-copy-completion-time
    case copyCompletionTime = "x-ms-copy-completion-time"
    /// x-ms-copy-destination-snapshot
    case copyDestinationSnapshot = "x-ms-copy-destination-snapshot"
    /// x-ms-copy-id
    case copyId = "x-ms-copy-id"
    /// x-ms-copy-progress
    case copyProgress = "x-ms-copy-progress"
    /// x-ms-copy-source
    case copySource = "x-ms-copy-source"
    /// x-ms-copy-status
    case copyStatus = "x-ms-copy-status"
    /// x-ms-copy-status-description
    case copyStatusDescription = "x-ms-copy-status-description"
    /// x-ms-creation-time
    case creationTime = "x-ms-creation-time"
    /// x-ms-default-encryption-scope
    case defaultEncryptionScope = "x-ms-default-encryption-scope"
    /// x-ms-delete-snapshots
    case deleteSnapshots = "x-ms-delete-snapshots"
    /// x-ms-delete-type-permanent
    case deleteTypePermanent = "x-ms-delete-type-permanent"
    /// x-ms-deny-encryption-scope-override
    case denyEncryptionScopeOverride = "x-ms-deny-encryption-scope-override"
    /// x-ms-encryption-algorithm
    case encryptionAlgorithm = "x-ms-encryption-algorithm"
    /// x-ms-encryption-key
    case encryptionKey = "x-ms-encryption-key"
    /// x-ms-encryption-key-sha256
    case encryptionKeySHA256 = "x-ms-encryption-key-sha256"
    /// x-ms-encryption-scope
    case encryptionScope = "x-ms-encryption-scope"
    /// x-ms-error-code
    case errorCode = "x-ms-error-code"
    /// x-ms-has-immutability-policy
    case hasImmutabilityPolicy = "x-ms-has-immutability-policy"
    /// x-ms-has-legal-hold
    case hasLegalHold = "x-ms-has-legal-hold"
    /// x-ms-if-sequence-number-eq
    case ifSequenceNumberEq = "x-ms-if-sequence-number-eq"
    /// x-ms-if-sequence-number-le
    case ifSequenceNumberLe = "x-ms-if-sequence-number-le"
    /// x-ms-if-sequence-number-lt
    case ifSequenceNumberLt = "x-ms-if-sequence-number-lt"
    /// x-ms-incremental-copy
    case incrementalCopy = "x-ms-incremental-copy"
    /// x-ms-lease-action
    case leaseAction = "x-ms-lease-action"
    /// x-ms-lease-break-period
    case leaseBreakPeriod = "x-ms-lease-break-period"
    /// x-ms-lease-duration
    case leaseDuration = "x-ms-lease-duration"
    /// x-ms-lease-id
    case leaseId = "x-ms-lease-id"
    /// x-ms-lease-state
    case leaseState = "x-ms-lease-state"
    /// x-ms-lease-status
    case leaseStatus = "x-ms-lease-status"
    /// x-ms-lease-time
    case leaseTime = "x-ms-lease-time"
    /// x-ms-meta
    case metadata = "x-ms-meta"
    /// x-ms-page-write
    case pageWrite = "x-ms-page-write"
    /// x-ms-proposed-lease-id
    case proposedLeaseId = "x-ms-proposed-lease-id"
    /// x-ms-range
    case xmsRange = "x-ms-range"
    /// x-ms-range-get-content-md5
    case rangeGetContentMD5 = "x-ms-range-get-content-md5"
    /// x-ms-range-get-content-crc64
    case rangeGetContentCRC64 = "x-ms-range-get-content-crc64"
    /// x-ms-rehydrate-priority
    case rehydratePriority = "x-ms-rehydrate-priority"
    /// x-ms-request-id
    case requestId = "x-ms-request-id"
    /// x-ms-request-server-encrypted
    case requestServerEncrypted = "x-ms-request-server-encrypted"
    /// x-ms-sequence-number-action
    case sequenceNumberAction = "x-ms-sequence-number-action"
    /// x-ms-server-encrypted
    case serverEncrypted = "x-ms-server-encrypted"
    /// x-ms-sku-name
    case skuName = "x-ms-sku-name"
    /// x-ms-snapshot
    case snapshot = "x-ms-snapshot"
    /// x-ms-source-content-md5
    case sourceContentMd5 = "x-ms-source-content-md5"
    /// x-ms-source-if-match
    case sourceIfMatch = "x-ms-source-if-match"
    /// x-ms-source-if-modified-since
    case sourceIfModifiedSince = "x-ms-source-if-modified-since"
    /// x-ms-source-if-none-match
    case sourceIfNoneMatch = "x-ms-source-if-none-match"
    /// x-ms-source-if-unmodified-since
    case sourceIfUnmodifiedSince = "x-ms-source-if-unmodified-since"
    /// x-ms-source-range
    case sourceRange = "x-ms-source-range"
    /// x-ms-tag-count
    case tagCount = "x-ms-tag-count"

    public var requestString: String {
        return rawValue
    }
}

public extension HTTPHeaders {
    /// Access the value of an `StorageHTTPHeader` within a collection of `HTTPHeaders`.
    /// - Parameters:
    ///   - index: The `StorageHTTPHeader` value to access.
    subscript(index: StorageHTTPHeader) -> String? {
        get {
            return self[index.requestString]
        }

        set(newValue) {
            self[index.requestString] = newValue
        }
    }

    /// Remove an `StorageHTTPHeader` value from a collection of `HTTPHeaders`.
    /// - Parameters:
    ///   - index: The `StorageHTTPHeader` value to remove.
    mutating func removeValue(forKey key: StorageHTTPHeader) -> Value? {
        return removeValue(forKey: key.requestString)
    }
}
