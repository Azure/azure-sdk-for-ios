//
//  BlobContainer.swift
//  AzureStorageBlob
//
//  Created by Travis Prescott on 9/27/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

public enum LeaseStatus: String, Codable {
    case locked, unlocked
}

public enum LeaseState: String, Codable {
    case available, leased, expired, breaking, broken
}

public enum LeaseDuration: String, Codable {
    case infinite, fixed
}

public enum PublicAccess: String, Codable {
    case container, blob
}

public class BlobContainer: Codable {

    public let name: String
    public let lastModified: Date
    public let eTag: String
    public let leaseStatus: LeaseStatus
    public let leaseState: LeaseState
    public let leaseDuration: LeaseDuration
    public let publicAccess: PublicAccess
    public let hasImmutabilityPolicy: Bool
    public let hasLegalHold: Bool

    init(name: String, lastModified: Date, eTag: String, leaseStatus: LeaseStatus, leaseState: LeaseState,
         leaseDuration: LeaseDuration, publicAccess: PublicAccess, hasImmutabilityPolicy: Bool,
         hasLegalHold: Bool) {
        self.name = name
        self.lastModified = lastModified
        self.eTag = eTag
        self.leaseStatus = leaseStatus
        self.leaseState = leaseState
        self.leaseDuration = leaseDuration
        self.publicAccess = publicAccess
        self.hasImmutabilityPolicy = hasImmutabilityPolicy
        self.hasLegalHold = hasLegalHold
    }
}
