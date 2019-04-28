//
//  ResourceWriteOperation.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Represents a pending write operation
/// waiting for an internet connection
/// to be performed.
struct ResourceWriteOperation: Codable {

    enum Kind: String, Codable {
        case create
        case replace
        case delete
    }

    /// The type of operation of the write.
    let type: Kind

    /// The raw data of the resource to be written.
    let resource: Data?

    /// The logical location of the resource to be written.
    let resourceLocation: ResourceLocation

    /// The path (relative to the Azure Data caches directory) on
    /// the local filesystem of the directory where the resource, its
    /// children and associated data are stored.
    let resourceLocalContentPath: String

    /// The HTTP headers necessary to perform
    /// the write online.
    let httpHeaders: [String: String]?
}

// MARK: -

extension ResourceWriteOperation {
    /// Returns the write operation with the type updated
    /// to the type provided in parameter.
    func withType(_ type: Kind) -> ResourceWriteOperation {
        return ResourceWriteOperation(type: type, resource: self.resource, resourceLocation: self.resourceLocation, resourceLocalContentPath: self.resourceLocalContentPath, httpHeaders: self.httpHeaders)
    }
}

// MARK: - Equatable

extension ResourceWriteOperation: Equatable {
    static func ==(lhs: ResourceWriteOperation, rhs: ResourceWriteOperation) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

// MARK: - Hashable

extension ResourceWriteOperation: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(resourceLocalContentPath.hashValue)
    }
}

// MARK: -

extension Array where Element == ResourceWriteOperation {
    func sortedByResourceType() -> [ResourceWriteOperation] {
        return self.sorted(by: { lhs, rhs in
            lhs.resourceLocation.resourceType.isAncestor(of: rhs.resourceLocation.resourceType)
        })
    }
}
