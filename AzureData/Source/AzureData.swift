//
//  AzureData.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCore

public class AzureData {

    // MARK: - Configure


    /// Whether or not `configure` has been called on the client
    public static func isConfigured() -> Bool { return DocumentClient.shared.isConfigured }


    /// Configures the client.  This should be called before performing any CRUD operations
    ///
    /// - Parameters:
    ///   - name:       The name of the Cosmos DB account - used to create resource urls
    ///   - key:        A master read/read-write key for the account, or a permission token for a resource
    ///   - keyType:    The type of key - `.master` read/read-write key or a `.resource` permission token
    //public static func configure (forAccountNamed name: String, withKey key: String, ofType keyType: TokenType) {
    //    return DocumentClient.shared.configure (forAccountNamed: name, withKey: key, ofType: keyType)
    //}

    /// Configures the client.  This should be called before performing any CRUD operations
    ///
    /// - Parameters:
    ///   - name:       The custom domain of the Cosmos DB account - used to create resource urls
    ///   - key:        A master read/read-write key for the account, or a permission token for a resource
    ///   - keyType:    The type of key - `.master` read/read-write key or a `.resource` permission token
    //public static func configure (forAccountAt url: URL, withKey key: String, ofType keyType: TokenType) {
    //    return DocumentClient.shared.configure (forAccountAt: url, withKey: key, ofType: keyType)
    //}

    public static func configure (forAccountNamed name: String, withMasterKey key: String, withPermissionMode mode: PermissionMode) {
        DocumentClient.shared.configure(forAccountNamed: name, withMasterKey: key, withPermissionMode: mode)
    }

    public static func configure (forAccountAt url: URL, withMasterKey key: String, withPermissionMode mode: PermissionMode) {
        DocumentClient.shared.configure(forAccountAt: url, withMasterKey: key, withPermissionMode: mode)
    }

    public static func configure (forAccountNamed name: String, withPermissionProvider permissionProvider: PermissionProvider) {
        DocumentClient.shared.configure(forAccountNamed: name, withPermissionProvider: permissionProvider)
    }

    public static func configure (forAccountAt url: URL, withPermissionProvider permissionProvider: PermissionProvider) {
        DocumentClient.shared.configure(forAccountAt: url, withPermissionProvider: permissionProvider)
    }

    public static func configure (withPlistNamed name: String? = nil, withPermissionMode mode: PermissionMode) {
        DocumentClient.shared.configure(withPlistNamed: name, withPermissionMode: mode)
    }

    public static var offlineDataEnabled: Bool {
        get { return ResourceCache.isEnabled }
        set { ResourceCache.isEnabled = newValue }
    }

    public static func purgeOfflineData() throws {
        try ResourceCache.purge()
    }



    // Resets the client
    public static func reset () {
        return DocumentClient.shared.reset()
    }


    // MARK: - JSONEncoder & JSONDecoder

    static var dateDecoder: ((Decoder) throws -> Date)? {
        get { return DocumentClient.shared.dateDecoder }
        set { DocumentClient.shared.dateDecoder = newValue }
    }

    static var dateEncoder: ((Date, Encoder) throws -> Void)? {
        get { return DocumentClient.shared.dateEncoder }
        set { DocumentClient.shared.dateEncoder = newValue }
    }

    static var jsonEncoder: JSONEncoder {
        get { return DocumentClient.shared.jsonEncoder }
        set { DocumentClient.shared.jsonEncoder = newValue }
    }

    static var jsonDecoder: JSONDecoder {
        get { return DocumentClient.shared.jsonDecoder }
        set { DocumentClient.shared.jsonDecoder = newValue }
    }


    // MARK: - Conflict Strategy

    public static var conflictStrategies: [ResourceType:ConflictStrategy] {
        get { return DocumentClient.shared.conflictStrategies }
        set { DocumentClient.shared.conflictStrategies = newValue }
    }

    public static func register(strategy: ConflictStrategy, for resourceTypes: ResourceType...) {
        return DocumentClient.shared.register(strategy: strategy, for: resourceTypes)
    }

    public static func register(resolver: @escaping ConflictResolver, for resourceTypes: ResourceType...) {
        return DocumentClient.shared.register(strategy: .custom(resolver), for: resourceTypes)
    }

    // MARK: - Resource Encryption

    public static var resourceEncryptor: ResourceEncryptor? {
        get { return ResourceCache.resourceEncryptor }
        set { ResourceCache.resourceEncryptor = newValue }
    }

    // MARK: - Databases

    /// Create a new Database
    public static func create (databaseWithId databaseId: String, callback: @escaping (Response<Database>) -> ()) {
        return DocumentClient.shared.create (databaseWithId: databaseId, callback: callback)
    }

    /// List all Databases
    public static func databases (maxPerPage: Int? = nil, callback: @escaping (Response<Resources<Database>>) -> ()) {
        return DocumentClient.shared.databases (maxPerPage: maxPerPage, callback: callback)
    }

    /// Get a Database
    public static func get (databaseWithId databaseId: String, callback: @escaping (Response<Database>) -> ()) {
        return DocumentClient.shared.get (databaseWithId: databaseId, callback: callback)
    }

    /// Delete a Database
    public static func delete (databaseWithId databaseId: String, callback: @escaping (Response<Data>) -> ()) {
        return DocumentClient.shared.delete (databaseWithId: databaseId, callback: callback)
    }




    // MARK: - Collections

    // create
    public static func create (collectionWithId collectionId: String, andPartitionKey partitionKey: DocumentCollection.PartitionKeyDefinition?, inDatabase databaseId: String, callback: @escaping (Response<DocumentCollection>) -> ()) {
        return DocumentClient.shared.create (collectionWithId: collectionId, andPartitionKey: partitionKey, inDatabase: databaseId, callback: callback)
    }

    public static func create (collectionWithId collectionId: String, andPartitionKey partitionKey: DocumentCollection.PartitionKeyDefinition?, in database: Database, callback: @escaping (Response<DocumentCollection>) -> ()) {
        return DocumentClient.shared.create(collectionWithId: collectionId, andPartitionKey: partitionKey, in: database, callback: callback)
    }

    // list
    public static func get (collectionsIn databaseId: String, maxPerPage: Int? = nil, callback: @escaping (Response<Resources<DocumentCollection>>) -> ()) {
        return DocumentClient.shared.get (collectionsIn: databaseId, maxPerPage: maxPerPage, callback: callback)
    }

    public static func get (collectionsIn database: Database, maxPerPage: Int? = nil, callback: @escaping (Response<Resources<DocumentCollection>>) -> ()) {
        return DocumentClient.shared.get (collectionsIn: database, maxPerPage: maxPerPage, callback: callback)
    }

    // get
    public static func get (collectionWithId collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<DocumentCollection>) -> ()) {
        return DocumentClient.shared.get (collectionWithId: collectionId, inDatabase: databaseId, callback: callback)
    }

    public static func get (collectionWithId collectionId: String, in database: Database, callback: @escaping (Response<DocumentCollection>) -> ()) {
        return DocumentClient.shared.get (collectionWithId: collectionId, in: database, callback: callback)
    }

    // delete
    public static func delete (collectionWithId collectionId: String, fromDatabase databaseId: String, callback: @escaping (Response<Data>) -> ()) {
        return DocumentClient.shared.delete (collectionWithId: collectionId, fromDatabase: databaseId, callback: callback)
    }

    public static func delete (collectionWithId collectionId: String, from database: Database, callback: @escaping (Response<Data>) -> ()) {
        return DocumentClient.shared.delete(collectionWithId: collectionId, from: database, callback: callback)
    }

    // replace
    public static func replace (collectionWithId collectionId: String, andPartitionKey partitionKey: DocumentCollection.PartitionKeyDefinition?, inDatabase databaseId: String, usingPolicy policy: DocumentCollection.IndexingPolicy, callback: @escaping (Response<DocumentCollection>) -> ()) {
        return DocumentClient.shared.replace(collectionWithId: collectionId, andPartitionKey: partitionKey, inDatabase: databaseId, usingPolicy: policy, callback: callback)
    }



    // MARK: - Documents

    // create
    public static func create<T: Document> (_ document: T, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<T>) -> ()) {
        return DocumentClient.shared.create (document, inCollection: collectionId, inDatabase: databaseId, callback: callback)
    }

    public static func create<T: Document> (_ document: T, in collection: DocumentCollection, callback: @escaping (Response<T>) -> ()) {
        return DocumentClient.shared.create (document, in: collection, callback: callback)
    }

    public static func createOrReplace<T: Document> (_ document: T, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<T>) -> ()) {
        return DocumentClient.shared.createOrReplace (document, inCollection: collectionId, inDatabase: databaseId, callback: callback)
    }

    public static func createOrReplace<T: Document> (_ document: T, in collection: DocumentCollection, callback: @escaping (Response<T>) -> ()) {
        return DocumentClient.shared.createOrReplace(document, in: collection, callback: callback)
    }

    // list
    public static func get<T: Document> (documentsAs documentType: T.Type, inCollection collectionId: String, inDatabase databaseId: String, maxPerPage: Int? = nil, callback: @escaping (Response<Documents<T>>) -> ()) {
        return DocumentClient.shared.get (documentsAs: documentType, inCollection: collectionId, inDatabase: databaseId, maxPerPage: maxPerPage, callback: callback)
    }

    public static func get<T: Document> (documentsAs documentType: T.Type, in collection: DocumentCollection, maxPerPage: Int? = nil, callback: @escaping (Response<Documents<T>>) -> ()) {
        return DocumentClient.shared.get (documentsAs: documentType, in: collection, maxPerPage: maxPerPage, callback: callback)
    }

    // get
    public static func get<T: Document> (documentWithId documentId: String, as documentType: T.Type, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<T>) -> ()) {
        return DocumentClient.shared.get (documentWithId: documentId, as: documentType, inCollection: collectionId, inDatabase: databaseId, callback: callback)
    }

    public static func get<T: Document> (documentWithId documentId: String, as documentType: T.Type, in collection: DocumentCollection, callback: @escaping (Response<T>) -> ()) {
        return DocumentClient.shared.get (documentWithId: documentId, as: documentType, in: collection, callback: callback)
    }

    public static func get<T: Document> (documentWithId documentId: String, as documentType: T.Type, inCollection collectionId: String, withPartitionKey partitionKey: String, inDatabase databaseId: String, callback: @escaping (Response<T>) -> ()) {
        return DocumentClient.shared.get (documentWithId: documentId, as: documentType, inCollection: collectionId, withPartitionKey: partitionKey, inDatabase: databaseId, callback: callback)
    }

    public static func get<T: Document> (documentWithId documentId: String, as documentType: T.Type, in collection: DocumentCollection, withPartitionKey partitionKey: String, callback: @escaping (Response<T>) -> ()) {
        return DocumentClient.shared.get (documentWithId: documentId, as: documentType, in: collection, withPartitionKey: partitionKey, callback: callback)
    }


    // delete
    public static func delete (documentWithId documentId: String, fromCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<Data>) -> ()) {
        return DocumentClient.shared.delete(documentWithId: documentId, fromCollection: collectionId, inDatabase: databaseId, callback: callback)
    }

    public static func delete (documentWithId documentId: String, from collection: DocumentCollection, callback: @escaping (Response<Data>) -> ()) {
        return DocumentClient.shared.delete(documentWithId: documentId, from: collection, callback: callback)
    }

    // replace
    public static func replace<T: Document> (_ document: T, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<T>) -> ()) {
        return DocumentClient.shared.replace (document, inCollection: collectionId, inDatabase: databaseId, callback: callback)
    }

    public static func replace<T: Document> (_ document: T, in collection: DocumentCollection, callback: @escaping (Response<T>) -> ()) {
        return DocumentClient.shared.replace (document, in: collection, callback: callback)
    }

    // query
    public static func query<T: Document> (documentsIn collectionId: String, as documentType: T.Type, inDatabase databaseId: String, with query: Query, andPartitionKey partitionKey: String, maxPerPage: Int? = nil, callback: @escaping (Response<Documents<T>>) -> ()) {
        return DocumentClient.shared.query (documentsIn: collectionId, as: documentType, inDatabase: databaseId, with: query, andPartitionKey: partitionKey, maxPerPage: maxPerPage, callback: callback)
    }

    public static func query<T: Document> (documentsIn collection: DocumentCollection, as documentType: T.Type, with query: Query, andPartitionKey partitionKey: String, maxPerPage: Int? = nil, callback: @escaping (Response<Documents<T>>) -> ()) {
        return DocumentClient.shared.query (documentsIn: collection, as: documentType, with: query, andPartitionKey: partitionKey, maxPerPage: maxPerPage, callback: callback)
    }

    public static func query<T: Document> (documentsAcrossAllPartitionsIn collectionId: String, as documentType: T.Type, inDatabase databaseId: String, with query: Query, maxPerPage: Int? = nil, callback: @escaping (Response<Documents<T>>) -> ()) {
        return DocumentClient.shared.query (documentsIn: collectionId, as: documentType, inDatabase: databaseId, with: query, andPartitionKey: nil, maxPerPage: maxPerPage, callback: callback)
    }

    public static func query<T: Document> (documentsAcrossAllPartitionsIn collection: DocumentCollection, as documentType: T.Type, with query: Query, maxPerPage: Int? = nil, callback: @escaping (Response<Documents<T>>) -> ()) {
        return DocumentClient.shared.query (documentsIn: collection, as: documentType, with: query, andPartitionKey: nil, maxPerPage: maxPerPage, callback: callback)
    }

    public static func query (documentPropertiesIn collectionId: String, inDatabase databaseId: String, with query: Query, andPartitionKey partitionKey: String, maxPerPage: Int? = nil, callback: @escaping (Response<Documents<DocumentProperties>>) -> ()) {
        return DocumentClient.shared.query (documentsIn: collectionId, as: DocumentProperties.self, inDatabase: databaseId, with: query, andPartitionKey: partitionKey, maxPerPage: maxPerPage, callback: callback)
    }

    public static func query (documentPropertiesIn collection: DocumentCollection, with query: Query, andPartitionKey partitionKey: String, maxPerPage: Int? = nil, callback: @escaping (Response<Documents<DocumentProperties>>) -> ()) {
        return DocumentClient.shared.query (documentsIn: collection, as: DocumentProperties.self, with: query, andPartitionKey: partitionKey, maxPerPage: maxPerPage, callback: callback)
    }

    public static func query (documentPropertiesAcrossAllPartitionsIn collectionId: String, inDatabase databaseId: String, with query: Query, maxPerPage: Int? = nil, callback: @escaping (Response<Documents<DocumentProperties>>) -> ()) {
        return DocumentClient.shared.query (documentsIn: collectionId, as: DocumentProperties.self, inDatabase: databaseId, with: query, andPartitionKey: nil, maxPerPage: maxPerPage, callback: callback)
    }

    public static func query (documentPropertiesAcrossAllPartitionsIn collection: DocumentCollection, with query: Query, maxPerPage: Int? = nil, callback: @escaping (Response<Documents<DocumentProperties>>) -> ()) {
        return DocumentClient.shared.query (documentsIn: collection, as: DocumentProperties.self, with: query, andPartitionKey: nil, maxPerPage: maxPerPage, callback: callback)
    }

    // delete
    public static func delete<T: Document>(_ document: T, callback: @escaping (Response<Data>) -> ()) {
        return DocumentClient.shared.delete(document, callback: callback)
    }

    // MARK: - Attachments

    // create
    public static func create (attachmentWithId attachmentId: String, contentType: String, andMediaUrl mediaUrl: URL, onDocument documentId: String, inCollection collectionId: String, withPartitionKey partitionKey: String?, inDatabase databaseId: String, callback: @escaping (Response<Attachment>) -> ()) {
        return DocumentClient.shared.create (attachmentWithId: attachmentId, contentType: contentType, andMediaUrl: mediaUrl, onDocument: documentId, inCollection: collectionId, withPartitionKey: partitionKey, inDatabase: databaseId, callback: callback)
    }

    public static func create (attachmentWithId attachmentId: String, contentType: String, name mediaName: String, with media: Data, onDocument documentId: String, inCollection collectionId: String, withPartitionKey partitionKey: String?, inDatabase databaseId: String, callback: @escaping (Response<Attachment>) -> ()) {
        return DocumentClient.shared.create (attachmentWithId: attachmentId, contentType: contentType, name: mediaName, with: media, onDocument: documentId, inCollection: collectionId, withPartitionKey: partitionKey, inDatabase: databaseId, callback: callback)
    }

    public static func create<T: Document> (attachmentWithId attachmentId: String, contentType: String, andMediaUrl mediaUrl: URL, on document: T, callback: @escaping (Response<Attachment>) -> ()) {
        return DocumentClient.shared.create (attachmentWithId: attachmentId, contentType: contentType, andMediaUrl: mediaUrl, on: document, callback: callback)
    }

    public static func create<T: Document> (attachmentWithId attachmentId: String, contentType: String, name mediaName: String, with media: Data, on document: T, callback: @escaping (Response<Attachment>) -> ()) {
        return DocumentClient.shared.create (attachmentWithId: attachmentId, contentType: contentType, name: mediaName, with: media, on: document, callback: callback)
    }

    // list
    public static func get (attachmentsOn documentId: String, inCollection collectionId: String, withPartitionKey partitionKey: String?, inDatabase databaseId: String, maxPerPage: Int? = nil, callback: @escaping (Response<Resources<Attachment>>) -> ()) {
        return DocumentClient.shared.get (attachmentsOn: documentId, inCollection: collectionId, withPartitionKey: partitionKey, inDatabase: databaseId, maxPerPage: maxPerPage, callback: callback)
    }

    public static func get<T: Document> (attachmentsOn document: T, maxPerPage: Int? = nil, callback: @escaping (Response<Resources<Attachment>>) -> ()) {
        return DocumentClient.shared.get (attachmentsOn: document, maxPerPage: maxPerPage, callback: callback)
    }

    // delete
    public static func delete (attachmentWithId attachmentId: String, fromDocument documentId: String, inCollection collectionId: String, withPartitionKey partitionKey: String?, inDatabase databaseId: String, callback: @escaping (Response<Data>) -> ()) {
        return DocumentClient.shared.delete(attachmentWithId: attachmentId, fromDocument: documentId, inCollection: collectionId, withPartitionKey: partitionKey, inDatabase: databaseId, callback: callback)
    }

    public static func delete<T: Document> (attachmentWithId attachmentId: String, from document: T, callback: @escaping (Response<Data>) -> ()) {
        return DocumentClient.shared.delete(attachmentWithId: attachmentId, from: document, callback: callback)
    }

    // replace
    public static func replace (attachmentWithId attachmentId: String, contentType: String, andMediaUrl mediaUrl: URL, onDocument documentId: String, inCollection collectionId: String, withPartitionKey partitionKey: String?, inDatabase databaseId: String, callback: @escaping (Response<Attachment>) -> ()) {
        return DocumentClient.shared.replace (attachmentWithId: attachmentId, contentType: contentType, andMediaUrl: mediaUrl, onDocument: documentId, inCollection: collectionId, withPartitionKey: partitionKey, inDatabase: databaseId, callback: callback)
    }

    public static func replace (attachmentWithId attachmentId: String, contentType: String, name mediaName: String, with media: Data, onDocument documentId: String, inCollection collectionId: String, withPartitionKey partitionKey: String?, inDatabase databaseId: String, callback: @escaping (Response<Attachment>) -> ()) {
        return DocumentClient.shared.replace (attachmentWithId: attachmentId, contentType: contentType, name: mediaName, with: media, onDocument: documentId, inCollection: collectionId, withPartitionKey: partitionKey, inDatabase: databaseId, callback: callback)
    }

    public static func replace<T: Document> (attachmentWithId attachmentId: String, contentType: String, andMediaUrl mediaUrl: URL, on document: T, callback: @escaping (Response<Attachment>) -> ()) {
        return DocumentClient.shared.replace (attachmentWithId: attachmentId, contentType: contentType, andMediaUrl: mediaUrl, on: document, callback: callback)
    }

    public static func replace<T: Document> (attachmentWithId attachmentId: String, contentType: String, name mediaName: String, with media: Data, on document: T, callback: @escaping (Response<Attachment>) -> ()) {
        return DocumentClient.shared.replace (attachmentWithId: attachmentId, contentType: contentType, name: mediaName, with: media, on: document, callback: callback)
    }




    // MARK: - Stored Procedures

    // create
    public static func create (storedProcedureWithId storedProcedureId: String, andBody procedure: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<StoredProcedure>) -> ()) {
        return DocumentClient.shared.create (storedProcedureWithId: storedProcedureId, andBody: procedure, inCollection: collectionId, inDatabase: databaseId, callback: callback)
    }

    public static func create (storedProcedureWithId storedProcedureId: String, andBody procedure: String, in collection: DocumentCollection, callback: @escaping (Response<StoredProcedure>) -> ()) {
        return DocumentClient.shared.create (storedProcedureWithId: storedProcedureId, andBody: procedure, in: collection, callback: callback)
    }

    // list
    public static func get (storedProceduresIn collectionId: String, inDatabase databaseId: String, maxPerPage: Int? = nil, callback: @escaping (Response<Resources<StoredProcedure>>) -> ()) {
        return DocumentClient.shared.get (storedProceduresIn: collectionId, inDatabase: databaseId, maxPerPage: maxPerPage, callback: callback)
    }

    public static func get (storedProceduresIn collection: DocumentCollection, maxPerPage: Int? = nil, callback: @escaping (Response<Resources<StoredProcedure>>) -> ()) {
        return DocumentClient.shared.get (storedProceduresIn: collection, maxPerPage: maxPerPage, callback: callback)
    }

    // delete
    public static func delete (storedProcedureWithId storedProcedureId: String, fromCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<Data>) -> ()) {
        return DocumentClient.shared.delete(storedProcedureWithId: storedProcedureId, fromCollection: collectionId, inDatabase: databaseId, callback: callback)
    }

    public static func delete (storedProcedureWithId storedProcedureId: String, from collection: DocumentCollection, callback: @escaping (Response<Data>) -> ()) {
        return DocumentClient.shared.delete(storedProcedureWithId: storedProcedureId, from: collection, callback: callback)
    }

    // replace
    public static func replace (storedProcedureWithId storedProcedureId: String, andBody procedure: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<StoredProcedure>) -> ()) {
        return DocumentClient.shared.replace (storedProcedureWithId: storedProcedureId, andBody: procedure, inCollection: collectionId, inDatabase: databaseId, callback: callback)
    }

    public static func replace (storedProcedureWithId storedProcedureId: String, andBody procedure: String, in collection: DocumentCollection, callback: @escaping (Response<StoredProcedure>) -> ()) {
        return DocumentClient.shared.replace (storedProcedureWithId: storedProcedureId, andBody: procedure, in: collection, callback: callback)
    }

    // execute
    public static func execute (_ storedProcedure: StoredProcedure, usingParameters parameters: [String]?, callback: @escaping (Response<Data>) -> ()) {
        return DocumentClient.shared.execute(storedProcedure, usingParameters: parameters, callback: callback)
    }

    public static func execute (storedProcedureWithId storedProcedureId: String, usingParameters parameters: [String]?, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<Data>) -> ()) {
        return DocumentClient.shared.execute (storedProcedureWithId: storedProcedureId, usingParameters: parameters, inCollection: collectionId, inDatabase: databaseId, callback: callback)
    }

    public static func execute (storedProcedureWithId storedProcedureId: String, usingParameters parameters: [String]?, in collection: DocumentCollection, callback: @escaping (Response<Data>) -> ()) {
        return DocumentClient.shared.execute (storedProcedureWithId: storedProcedureId, usingParameters: parameters, in: collection, callback: callback)
    }

    public static func execute (storedProcedureWithId storedProcedureId: String, usingParameters parameters: [String]?, andPartitionKey partitionKey: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<Data>) -> ()) {
        return DocumentClient.shared.execute (storedProcedureWithId: storedProcedureId, usingParameters: parameters, andPartitionKey: partitionKey, inCollection: collectionId, inDatabase: databaseId, callback: callback)
    }

    public static func execute (storedProcedureWithId storedProcedureId: String, usingParameters parameters: [String]?, andPartitionKey partitionKey: String, in collection: DocumentCollection, callback: @escaping (Response<Data>) -> ()) {
        return DocumentClient.shared.execute (storedProcedureWithId: storedProcedureId, usingParameters: parameters, andPartitionKey: partitionKey, in: collection, callback: callback)
    }


    // MARK: - User Defined Functions

    // create
    public static func create (userDefinedFunctionWithId functionId: String, andBody function: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<UserDefinedFunction>) -> ()) {
        return DocumentClient.shared.create (userDefinedFunctionWithId: functionId, andBody: function, inCollection: collectionId, inDatabase: databaseId, callback: callback)
    }

    public static func create (userDefinedFunctionWithId functionId: String, andBody function: String, in collection: DocumentCollection, callback: @escaping (Response<UserDefinedFunction>) -> ()) {
        return DocumentClient.shared.create (userDefinedFunctionWithId: functionId, andBody: function, in: collection, callback: callback)
    }

    // list
    public static func get (userDefinedFunctionsIn collectionId: String, inDatabase databaseId: String, maxPerPage: Int? = nil, callback: @escaping (Response<Resources<UserDefinedFunction>>) -> ()) {
        return DocumentClient.shared.get (userDefinedFunctionsIn: collectionId, inDatabase: databaseId, maxPerPage: maxPerPage, callback: callback)
    }

    public static func get (userDefinedFunctionsIn collection: DocumentCollection, maxPerPage: Int? = nil, callback: @escaping (Response<Resources<UserDefinedFunction>>) -> ()) {
        return DocumentClient.shared.get (userDefinedFunctionsIn: collection, maxPerPage: maxPerPage, callback: callback)
    }

    // delete
    public static func delete (userDefinedFunctionWithId functionId: String, fromCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<Data>) -> ()) {
        return DocumentClient.shared.delete(userDefinedFunctionWithId: functionId, fromCollection: collectionId, inDatabase: databaseId, callback: callback)
    }

    public static func delete (userDefinedFunctionWithId functionId: String, from collection: DocumentCollection, callback: @escaping (Response<Data>) -> ()) {
        return DocumentClient.shared.delete(userDefinedFunctionWithId: functionId, from: collection, callback: callback)
    }

    // replace
    public static func replace (userDefinedFunctionWithId functionId: String, andBody function: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<UserDefinedFunction>) -> ()) {
        return DocumentClient.shared.replace (userDefinedFunctionWithId: functionId, andBody: function, inCollection: collectionId, inDatabase: databaseId, callback: callback)
    }

    public static func replace (userDefinedFunctionWithId functionId: String, andBody function: String, in collection: DocumentCollection, callback: @escaping (Response<UserDefinedFunction>) -> ()) {
        return DocumentClient.shared.replace (userDefinedFunctionWithId: functionId, andBody: function, in: collection, callback: callback)
    }

    // MARK: - Triggers

    // create
    public static func create (triggerWithId triggerId: String, operation: Trigger.TriggerOperation, type triggerType: Trigger.TriggerType, andBody triggerBody: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<Trigger>) -> ()) {
        return DocumentClient.shared.create (triggerWithId: triggerId, operation: operation, type: triggerType, andBody: triggerBody, inCollection: collectionId, inDatabase: databaseId, callback: callback)
    }

    public static func create (triggerWithId triggerId: String, operation: Trigger.TriggerOperation, type: Trigger.TriggerType, andBody triggerBody: String, in collection: DocumentCollection, callback: @escaping (Response<Trigger>) -> ()) {
        return DocumentClient.shared.create (triggerWithId: triggerId, operation: operation, type: type, andBody: triggerBody, in: collection, callback: callback)
    }

    // list
    public static func get (triggersIn collectionId: String, inDatabase databaseId: String, maxPerPage: Int? = nil, callback: @escaping (Response<Resources<Trigger>>) -> ()) {
        return DocumentClient.shared.get (triggersIn: collectionId, inDatabase: databaseId, maxPerPage: maxPerPage, callback: callback)
    }

    public static func get (triggersIn collection: DocumentCollection, maxPerPage: Int? = nil, callback: @escaping (Response<Resources<Trigger>>) -> ()) {
        return DocumentClient.shared.get (triggersIn: collection, maxPerPage: maxPerPage, callback: callback)
    }

    // delete
    public static func delete (triggerWithId triggerId: String, fromCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<Data>) -> ()) {
        return DocumentClient.shared.delete(triggerWithId: triggerId, fromCollection: collectionId, inDatabase: databaseId, callback: callback)
    }

    public static func delete (triggerWithId triggerId: String, from collection: DocumentCollection, callback: @escaping (Response<Data>) -> ()) {
        return DocumentClient.shared.delete(triggerWithId: triggerId, from: collection, callback: callback)
    }

    // replace
    public static func replace (triggerWithId triggerId: String, operation: Trigger.TriggerOperation, type triggerType: Trigger.TriggerType, andBody triggerBody: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<Trigger>) -> ()) {
        return DocumentClient.shared.replace (triggerWithId: triggerId, operation: operation, type: triggerType, andBody: triggerBody, inCollection: collectionId, inDatabase: databaseId, callback: callback)
    }

    public static func replace (triggerWithId triggerId: String, operation: Trigger.TriggerOperation, type triggerType: Trigger.TriggerType, andBody triggerBody: String, in collection: DocumentCollection, callback: @escaping (Response<Trigger>) -> ()) {
        return DocumentClient.shared.replace (triggerWithId: triggerId, operation: operation, type: triggerType, andBody: triggerBody, in: collection, callback: callback)
    }




    // MARK: - Users

    // create
    public static func create (userWithId userId: String, inDatabase databaseId: String, callback: @escaping (Response<User>) -> ()) {
        return DocumentClient.shared.create (userWithId: userId, inDatabase: databaseId, callback: callback)
    }

    public static func create (userWithId userId: String, in database: Database, callback: @escaping (Response<User>) -> ()) {
        return DocumentClient.shared.create (userWithId: userId, in: database, callback: callback)
    }

    // list
    public static func get (usersIn databaseId: String, maxPerPage: Int? = nil, callback: @escaping (Response<Resources<User>>) -> ()) {
        return DocumentClient.shared.get (usersIn: databaseId, maxPerPage: maxPerPage, callback: callback)
    }

    public static func get (usersIn database: Database, maxPerPage: Int? = nil, callback: @escaping (Response<Resources<User>>) -> ()) {
        return DocumentClient.shared.get (usersIn: database, maxPerPage: maxPerPage, callback: callback)
    }

    // get
    public static func get (userWithId userId: String, inDatabase databaseId: String, callback: @escaping (Response<User>) -> ()) {
        return DocumentClient.shared.get (userWithId: userId, inDatabase: databaseId, callback: callback)
    }

    public static func get (userWithId userId: String, in database: Database, callback: @escaping (Response<User>) -> ()) {
        return DocumentClient.shared.get (userWithId: userId, in: database, callback: callback)
    }

    // delete
    public static func delete (userWithId userId: String, fromDatabase databaseId: String, callback: @escaping (Response<Data>) -> ()) {
        return DocumentClient.shared.delete(userWithId: userId, fromDatabase: databaseId, callback: callback)
    }

    public static func delete (userWithId userId: String, from database: Database, callback: @escaping (Response<Data>) -> ()) {
        return DocumentClient.shared.delete(userWithId: userId, from: database, callback: callback)
    }

    // replace
    public static func replace (userWithId userId: String, with newUserId: String, inDatabase databaseId: String, callback: @escaping (Response<User>) -> ()) {
        return DocumentClient.shared.replace (userWithId: userId, with: newUserId, inDatabase: databaseId, callback: callback)
    }

    public static func replace (userWithId userId: String, with newUserId: String, in database: Database, callback: @escaping (Response<User>) -> ()) {
        return DocumentClient.shared.replace (userWithId: userId, with: newUserId, in: database, callback: callback)
    }



    // MARK: - Permissions

    // create
    public static func create (permissionWithId permissionId: String, mode permissionMode: PermissionMode, in resource: CodableResource & SupportsPermissionToken, forUser userId: String, inDatabase databaseId: String, callback: @escaping (Response<Permission>) -> ()) {
        return DocumentClient.shared.create (permissionWithId: permissionId, mode: permissionMode, in: resource, forUser: userId, inDatabase: databaseId, callback: callback)
    }

    public static func create (permissionWithId permissionId: String, mode permissionMode: PermissionMode, in resource: CodableResource & SupportsPermissionToken, for user: User, callback: @escaping (Response<Permission>) -> ()) {
        return DocumentClient.shared.create (permissionWithId: permissionId, mode: permissionMode, in: resource, for: user, callback: callback)
    }

    // list
    public static func get (permissionsFor userId: String, inDatabase databaseId: String, maxPerPage: Int? = nil, callback: @escaping (Response<Resources<Permission>>) -> ()) {
        return DocumentClient.shared.get (permissionsFor: userId, inDatabase: databaseId, maxPerPage: maxPerPage, callback: callback)
    }

    public static func get (permissionsFor user: User, maxPerPage: Int? = nil, callback: @escaping (Response<Resources<Permission>>) -> ()) {
        return DocumentClient.shared.get (permissionsFor: user, maxPerPage: maxPerPage, callback: callback)
    }

    // get
    public static func get (permissionWithId permissionId: String, forUser userId: String, inDatabase databaseId: String, callback: @escaping (Response<Permission>) -> ()) {
        return DocumentClient.shared.get (permissionWithId: permissionId, forUser: userId, inDatabase: databaseId, callback: callback)
    }

    public static func get (permissionWithId permissionId: String, for user: User, callback: @escaping (Response<Permission>) -> ()) {
        return DocumentClient.shared.get (permissionWithId: permissionId, for: user, callback: callback)
    }

    // delete
    public static func delete (permissionWithId permissionId: String, fromUser userId: String, inDatabase databaseId: String, callback: @escaping (Response<Data>) -> ()) {
        return DocumentClient.shared.delete(permissionWithId: permissionId, fromUser: userId, inDatabase: databaseId, callback: callback)
    }

    public static func delete (permissionWithId permissionId: String, from user: User, callback: @escaping (Response<Data>) -> ()) {
        return DocumentClient.shared.delete(permissionWithId: permissionId, from: user, callback: callback)
    }

    // replace
    public static func replace (permissionWithId permissionId: String, mode permissionMode: PermissionMode, in resource: CodableResource & SupportsPermissionToken, forUser userId: String, inDatabase databaseId: String, callback: @escaping (Response<Permission>) -> ()) {
        return DocumentClient.shared.replace (permissionWithId: permissionId, mode: permissionMode, in: resource, forUser: userId, inDatabase: databaseId, callback: callback)
    }

    public static func replace (permissionWithId permissionId: String, mode permissionMode: PermissionMode, in resource: CodableResource & SupportsPermissionToken, for user: User, callback: @escaping (Response<Permission>) -> ()) {
        return DocumentClient.shared.replace (permissionWithId: permissionId, mode: permissionMode, in: resource, for: user, callback: callback)
    }



    // MARK: - Offers

    // list
    public static func offers (maxPerPage: Int? = nil, callback: @escaping (Response<Resources<Offer>>) -> ()) {
        return DocumentClient.shared.offers (maxPerPage: maxPerPage, callback: callback)
    }

    // get
    public static func get (offerWithId offerId: String, callback: @escaping (Response<Offer>) -> ()) {
        return DocumentClient.shared.get (offerWithId: offerId, callback: callback)
    }

    // replace
    // TODO: replace

    // query
    // TODO: query



    // MARK: - Resources

    // Refresh
    public static func refresh<T:CodableResource> (_ resource: T, callback: @escaping (Response<T>) -> ()) {
        return DocumentClient.shared.refresh(resource, callback: callback)
    }


    // Delete
    public static func delete<T:CodableResource>(_ resource: T, callback: @escaping (Response<Data>) -> ()) {
        return DocumentClient.shared.delete(resource, callback: callback)
    }

}



