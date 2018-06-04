//
//  ADResourceType.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

@objc(ADResourceType)
public enum ADResourceType: Int {
    @objc(ADResourceTypeDatabase)
    case database

    @objc(ADResourceTypeUser)
    case user

    @objc(ADResourceTypePermission)
    case permission

    @objc(ADResourceTypeCollection)
    case collection

    @objc(ADResourceTypeStoredProcedure)
    case storedProcedure

    @objc(ADResourceTypeTrigger)
    case trigger

    @objc(ADResourceTypeUDF)
    case udf

    @objc(ADResourceTypeDocument)
    case document

    @objc(ADResourceTypeAttachment)
    case attachment

    @objc(ADResourceTypeOffer)
    case offer

    public var description: String {
        switch self {
        case .database:
            return "dbs"
        case .user:
            return "users"
        case .permission:
            return "permissions"
        case .collection:
            return "colls"
        case .storedProcedure:
            return "sprocs"
        case .trigger:
            return "triggers"
        case  .udf:
            return "udfs"
        case .document:
            return "docs"
        case .attachment:
            return "attachments"
        case .offer:
            return "offers"
        }
    }

    public var path: String {
        return swiftResourceType.path
    }

    public func isDecendent(of rt: ADResourceType) -> Bool {
        return swiftResourceType.isDecendent(of: rt.swiftResourceType)
    }

    public func isAncestor(of rt: ADResourceType) -> Bool {
        return swiftResourceType.isAncestor(of: rt.swiftResourceType)
    }

    public var supportsPermissionToken: Bool {
        return swiftResourceType.supportsPermissionToken
    }

    public static var ancestors: [ADResourceType] {
        return [.database, .user, .collection, .document]
    }

    private var swiftResourceType: ResourceType { return ResourceType(bridgedFromObjectiveC: self)! }
}

extension ResourceType {
    func bridgeToObjectiveC() -> ADResourceType {
        switch self {
        case .database: return .database
        case .user: return .user
        case .permission: return .permission
        case .collection: return .collection
        case .storedProcedure: return .storedProcedure
        case .trigger: return .trigger
        case .udf: return .udf
        case .document: return .document
        case .attachment: return .attachment
        case .offer: return .offer
        }
    }

    init?(bridgedFromObjectiveC: ADResourceType?) {
        guard let source = bridgedFromObjectiveC else { return nil }
        guard let rt = ResourceType(rawValue: source.description) else { return nil }
        self = rt
    }
}
