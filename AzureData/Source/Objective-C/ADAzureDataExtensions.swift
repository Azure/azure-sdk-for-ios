//
//  ADAzureDataExtensions.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

// MARK: - Database

public extension ADDatabase {

    // MARK: - Collections

    @objc(createCollectionWithId:completion:)
    public func create(collectionWithId collectionId: String, completion: @escaping (ADResponse) -> Void) {
        ADAzureData.create(collectionWithId: collectionId, in: self, completion: completion)
    }

    @objc(getCollectionsWithCompletion:)
    public func getCollections(completion: @escaping (ADResponse) -> Void) {
        ADAzureData.get(collectionsIn: self, completion: completion)
    }

    @objc(getCollectionsWithMaxPerPage:completion:)
    public func getCollections(maxPerPage: Int, completion: @escaping (ADResponse) -> Void) {
        ADAzureData.get(collectionsIn: self, maxPerPage: maxPerPage, completion: completion)
    }

    @objc(getCollectionWithId:completion:)
    public func get(collectionWithId collectionId: String, completion: @escaping (ADResponse) -> Void) {
        ADAzureData.get(collectionWithId: collectionId, in: self, completion: completion)
    }

    @objc(deleteCollectionWithId:completion:)
    public func delete(collectionWithId collectionId: String, completion: @escaping (ADResponse) -> Void) {
        ADAzureData.delete(collectionWithId: collectionId, from: self, completion: completion)
    }

    // MARK: - Users

    @objc(createUserWithId:completion:)
    public func create(userWithId userId: String, completion: @escaping (ADResponse) -> Void) {
        ADAzureData.create(userWithId: userId, in: self, completion: completion)
    }

    @objc(getUsersWithCompletion:)
    public func getUsers(completion: @escaping (ADResponse) -> Void) {
        ADAzureData.get(usersIn: self, completion: completion)
    }

    @objc(getUsersWithMaxPerPage:completion:)
    public func getUsers(maxPerPage: Int, completion: @escaping (ADResponse) -> Void) {
        ADAzureData.get(usersIn: self, maxPerPage: maxPerPage, completion: completion)
    }

    @objc(getUserWithId:completion:)
    public func get(userWithId userId: String, completion: @escaping (ADResponse) -> Void) {
        ADAzureData.get(userWithId: userId, in: self, completion: completion)
    }

    @objc(deleteUser:completion:)
    public func delete(user: ADUser, completion: @escaping (ADResponse) -> Void) {
        ADAzureData.delete(user, completion: completion)
    }

    @objc(deleteUserWithId:completion:)
    public func delete(userWithId userId: String, completion: @escaping (ADResponse) -> Void) {
        ADAzureData.delete(userWithId: userId, from: self, completion: completion)
    }

    @objc(replaceUserWithId:withNewUserId:completion:)
    public func replace(userWithId userId: String, with newUserId: String, completion: @escaping (ADResponse) -> Void) {
        ADAzureData.replace(userWithId: userId, with: newUserId, in: self, completion: completion)
    }
}

// MARK: - Collection

public extension ADDocumentCollection {

    // MARK: - Documents

    @objc(createDocument:completion:)
    public func create(document: ADDocument, completion: @escaping (ADResponse) -> Void) {
        ADAzureData.create(document: document, in: self, completion: completion)
    }

    @objc(createOrReplaceDocument:completion:)
    public func createOrReplace(document: ADDocument, completion: @escaping (ADResponse) -> Void) {
        ADAzureData.createOrReplace(document: document, in: self, completion: completion)
    }

    @objc(getDocumentsAs:completion:)
    public func get(documentsAs documentType: ADDocument.Type, completion: @escaping (ADResponse) -> Void) {
        ADAzureData.get(documentsAs: documentType, in: self, completion: completion)
    }

    @objc(getDocumentsAs:maxPerPage:completion:)
    public func get(documentsAs documentType: ADDocument.Type, maxPerPage: Int, completion: @escaping (ADResponse) -> Void) {
        ADAzureData.get(documentsAs: documentType, in: self, maxPerPage: maxPerPage, completion: completion)
    }

    @objc(getDocumentWithId:as:completion:)
    public func get(documentWithId documentId: String, as documentType: ADDocument.Type, completion: @escaping (ADResponse) -> Void) {
        ADAzureData.get(documentWithId: documentId, as: documentType, in: self, completion: completion)
    }

    @objc(deleteDocument:completion:)
    public func delete(document: ADDocument, completion: @escaping (ADResponse) -> Void) {
        ADAzureData.delete(document, completion: completion)
    }

    @objc(deleteDocumentWithId:completion:)
    public func delete(documentWithId documentId: String, completion: @escaping (ADResponse) -> Void) {
        ADAzureData.delete(documentWithId: documentId, from: self, completion: completion)
    }

    @objc(replaceDocument:completion:)
    public func replace(document: ADDocument, completion: @escaping (ADResponse) -> Void) {
        ADAzureData.replace(document: document, in: self, completion: completion)
    }

    @objc(queryDocumentsWithQuery:as:completion:)
    public func query(documentsWith query: ADQuery, as documentType: ADDocument.Type, completion: @escaping (ADResponse) -> Void) {
        ADAzureData.query(documentsIn: self, as: documentType, with: query, completion: completion)
    }

    @objc(queryDocumentsWithQuery:as:withMaxPerPage:completion:)
    public func query(documentsWith query: ADQuery, as documentType: ADDocument.Type, maxPerPage: Int, completion: @escaping (ADResponse) -> Void) {
        ADAzureData.query(documentsIn: self, as: documentType, with: query, maxPerPage: maxPerPage, completion: completion)
    }

    // MARK: - Stored Procedures

    @objc(createStoredProcedureWithId:andBody:completion:)
    public func create(storedProcedureWithId id: String, andBody body: String, completion: @escaping (ADResponse) -> Void) {
        ADAzureData.create(storedProcedureWithId: id, andBody: body, in: self, completion: completion)
    }

    @objc(getStoredProceduresWithCompletion:)
    public func getStoredProcedures(completion: @escaping (ADResponse) -> Void) {
        ADAzureData.get(storedProceduresIn: self, completion: completion)
    }

    @objc(getStoredProceduresWithMaxPerPage:Completion:)
    public func getStoredProcedures(maxPerPage: Int, completion: @escaping (ADResponse) -> Void) {
        ADAzureData.get(storedProceduresIn: self, maxPerPage: maxPerPage, completion: completion)
    }

    @objc(deleteStoredProcedure:completion:)
    public func delete(storedProcedure: ADStoredProcedure, completion: @escaping (ADResponse) -> Void) {
        ADAzureData.delete(storedProcedure, completion: completion)
    }

    @objc(deleteStoredProcedureWithId:completion:)
    public func delete(storedProcedureWithId id: String, completion: @escaping (ADResponse) -> Void) {
        ADAzureData.delete(storedProcedureWithId: id, from: self, completion: completion)
    }

    @objc(replaceStoredProcedureWithId:andBody:completion:)
    public func replace(storedProcedureWithId id: String, andBody body: String, completion: @escaping (ADResponse) -> Void) {
        ADAzureData.replace(storedProcedureWithId: id, andBody: body, in: self, completion: completion)
    }

    @objc(executeStoredProcedure:usingParameters:completion:)
    public func execute(storedProcedure: ADStoredProcedure, usingParameters parameters: [String]?, completion: @escaping (ADResponse) -> Void) {
        ADAzureData.execute(storedProcedure: storedProcedure, usingParameters: parameters, completion: completion)
    }

    @objc(executeStoredProcedureWithId:usingParameters:completion:)
    public func execute(storedProcedureWithId id: String, usingParameters parameters: [String]?, completion: @escaping (ADResponse) -> Void) {
        ADAzureData.execute(storedProcedureWithId: id, usingParameters: parameters, in: self, completion: completion)
    }

    // MARK: - User Defined Functions

    @objc(createUserDefinedFunctionWithId:andBody:completion:)
    public func create(userDefinedFunctionWithId id: String, andBody body: String, completion: @escaping (ADResponse) -> Void) {
        ADAzureData.create(userDefinedFunctionWithId: id, andBody: body, in: self, completion: completion)
    }

    @objc(getUserDefinedFunctionsWithCompletion:)
    public func getUserDefinedFunctions(completion: @escaping (ADResponse) -> Void) {
        ADAzureData.get(userDefinedFunctionsIn: self, completion: completion)
    }

    @objc(getUserDefinedFunctionsWithMaxPerPage:completion:)
    public func getUserDefinedFunctions(maxPerPage: Int, completion: @escaping (ADResponse) -> Void) {
        ADAzureData.get(userDefinedFunctionsIn: self, maxPerPage: maxPerPage, completion: completion)
    }

    @objc(deleteUserDefinedFunction:completion:)
    public func delete(userDefinedFunction: ADUserDefinedFunction, completion: @escaping (ADResponse) -> Void) {
        ADAzureData.delete(userDefinedFunction, completion: completion)
    }

    @objc(deleteUserDefinedFunctionWithId:completion:)
    public func delete(userDefinedFunctionWithId id: String, completion: @escaping (ADResponse) -> Void) {
        ADAzureData.delete(userDefinedFunctionWithId: id, from: self, completion: completion)
    }

    @objc(replaceUserDefinedFunctionWithId:andBody:completion:)
    public func replace(userDefinedFunctionWithId id: String, andBody body: String, completion: @escaping (ADResponse) -> Void) {
        ADAzureData.replace(userDefinedFunctionWithId: id, andBody: body, in: self, completion: completion)
    }

    // MARK: - Triggers

    @objc(createTriggerWithId:operation:type:andBody:completion:)
    public func create(triggerWithId id: String, operation: ADTrigger.ADTriggerOperation, type: ADTrigger.ADTriggerType, andBody body: String, completion: @escaping (ADResponse) -> Void) {
        ADAzureData.create(triggerWithId: id, operation: operation, type: type, andBody: body, in: self, completion: completion)
    }

    @objc(getTriggersWithCompletion:)
    public func getTriggers(completion: @escaping (ADResponse) -> Void) {
        ADAzureData.get(triggersIn: self, completion: completion)
    }

    @objc(getTriggersWithMaxPerPage:completion:)
    public func getTriggers(maxPerPage: Int, completion: @escaping (ADResponse) -> Void) {
        ADAzureData.get(triggersIn: self, maxPerPage: maxPerPage, completion: completion)
    }

    @objc(deleteTrigger:completion:)
    public func delete(trigger: ADTrigger, completion: @escaping (ADResponse) -> Void) {
        ADAzureData.delete(trigger, completion: completion)
    }

    @objc(deleteTriggerWithId:completion:)
    public func delete(triggerWithId triggerId: String, completion: @escaping (ADResponse) -> Void) {
        ADAzureData.delete(triggerWithId: triggerId, from: self, completion: completion)
    }

    @objc(replaceTriggerWithId:operation:type:andBody:completion:)
    public func replace(triggerWithId triggerId: String, operation: ADTrigger.ADTriggerOperation, type: ADTrigger.ADTriggerType, andBody body: String, completion: @escaping (ADResponse) -> Void) {
        ADAzureData.replace(triggerWithId: triggerId, operation: operation, type: type, andBody: body, in: self, completion: completion)
    }
}

// MARK: - Document

public extension ADDocument {

    // MARK: - Attachments

    @objc(createAttachmentWithId:contentType:andMediaUrl:completion:)
    public func create(attachmentWithId attachmentId: String, contentType: String, andMediaUrl mediaUrl: URL, completion: @escaping (ADResponse) -> Void) {
        ADAzureData.create(attachmentWithId: attachmentId, contentType: contentType, andMediaUrl: mediaUrl, on: self, completion: completion)
    }

    @objc(createAttachmentWithId:contentType:name:andMedia:completion:)
    public func create(attachmentWithId attachmentId: String, contentType: String, name mediaName: String, with media: Data, completion: @escaping (ADResponse) -> Void) {
        ADAzureData.create(attachmentWithId: attachmentId, contentType: contentType, name: mediaName, with: media, on: self, completion: completion)
    }

    @objc(getAttachmentsWithCompletion:)
    public func getAttachments(completion: @escaping (ADResponse) -> Void) {
        ADAzureData.get(attachmentsOn: self, completion: completion)
    }

    @objc(getAttachmentsWithMaxPerPage:completion:)
    public func getAttachments(maxPerPage: Int, completion: @escaping (ADResponse) -> Void) {
        ADAzureData.get(attachmentsOn: self, maxPerPage: maxPerPage, completion: completion)
    }

    @objc(deleteAttachment:completion:)
    public func delete(attachment: ADAttachment, completion: @escaping (ADResponse) -> Void) {
        ADAzureData.delete(attachment, completion: completion)
    }

    @objc(deleteAttachmentWithId:completion:)
    public func delete(attachmentWithId attachmentId: String, completion: @escaping (ADResponse) -> Void) {
        ADAzureData.delete(attachmentWithId: attachmentId, from: self, completion: completion)
    }

    @objc(replaceAttachmentWithId:contentType:andMediaUrl:completion:)
    public func replace(attachmentWithId attachmentId: String, contentType: String, andMediaUrl mediaUrl: URL, completion: @escaping (ADResponse) -> Void) {
        ADAzureData.replace(attachmentWithId: attachmentId, contentType: contentType, andMediaUrl: mediaUrl, on: self, completion: completion)
    }

    @objc(replaceAttachmentWithId:contentType:name:andMedia:completion:)
    public func replace(attachmentWithId attachmentId: String, contentType: String, name mediaName: String, with media: Data, completion: @escaping (ADResponse) -> Void) {
        ADAzureData.replace(attachmentWithId: attachmentId, contentType: contentType, name: mediaName, with: media, on: self, completion: completion)
    }
}

// MARK: - User

public extension ADUser {

    // MARK: - Permissions

    @objc(createPermissionWithId:andMode:inResource:completion:)
    public func create(permissionWithId permissionId: String, mode permissionMode: ADPermissionMode, in resource: ADResource & ADSupportsPermissionToken, completion: @escaping (ADResponse) -> Void) {
        ADAzureData.create(permissionWithId: permissionId, mode: permissionMode, in: resource, for: self, completion: completion)
    }

    @objc(getPermissionsWithCompletion:)
    public func getPermissions(completion: @escaping (ADResponse) -> Void) {
        ADAzureData.get(permissionsFor: self, completion: completion)
    }

    @objc(getPermissionsWithMaxPerPage:completion:)
    public func getPermissions(maxPerPage: Int, completion: @escaping (ADResponse) -> Void) {
        ADAzureData.get(permissionsFor: self, maxPerPage: maxPerPage, completion: completion)
    }

    @objc(getPermissionWithId:completion:)
    public func get(permissionWithId permissionId: String, completion: @escaping (ADResponse) -> Void) {
        ADAzureData.get(permissionWithId: permissionId, for: self, completion: completion)
    }

    @objc(deletePermission:completion:)
    public func delete(permission: ADPermission, completion: @escaping (ADResponse) -> Void) {
        ADAzureData.delete(permission, completion: completion)
    }

    @objc(deletePermissionWithId:completion:)
    public func delete(permissionWithId permissionId: String, completion: @escaping (ADResponse) -> Void) {
        ADAzureData.delete(permissionWithId: permissionId, from: self, completion: completion)
    }

    @objc(replacePermissionWithId:mode:inResource:completion:)
    public func replace(permissionWithId permissionId: String, mode permissionMode: ADPermissionMode, in resource: ADResource & ADSupportsPermissionToken, completion: @escaping (ADResponse) -> Void) {
        ADAzureData.replace(permissionWithId: permissionId, mode: permissionMode, in: resource, for: self, completion: completion)
    }
}

// MARK: - Stored Procedure

public extension ADStoredProcedure {
    @objc(executeUsingParameters:completion:)
    public func execute(usingParameters: [String]?, completion: @escaping (ADResponse) -> Void) {
        ADAzureData.execute(storedProcedure: self, usingParameters: usingParameters, completion: completion)
    }
}
