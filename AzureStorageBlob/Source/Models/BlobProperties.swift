//
//  BlobProperties.swift
//  AzureStorageBlob
//
//  Created by Travis Prescott on 10/7/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

public final class BlobProperties {

    public let name: String
    public let deleted: Bool?
    public let snapshot: Date?
    public let metadata: [String: String]?
    public let creationTime: Date?
    public let lastModified: Date?
    public let eTag: String?
    public let contentLength: Int?
    public let contentType: String?
    public let contentEncoding: String?
    public let contentLanguage: String?
    public let contentMD5: String?
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

    public init(name: String,
                deleted: Bool? = nil,
                snapshot: Date? = nil,
                metadata: [String: String]? = nil,
                creationTime: Date? = nil,
                lastModified: Date? = nil,
                eTag: String? = nil,
                contentLength: Int? = nil,
                contentType: String? = nil,
                contentEncoding: String? = nil,
                contentLanguage: String? = nil,
                contentMD5: String? = nil,
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
        self.name = name
        self.deleted = deleted
        self.snapshot = snapshot
        self.metadata = metadata
        self.creationTime = creationTime
        self.lastModified = lastModified
        self.eTag = eTag
        self.contentLength = contentLength
        self.contentType = contentType
        self.contentEncoding = contentEncoding
        self.contentLanguage = contentLanguage
        self.contentMD5 = contentMD5
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
}

extension BlobProperties: Codable {

    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case deleted = "Deleted"
        case snapshot = "Snapshot"
        case properties = "Properties"
        case metadata = "Metadata"

        enum PropertyKeys: String, CodingKey {
            case creationTime = "Creation-Time"
            case lastModified = "Last-Modified"
            case eTag = "eTag"
            case contentLength = "Content-Length"
            case contentType = "Content-Type"
            case contentEncoding = "Content-Encoding"
            case contentLanguage = "Content-Language"
            case contentMD5 = "Content-MD5"
            case cacheControl = "Cache-Control"
            case sequenceNumber = "x-ms-blob-sequence-number"
            case blobType = "BlobType"
            case accessTier = "AccessTier"
            case leaseStatus = "LeaseStatus"
            case leaseState = "LeaseState"
            case leaseDuration = "LeaseDuration"
            case copyId = "CopyId"
            case copyStatus = "CopyStatus"
            case copySource = "CopySource"
            case copyProgress = "CopyProgress"
            case copyCompletionTime = "CopyCompletionTime"
            case copyStatusDescription = "CopyStatusDescription"
            case serverEncrypted = "ServerEncrypted"
            case incrementalCopy = "IncrementalCopy"
            case accessTierInferred = "AccessTierInferred"
            case accessTierChangeTime = "AccessTierChangeTime"
            case deletedTime = "DeletedTime"
            case remainingRetentionDays = "RemainingRetentionDays"
        }
    }

    public convenience init(from decoder: Decoder) throws {
        let root = try decoder.container(keyedBy: CodingKeys.self)
        let properties = try root.nestedContainer(keyedBy: CodingKeys.PropertyKeys.self, forKey: .properties)

        self.init(name: try root.decode(String.self, forKey: .name),
                  deleted: try? root.decode(Bool.self, forKey: .deleted),
                  snapshot: try? root.decode(Date.self, forKey: .snapshot),
                  metadata: try? root.decode([String: String].self, forKey: .metadata),
                  creationTime: try? properties.decode(Date.self, forKey: .creationTime),
                  lastModified: try? properties.decode(Date.self, forKey: .lastModified),
                  eTag: try? properties.decode(String.self, forKey: .eTag),
                  contentLength: try? properties.decode(Int.self, forKey: .contentLength),
                  contentType: try? properties.decode(String.self, forKey: .contentType),
                  contentEncoding: try? properties.decode(String.self, forKey: .contentEncoding),
                  contentLanguage: try? properties.decode(String.self, forKey: .contentLanguage),
                  contentMD5: try? properties.decode(String.self, forKey: .contentMD5),
                  cacheControl: try? properties.decode(String.self, forKey: .cacheControl),
                  sequenceNumber: try? properties.decode(Int.self, forKey: .sequenceNumber),
                  blobType: try? properties.decode(BlobType.self, forKey: .blobType),
                  accessTier: try? properties.decode(AccessTier.self, forKey: .accessTier),
                  leaseStatus: try? properties.decode(LeaseStatus.self, forKey: .leaseStatus),
                  leaseState: try? properties.decode(LeaseState.self, forKey: .leaseState),
                  leaseDuration: try? properties.decode(LeaseDuration.self, forKey: .leaseDuration),
                  copyId: try? properties.decode(String.self, forKey: .copyId),
                  copyStatus: try? properties.decode(CopyStatus.self, forKey: .copyStatus),
                  copySource: try? properties.decode(URL.self, forKey: .copySource),
                  copyProgress: try? properties.decode(String.self, forKey: .copyProgress),
                  copyCompletionTime: try? properties.decode(Date.self, forKey: .copyCompletionTime),
                  copyStatusDescription: try? properties.decode(String.self, forKey: .copyStatusDescription),
                  serverEncrypted: try? properties.decode(Bool.self, forKey: .serverEncrypted),
                  incrementalCopy: try? properties.decode(Bool.self, forKey: .incrementalCopy),
                  accessTierInferred: try? properties.decode(Bool.self, forKey: .accessTierInferred),
                  accessTierChangeTime: try? properties.decode(Date.self, forKey: .accessTierChangeTime),
                  deletedTime: try? properties.decode(Date.self, forKey: .deletedTime),
                  remainingRetentionDays: try? properties.decode(Int.self, forKey: .remainingRetentionDays))
    }

    public func encode(to encoder: Encoder) throws {
        var root = encoder.container(keyedBy: CodingKeys.self)
        try root.encode(name, forKey: .name)
        try root.encode(deleted, forKey: .deleted)
        try root.encode(snapshot, forKey: .snapshot)
        try root.encode(metadata, forKey: .metadata)

        var properties = root.nestedContainer(keyedBy: CodingKeys.PropertyKeys.self, forKey: .properties)
        try properties.encode(lastModified, forKey: .lastModified)
        try properties.encode(eTag, forKey: .eTag)
        try properties.encode(leaseStatus, forKey: .leaseStatus)
        try properties.encode(leaseState, forKey: .leaseState)
        try properties.encode(leaseDuration, forKey: .leaseDuration)
        try properties.encode(creationTime, forKey: .creationTime)
        try properties.encode(contentLength, forKey: .contentLength)
        try properties.encode(contentType, forKey: .contentType)
        try properties.encode(contentEncoding, forKey: .contentEncoding)
        try properties.encode(contentLanguage, forKey: .contentLanguage)
        try properties.encode(contentMD5, forKey: .contentMD5)
        try properties.encode(cacheControl, forKey: .cacheControl)
        try properties.encode(sequenceNumber, forKey: .sequenceNumber)
        try properties.encode(blobType, forKey: .blobType)
        try properties.encode(accessTier, forKey: .accessTier)
        try properties.encode(copyId, forKey: .copyId)
        try properties.encode(copyStatus, forKey: .copyStatus)
        try properties.encode(copySource, forKey: .copySource)
        try properties.encode(copyProgress, forKey: .copyProgress)
        try properties.encode(copyCompletionTime, forKey: .copyCompletionTime)
        try properties.encode(copyStatusDescription, forKey: .copyStatusDescription)
        try properties.encode(serverEncrypted, forKey: .serverEncrypted)
        try properties.encode(incrementalCopy, forKey: .incrementalCopy)
        try properties.encode(accessTierInferred, forKey: .accessTierInferred)
        try properties.encode(accessTierChangeTime, forKey: .accessTierChangeTime)
        try properties.encode(deletedTime, forKey: .deletedTime)
        try properties.encode(remainingRetentionDays, forKey: .remainingRetentionDays)
    }
}
