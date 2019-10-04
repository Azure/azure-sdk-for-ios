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

public final class BlobContainer: Codable {

    public let name: String
    public var properties: BlobContainerProperties

    public var lastModified: Date {
        get { return properties.lastModified }
        set { properties.lastModified = newValue }
    }

    public var eTag: String {
        get { return properties.eTag }
        set { properties.eTag = newValue }
    }

    public var leaseStatus: LeaseStatus {
        get { return properties.leaseStatus }
        set { properties.leaseStatus = newValue }
    }

    public var leaseState: LeaseState {
        get { return properties.leaseState }
        set { properties.leaseState = newValue }
    }

    public var leaseDuration: LeaseDuration? {
        get { return properties.leaseDuration }
        set { properties.leaseDuration = newValue }
    }

    public var hasImmutabilityPolicy: String {
        get { return properties.hasImmutabilityPolicy }
        set { properties.hasImmutabilityPolicy = newValue }
    }

    public var hasLegalHold: String {
        get { return properties.hasLegalHold }
        set { properties.hasLegalHold = newValue }
    }

    init(name: String, lastModified: Date, eTag: String, leaseStatus: LeaseStatus, leaseState: LeaseState,
         leaseDuration: LeaseDuration, hasImmutabilityPolicy: Bool,
         hasLegalHold: Bool) {
        self.name = name
        self.properties = BlobContainerProperties(lastModified: lastModified, eTag: eTag, leaseStatus: leaseStatus,
                                                  leaseState: leaseState, leaseDuration: leaseDuration,
                                                  hasImmutabilityPolicy: hasImmutabilityPolicy,
                                                  hasLegalHold: hasLegalHold)
    }

    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case properties = "Properties"
    }
}

// MARK: - Model Properties

public class BlobContainerProperties: Codable {
    public var lastModified: Date
    public var eTag: String
    public var leaseStatus: LeaseStatus
    public var leaseState: LeaseState
    public var leaseDuration: LeaseDuration?
    // TODO: Decodable refuses to convert strings to booleans
    public var hasImmutabilityPolicy: String
    public var hasLegalHold: String

    enum CodingKeys: String, CodingKey {
        case lastModified = "Last-Modified"
        case eTag = "Etag"
        case leaseStatus = "LeaseStatus"
        case leaseState = "LeaseState"
        case leaseDuration = "LeaseDuration"
        case hasImmutabilityPolicy = "HasImmutabilityPolicy"
        case hasLegalHold = "HasLegalHold"
    }

    init(lastModified: Date, eTag: String, leaseStatus: LeaseStatus, leaseState: LeaseState,
         leaseDuration: LeaseDuration?, hasImmutabilityPolicy: Bool,
         hasLegalHold: Bool) {
        self.lastModified = lastModified
        self.eTag = eTag
        self.leaseStatus = leaseStatus
        self.leaseState = leaseState
        self.leaseDuration = leaseDuration
        self.hasImmutabilityPolicy = String(hasImmutabilityPolicy)
        self.hasLegalHold = String(hasLegalHold)
    }
}
