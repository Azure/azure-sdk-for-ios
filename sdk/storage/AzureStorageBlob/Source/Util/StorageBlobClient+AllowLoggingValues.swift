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

extension StorageBlobClient {
    public static let allowHeaders: [String] = LoggingPolicy.defaultAllowHeaders + [
        HTTPHeader.acceptRanges.rawValue,
        HTTPHeader.accessControlAllowOrigin.rawValue,
        HTTPHeader.apiVersion.rawValue,
        HTTPHeader.clientRequestId.rawValue,
        HTTPHeader.contentDisposition.rawValue,
        HTTPHeader.contentEncoding.rawValue,
        HTTPHeader.contentLanguage.rawValue,
        HTTPHeader.contentMD5.rawValue,
        HTTPHeader.contentRange.rawValue,
        HTTPHeader.returnClientRequestId.rawValue,
        HTTPHeader.vary.rawValue,
        HTTPHeader.xmsDate.rawValue,
        StorageHTTPHeader.accessTier.rawValue,
        StorageHTTPHeader.accessTierChangeTime.rawValue,
        StorageHTTPHeader.accessTierInferred.rawValue,
        StorageHTTPHeader.accountKind.rawValue,
        StorageHTTPHeader.archiveStatus.rawValue,
        StorageHTTPHeader.blobAppendOffset.rawValue,
        StorageHTTPHeader.blobCacheControl.rawValue,
        StorageHTTPHeader.blobCommittedBlockCount.rawValue,
        StorageHTTPHeader.blobConditionAppendpos.rawValue,
        StorageHTTPHeader.blobConditionMaxsize.rawValue,
        StorageHTTPHeader.blobContentDisposition.rawValue,
        StorageHTTPHeader.blobContentEncoding.rawValue,
        StorageHTTPHeader.blobContentLanguage.rawValue,
        StorageHTTPHeader.blobContentLength.rawValue,
        StorageHTTPHeader.blobContentMD5.rawValue,
        StorageHTTPHeader.blobContentType.rawValue,
        StorageHTTPHeader.blobPublicAccess.rawValue,
        StorageHTTPHeader.blobSequenceNumber.rawValue,
        StorageHTTPHeader.blobType.rawValue,
        StorageHTTPHeader.contentCRC64.rawValue,
        StorageHTTPHeader.copyAction.rawValue,
        StorageHTTPHeader.copyCompletionTime.rawValue,
        StorageHTTPHeader.copyDestinationSnapshot.rawValue,
        StorageHTTPHeader.copyId.rawValue,
        StorageHTTPHeader.copyProgress.rawValue,
        StorageHTTPHeader.copyStatus.rawValue,
        StorageHTTPHeader.creationTime.rawValue,
        StorageHTTPHeader.defaultEncryptionScope.rawValue,
        StorageHTTPHeader.deleteSnapshots.rawValue,
        StorageHTTPHeader.deleteTypePermanent.rawValue,
        StorageHTTPHeader.denyEncryptionScopeOverride.rawValue,
        StorageHTTPHeader.encryptionAlgorithm.rawValue,
        StorageHTTPHeader.encryptionKeySHA256.rawValue,
        StorageHTTPHeader.errorCode.rawValue,
        StorageHTTPHeader.hasImmutabilityPolicy.rawValue,
        StorageHTTPHeader.hasLegalHold.rawValue,
        StorageHTTPHeader.ifSequenceNumberEq.rawValue,
        StorageHTTPHeader.ifSequenceNumberLe.rawValue,
        StorageHTTPHeader.ifSequenceNumberLt.rawValue,
        StorageHTTPHeader.incrementalCopy.rawValue,
        StorageHTTPHeader.leaseAction.rawValue,
        StorageHTTPHeader.leaseBreakPeriod.rawValue,
        StorageHTTPHeader.leaseDuration.rawValue,
        StorageHTTPHeader.leaseId.rawValue,
        StorageHTTPHeader.leaseState.rawValue,
        StorageHTTPHeader.leaseStatus.rawValue,
        StorageHTTPHeader.leaseTime.rawValue,
        StorageHTTPHeader.pageWrite.rawValue,
        StorageHTTPHeader.proposedLeaseId.rawValue,
        StorageHTTPHeader.range.rawValue,
        StorageHTTPHeader.rangeGetContentMD5.rawValue,
        StorageHTTPHeader.rehydratePriority.rawValue,
        StorageHTTPHeader.requestId.rawValue,
        StorageHTTPHeader.requestServerEncrypted.rawValue,
        StorageHTTPHeader.sequenceNumberAction.rawValue,
        StorageHTTPHeader.serverEncrypted.rawValue,
        StorageHTTPHeader.skuName.rawValue,
        StorageHTTPHeader.snapshot.rawValue,
        StorageHTTPHeader.sourceContentMd5.rawValue,
        StorageHTTPHeader.sourceIfMatch.rawValue,
        StorageHTTPHeader.sourceIfModifiedSince.rawValue,
        StorageHTTPHeader.sourceIfNoneMatch.rawValue,
        StorageHTTPHeader.sourceIfUnmodifiedSince.rawValue,
        StorageHTTPHeader.sourceRange.rawValue,
        StorageHTTPHeader.tagCount.rawValue
    ]

    public static let allowQueryParams: [String] = [
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
