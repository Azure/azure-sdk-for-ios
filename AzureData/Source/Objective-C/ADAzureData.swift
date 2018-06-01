//
//  ADAzureData.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

@objc(ADAzureData)
public class ADAzureData: NSObject {

    // MARK: - Configuration

    @objc
    public static func isConfigured() -> Bool {
        return AzureData.isConfigured()
    }

    @objc(configureForAccountNamed:withMasterKey:andPermissionMode:)
    public static func configure(forAccountNamed name: String, withMasterKey key: String, withPermissionMode mode: ADPermissionMode) {
        AzureData.configure(forAccountNamed: name, withMasterKey: key, withPermissionMode: mode.permissionMode)
    }

    @objc(configureForAccountAt:withMasterKey:andPermissionMode:)
    public static func configure(forAccountAt url: URL, withMasterKey key: String, withPermissionMode mode: ADPermissionMode) {
        AzureData.configure(forAccountAt: url, withMasterKey: key, withPermissionMode: mode.permissionMode)
    }

    @objc(configureForAccountNamed:withPermissionProvider:)
    public static func configure(forAccountNamed name: String, withPermissionProvider permissionProvider: ADPermissionProvider) {
        AzureData.configure(forAccountNamed: name, withPermissionProvider: ADPermissionProviderWrapper(permissionProvider))
    }

    @objc(configureForAccountAt:withPermissionProvider:)
    public static func configure(forAccountAt url: URL, withPermissionProvider permissionProvider: ADPermissionProvider) {
        AzureData.configure(forAccountAt: url, withPermissionProvider: ADPermissionProviderWrapper(permissionProvider))
    }

    @objc(configureWithPlistNamed:andPermissionMode:)
    public static func configure(withPlistNamed name: String? = nil, withPermissionMode mode: ADPermissionMode) {
        AzureData.configure(withPlistNamed: name, withPermissionMode: mode.permissionMode)
    }

    // MARK: - Offline Data

    @objc
    public static var offlineDataEnabled: Bool {
        get { return AzureData.offlineDataEnabled }
        set { AzureData.offlineDataEnabled = newValue }
    }

    @objc(purgeOfflineData:)
    public static func purgeOfflineData() throws {
        try AzureData.purgeOfflineData()
    }

    // MARK: - Reset

    @objc
    public static func reset() {
        AzureData.reset()
    }

    // MARK: - Encoders & Decoders

    public static var dateDecoder: ((Decoder) throws -> Date)? {
        get { return AzureData.dateDecoder }
        set { AzureData.dateDecoder = newValue }
    }

    public static var dateEncoder: ((Date, Encoder) throws -> Void)? {
        get { return AzureData.dateEncoder }
        set { AzureData.dateEncoder = newValue }
    }

    public static var jsonEncoder: JSONEncoder {
        get { return AzureData.jsonEncoder }
        set { AzureData.jsonEncoder = newValue }
    }

    public static var jsonDecoder: JSONDecoder {
        get { return AzureData.jsonDecoder }
        set { AzureData.jsonDecoder = newValue }
    }

    // MARK: - Conflict Strategy

    // MARK: - Resource Encryption

    // MARK: - Databases

    // create
    @objc(createDatabaseWithId:completion:)
    public static func create(databaseWithId databaseId: String, completion: @escaping (ADResponse) -> Void) {
        AzureData.create(databaseWithId: databaseId) { completion($0.bridgeToObjectiveC()) }
    }

    // list
    @objc(databasesWithCompletion:)
    public static func databases(completion: @escaping (ADResponse) -> Void) {
        AzureData.databases(maxPerPage: nil) { completion($0.bridgeToObjectiveC()) }
    }

    @objc(databasesWithMaxPerPage:completion:)
    public static func databases(maxPerPage: Int, completion: @escaping (ADResponse) -> Void) {
        AzureData.databases(maxPerPage: maxPerPage) { completion($0.bridgeToObjectiveC()) }
    }

    // get
    @objc(getDatabaseWithId:completion:)
    public static func get(databaseWithId databaseId: String, callback: @escaping (ADResponse) -> Void) {
        AzureData.get(databaseWithId: databaseId) { callback($0.bridgeToObjectiveC()) }
    }

    // delete
    @objc(deleteDatabaseWithId:completion:)
    public static func delete(databaseWithId databaseId: String, completion: @escaping (ADResponse) -> Void) {
        AzureData.delete(databaseWithId: databaseId) { completion($0.bridgeToObjectiveC()) }
    }

    // MARK: - Collections

    // create
    @objc(createCollectionWithId:inDatabaseWithId:completion:)
    public static func create(collectionWithId collectionId: String, inDatabase databaseId: String, completion: @escaping (ADResponse) -> Void) {
        AzureData.create(collectionWithId: collectionId, inDatabase: databaseId) { completion($0.bridgeToObjectiveC()) }
    }

    @objc(createCollectionWithId:inDatabase:completion:)
    public static func create(collectionWithId collectionId: String, in database: ADDatabase, completion: @escaping (ADResponse) -> Void) {
        AzureData.create(collectionWithId: collectionId, inDatabase: database.id) { completion($0.bridgeToObjectiveC()) }
    }

    // list
    @objc(getCollectionsInDatabaseWithId:completion:)
    public static func get(collectionsIn databaseId: String, completion: @escaping (ADResponse) -> Void) {
        AzureData.get(collectionsIn: databaseId, maxPerPage: nil) { completion($0.bridgeToObjectiveC()) }
    }

    @objc(getCollectionsInDatabaseWithId:withMaxPerPage:completion:)
    public static func get(collectionsIn databaseId: String, maxPerPage: Int, callback: @escaping (ADResponse) -> Void) {
        AzureData.get(collectionsIn: databaseId, maxPerPage: maxPerPage) { callback($0.bridgeToObjectiveC()) }
    }

    @objc(getCollectionsInDatabase:completion:)
    public static func get(collectionsIn database: ADDatabase, callback: @escaping (ADResponse) -> Void) {
        AzureData.get(collectionsIn: database.id, maxPerPage: nil) { callback($0.bridgeToObjectiveC()) }
    }

    @objc(getCollectionsInDatabase:withMaxPerPage:completion:)
    public static func get(collectionsIn database: ADDatabase, maxPerPage: Int, callback: @escaping (ADResponse) -> Void) {
        AzureData.get(collectionsIn: database.id, maxPerPage: maxPerPage) { callback($0.bridgeToObjectiveC()) }
    }

    // get
    @objc(getCollectionWithId:inDatabaseWithId:completion:)
    public static func get(collectionWithId collectionId: String, inDatabase databaseId: String, completion: @escaping (ADResponse) -> Void) {
        AzureData.get(collectionWithId: collectionId, inDatabase: databaseId) { completion($0.bridgeToObjectiveC()) }
    }

    @objc(getCollectionWithId:inDatabase:completion:)
    public static func get(collectionWithId collectionId: String, in database: ADDatabase, callback: @escaping (ADResponse) -> Void) {
        AzureData.get(collectionWithId: collectionId, inDatabase: database.id) { callback($0.bridgeToObjectiveC()) }
    }

    // delete
    @objc(deleteCollectionWithId:fromDatabaseWithId:completion:)
    public static func delete(collectionWithId collectionId: String, fromDatabase databaseId: String, completion: @escaping (ADResponse) -> Void) {
        AzureData.delete(collectionWithId: collectionId, fromDatabase: databaseId) { completion($0.bridgeToObjectiveC()) }
    }

    // replace
    @objc(replaceCollectionWithId:inDatabaseWithId:usingPolicy:completion:)
    public static func replace(collectionWithId collectionId: String, inDatabase databaseId: String, usingPolicy policy: ADIndexingPolicy, completion: @escaping (ADResponse) -> Void) {
        AzureData.replace(collectionWithId: collectionId, inDatabase: databaseId, usingPolicy: DocumentCollection.IndexingPolicy(unconditionallyBridgedFromObjectiveC: policy)) { completion($0.bridgeToObjectiveC()) }
    }

    // MARK: - Documents

    // create or replace
    @objc(createDocument:inCollectionWithId:inDatabaseWithId:completion:)
    public static func create(document: ADDocument, inCollection collectionId: String, inDatabase databaseId: String, completion: @escaping (ADResponse) -> Void) {
        AzureData.create(document.dictionaryDocument, inCollection: collectionId, inDatabase: databaseId) {
            let documentType = type(of: document)
            completion($0.bridgeToObjectiveC(withDocumentType: documentType))
        }
    }

    @objc(createDocument:inCollection:completion:)
    public static func create(document: ADDocument, in collection: ADDocumentCollection, completion: @escaping (ADResponse) -> Void) {
        AzureData.create(document.dictionaryDocument, in: DocumentCollection(unconditionallyBridgedFromObjectiveC: collection)) {
            let documentType = type(of: document)
            completion($0.bridgeToObjectiveC(withDocumentType: documentType))
        }
    }

    @objc(createOrReplaceDocument:inCollectionWithId:inDatabaseWithId:completion:)
    public static func createOrReplace(document: ADDocument, inCollection collectionId: String, inDatabase databaseId: String, completion: @escaping (ADResponse) -> Void) {
        AzureData.createOrReplace(document.dictionaryDocument, inCollection: collectionId, inDatabase: databaseId) {
            let documentType = type(of: document)
            completion($0.bridgeToObjectiveC(withDocumentType: documentType))
        }
    }

    @objc(createOrReplaceDocument:inCollection:completion:)
    public static func createOrReplace(document: ADDocument, in collection: ADDocumentCollection, completion: @escaping (ADResponse) -> Void) {
        AzureData.createOrReplace(document.dictionaryDocument, in: DocumentCollection(unconditionallyBridgedFromObjectiveC: collection)) {
            let documentType = type(of: document)
            completion($0.bridgeToObjectiveC(withDocumentType: documentType))
        }
    }

    // list
    @objc(getDocumentsAs:inCollectionWithId:inDatabaseWithId:completion:)
    public static func get(documentsAs documentType: ADDocument.Type, inCollection collectionId: String, inDatabase databaseId: String, completion: @escaping (ADResponse) -> Void) {
        AzureData.get(documentsAs: DictionaryDocument.self, inCollection: collectionId, inDatabase: databaseId, maxPerPage: nil) {
            completion($0.bridgeToObjectiveC(withDocumentType: documentType))
        }
    }

    @objc(getDocumentsAs:inCollectionWithId:inDatabaseWithId:withMaxPerPage:completion:)
    public static func get(documentsAs documentType: ADDocument.Type, inCollection collectionId: String, inDatabase databaseId: String, maxPerPage: Int, completion: @escaping (ADResponse) -> Void) {
        AzureData.get(documentsAs: DictionaryDocument.self, inCollection: collectionId, inDatabase: databaseId, maxPerPage: maxPerPage) {
            completion($0.bridgeToObjectiveC(withDocumentType: documentType))
        }
    }

    @objc(getDocumentsAs:inCollection:completion:)
    public static func get(documentsAs documentType: ADDocument.Type, in collection: ADDocumentCollection, completion: @escaping (ADResponse) -> Void) {
        AzureData.get(documentsAs: DictionaryDocument.self, in: DocumentCollection(unconditionallyBridgedFromObjectiveC: collection), maxPerPage: nil) {
            completion($0.bridgeToObjectiveC(withDocumentType: documentType))
        }
    }

    @objc(getDocumentsAs:inCollection:withMaxPerPage:completion:)
    public static func get(documentsAs documentType: ADDocument.Type, in collection: ADDocumentCollection, maxPerPage: Int, completion: @escaping (ADResponse) -> Void) {
        AzureData.get(documentsAs: DictionaryDocument.self, in: DocumentCollection(unconditionallyBridgedFromObjectiveC: collection), maxPerPage: maxPerPage) {
            completion($0.bridgeToObjectiveC(withDocumentType: documentType))
        }
    }

    // get
    @objc(getDocumentWithId:as:inCollectionWithId:inDatabaseWithId:completion:)
    public static func get(documentWithId documentId: String, as documentType: ADDocument.Type, inCollection collectionId: String, inDatabase databaseId: String, completion: @escaping (ADResponse) -> Void) {
        AzureData.get(documentWithId: documentId, as: DictionaryDocument.self, inCollection: collectionId, inDatabase: databaseId) {
            completion($0.bridgeToObjectiveC(withDocumentType: documentType))
        }
    }

    @objc(getDocumentWithId:as:inCollection:completion:)
    public static func get(documentWithId documentId: String, as documentType: ADDocument.Type, in collection: ADDocumentCollection, completion: @escaping (ADResponse) -> Void) {
        AzureData.get(documentWithId: documentId, as: DictionaryDocument.self, in: DocumentCollection(unconditionallyBridgedFromObjectiveC: collection)) {
            completion($0.bridgeToObjectiveC(withDocumentType: documentType))
        }
    }

    // delete
    @objc(deleteDocumentWithId:fromCollectionWithId:inDatabaseWithId:completion:)
    public static func delete(documentWithId documentId: String, fromCollection collectionId: String, inDatabase databaseId: String, completion: @escaping (ADResponse) -> Void) {
        AzureData.delete(documentWithId: documentId, fromCollection: collectionId, inDatabase: databaseId) { completion($0.bridgeToObjectiveC()) }
    }

    @objc(deleteDocumentWithId:fromCollection:completion:)
    public static func delete(documentWithId documentId: String, from collection: ADDocumentCollection, completion: @escaping (ADResponse) -> Void) {
        AzureData.delete(documentWithId: documentId, from: DocumentCollection(unconditionallyBridgedFromObjectiveC: collection)) { completion($0.bridgeToObjectiveC()) }
    }

    // replace
    @objc(replaceDocument:inCollectionWithId:inDatabaseWithId:completion:)
    public static func replace(document: ADDocument, inCollection collectionId: String, inDatabase databaseId: String, completion: @escaping (ADResponse) -> Void) {
        AzureData.replace(document.dictionaryDocument, inCollection: collectionId, inDatabase: databaseId) {
            let documentType = type(of: document)
            completion($0.bridgeToObjectiveC(withDocumentType: documentType))
        }
    }

    @objc(replaceDocument:inCollection:completion:)
    public static func replace(document: ADDocument, in collection: ADDocumentCollection, completion: @escaping (ADResponse) -> Void) {
        AzureData.replace(document.dictionaryDocument, in: DocumentCollection(unconditionallyBridgedFromObjectiveC: collection)) {
            let documentType = type(of: document)
            completion($0.bridgeToObjectiveC(withDocumentType: documentType))
        }
    }

    // query
    @objc(queryInCollectionWithId:documentsAs:inDatabaseId:withQuery:completion:)
    public static func query(documentsIn collectionId: String, as documentType: ADDocument.Type, inDatabase databaseId: String, with query: ADQuery, completion: @escaping (ADResponse) -> Void) {
        AzureData.query(documentsIn: collectionId, as: DictionaryDocument.self, inDatabase: databaseId, with: query.query, maxPerPage: nil) {
            completion($0.bridgeToObjectiveC(withDocumentType: documentType))
        }
    }

    @objc(queryInCollectionWithId:documentsAs:inDatabaseWithId:withQuery:withMaxPerPage:completion:)
    public static func query(documentsIn collectionId: String, as documentType: ADDocument.Type, inDatabase databaseId: String, with query: ADQuery, maxPerPage: Int, completion: @escaping (ADResponse) -> Void) {
        AzureData.query(documentsIn: collectionId, as: DictionaryDocument.self, inDatabase: databaseId, with: query.query, maxPerPage: maxPerPage) {
            completion($0.bridgeToObjectiveC(withDocumentType: documentType))
        }
    }

    @objc(queryDocumentsInCollection:as:withQuery:completion:)
    public static func query(documentsIn collection: ADDocumentCollection, as documentType: ADDocument.Type, with query: ADQuery, completion: @escaping (ADResponse) -> Void) {
        AzureData.query(documentsIn: DocumentCollection(unconditionallyBridgedFromObjectiveC: collection), with: query.query, maxPerPage: nil) {
            completion($0.bridgeToObjectiveC(withDocumentType: documentType))
        }
    }

    @objc(queryDocumentsInCollection:as:withQuery:withMaxPerPage:completion:)
    public static func query(documentsIn collection: ADDocumentCollection, as documentType: ADDocument.Type, with query: ADQuery, maxPerPage: Int, completion: @escaping (ADResponse) -> Void) {
        AzureData.query(documentsIn: DocumentCollection(unconditionallyBridgedFromObjectiveC: collection), with: query.query, maxPerPage: maxPerPage) {
            completion($0.bridgeToObjectiveC(withDocumentType: documentType))
        }
    }

    // MARK: - Attachments

    @objc(createAttachmentWithId:contentType:andMediaUrl:onDocumentWithId:inCollectionId:inDatabaseId:completion:)
    public static func create(attachmentWithId attachmentId: String, contentType: String, andMediaUrl mediaUrl: URL, onDocument documentId: String, inCollection collectionId: String, inDatabase databaseId: String, completion: @escaping (ADResponse) -> Void) {
        AzureData.create(attachmentWithId: attachmentId, contentType: contentType, andMediaUrl: mediaUrl, onDocument: documentId, inCollection: collectionId, inDatabase: databaseId) { completion($0.bridgeToObjectiveC()) }
    }

    @objc(createAttachmentWithId:contentType:name:andMedia:onDocumentWithId:inCollectionWithId:inDatabaseId:completion:)
    public static func create(attachmentWithId attachmentId: String, contentType: String, name mediaName: String, with media: Data, onDocument documentId: String, inCollection collectionId: String, inDatabase databaseId: String, completion: @escaping (ADResponse) -> Void) {
        AzureData.create(attachmentWithId: attachmentId, contentType: contentType, name: mediaName, with: media, onDocument: documentId, inCollection: collectionId, inDatabase: databaseId) { completion($0.bridgeToObjectiveC()) }
    }

    @objc(createAttachmentWithId:contentType:andMediaUrl:onDocument:completion:)
    public static func create(attachmentWithId attachmentId: String, contentType: String, andMediaUrl mediaUrl: URL, on document: ADDocument, completion: @escaping (ADResponse) -> Void) {
        AzureData.create(attachmentWithId: attachmentId, contentType: contentType, andMediaUrl: mediaUrl, on: document.dictionaryDocument) { completion($0.bridgeToObjectiveC()) }
    }

    @objc(createAttachmentWithId:contentType:name:andMedia:onDocument:completion:)
    public static func create(attachmentWithId attachmentId: String, contentType: String, name mediaName: String, with media: Data, on document: ADDocument, completion: @escaping (ADResponse) -> Void) {
        AzureData.create(attachmentWithId: attachmentId, contentType: contentType, name: mediaName, with: media, on: document.dictionaryDocument) { completion($0.bridgeToObjectiveC()) }
    }

    // list
    @objc(getAttachmentsOnDocumentWithId:inCollectionWithId:inDatabaseWithId:completion:)
    public static func get(attachmentsOn documentId: String, inCollection collectionId: String, inDatabase databaseId: String, completion: @escaping (ADResponse) -> Void) {
        AzureData.get(attachmentsOn: documentId, inCollection: collectionId, inDatabase: databaseId, maxPerPage: nil) { completion($0.bridgeToObjectiveC()) }
    }

    @objc(getAttachmentsOnDocumentWithId:inCollectionWithId:inDatabaseWithId:withMaxPerPage:completion:)
    public static func get(attachmentsOn documentId: String, inCollection collectionId: String, inDatabase databaseId: String, maxPerPage: Int, completion: @escaping (ADResponse) -> Void) {
        AzureData.get(attachmentsOn: documentId, inCollection: collectionId, inDatabase: databaseId, maxPerPage: maxPerPage) { completion($0.bridgeToObjectiveC()) }
    }

    @objc(getAttachmentsOnDocument:completion:)
    public static func get(attachmentsOn document: ADDocument, completion: @escaping (ADResponse) -> Void) {
        AzureData.get(attachmentsOn: document.dictionaryDocument, maxPerPage: nil) { completion($0.bridgeToObjectiveC()) }
    }


    @objc(getAttachmentsOnDocument:withMaxPerPage:completion:)
    public static func get(attachmentsOn document: ADDocument, maxPerPage: Int, completion: @escaping (ADResponse) -> Void) {
        AzureData.get(attachmentsOn: document.dictionaryDocument, maxPerPage: maxPerPage) { completion($0.bridgeToObjectiveC()) }
    }

    // delete
    @objc(deleteAttachmentWithId:fromDocumentWithId:inCollectionWithId:inDatabaseWithId:completion:)
    public func delete(attachmentWithId attachmentId: String, fromDocument documentId: String, inCollection collectionId: String, inDatabase databaseId: String, completion: @escaping (ADResponse) -> Void) {
        AzureData.delete(attachmentWithId: attachmentId, fromDocument: documentId, inCollection: collectionId, inDatabase: databaseId) { completion($0.bridgeToObjectiveC()) }
    }

    @objc(deleteAttachmentWithId:fromDocument:completion:)
    public static func delete(attachmentWithId attachmentId: String, from document: ADDocument, completion: @escaping (ADResponse) -> Void) {
        AzureData.delete(attachmentWithId: attachmentId, from: document.dictionaryDocument) { completion($0.bridgeToObjectiveC()) }
    }

    // replace
    @objc(replaceAttachmentWithId:contentType:andMediaUrl:onDocumentWithId:inCollectionWithId:inDatabaseId:completion:)
    public static func replace(attachmentWithId attachmentId: String, contentType: String, andMediaUrl mediaUrl: URL, onDocument documentId: String, inCollection collectionId: String, inDatabase databaseId: String, completion: @escaping (ADResponse) -> Void) {
        AzureData.replace(attachmentWithId: attachmentId, contentType: contentType, andMediaUrl: mediaUrl, onDocument: documentId, inCollection: collectionId, inDatabase: databaseId) { completion($0.bridgeToObjectiveC()) }
    }

    @objc(replaceAttachmentWithId:contentType:name:withMedia:onDocumentWithId:inCollectionWithId:inDatabaseId:completion:)
    public static func replace(attachmentWithId attachmentId: String, contentType: String, name mediaName: String, with media: Data, onDocument documentId: String, inCollection collectionId: String, inDatabase databaseId: String, completion: @escaping (ADResponse) -> Void) {
        AzureData.replace(attachmentWithId: attachmentId, contentType: contentType, name: mediaName, with: media, onDocument: documentId, inCollection: collectionId, inDatabase: databaseId) { completion($0.bridgeToObjectiveC()) }
    }

    @objc(replaceAttachmentWithId:contentType:andMediaUrl:onDocument:completion:)
    public static func replace(attachmentWithId attachmentId: String, contentType: String, andMediaUrl mediaUrl: URL, on document: ADDocument, completion: @escaping (ADResponse) -> Void) {
        AzureData.replace(attachmentWithId: attachmentId, contentType: contentType, andMediaUrl: mediaUrl, on: document.dictionaryDocument) { completion($0.bridgeToObjectiveC()) }
    }

    @objc(replaceAttachmentWithId:contentType:name:withMedia:onDocument:completion:)
    public static func replace (attachmentWithId attachmentId: String, contentType: String, name mediaName: String, with media: Data, on document: ADDocument, callback: @escaping (ADResponse) -> Void) {
        AzureData.replace(attachmentWithId: attachmentId, contentType: contentType, name: mediaName, with: media, on: document.dictionaryDocument) { callback($0.bridgeToObjectiveC()) }
    }

    // MARK: - Stored Procedures

    // create
    @objc(createStoredProcedureWithId:andBody:inCollectionWithId:inDatabaseWithId:completion:)
    public static func create(storedProcedureWithId storedProcedureId: String, andBody procedure: String, inCollection collectionId: String, inDatabase databaseId: String, completion: @escaping (ADResponse) -> Void) {
        AzureData.create(storedProcedureWithId: storedProcedureId, andBody: procedure, inCollection: collectionId, inDatabase: databaseId) { completion($0.bridgeToObjectiveC()) }
    }

    @objc(createStoredProcedureWithId:andBody:inCollection:completion:)
    public static func create(storedProcedureWithId storedProcedureId: String, andBody procedure: String, in collection: ADDocumentCollection, completion: @escaping (ADResponse) -> Void) {
        AzureData.create(storedProcedureWithId: storedProcedureId, andBody: procedure, in: DocumentCollection(unconditionallyBridgedFromObjectiveC: collection)) { completion($0.bridgeToObjectiveC()) }
    }

    // list
    @objc(getStoredProceduresInCollectionWithId:inDatabaseWithId:completion:)
    public static func get(storedProceduresIn collectionId: String, inDatabase databaseId: String, completion: @escaping (ADResponse) -> Void) {
        AzureData.get(storedProceduresIn: collectionId, inDatabase: databaseId, maxPerPage: nil) { completion($0.bridgeToObjectiveC()) }
    }

    @objc(getStoredProceduresInCollectionWithId:inDatabaseWithId:withMaxPerPage:completion:)
    public static func get(storedProceduresIn collectionId: String, inDatabase databaseId: String, maxPerPage: Int, completion: @escaping (ADResponse) -> Void) {
        AzureData.get(storedProceduresIn: collectionId, inDatabase: databaseId, maxPerPage: maxPerPage) { completion($0.bridgeToObjectiveC()) }
    }

    @objc(getStoredProceduresInCollection:completion:)
    public static func get(storedProceduresIn collection: ADDocumentCollection, completion: @escaping (ADResponse) -> Void) {
        AzureData.get(storedProceduresIn: DocumentCollection(unconditionallyBridgedFromObjectiveC: collection), maxPerPage: nil) { completion($0.bridgeToObjectiveC()) }
    }

    @objc(getStoredProceduresInCollection:withMaxPerPage:completion:)
    public static func get(storedProceduresIn collection: ADDocumentCollection, maxPerPage: Int, completion: @escaping (ADResponse) -> Void) {
        AzureData.get(storedProceduresIn: DocumentCollection(unconditionallyBridgedFromObjectiveC: collection), maxPerPage: maxPerPage) { completion($0.bridgeToObjectiveC()) }
    }

    // delete
    @objc(deleteStoredProcedureWithId:fromCollectionWithId:inDatabaseWithId:completion:)
    public static func delete(storedProcedureWithId storedProcedureId: String, fromCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (ADResponse) -> Void) {
        AzureData.delete(storedProcedureWithId: storedProcedureId, fromCollection: collectionId, inDatabase: databaseId) { callback($0.bridgeToObjectiveC()) }
    }

    @objc(deleteStoredProcedureWithId:fromCollection:completion:)
    public static func delete(storedProcedureWithId storedProcedureId: String, from collection: ADDocumentCollection, completion: @escaping (ADResponse) -> Void) {
        AzureData.delete(storedProcedureWithId: storedProcedureId, from: DocumentCollection(unconditionallyBridgedFromObjectiveC: collection)) { completion($0.bridgeToObjectiveC())}
    }

    // replace
    @objc(replaceStoredProcedureWithId:andBody:inCollectionWithId:inDatabaseWithId:completion:)
    public static func replace(storedProcedureWithId storedProcedureId: String, andBody procedure: String, inCollection collectionId: String, inDatabase databaseId: String, completion: @escaping (ADResponse) -> Void) {
        AzureData.replace(storedProcedureWithId: storedProcedureId, andBody: procedure, inCollection: collectionId, inDatabase: databaseId) { completion($0.bridgeToObjectiveC()) }
    }

    @objc(replaceStoredProcedureWithId:andBody:inCollection:completion:)
    public static func replace(storedProcedureWithId storedProcedureId: String, andBody procedure: String, in collection: ADDocumentCollection, completion: @escaping (ADResponse) -> Void) {
        AzureData.replace(storedProcedureWithId: storedProcedureId, andBody: procedure, in: DocumentCollection(unconditionallyBridgedFromObjectiveC: collection)) { completion($0.bridgeToObjectiveC()) }
    }

    // execute
    @objc(executeStoredProcedure:usingParameters:completion:)
    public static func execute(storedProcedure: ADStoredProcedure, usingParameters parameters: [String]?, completion: @escaping (ADResponse) -> Void) {
        AzureData.execute(StoredProcedure(unconditionallyBridgedFromObjectiveC: storedProcedure), usingParameters: parameters) { completion($0.bridgeToObjectiveC()) }
    }

    @objc(executeStoredProcedureWithId:usingParameters:inCollectionWithId:inDatabaseWithId:completion:)
    public static func execute(storedProcedureWithId storedProcedureId: String, usingParameters parameters: [String]?, inCollection collectionId: String, inDatabase databaseId: String, completion: @escaping (ADResponse) -> Void) {
        AzureData.execute(storedProcedureWithId: storedProcedureId, usingParameters: parameters, inCollection: collectionId, inDatabase: databaseId) { completion($0.bridgeToObjectiveC()) }
    }

    @objc(executeStoredProcedureWithId:usingParameters:inCollection:completion:)
    public static func execute(storedProcedureWithId storedProcedureId: String, usingParameters parameters: [String]?, in collection: ADDocumentCollection, completion: @escaping (ADResponse) -> Void) {
        AzureData.execute(storedProcedureWithId: storedProcedureId, usingParameters: parameters, in: DocumentCollection(unconditionallyBridgedFromObjectiveC: collection)) { completion($0.bridgeToObjectiveC()) }
    }

    // MARK: - User Defined Functions

    // create
    @objc(createUserDefinedFunctionWithId:andBody:inCollectionWithId:inDatabaseWithId:completion:)
    public static func create(userDefinedFunctionWithId functionId: String, andBody function: String, inCollection collectionId: String, inDatabase databaseId: String, completion: @escaping (ADResponse) -> Void) {
        AzureData.create(userDefinedFunctionWithId: functionId, andBody: function, inCollection: collectionId, inDatabase: databaseId) { completion($0.bridgeToObjectiveC()) }
    }

    @objc(createUserDefinedFunctionWithId:andBody:inCollection:completion:)
    public static func create(userDefinedFunctionWithId functionId: String, andBody function: String, in collection: ADDocumentCollection, completion: @escaping (ADResponse) -> Void) {
        AzureData.create(userDefinedFunctionWithId: functionId, andBody: function, in: DocumentCollection(unconditionallyBridgedFromObjectiveC: collection)) { completion($0.bridgeToObjectiveC()) }
    }

    // list
    @objc(getUsersDefinedFunctionsInCollectionWithId:inDatabaseWithId:completion:)
    public static func get(userDefinedFunctionsIn collectionId: String, inDatabase databaseId: String, completion: @escaping (ADResponse) -> Void) {
        AzureData.get(userDefinedFunctionsIn: collectionId, inDatabase: databaseId, maxPerPage: nil) { completion($0.bridgeToObjectiveC()) }
    }

    @objc(getUsersDefinedFunctionsInCollectionWithId:inDatabaseWithId:withMaxPerPage:completion:)
    public static func get(userDefinedFunctionsIn collectionId: String, inDatabase databaseId: String, maxPerPage: Int, completion: @escaping (ADResponse) -> Void) {
        AzureData.get(userDefinedFunctionsIn: collectionId, inDatabase: databaseId, maxPerPage: maxPerPage) { completion($0.bridgeToObjectiveC()) }
    }

    @objc(getUserDefinedFunctionsInCollection:completion:)
    public static func get(userDefinedFunctionsIn collection: ADDocumentCollection, completion: @escaping (ADResponse) -> Void) {
        AzureData.get(userDefinedFunctionsIn: DocumentCollection(unconditionallyBridgedFromObjectiveC: collection), maxPerPage: nil) { completion($0.bridgeToObjectiveC()) }
    }

    @objc(getUserDefinedFunctionsInCollection:withMaxPerPage:completion:)
    public static func get(userDefinedFunctionsIn collection: ADDocumentCollection, maxPerPage: Int, completion: @escaping (ADResponse) -> Void) {
        AzureData.get(userDefinedFunctionsIn: DocumentCollection(unconditionallyBridgedFromObjectiveC: collection), maxPerPage: maxPerPage) { completion($0.bridgeToObjectiveC()) }
    }

    // delete
    @objc(deleteUserDefinedFunctionWithId:fromCollectionWithId:inDatabaseWithId:completion:)
    public static func delete(userDefinedFunctionWithId functionId: String, fromCollection collectionId: String, inDatabase databaseId: String, completion: @escaping (ADResponse) -> Void) {
        AzureData.delete(userDefinedFunctionWithId: functionId, fromCollection: collectionId, inDatabase: databaseId) { completion($0.bridgeToObjectiveC()) }
    }

    @objc(deleteUserDefinedFunctionWithId:fromCollection:completion:)
    public static func delete(userDefinedFunctionWithId functionId: String, from collection: ADDocumentCollection, completion: @escaping (ADResponse) -> Void) {
        AzureData.delete(userDefinedFunctionWithId: functionId, from: DocumentCollection(unconditionallyBridgedFromObjectiveC: collection)) { completion($0.bridgeToObjectiveC()) }
    }

    // replace
    @objc(replaceUserDefinedFunctionWithId:andBody:inCollectionWithId:inDatabaseWithId:completion:)
    public static func replace(userDefinedFunctionWithId functionId: String, andBody function: String, inCollection collectionId: String, inDatabase databaseId: String, completion: @escaping (ADResponse) -> Void) {
        AzureData.replace(userDefinedFunctionWithId: functionId, andBody: function, inCollection: collectionId, inDatabase: databaseId) { completion($0.bridgeToObjectiveC()) }
    }

    @objc(replaceUserDefinedFunctionWithId:andBody:fromCollection:completion:)
    public static func replace(userDefinedFunctionWithId functionId: String, andBody function: String, from collection: ADDocumentCollection, completion: @escaping (ADResponse) -> Void) {
        AzureData.replace(userDefinedFunctionWithId: functionId, andBody: function, from: DocumentCollection(unconditionallyBridgedFromObjectiveC: collection)) { completion($0.bridgeToObjectiveC()) }
    }

    // MARK: - Triggers

    // create
    @objc(createTriggerWithId:operation:type:andBody:inCollectionWithId:inDatabaseWithId:completion:)
    public static func create(triggerWithId triggerId: String, operation: ADTrigger.ObjCTriggerOperation, type: ADTrigger.ObjCTriggerType, andBody body: String, inCollection collectionId: String, inDatabase databaseId: String, completion: @escaping (ADResponse) -> ()) {
        AzureData.create(triggerWithId: triggerId, operation: Trigger.TriggerOperation(bridgedFromObjectiveC: operation), type: Trigger.TriggerType(bridgedFromObjectiveC: type), andBody: body, inCollection: collectionId, inDatabase: databaseId) { completion($0.bridgeToObjectiveC()) }
    }

    @objc(createTriggerWithId:operation:type:andBody:inCollection:completion:)
    public static func create(triggerWithId triggerId: String, operation: ADTrigger.ObjCTriggerOperation, type: ADTrigger.ObjCTriggerType, andBody body: String, in collection: ADDocumentCollection, completion: @escaping (ADResponse) -> ()) {
        AzureData.create(triggerWithId: triggerId, operation: Trigger.TriggerOperation(bridgedFromObjectiveC: operation), type: Trigger.TriggerType(bridgedFromObjectiveC: type), andBody: body, in: DocumentCollection(unconditionallyBridgedFromObjectiveC: collection)) { completion($0.bridgeToObjectiveC()) }
    }

    // list
    @objc(getTriggersInCollectionWithId:inDatabaseWithId:completion:)
    public static func get(triggersIn collectionId: String, inDatabase databaseId: String, completion: @escaping (ADResponse) -> Void) {
        AzureData.get(triggersIn: collectionId, inDatabase: databaseId, maxPerPage: nil) { completion($0.bridgeToObjectiveC()) }
    }

    @objc(getTriggersInCollectionWithId:inDatabaseWithId:withMaxPerPage:completion:)
    public static func get(triggersIn collectionId: String, inDatabase databaseId: String, maxPerPage: Int, completion: @escaping (ADResponse) -> Void) {
        AzureData.get(triggersIn: collectionId, inDatabase: databaseId, maxPerPage: maxPerPage) { completion($0.bridgeToObjectiveC()) }
    }

    @objc(getTriggersInCollection:completion:)
    public static func get(triggersIn collection: ADDocumentCollection, completion: @escaping (ADResponse) -> Void) {
        AzureData.get(triggersIn: DocumentCollection(unconditionallyBridgedFromObjectiveC: collection), maxPerPage: nil) { completion($0.bridgeToObjectiveC()) }
    }

    @objc(getTriggersInCollection:withMaxPerPage:completion:)
    public static func get(triggersIn collection: ADDocumentCollection, maxPerPage: Int, completion: @escaping (ADResponse) -> Void) {
        AzureData.get(triggersIn: DocumentCollection(unconditionallyBridgedFromObjectiveC: collection), maxPerPage: maxPerPage) { completion($0.bridgeToObjectiveC()) }
    }

    // delete
    @objc(deleteTriggerWithId:fromCollectionWithId:inDatabaseWithId:completion:)
    public static func delete(triggerWithId triggerId: String, fromCollection collectionId: String, inDatabase databaseId: String, completion: @escaping (ADResponse) -> Void) {
        AzureData.delete(triggerWithId: triggerId, fromCollection: collectionId, inDatabase: databaseId) { completion($0.bridgeToObjectiveC()) }
    }

    @objc(deleteTriggerWithId:fromCollection:completion:)
    public static func delete(triggerWithId triggerId: String, from collection: ADDocumentCollection, completion: @escaping (ADResponse) -> Void) {
        AzureData.delete(triggerWithId: triggerId, from: DocumentCollection(unconditionallyBridgedFromObjectiveC: collection)) { completion($0.bridgeToObjectiveC()) }
    }

    // replace
    @objc(replaceTriggerWithId:operation:type:andBody:inCollectionWithId:inDatabaseWithId:completion:)
    public static func replace(triggerWithId triggerId: String, operation: ADTrigger.ObjCTriggerOperation, type: ADTrigger.ObjCTriggerType, andBody body: String, inCollection collectionId: String, inDatabase databaseId: String, completion: @escaping (ADResponse) -> Void) {
        AzureData.replace(triggerWithId: triggerId, operation: Trigger.TriggerOperation(bridgedFromObjectiveC: operation), type: Trigger.TriggerType(bridgedFromObjectiveC: type), andBody: body, inCollection: collectionId, inDatabase: databaseId) { completion($0.bridgeToObjectiveC()) }
    }

    @objc(replaceTriggerWithId:operation:type:andBody:inCollection:completion:)
    public static func replace(triggerWithId triggerId: String, operation: ADTrigger.ObjCTriggerOperation, type: ADTrigger.ObjCTriggerType, andBody body: String, in collection: ADDocumentCollection, completion: @escaping (ADResponse) -> Void) {
        AzureData.replace(triggerWithId: triggerId, operation: Trigger.TriggerOperation(bridgedFromObjectiveC: operation), type: Trigger.TriggerType(bridgedFromObjectiveC: type), andBody: body, in: DocumentCollection(unconditionallyBridgedFromObjectiveC: collection)) { completion($0.bridgeToObjectiveC()) }
    }

    // MARK: - Users

    // create
    @objc(createUserWithId:inDatabaseWithId:completion:)
    public static func create(userWithId userId: String, inDatabase databaseId: String, completion: @escaping (ADResponse) -> Void) {
        AzureData.create(userWithId: userId, inDatabase: databaseId) { completion($0.bridgeToObjectiveC()) }
    }

    @objc(createUserWithId:inDatabase:completion:)
    public static func create(userWithId userId: String, in database: ADDatabase, completion: @escaping (ADResponse) -> Void) {
        AzureData.create(userWithId: userId, in: Database(unconditionallyBridgedFromObjectiveC: database)) { completion($0.bridgeToObjectiveC()) }
    }

    // list
    @objc(getUsersInDatabaseWithId:completion:)
    public static func get(usersIn databaseId: String, completion: @escaping (ADResponse) -> Void) {
        AzureData.get(usersIn: databaseId, maxPerPage: nil) { completion($0.bridgeToObjectiveC()) }
    }

    @objc(getUsersInDatabaseWithId:withMaxPerPage:completion:)
    public static func get(usersIn databaseId: String, maxPerPage: Int, completion: @escaping (ADResponse) -> Void) {
        AzureData.get(usersIn: databaseId, maxPerPage: maxPerPage) { completion($0.bridgeToObjectiveC()) }
    }

    @objc(getUsersInDatabase:completion:)
    public static func get(usersIn database: ADDatabase, completion: @escaping (ADResponse) -> Void) {
        AzureData.get(usersIn: Database(unconditionallyBridgedFromObjectiveC: database), maxPerPage: nil) { completion($0.bridgeToObjectiveC()) }
    }

    @objc(getUsersInDatabase:withMaxPerPage:completion:)
    public static func get(usersIn database: ADDatabase, maxPerPage: Int, completion: @escaping (ADResponse) -> Void) {
        AzureData.get(usersIn: Database(unconditionallyBridgedFromObjectiveC: database), maxPerPage: maxPerPage) { completion($0.bridgeToObjectiveC()) }
    }

    // get
    @objc(getUserWithId:inDatabaseWithId:completion:)
    public static func get(userWithId userId: String, inDatabase databaseId: String, completion: @escaping (ADResponse) -> Void) {
        AzureData.get(userWithId: userId, inDatabase: databaseId) { completion($0.bridgeToObjectiveC()) }
    }

    @objc(getUserWithId:inDatabase:completion:)
    public static func get(userWithId userId: String, in database: ADDatabase, completion: @escaping (ADResponse) -> Void) {
        AzureData.get(userWithId: userId, in: Database(unconditionallyBridgedFromObjectiveC: database)) { completion($0.bridgeToObjectiveC()) }
    }

    // delete
    @objc(deleteUserWithId:fromDatabaseWithId:completion:)
    public static func delete(userWithId userId: String, fromDatabase databaseId: String, completion: @escaping (ADResponse) -> Void) {
        AzureData.delete(userWithId: userId, fromDatabase: databaseId) { completion($0.bridgeToObjectiveC()) }
    }

    @objc(deleteUserWithId:fromDatabase:completion:)
    public static func delete(userWithId userId: String, from database: ADDatabase, completion: @escaping (ADResponse) -> Void) {
        AzureData.delete(userWithId: userId, from: Database(unconditionallyBridgedFromObjectiveC: database)) { completion($0.bridgeToObjectiveC()) }
    }

    // replace
    @objc(replaceUserWithId:withNewUserId:inDatabaseWithId:completion:)
    public static func replace(userWithId userId: String, with newUserId: String, inDatabase databaseId: String, completion: @escaping (ADResponse) -> Void) {
        AzureData.replace(userWithId: userId, with: newUserId, inDatabase: databaseId) { completion($0.bridgeToObjectiveC()) }
    }

    @objc(replaceUserWithId:withNewUserId:inDatabase:completion:)
    public static func replace(userWithId userId: String, with newUserId: String, in database: ADDatabase, completion: @escaping (ADResponse) -> Void) {
        AzureData.replace(userWithId: userId, with: newUserId, in: Database(unconditionallyBridgedFromObjectiveC: database)) { completion($0.bridgeToObjectiveC()) }
    }

    // MARK: - Permissions

    // create
    @objc(createPermissionWithId:andMode:inResource:forUserWithId:inDatabaseWithId:completion:)
    public static func create(permissionWithId permissionId: String, mode: ADPermissionMode, in resource: ADResource & ADSupportsPermissionToken, forUser userId: String, inDatabase databaseId: String, completion: @escaping (ADResponse) -> Void) {
        AzureData.create(permissionWithId: permissionId, mode: mode.permissionMode, in: PermissionEnabledADResourceWrapper(resource), forUser: userId, inDatabase: databaseId) { completion($0.bridgeToObjectiveC()) }
    }

    @objc(createPermissionWithId:andMode:inResource:forUser:completion:)
    public static func create(permissionWithId permissionId: String, mode: ADPermissionMode, in resource: ADResource & ADSupportsPermissionToken, for user: ADUser, completion: @escaping (ADResponse) -> Void) {
        AzureData.create(permissionWithId: permissionId, mode: mode.permissionMode, in: PermissionEnabledADResourceWrapper(resource), for: User(unconditionallyBridgedFromObjectiveC: user)) { completion($0.bridgeToObjectiveC()) }
    }

    // list
    @objc(getPermissionsForUserWithId:inDatabaseWithId:completion:)
    public static func get(permissionsFor userId: String, inDatabase databaseId: String, completion: @escaping (ADResponse) -> Void) {
        AzureData.get(permissionsFor: userId, inDatabase: databaseId, maxPerPage: nil) { completion($0.bridgeToObjectiveC()) }
    }

    @objc(getPermissionsForUserWithId:inDatabaseWithId:withMaxPerPage:completion:)
    public static func get(permissionsFor userId: String, inDatabase databaseId: String, maxPerPage: Int, completion: @escaping (ADResponse) -> Void) {
        AzureData.get(permissionsFor: userId, inDatabase: databaseId, maxPerPage: maxPerPage) { completion($0.bridgeToObjectiveC()) }
    }

    @objc(getPermissionsForUser:completion:)
    public static func get(permissionsFor user: ADUser, completion: @escaping (ADResponse) -> Void) {
        AzureData.get(permissionsFor: User(unconditionallyBridgedFromObjectiveC: user), maxPerPage: nil) { completion($0.bridgeToObjectiveC()) }
    }

    @objc(getPermissionsForUser:withMaxPerPage:completion:)
    public static func get(permissionsFor user: ADUser, maxPerPage: Int, completion: @escaping (ADResponse) -> Void) {
        AzureData.get(permissionsFor: User(unconditionallyBridgedFromObjectiveC: user), maxPerPage: maxPerPage) { completion($0.bridgeToObjectiveC()) }
    }

    // get
    @objc(getPermissionWithId:forUserWithId:inDatabaseWithId:completion:)
    public static func get(permissionWithId permissionId: String, forUser userId: String, inDatabase databaseId: String, completion: @escaping (ADResponse) -> Void) {
        AzureData.get(permissionWithId: permissionId, forUser: userId, inDatabase: databaseId) { completion($0.bridgeToObjectiveC()) }
    }

    @objc(getPermissionWithId:forUser:completion:)
    public static func get(permissionWithId permissionId: String, for user: ADUser, completion: @escaping (ADResponse) -> Void) {
        AzureData.get(permissionWithId: permissionId, for: User(unconditionallyBridgedFromObjectiveC: user)) { completion($0.bridgeToObjectiveC()) }
    }

    // delete
    @objc(deletePermissionWithId:fromUserWithId:inDatabaseWithId:completion:)
    public static func delete(permissionWithId permissionId: String, fromUser userId: String, inDatabase databaseId: String, completion: @escaping (ADResponse) -> Void) {
        AzureData.delete(permissionWithId: permissionId, fromUser: userId, inDatabase: databaseId) { completion($0.bridgeToObjectiveC()) }
    }

    @objc(deletePermissionWithId:fromUser:completion:)
    public static func delete(permissionWithId permissionId: String, from user: ADUser, completion: @escaping (ADResponse) -> Void) {
        AzureData.delete(permissionWithId: permissionId, from: User(unconditionallyBridgedFromObjectiveC: user)) { completion($0.bridgeToObjectiveC()) }
    }

    // replace
    @objc(replacePermissionWithId:andMode:inResource:forUserWithId:inDatabaseWithId:completion:)
    public static func replace(permissionWithId permissionId: String, mode: ADPermissionMode, in resource: ADResource & ADSupportsPermissionToken, forUser userId: String, inDatabase databaseId: String, completion: @escaping (ADResponse) -> Void) {
        AzureData.replace(permissionWithId: permissionId, mode: mode.permissionMode, in: PermissionEnabledADResourceWrapper(resource), forUser: userId, inDatabase: databaseId) { completion($0.bridgeToObjectiveC()) }
    }

    @objc(replacePermissionWithId:andMode:inResource:forUser:completion:)
    public static func replace(permissionWithId permissionId: String, mode: ADPermissionMode, in resource: ADResource & ADSupportsPermissionToken, for user: ADUser, completion: @escaping (ADResponse) -> Void) {
        AzureData.replace(permissionWithId: permissionId, mode: mode.permissionMode, in: PermissionEnabledADResourceWrapper(resource), for: User(unconditionallyBridgedFromObjectiveC: user)) { completion($0.bridgeToObjectiveC()) }
    }

    // MARK: - Offers

    // list
    @objc
    public static func offers(completion: @escaping (ADResponse) -> Void) {
        AzureData.offers(maxPerPage: nil) { completion($0.bridgeToObjectiveC()) }
    }

    @objc(offersWithMaxPerPage:completion:)
    public static func offers(maxPerPage: Int, completion: @escaping (ADResponse) -> Void) {
        AzureData.offers(maxPerPage: maxPerPage) { completion($0.bridgeToObjectiveC()) }
    }

    @objc(getOfferWithId:completion:)
    public static func get(offerWithId offerId: String, completion: @escaping (ADResponse) -> Void)  {
        AzureData.get(offerWithId: offerId) { completion($0.bridgeToObjectiveC()) }
    }

    // MARK: - Resources

    @objc(refreshResource:completion:)
    public static func refresh(_ resource: ADResource, completion: @escaping (ADResponse) -> Void) {
        do {
            let data = try resource.encode().data()
            let properties = ResourceSystemProperties(for: data)!
            let resourceType = type(of: resource)

            DocumentClient.shared.refresh(data, at: .resource(resource: properties)) { r in
                let response: Response<ADResource> = r.map { (try resourceType.init(from: $0.dictionary()))! }
                completion(ADResponse(erasingTypeOf: response))
            }
        } catch {
            completion(ADResponse(Response(DocumentClientError(withError: error))))
        }
    }

    @objc(deleteResource:completion:)
    public static func delete(_ resource: ADResource, completion: @escaping (ADResponse) -> Void) {
        AzureData.delete(ADResourceWrapper(resource)) { completion($0.bridgeToObjectiveC()) }
    }
}
