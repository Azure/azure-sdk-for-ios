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

/// Structure containing properties of a blob or blob snapshot.
public struct BlobProperties: XMLModel, Codable, Equatable {
    /// The date that the blob was created.
    public let creationTime: Rfc1123Date?
    /// The date that the blob was last modified.
    public let lastModified: Rfc1123Date?
    /// The entity tag for the blob.
    public let eTag: String?
    /// The size of the blob in bytes.
    public internal(set) var contentLength: Int?
    /// The content type specified for the blob.
    public let contentType: String?
    /// The value of the blob's Content-Disposition request header, if previously set.
    public let contentDisposition: String?
    /// The value of the blob's Content-Encoding request header, if previously set.
    public let contentEncoding: String?
    /// The value of the blob's Content-Language request header, if previously set.
    public let contentLanguage: String?
    /// The value of the blob's Content-MD5 request header, if previously set.
    public let contentMD5: String?
    /// The value of the blob's x-ms-content-crc64 request header, if previously set.
    public let contentCRC64: String?
    /// The value of the blob's Cache-Control request header, if previously set.
    public let cacheControl: String?
    /// The current sequence number for a page blob. This value is nil for block or append blobs.
    public let sequenceNumber: Int?
    /// The type of the blob.
    public let blobType: BlobType?
    /// The access tier of the blob.
    public let accessTier: AccessTier?
    /// The lease status of the blob.
    public let leaseStatus: LeaseStatus?
    /// The lease state of the blob.
    public let leaseState: LeaseState?
    /// Specifies whether the lease on a blob is of infinite or fixed duration.
    public let leaseDuration: LeaseDuration?
    /// String identifier for the last attempted Copy Blob operation where this blob was the destination blob.
    public let copyId: String?
    /// Status of the copy operation identified by `copyId`.
    public let copyStatus: CopyStatus?
    /// The URL of the source blob used in the copy operation identified by `copyId`.
    public let copySource: URL?
    /// Contains the number of bytes copied and the total bytes in the source blob, for the copy operation identified by
    /// `copyId`.
    public let copyProgress: String?
    /// Completion time of the copy operation identified by `copyId`.
    public let copyCompletionTime: Rfc1123Date?
    /// Describes the cause of a fatal or non-fatal copy operation failure encounted in the copy operation identified by
    /// `copyId`.
    public let copyStatusDescription: String?
    /// Indicates whether the blob data and application metadata are completely encrypted.
    public let serverEncrypted: Bool?
    /// Indicates whether the blob is an incremental copy blob.
    public let incrementalCopy: Bool?
    /// If the access tier is not explicitly set on the blob, indicates whether the access tier is inferred based on the
    /// blob's content length.
    public let accessTierInferred: Bool?
    /// The date that the access tier was last changed on the blob.
    public let accessTierChangeTime: Rfc1123Date?
    /// The date that the blob was soft-deleted.
    public let deletedTime: Rfc1123Date?
    /// The number of days remaining in the blob's time-based retention policy.
    public let remainingRetentionDays: Int?

    // MARK: XMLModel Delegate

    /// :nodoc:
    public static func xmlMap() -> XMLMap {
        return XMLMap([
            "Creation-Time": XMLMetadata(jsonName: "creationTime"),
            "Last-Modified": XMLMetadata(jsonName: "lastModified"),
            "Etag": XMLMetadata(jsonName: "eTag"),
            "Content-Length": XMLMetadata(jsonName: "contentLength"),
            "Content-Type": XMLMetadata(jsonName: "contentType"),
            "Content-Disposition": XMLMetadata(jsonName: "contentDisposition"),
            "Content-Encoding": XMLMetadata(jsonName: "contentEncoding"),
            "Content-Language": XMLMetadata(jsonName: "contentLanguage"),
            "Content-MD5": XMLMetadata(jsonName: "contentMD5"),
            "Content-CRC64": XMLMetadata(jsonName: "contentCRC64"),
            "Cache-Control": XMLMetadata(jsonName: "cacheControl"),
            "x-ms-blob-sequence-number": XMLMetadata(jsonName: "sequenceNumber"),
            "BlobType": XMLMetadata(jsonName: "blobType"),
            "AccessTier": XMLMetadata(jsonName: "accessTier"),
            "LeaseStatus": XMLMetadata(jsonName: "leaseStatus"),
            "LeaseState": XMLMetadata(jsonName: "leaseState"),
            "LeaseDuration": XMLMetadata(jsonName: "leaseDuration"),
            "CopyId": XMLMetadata(jsonName: "copyId"),
            "CopyStatus": XMLMetadata(jsonName: "copyStatus"),
            "CopySource": XMLMetadata(jsonName: "copySource"),
            "CopyProgress": XMLMetadata(jsonName: "copyProgress"),
            "CopyCompletionTime": XMLMetadata(jsonName: "copyCompletionTime"),
            "CopyStatusDescription": XMLMetadata(jsonName: "copyStatusDescription"),
            "ServerEncrypted": XMLMetadata(jsonName: "serverEncrypted"),
            "IncrementalCopy": XMLMetadata(jsonName: "incrementalCopy"),
            "AccessTierInferred": XMLMetadata(jsonName: "accessTierInferred"),
            "AccessTierChangeTime": XMLMetadata(jsonName: "accessTierChangeTime"),
            "DeletedTime": XMLMetadata(jsonName: "deletedTime"),
            "RemainingRetentionDays": XMLMetadata(jsonName: "remainingRetentionDays")
        ])
    }
}

public extension BlobProperties {
    /// Initialize a `BlobProperties` structure.
    /// - Parameters:
    ///   - contentType: The content type specified for the blob.
    ///   - contentDisposition: The value of the blob's Content-Disposition request header.
    ///   - contentEncoding: The value of the blob's Content-Encoding request header.
    ///   - contentLanguage: The value of the blob's Content-Language request header.
    ///   - contentMD5: The value of the blob's Content-MD5 request header.
    ///   - contentCRC64: The value of the blob's x-ms-content-crc64 request header.
    ///   - cacheControl: The value of the blob's Cache-Control request header.
    ///   - accessTier: The access tier of the blob.
    init(
        contentType: String? = nil,
        contentDisposition: String? = nil,
        contentEncoding: String? = nil,
        contentLanguage: String? = nil,
        contentMD5: String? = nil,
        contentCRC64: String? = nil,
        cacheControl: String? = nil,
        accessTier: AccessTier? = nil
    ) {
        self.creationTime = nil
        self.lastModified = nil
        self.eTag = nil
        self.contentLength = nil
        self.contentType = contentType
        self.contentDisposition = contentDisposition
        self.contentEncoding = contentEncoding
        self.contentLanguage = contentLanguage
        self.contentMD5 = contentMD5
        self.contentCRC64 = contentCRC64
        self.cacheControl = cacheControl
        self.sequenceNumber = nil
        self.blobType = nil
        self.accessTier = accessTier
        self.leaseStatus = nil
        self.leaseState = nil
        self.leaseDuration = nil
        self.copyId = nil
        self.copyStatus = nil
        self.copySource = nil
        self.copyProgress = nil
        self.copyCompletionTime = nil
        self.copyStatusDescription = nil
        self.serverEncrypted = nil
        self.incrementalCopy = nil
        self.accessTierInferred = nil
        self.accessTierChangeTime = nil
        self.deletedTime = nil
        self.remainingRetentionDays = nil
    }

    internal init(from headers: HTTPHeaders) {
        self.creationTime = Rfc1123Date(string: headers[.creationTime])
        self.lastModified = Rfc1123Date(string: headers[.lastModified])
        self.copyCompletionTime = Rfc1123Date(string: headers[.copyCompletionTime])

        self.eTag = headers[.etag]
        self.contentType = headers[.contentType]
        self.contentDisposition = headers[.contentDisposition]
        self.contentEncoding = headers[.contentEncoding]
        self.contentLanguage = headers[.contentLanguage]
        self.contentMD5 = headers[.contentMD5]
        self.contentCRC64 = headers[.contentCRC64]
        self.cacheControl = headers[.cacheControl]
        self.copyId = headers[.copyId]
        self.copyProgress = headers[.copyProgress]
        self.copyStatusDescription = headers[.copyStatusDescription]

        self.contentLength = Int(headers[.contentLength])
        self.sequenceNumber = Int(headers[.blobSequenceNumber])
        self.serverEncrypted = Bool(headers[.serverEncrypted])

        self.blobType = BlobType(rawValue: headers[.blobType])
        self.leaseStatus = LeaseStatus(rawValue: headers[.leaseStatus])
        self.leaseState = LeaseState(rawValue: headers[.leaseState])
        self.leaseDuration = LeaseDuration(rawValue: headers[.leaseDuration])
        self.copyStatus = CopyStatus(rawValue: headers[.copyStatus])
        self.copySource = URL(string: headers[.copySource])

        // Not documented as a valid response header
        self.accessTier = nil
        self.incrementalCopy = nil
        self.accessTierInferred = nil
        self.accessTierChangeTime = nil
        self.deletedTime = nil
        self.remainingRetentionDays = nil
    }

    /// :nodoc:
    init(from decoder: Decoder) throws {
        let root = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            creationTime: try root.decodeIfPresent(Rfc1123Date.self, forKey: .creationTime),
            lastModified: try root.decodeIfPresent(Rfc1123Date.self, forKey: .lastModified),
            eTag: try root.decodeIfPresent(String.self, forKey: .eTag),
            contentLength: try root.decodeIntIfPresent(forKey: .contentLength),
            contentType: try root.decodeIfPresent(String.self, forKey: .contentType),
            contentDisposition: try root.decodeIfPresent(String.self, forKey: .contentDisposition),
            contentEncoding: try root.decodeIfPresent(String.self, forKey: .contentEncoding),
            contentLanguage: try root.decodeIfPresent(String.self, forKey: .contentLanguage),
            contentMD5: try root.decodeIfPresent(String.self, forKey: .contentMD5),
            contentCRC64: try root.decodeIfPresent(String.self, forKey: .contentCRC64),
            cacheControl: try root.decodeIfPresent(String.self, forKey: .cacheControl),
            sequenceNumber: try root.decodeIntIfPresent(forKey: .sequenceNumber),
            blobType: try root.decodeIfPresent(BlobType.self, forKey: .blobType),
            accessTier: try root.decodeIfPresent(AccessTier.self, forKey: .accessTier),
            leaseStatus: try root.decodeIfPresent(LeaseStatus.self, forKey: .leaseStatus),
            leaseState: try root.decodeIfPresent(LeaseState.self, forKey: .leaseState),
            leaseDuration: try root.decodeIfPresent(LeaseDuration.self, forKey: .leaseDuration),
            copyId: try root.decodeIfPresent(String.self, forKey: .copyId),
            copyStatus: try root.decodeIfPresent(CopyStatus.self, forKey: .copyStatus),
            copySource: try URL(string: root.decodeIfPresent(String.self, forKey: .copySource) ?? ""),
            copyProgress: try root.decodeIfPresent(String.self, forKey: .copyProgress),
            copyCompletionTime: try root.decodeIfPresent(Rfc1123Date.self, forKey: .copyCompletionTime),
            copyStatusDescription: try root.decodeIfPresent(String.self, forKey: .copyStatusDescription),
            serverEncrypted: try root.decodeBoolIfPresent(forKey: .serverEncrypted),
            incrementalCopy: try root.decodeBoolIfPresent(forKey: .incrementalCopy),
            accessTierInferred: try root.decodeBoolIfPresent(forKey: .accessTierInferred),
            accessTierChangeTime: try root.decodeIfPresent(Rfc1123Date.self, forKey: .accessTierChangeTime),
            deletedTime: try root.decodeIfPresent(Rfc1123Date.self, forKey: .deletedTime),
            remainingRetentionDays: try root.decodeIntIfPresent(forKey: .remainingRetentionDays)
        )
    }
}
