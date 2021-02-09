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

public extension StorageBlobClient {
    internal static let allowHeadersEnum: [RequestStringConvertible] = [
        HTTPHeader.acceptRanges,
        HTTPHeader.accessControlAllowOrigin,
        HTTPHeader.apiVersion,
        HTTPHeader.clientRequestId,
        HTTPHeader.contentDisposition,
        HTTPHeader.contentEncoding,
        HTTPHeader.contentLanguage,
        HTTPHeader.contentMD5,
        HTTPHeader.contentRange,
        HTTPHeader.range,
        HTTPHeader.returnClientRequestId,
        HTTPHeader.vary,
        HTTPHeader.xmsDate,
        StorageHTTPHeader.accessTier,
        StorageHTTPHeader.accessTierChangeTime,
        StorageHTTPHeader.accessTierInferred,
        StorageHTTPHeader.accountKind,
        StorageHTTPHeader.archiveStatus,
        StorageHTTPHeader.blobAppendOffset,
        StorageHTTPHeader.blobCacheControl,
        StorageHTTPHeader.blobCommittedBlockCount,
        StorageHTTPHeader.blobConditionAppendpos,
        StorageHTTPHeader.blobConditionMaxsize,
        StorageHTTPHeader.blobContentDisposition,
        StorageHTTPHeader.blobContentEncoding,
        StorageHTTPHeader.blobContentLanguage,
        StorageHTTPHeader.blobContentLength,
        StorageHTTPHeader.blobContentMD5,
        StorageHTTPHeader.blobContentType,
        StorageHTTPHeader.blobPublicAccess,
        StorageHTTPHeader.blobSequenceNumber,
        StorageHTTPHeader.blobType,
        StorageHTTPHeader.contentCRC64,
        StorageHTTPHeader.copyAction,
        StorageHTTPHeader.copyCompletionTime,
        StorageHTTPHeader.copyDestinationSnapshot,
        StorageHTTPHeader.copyId,
        StorageHTTPHeader.copyProgress,
        StorageHTTPHeader.copyStatus,
        StorageHTTPHeader.creationTime,
        StorageHTTPHeader.defaultEncryptionScope,
        StorageHTTPHeader.deleteSnapshots,
        StorageHTTPHeader.deleteTypePermanent,
        StorageHTTPHeader.denyEncryptionScopeOverride,
        StorageHTTPHeader.encryptionAlgorithm,
        StorageHTTPHeader.encryptionKeySHA256,
        StorageHTTPHeader.errorCode,
        StorageHTTPHeader.hasImmutabilityPolicy,
        StorageHTTPHeader.hasLegalHold,
        StorageHTTPHeader.ifSequenceNumberEq,
        StorageHTTPHeader.ifSequenceNumberLe,
        StorageHTTPHeader.ifSequenceNumberLt,
        StorageHTTPHeader.incrementalCopy,
        StorageHTTPHeader.leaseAction,
        StorageHTTPHeader.leaseBreakPeriod,
        StorageHTTPHeader.leaseDuration,
        StorageHTTPHeader.leaseId,
        StorageHTTPHeader.leaseState,
        StorageHTTPHeader.leaseStatus,
        StorageHTTPHeader.leaseTime,
        StorageHTTPHeader.pageWrite,
        StorageHTTPHeader.proposedLeaseId,
        StorageHTTPHeader.xmsRange,
        StorageHTTPHeader.rangeGetContentMD5,
        StorageHTTPHeader.rehydratePriority,
        StorageHTTPHeader.requestId,
        StorageHTTPHeader.requestServerEncrypted,
        StorageHTTPHeader.sequenceNumberAction,
        StorageHTTPHeader.serverEncrypted,
        StorageHTTPHeader.skuName,
        StorageHTTPHeader.snapshot,
        StorageHTTPHeader.sourceContentMd5,
        StorageHTTPHeader.sourceIfMatch,
        StorageHTTPHeader.sourceIfModifiedSince,
        StorageHTTPHeader.sourceIfNoneMatch,
        StorageHTTPHeader.sourceIfUnmodifiedSince,
        StorageHTTPHeader.sourceRange,
        StorageHTTPHeader.tagCount
    ]

    /// Header values that are permitted to be logged from StorageBlobClient API calls.
    static var allowHeaders: [String] {
        return LoggingPolicy.defaultAllowHeaders + StorageBlobClient.allowHeadersEnum.map { $0.requestString }
    }

    /// Query string parameter values that are permitted to be logged from StorageBlobClient API calls.
    static let allowQueryParams: [String] = [
        "blockid",
        "blocklisttype",
        "comp",
        "copyid",
        "delimiter",
        "include",
        "marker",
        "maxresults",
        "prefix",
        "prevsnapshot",
        "restype",
        "rscc",
        "rscd",
        "rsce",
        "rscl",
        "rsct",
        "se",
        "si",
        "sip",
        "ske",
        "skoid",
        "sks",
        "skt",
        "sktid",
        "skv",
        "snapshot",
        "sp",
        "spr",
        "sr",
        "srt",
        "ss",
        "st",
        "sv"
    ]
}
