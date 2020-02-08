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

import Foundation

public struct LeaseAccessConditions {
    public var leaseId: String
}

public struct ModifiedAccessConditions {
    public var ifModifiedSince: Date?
    public var ifUnmodifiedSince: Date?
    public var ifMatch: String?
    public var ifNoneMatch: String?
}

public struct RangeOptions {
    /// Start of byte range to use for downloading a section of the blob.
    /// Must be set if length is provided.
    public var offset = 0

    /// Number of bytes to read from the stream. Should be specified
    /// for optimal performance.
    public var length: Int?

    /// When set to true, the service returns the MD5 hash for the range
    /// as long as the range is less than or equal to 4 MB in size.
    public var calculateMD5: Bool?

    /// When set to true, the service returns the CRC64 hash for the range
    /// as long as the range is less than or equal to 4 MB in size.
    public var calculateCRC64: Bool?

    public init() {}
}

public struct DestinationOptions {
    /// When set to true, files will be downloaded to the app's tmp
    /// folder.
    public var isTemporary = false

    /// Override the default destination subfolder, which is the container name.
    public var subfolder: String?

    /// Override the default destination filename, which is the blob name.
    public var filename: String?

    public init() {}
}

public class EncryptionOptions {
    // MARK: Public Properties

    /// Actual key data in bytes.
    public let key: Data?

    /// Dictionary mapping resources to keys.
    public let keyResolver: [String: Data]?

    /// Specify whether encryption is required.
    public var required: Bool

    // MARK: Initializers

    public init(key: Data? = nil, keyResolver: [String: Data]? = nil, required: Bool = false) {
        self.key = key
        self.keyResolver = keyResolver
        self.required = required
    }
}

public struct CpkInfo {
    public let key: Data

    public var hash: String {
        // TODO: Needs implementation.
        return ""
    }

    public let algorithm: String
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
public class CustomerProvidedEncryptionKey {
    /// Base64-encoded AES-256 encryption key value.
    public let value: Data

    /// Base64-encoded SHA256 of the encryption key.
    public var hash: String {
        // TODO: Needs implementation.
        return ""
    }

    /// Specifies the algorithm to use when encrypting data using the given key. Must be AES256.
    public let algorithm = "AES256"

    public init(_ value: Data) {
        self.value = value.base64EncodedData()
    }
}

/**
 A user delegation key.
 */
public struct UserDelegationKey {
    /// The Azure Active Directory object ID in GUID format.
    public let signedOID: String

    /// The Azure Active Directory tenant ID in GUID format.
    public let signedTID: String

    /// The date-time the key is active.
    public let signedStart: String

    /// The date-time the key expires.
    public let signedExpiry: String

    /// Abbreviation of the Azure Storage service that accepts the key.
    public let signedService: String

    /// The service version that created the key.
    public let signedVersion: String

    /// The key as a base64 string.
    public let value: String

    public init(
        signedOID: String,
        signedTID: String,
        signedStart: String,
        signedExpiry: String,
        signedService: String,
        signedVersion: String,
        value: String
    ) {
        self.signedOID = signedOID
        self.signedTID = signedTID
        self.signedStart = signedStart
        self.signedExpiry = signedExpiry
        self.signedService = signedService
        self.signedVersion = signedVersion
        self.value = value
    }
}
