//
//  SwiftUtilities.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

// MARK: - ADResourceWrapper

class ADResourceWrapper: CodableResource {
    private enum CodingKeys: String, CodingKey {
        case id
        case resourceId         = "_rid"
        case selfLink           = "_self"
        case etag               = "_etag"
        case timestamp          = "_ts"
    }

    static var type: String { return "" }
    static var list: String { return "" }

    var id:         String
    var resourceId: String
    var selfLink:   String?
    var etag:       String?
    var timestamp:  Date?
    var altLink:    String?

    func setEtag(to tag: String) { etag = tag }

    func setAltLink(to link: String) { altLink = link }

    init(_ resource: ADResource) {
        self.id = resource.id
        self.resourceId = resource.resourceId
        self.selfLink = resource.selfLink
        self.etag = resource.etag
        self.timestamp = resource.timestamp
        self.altLink = resource.altLink
    }
}

// MARK: - PermissionEnabledADResourceWrapper

class PermissionEnabledADResourceWrapper: CodableResource, SupportsPermissionToken {
    private enum CodingKeys: String, CodingKey {
        case id
        case resourceId         = "_rid"
        case selfLink           = "_self"
        case etag               = "_etag"
        case timestamp          = "_ts"
    }

    static var type: String { return "" }
    static var list: String { return "" }

    var id:         String
    var resourceId: String
    var selfLink:   String?
    var etag:       String?
    var timestamp:  Date?
    var altLink:    String?

    func setEtag(to tag: String) { etag = tag }

    func setAltLink(to link: String) { altLink = link }

    init(_ resource: ADResource & ADSupportsPermissionToken) {
        self.id = resource.id
        self.resourceId = resource.resourceId
        self.selfLink = resource.selfLink
        self.etag = resource.etag
        self.timestamp = resource.timestamp
        self.altLink = resource.altLink
    }
}

// MARK: - ADPermissionProviderWrapper

class ADPermissionProviderWrapper: PermissionProvider {

    var configuration: PermissionProviderConfiguration! {
        get { return PermissionProviderConfiguration(unconditionallyBridgedFromObjectiveC: permissionProvider.configuration) }
        set { permissionProvider.configuration = configuration.bridgeToObjectiveC() }
    }

    func getPermission(forCollectionWithId collectionId: String, inDatabase databaseId: String, withPermissionMode mode: PermissionMode, completion: @escaping (Response<Permission>) -> Void) {
        permissionProvider.getPermission(forCollectionWithId: collectionId, inDatabase: databaseId, withPermissionMode: ADPermissionMode(mode)) {
            completion(Response<Permission>(unconditionallyBridgedFromObjectiveC: $0))
        }
    }

    func getPermission(forDocumentWithId documentId: String, inCollection collectionId: String, inDatabase databaseId: String, withPermissionMode mode: PermissionMode, completion: @escaping (Response<Permission>) -> Void) {
        permissionProvider.getPermission(forDocumentWithId: documentId, inCollection: collectionId, inDatabase: databaseId, withPermissionMode: ADPermissionMode(mode)) {
            completion(Response<Permission>(unconditionallyBridgedFromObjectiveC: $0))
        }
    }

    func getPermission(forAttachmentsWithId attachmentId: String, onDocument documentId: String, inCollection collectionId: String, inDatabase databaseId: String, withPermissionMode mode: PermissionMode, completion: @escaping (Response<Permission>) -> Void) {
        permissionProvider.getPermission(forAttachmentsWithId: attachmentId, onDocument: documentId, inCollection: collectionId, inDatabase: databaseId, withPermissionMode: ADPermissionMode(mode)) {
            completion(Response<Permission>(unconditionallyBridgedFromObjectiveC: $0))
        }
    }

    func getPermission(forStoredProcedureWithId storedProcedureId: String, inCollection collectionId: String, inDatabase databaseId: String, withPermissionMode mode: PermissionMode, completion: @escaping (Response<Permission>) -> Void) {
        permissionProvider.getPermission(forStoredProcedureWithId: storedProcedureId, inCollection: collectionId, inDatabase: databaseId, withPermissionMode: ADPermissionMode(mode)) {
            completion(Response<Permission>(unconditionallyBridgedFromObjectiveC: $0))
        }
    }

    func getPermission(forUserDefinedFunctionWithId functionId: String, inCollection collectionId: String, inDatabase databaseId: String, withPermissionMode mode: PermissionMode, completion: @escaping (Response<Permission>) -> Void) {
        permissionProvider.getPermission(forUserDefinedFunctionWithId: functionId, inCollection: collectionId, inDatabase: databaseId, withPermissionMode: ADPermissionMode(mode)) {
            completion(Response<Permission>(unconditionallyBridgedFromObjectiveC: $0))
        }
    }

    func getPermission(forTriggerWithId triggerId: String, inCollection collectionId: String, inDatabase databaseId: String, withPermissionMode mode: PermissionMode, completion: @escaping (Response<Permission>) -> Void) {
        permissionProvider.getPermission(forTriggerWithId: triggerId, inCollection: collectionId, inDatabase: databaseId, withPermissionMode: ADPermissionMode(mode)) {
            completion(Response<Permission>(unconditionallyBridgedFromObjectiveC: $0))
        }
    }

    // MARK: -

    private var permissionProvider: ADPermissionProvider

    internal init(_ permissionProvider: ADPermissionProvider) {
        self.permissionProvider = permissionProvider
    }
}
