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

/// Options for accessing a blob based on the condition of a lease. If specified, the operation will be performed only
/// if both of the following conditions are met:
/// - The blob's lease is currently active.
/// - The specified lease ID matches that of the blob.
public struct LeaseAccessConditions: Codable, Equatable {
    /// The lease ID which must match that of the blob.
    public let leaseId: String

    /// Initialize a `LeaseAccessConditions` structure.
    /// - Parameter leaseId: The lease ID which must match that of the blob.
    public init(leaseId: String) {
        self.leaseId = leaseId
    }
}

/// Options for accessing a blob based on its modification date and/or eTag. If specified, the operation will be
/// performed only if all the specified conditions are met.
public struct ModifiedAccessConditions: Codable, Equatable {
    /// Perform the operation only if the blob has been modified since the specified date.
    public let ifModifiedSince: Rfc1123Date?
    /// Perform the operation only if the blob has not been modified since the specified date.
    public let ifUnmodifiedSince: Rfc1123Date?
    /// Perform the operation only if the blob's `eTag` matches the value specified.
    public internal(set) var ifMatch: String?
    /// Perform the operation only if the blob's `eTag` does not match the value specified.
    public let ifNoneMatch: String?

    /// Initialize a `ModifiedAccessConditions` structure.
    /// - Parameters:
    ///   - ifModifiedSince: Perform the operation only if the blob has been modified since the specified date.
    ///   - ifUnmodifiedSince: Perform the operation only if the blob has not been modified since the specified date.
    ///   - ifMatch: Perform the operation only if the blob's `eTag` matches the value specified.
    ///   - ifNoneMatch: Perform the operation only if the blob's `eTag` does not match the value specified.
    public init(
        ifModifiedSince: Date? = nil,
        ifUnmodifiedSince: Date? = nil,
        ifMatch: String? = nil,
        ifNoneMatch: String? = nil
    ) {
        self.ifModifiedSince = Rfc1123Date(ifModifiedSince)
        self.ifUnmodifiedSince = Rfc1123Date(ifUnmodifiedSince)
        self.ifMatch = ifMatch
        self.ifNoneMatch = ifNoneMatch
    }
}

/// Options for working on a subset of data for a blob.
public struct RangeOptions: Codable, Equatable {
    /// Start of byte range to use for downloading a section of the blob.
    /// Must be set if length is provided.
    public let offsetBytes: Int
    /// Number of bytes to read from the stream. Should be specified
    /// for optimal performance.
    public let lengthInBytes: Int?
    /// When set to true, the service returns the MD5 hash for the range
    /// as long as the range is less than or equal to 4 MB in size.
    public let calculateMD5: Bool?
    /// When set to true, the service returns the CRC64 hash for the range
    /// as long as the range is less than or equal to 4 MB in size.
    public let calculateCRC64: Bool?

    /// Initialize a `RangeOptions` structure.
    /// - Parameters:
    ///   - offsetBytes: Start of byte range to use for downloading a section of the blob. Must be set if length is
    ///     provided.
    ///   - lengthInBytes: Number of bytes to read from the stream. Should be specified for optimal performance.
    ///   - calculateMD5: When set to true, the service returns the MD5 hash for the range as long as the range is less
    ///     than or equal to 4 MB in size.
    ///   - calculateCRC64: When set to true, the service returns the CRC64 hash for the range as long as the range is
    ///     less than or equal to 4 MB in size.
    public init(
        offsetBytes: Int = 0,
        lengthInBytes: Int? = nil,
        calculateMD5: Bool? = nil,
        calculateCRC64: Bool? = nil
    ) {
        self.offsetBytes = offsetBytes
        self.lengthInBytes = lengthInBytes
        self.calculateMD5 = calculateMD5
        self.calculateCRC64 = calculateCRC64
    }
}

/// Blob encryption options.
public struct EncryptionOptions: Codable, Equatable {
    /// Actual key data in bytes.
    public let key: Data?
    /// Dictionary mapping resources to keys.
    public let keyResolver: [String: Data]?
    /// Specify whether encryption is required.
    public let required: Bool

    /// Initialize an `EncryptionOptions` structure.
    /// - Parameters:
    ///   - key: Actual key data in bytes.
    ///   - keyResolver: Dictionary mapping resources to keys.
    ///   - required: Specify whether encryption is required.
    public init(key: Data? = nil, keyResolver: [String: Data]? = nil, required: Bool = false) {
        self.key = key
        self.keyResolver = keyResolver
        self.required = required
    }
}

/**
 All data in Azure Storage is encrypted at-rest using an account-level encryption key.
 In versions 2018-06-17 and newer, you can manage the key used to encrypt blob contents
 and application metadata per-blob by providing an AES-256 encryption key in requests to the storage service.

 When you use a customer-provided key, Azure Storage does not manage or persist your key.
 When writing data to a blob, the provided key is used to encrypt your data before writing it to disk.
 A SHA-256 hash of the encryption key is written alongside the blob contents,
 and is used to verify that all subsequent operations against the blob use the same encryption key.
 This hash cannot be used to retrieve the encryption key or decrypt the contents of the blob.
 When reading a blob, the provided key is used to decrypt your data after reading it from disk.
 In both cases, the provided encryption key is securely discarded
 as soon as the encryption or decryption process completes.
 */
public struct CustomerProvidedEncryptionKey: Codable, Equatable {
    /// Base64-encoded AES-256 encryption key.
    public let keyData: Data
    /// Base64-encoded SHA256 of the encryption key.
    public var hash: String {
        // TODO: Needs implementation.
        return ""
    }

    /// Specifies the algorithm to use when encrypting data using the given key. Must be AES256.
    var algorithm = "AES256"

    /// Initialize a `CustomerProvidedEncryptionKey` structure.
    /// - Parameter keyData: The binary AES-256 encryption key.
    public init(keyData: Data) {
        self.keyData = keyData.base64EncodedData()
    }
}
