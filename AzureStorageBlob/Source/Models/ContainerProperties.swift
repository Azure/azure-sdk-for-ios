//
//  ContainerProperties.swift
//  AzureStorageBlob
//
//  Created by Travis Prescott on 10/8/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import AzureCore
import Foundation

public final class ContainerProperties: XMLModelProtocol {
    public let lastModified: Date
    public let eTag: String
    public let leaseStatus: LeaseStatus
    public let leaseState: LeaseState
    public let leaseDuration: LeaseDuration?
    public let hasImmutabilityPolicy: Bool?
    public let hasLegalHold: Bool?

    public init(lastModified: Date,
                eTag: String,
                leaseStatus: LeaseStatus,
                leaseState: LeaseState,
                leaseDuration: LeaseDuration? = nil,
                hasImmutabilityPolicy: Bool? = nil,
                hasLegalHold: Bool? = nil) {
        self.lastModified = lastModified
        self.eTag = eTag
        self.leaseStatus = leaseStatus
        self.leaseState = leaseState
        self.leaseDuration = leaseDuration
        self.hasImmutabilityPolicy = hasImmutabilityPolicy
        self.hasLegalHold = hasLegalHold
    }

    public static func xmlMap() -> XMLMap {
        return XMLMap([
            "Last-Modified": XMLMetadata(jsonName: "lastModified"),
            "Etag": XMLMetadata(jsonName: "eTag"),
            "LeaseStatus": XMLMetadata(jsonName: "leaseStatus"),
            "LeaseState": XMLMetadata(jsonName: "leaseState"),
            "LeaseDuration": XMLMetadata(jsonName: "leaseDuration"),
            "HasImmutabilityPolicy": XMLMetadata(jsonName: "hasImmutabilityPolicy"),
            "HasLegalHold": XMLMetadata(jsonName: "hasLegalHold"),
        ])
    }
}

extension ContainerProperties: Codable {
    public convenience init(from decoder: Decoder) throws {
        let root = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            lastModified: try root.decode(Date.self, forKey: .lastModified),
            eTag: try root.decode(String.self, forKey: .eTag),
            leaseStatus: try root.decode(LeaseStatus.self, forKey: .leaseStatus),
            leaseState: try root.decode(LeaseState.self, forKey: .leaseState),
            leaseDuration: try root.decodeIfPresent(LeaseDuration.self, forKey: .leaseDuration),
            hasImmutabilityPolicy: try root.decodeBoolIfPresent(forKey: .hasImmutabilityPolicy),
            hasLegalHold: try root.decodeBoolIfPresent(forKey: .hasLegalHold)
        )
    }
}
