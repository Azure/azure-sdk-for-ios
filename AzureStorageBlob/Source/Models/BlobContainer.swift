//
//  BlobContainer.swift
//  AzureStorageBlob
//
//  Created by Travis Prescott on 9/27/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

// MARK: - Model

public final class BlobContainer {

    public let name: String
    public let lastModified: Date
    public let eTag: String
    public let leaseStatus: LeaseStatus
    public let leaseState: LeaseState
    public let leaseDuration: LeaseDuration?
    public let hasImmutabilityPolicy: Bool?
    public let hasLegalHold: Bool?

    init(name: String,
         lastModified: Date,
         eTag: String,
         leaseStatus: LeaseStatus,
         leaseState: LeaseState,
         leaseDuration: LeaseDuration? = nil,
         hasImmutabilityPolicy: Bool? = nil,
         hasLegalHold: Bool? = nil
    ) {
        self.name = name
        self.lastModified = lastModified
        self.eTag = eTag
        self.leaseStatus = leaseStatus
        self.leaseState = leaseState
        self.leaseDuration = leaseDuration
        self.hasImmutabilityPolicy = hasImmutabilityPolicy
        self.hasLegalHold = hasLegalHold
    }
}

extension BlobContainer: Codable {

    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case properties = "Properties"

        enum PropertyKeys: String, CodingKey {
            case lastModified = "Last-Modified"
            case eTag = "Etag"
            case leaseStatus = "LeaseStatus"
            case leaseState = "LeaseState"
            case leaseDuration = "LeaseDuration"
            case hasImmutabilityPolicy = "HasImmutabilityPolicy"
            case hasLegalHold = "HasLegalHold"
        }
    }

    public convenience init(from decoder: Decoder) throws {
        let root = try decoder.container(keyedBy: CodingKeys.self)
        let properties = try root.nestedContainer(keyedBy: CodingKeys.PropertyKeys.self, forKey: .properties)
        self.init(name: try root.decode(String.self, forKey: .name),
                  lastModified: try properties.decode(Date.self, forKey: .lastModified),
                  eTag: try properties.decode(String.self, forKey: .eTag),
                  leaseStatus: try properties.decode(LeaseStatus.self, forKey: .leaseStatus),
                  leaseState: try properties.decode(LeaseState.self, forKey: .leaseState),
                  leaseDuration: try? properties.decode(LeaseDuration.self, forKey: .leaseDuration),
                  hasImmutabilityPolicy: Bool(try properties.decode(String.self, forKey: .hasImmutabilityPolicy)),
                  hasLegalHold: Bool(try properties.decode(String.self, forKey: .hasLegalHold))
        )
    }

    public func encode(to encoder: Encoder) throws {
        var root = encoder.container(keyedBy: CodingKeys.self)
        try root.encode(name, forKey: .name)

        var properties = root.nestedContainer(keyedBy: CodingKeys.PropertyKeys.self, forKey: .properties)
        try properties.encode(lastModified, forKey: .lastModified)
        try properties.encode(eTag, forKey: .eTag)
        try properties.encode(leaseStatus, forKey: .leaseStatus)
        try properties.encode(leaseState, forKey: .leaseState)
        try properties.encode(leaseDuration, forKey: .leaseDuration)
        try properties.encode(hasImmutabilityPolicy, forKey: .hasImmutabilityPolicy)
        try properties.encode(hasLegalHold, forKey: .hasLegalHold)
    }
}
