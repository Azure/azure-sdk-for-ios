//
//  BlobContainer.swift
//  AzureStorageBlob
//
//  Created by Travis Prescott on 9/27/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

// MARK: - Enumerations

public enum LeaseStatus: String, Codable {
    case locked, unlocked
}

public enum LeaseState: String, Codable {
    case available, leased, expired, breaking, broken
}

public enum LeaseDuration: String, Codable {
    case infinite, fixed
}

// MARK: - Model

public final class BlobContainer {

    public let name: String
    public let lastModified: Date
    public let eTag: String
    public let leaseStatus: LeaseStatus
    public let leaseState: LeaseState
    public let leaseDuration: LeaseDuration?
    // TODO: Decodable refuses to convert strings to booleans
    public let hasImmutabilityPolicy: Bool
    public let hasLegalHold: Bool

    init(name: String, lastModified: Date, eTag: String, leaseStatus: LeaseStatus, leaseState: LeaseState,
         leaseDuration: LeaseDuration?, hasImmutabilityPolicy: Bool,
         hasLegalHold: Bool) {
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
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let name = try container.decode(String.self, forKey: .name)

        let propertyContainer = try container.nestedContainer(keyedBy: CodingKeys.PropertyKeys.self, forKey: .properties)
        let lastModified = try propertyContainer.decode(Date.self, forKey: .lastModified)
        let eTag = try propertyContainer.decode(String.self, forKey: .eTag)
        let leaseStatus = try propertyContainer.decode(LeaseStatus.self, forKey: .leaseStatus)
        let leaseState = try propertyContainer.decode(LeaseState.self, forKey: .leaseState)
        let leaseDuration = try propertyContainer.decode(Optional<LeaseDuration>.self, forKey: .leaseDuration)
        let hasImmutabilityPolicy = try propertyContainer.decode(String.self, forKey: .hasImmutabilityPolicy)
        let hasLegalHold = try propertyContainer.decode(String.self, forKey: .hasLegalHold)

        self.init(name: name, lastModified: lastModified, eTag: eTag, leaseStatus: leaseStatus, leaseState: leaseState,
                  leaseDuration: leaseDuration, hasImmutabilityPolicy: hasImmutabilityPolicy == "true",
                  hasLegalHold: hasLegalHold == "true")
    }
}
