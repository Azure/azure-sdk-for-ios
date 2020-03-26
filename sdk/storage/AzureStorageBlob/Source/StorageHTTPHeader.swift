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
public enum StorageHTTPHeader: String {
    /// x-ms-access-tier
    case accessTier = "x-ms-access-tier"
    /// x-ms-blob-cache-control
    case blobCacheControl = "x-ms-blob-cache-control"
    /// x-ms-blob-content-disposition
    case blobContentDisposition = "x-ms-blob-content-disposition"
    /// x-ms-blob-content-encoding
    case blobContentEncoding = "x-ms-blob-content-encoding"
    /// x-ms-blob-content-language
    case blobContentLanguage = "x-ms-blob-content-language"
    /// x-ms-blob-content-md5
    case blobContentMD5 = "x-ms-blob-content-md5"
    /// x-ms-blob-content-type
    case blobContentType = "x-ms-blob-content-type"
    /// x-ms-blob-sequence-number
    case blobSequenceNumber = "x-ms-blob-sequence-number"
    /// x-ms-blob-type
    case blobType = "x-ms-blob-type"
    /// x-ms-content-crc64
    case contentCRC64 = "x-ms-content-crc64"
    /// Content-MD5
    case contentMD5 = "Content-MD5"
    /// x-ms-copy-completion-time
    case copyCompletionTime = "x-ms-copy-completion-time"
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
    /// x-ms-encryption-key
    case encryptionKey = "x-ms-encryption-key"
    /// x-ms-encryption-algorithm
    case encryptionKeyAlgorithm = "x-ms-encryption-algorithm"
    /// x-ms-encryption-key-sha256
    case encryptionKeySHA256 = "x-ms-encryption-key-sha256"
    /// x-ms-encryption-scope
    case encryptionScope = "x-ms-encryption-scope"
    /// x-ms-server-encrypted
    case serverEncrypted = "x-ms-server-encrypted"
    /// x-ms-lease-duration
    case leaseDuration = "x-ms-lease-duration"
    /// x-ms-lease-id
    case leaseId = "x-ms-lease-id"
    /// x-ms-lease-state
    case leaseState = "x-ms-lease-state"
    /// x-ms-lease-status
    case leaseStatus = "x-ms-lease-status"
    /// x-ms-meta
    case metadata = "x-ms-meta"
    /// x-ms-range
    case range = "x-ms-range"
    /// x-ms-range-get-content-md5
    case rangeGetContentMD5 = "x-ms-range-get-content-md5"
    /// x-ms-range-get-content-crc64
    case rangeGetContentCRC64 = "x-ms-range-get-content-crc64"
}

/// :nodoc:
extension HTTPHeaders {
    public subscript(index: StorageHTTPHeader) -> String? {
        get {
            return self[index.rawValue]
        }

        set(newValue) {
            self[index.rawValue] = newValue
        }
    }

    public mutating func removeValue(forKey key: StorageHTTPHeader) -> String? {
        return removeValue(forKey: key.rawValue)
    }
}
