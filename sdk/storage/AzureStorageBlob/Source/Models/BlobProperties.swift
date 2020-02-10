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

public final class BlobProperties: XMLModel {
    public let creationTime: Date?
    public let lastModified: Date?
    public let eTag: String?
    public var contentLength: Int?
    public let contentType: String?
    public let contentDisposition: String?
    public let contentEncoding: String?
    public let contentLanguage: String?
    public var contentMD5: String?
    public let contentCRC64: String?
    public let cacheControl: String?
    public let sequenceNumber: Int?
    public let blobType: BlobType?
    public let accessTier: AccessTier?
    public let leaseStatus: LeaseStatus?
    public let leaseState: LeaseState?
    public let leaseDuration: LeaseDuration?
    public let copyId: String?
    public let copyStatus: CopyStatus?
    public let copySource: URL?
    public let copyProgress: String?
    public let copyCompletionTime: Date?
    public let copyStatusDescription: String?
    public let serverEncrypted: Bool?
    public let incrementalCopy: Bool?
    public let accessTierInferred: Bool?
    public let accessTierChangeTime: Date?
    public let deletedTime: Date?
    public let remainingRetentionDays: Int?

    public init(
        creationTime: Date? = nil,
        lastModified: Date? = nil,
        eTag: String? = nil,
        contentLength: Int? = nil,
        contentType: String? = nil,
        contentDisposition: String? = nil,
        contentEncoding: String? = nil,
        contentLanguage: String? = nil,
        contentMD5: String? = nil,
        contentCRC64: String? = nil,
        cacheControl: String? = nil,
        sequenceNumber: Int? = nil,
        blobType: BlobType? = nil,
        accessTier: AccessTier? = nil,
        leaseStatus: LeaseStatus? = nil,
        leaseState: LeaseState? = nil,
        leaseDuration: LeaseDuration? = nil,
        copyId: String? = nil,
        copyStatus: CopyStatus? = nil,
        copySource: URL? = nil,
        copyProgress: String? = nil,
        copyCompletionTime: Date? = nil,
        copyStatusDescription: String? = nil,
        serverEncrypted: Bool? = nil,
        incrementalCopy: Bool? = nil,
        accessTierInferred: Bool? = nil,
        accessTierChangeTime: Date? = nil,
        deletedTime: Date? = nil,
        remainingRetentionDays: Int? = nil
    ) {
        self.creationTime = creationTime
        self.lastModified = lastModified
        self.eTag = eTag
        self.contentLength = contentLength
        self.contentType = contentType
        self.contentDisposition = contentDisposition
        self.contentEncoding = contentEncoding
        self.contentLanguage = contentLanguage
        self.contentMD5 = contentMD5
        self.contentCRC64 = contentCRC64
        self.cacheControl = cacheControl
        self.sequenceNumber = sequenceNumber
        self.blobType = blobType
        self.accessTier = accessTier
        self.leaseStatus = leaseStatus
        self.leaseState = leaseState
        self.leaseDuration = leaseDuration
        self.copyId = copyId
        self.copyStatus = copyStatus
        self.copySource = copySource
        self.copyProgress = copyProgress
        self.copyCompletionTime = copyCompletionTime
        self.copyStatusDescription = copyStatusDescription
        self.serverEncrypted = serverEncrypted
        self.incrementalCopy = incrementalCopy
        self.accessTierInferred = accessTierInferred
        self.accessTierChangeTime = accessTierChangeTime
        self.deletedTime = deletedTime
        self.remainingRetentionDays = remainingRetentionDays
    }

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

    internal init(from headers: HTTPHeaders) {
        creationTime = Date(headers[.creationTime], format: .rfc1123)
        lastModified = Date(headers[.lastModified], format: .rfc1123)
        copyCompletionTime = Date(headers[.copyCompletionTime], format: .rfc1123)

        eTag = headers[.etag]
        contentType = headers[.contentType]
        contentDisposition = headers[.contentDisposition]
        contentEncoding = headers[.contentEncoding]
        contentLanguage = headers[.contentLanguage]
        contentMD5 = headers[.contentMD5]
        contentCRC64 = headers[.contentCRC64]
        cacheControl = headers[.cacheControl]
        copyId = headers[.copyId]
        copyProgress = headers[.copyProgress]
        copyStatusDescription = headers[.copyStatusDescription]

        contentLength = Int(headers[.contentLength])
        sequenceNumber = Int(headers[.blobSequenceNumber])
        serverEncrypted = Bool(headers[.serverEncrypted])

        blobType = BlobType(rawValue: headers[.blobType])
        leaseStatus = LeaseStatus(rawValue: headers[.leaseStatus])
        leaseState = LeaseState(rawValue: headers[.leaseState])
        leaseDuration = LeaseDuration(rawValue: headers[.leaseDuration])
        copyStatus = CopyStatus(rawValue: headers[.copyStatus])
        copySource = URL(string: headers[.copySource])

        // Not documented as a valid response header
        accessTier = nil
        incrementalCopy = nil
        accessTierInferred = nil
        accessTierChangeTime = nil
        deletedTime = nil
        remainingRetentionDays = nil
    }
}

extension BlobProperties: Codable {
    public convenience init(from decoder: Decoder) throws {
        let root = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            creationTime: try root.decodeIfPresent(Date.self, forKey: .creationTime),
            lastModified: try root.decodeIfPresent(Date.self, forKey: .lastModified),
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
            copyCompletionTime: try root.decodeIfPresent(Date.self, forKey: .copyCompletionTime),
            copyStatusDescription: try root.decodeIfPresent(String.self, forKey: .copyStatusDescription),
            serverEncrypted: try root.decodeBoolIfPresent(forKey: .serverEncrypted),
            incrementalCopy: try root.decodeBoolIfPresent(forKey: .incrementalCopy),
            accessTierInferred: try root.decodeBoolIfPresent(forKey: .accessTierInferred),
            accessTierChangeTime: try root.decodeIfPresent(Date.self, forKey: .accessTierChangeTime),
            deletedTime: try root.decodeIfPresent(Date.self, forKey: .deletedTime),
            remainingRetentionDays: try root.decodeIntIfPresent(forKey: .remainingRetentionDays)
        )
    }
}
