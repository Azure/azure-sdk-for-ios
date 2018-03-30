//
//  AzureData.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation


// MARK: - Configure


/// Whether or not `configure` has been called on the client
public func isConfigured() -> Bool { return DocumentClient.default.isConfigured }


/// Configures the client.  This should be called before performing any CRUD operations
///
/// - Parameters:
///   - name:       The name of the Cosmos DB account - used to create resource urls
///   - key:        A master read/read-write key for the account, or a permission token for a resource
///   - keyType:    The type of key - `.master` read/read-write key or a `.resource` permission token
//public func configure (forAccountNamed name: String, withKey key: String, ofType keyType: TokenType) {
//    return DocumentClient.default.configure (forAccountNamed: name, withKey: key, ofType: keyType)
//}

/// Configures the client.  This should be called before performing any CRUD operations
///
/// - Parameters:
///   - name:       The custom domain of the Cosmos DB account - used to create resource urls
///   - key:        A master read/read-write key for the account, or a permission token for a resource
///   - keyType:    The type of key - `.master` read/read-write key or a `.resource` permission token
//public func configure (forAccountAt url: URL, withKey key: String, ofType keyType: TokenType) {
//    return DocumentClient.default.configure (forAccountAt: url, withKey: key, ofType: keyType)
//}

public func configure (forAccountNamed name: String, withMasterKey key: String, withPermissionMode mode: PermissionMode) {
    DocumentClient.default.configure(forAccountNamed: name, withMasterKey: key, withPermissionMode: mode)
}

public func configure (forAccountAt url: URL, withMasterKey key: String, withPermissionMode mode: PermissionMode) {
    DocumentClient.default.configure(forAccountAt: url, withMasterKey: key, withPermissionMode: mode)
}

public func configure (forAccountNamed name: String, withPermissionProvider permissionProvider: PermissionProvider) {
    DocumentClient.default.configure(forAccountNamed: name, withPermissionProvider: permissionProvider)
}

public func configure (forAccountAt url: URL, withPermissionProvider permissionProvider: PermissionProvider) {
    DocumentClient.default.configure(forAccountAt: url, withPermissionProvider: permissionProvider)
}


// Resets the client
public func reset () {
    return DocumentClient.default.reset()
}




// MARK: - Databases

/// Create a new Database
public func create (databaseWithId databaseId: String, callback: @escaping (Response<Database>) -> ()) {
    return DocumentClient.default.create (databaseWithId: databaseId, callback: callback)
}

/// List all Databases
public func databases (callback: @escaping (ListResponse<Database>) -> ()) {
    return DocumentClient.default.databases (callback: callback)
}

/// Get a Database
public func get (databaseWithId databaseId: String, callback: @escaping (Response<Database>) -> ()) {
    return DocumentClient.default.get (databaseWithId: databaseId, callback: callback)
}

/// Delete a Database
public func delete (databaseWithId databaseId: String, callback: @escaping (DataResponse) -> ()) {
    return DocumentClient.default.delete (databaseWithId: databaseId, callback: callback)
}




// MARK: - Collections

// create
public func create (collectionWithId collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<DocumentCollection>) -> ()) {
    return DocumentClient.default.create (collectionWithId: collectionId, inDatabase: databaseId, callback: callback)
}

// list
public func get (collectionsIn databaseId: String, callback: @escaping (ListResponse<DocumentCollection>) -> ()) {
    return DocumentClient.default.get (collectionsIn: databaseId, callback: callback)
}

// get
public func get (collectionWithId collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<DocumentCollection>) -> ()) {
    return DocumentClient.default.get (collectionWithId: collectionId, inDatabase: databaseId, callback: callback)
}

// delete
public func delete (_ collection: DocumentCollection, fromDatabase databaseId: String, callback: @escaping (DataResponse) -> ()) {
    return DocumentClient.default.delete (collection, fromDatabase: databaseId, callback: callback)
}

public func delete (collectionWithId collectionId: String, fromDatabase databaseId: String, callback: @escaping (DataResponse) -> ()) {
    return DocumentClient.default.delete (collectionWithId: collectionId, fromDatabase: databaseId, callback: callback)
}

// replace
// TODO: replace




// MARK: - Documents

// create
public func create<T: Document> (_ document: T, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<T>) -> ()) {
    return DocumentClient.default.create (document, inCollection: collectionId, inDatabase: databaseId, callback: callback)
}

public func create<T: Document> (_ document: T, in collection: DocumentCollection, callback: @escaping (Response<T>) -> ()) {
    return DocumentClient.default.create (document, in: collection, callback: callback)
}

// list
public func get<T: Document> (documentsAs documentType: T.Type, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (ListResponse<T>) -> ()) {
    return DocumentClient.default.get (documentsAs: documentType, inCollection: collectionId, inDatabase: databaseId, callback: callback)
}

public func get<T: Document> (documentsAs documentType: T.Type, in collection: DocumentCollection, callback: @escaping (ListResponse<T>) -> ()) {
    return DocumentClient.default.get (documentsAs: documentType, in: collection, callback: callback)
}

// get
public func get<T: Document> (documentWithId documentId: String, as documentType:T.Type, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<T>) -> ()) {
    return DocumentClient.default.get (documentWithId: documentId, as: documentType, inCollection: collectionId, inDatabase: databaseId, callback: callback)
}

public func get<T: Document> (documentWithId documentId: String, as documentType:T.Type, in collection: DocumentCollection, callback: @escaping (Response<T>) -> ()) {
    return DocumentClient.default.get (documentWithId: documentId, as: documentType, in: collection, callback: callback)
}

// delete
//public func delete (_ document: Document, fromCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (DataResponse) -> ()) {
//    return DocumentClient.default.delete (document, fromCollection: collectionId, inDatabase: databaseId, callback: callback)
//}
//
//public func delete (_ document: Document, from collection: DocumentCollection, callback: @escaping (DataResponse) -> ()) {
//    return DocumentClient.default.delete (document, from: collection, callback: callback)
//}

// replace
public func replace<T: Document> (_ document: T, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<T>) -> ()) {
    return DocumentClient.default.replace (document, inCollection: collectionId, inDatabase: databaseId, callback: callback)
}

public func replace<T: Document> (_ document: T, in collection: DocumentCollection, callback: @escaping (Response<T>) -> ()) {
    return DocumentClient.default.replace (document, in: collection, callback: callback)
}

// query
public func query (documentsIn collectionId: String, inDatabase databaseId: String, with query: Query, callback: @escaping (ListResponse<Document>) -> ()) {
    return DocumentClient.default.query (documentsIn: collectionId, inDatabase: databaseId, with: query, callback: callback)
}

public func query (documentsIn collection: DocumentCollection, with query: Query, callback: @escaping (ListResponse<Document>) -> ()) {
    return DocumentClient.default.query (documentsIn: collection, with: query, callback: callback)
}

public func query (documentsIn collectionId: String, inDatabase databaseId: String, with query: Query, callback: @escaping (ListResponse<DictionaryDocument>) -> ()) {
    return DocumentClient.default.query (documentsIn: collectionId, inDatabase: databaseId, with: query, callback: callback)
}

public func query (documentsIn collection: DocumentCollection, with query: Query, callback: @escaping (ListResponse<DictionaryDocument>) -> ()) {
    return DocumentClient.default.query (documentsIn: collection, with: query, callback: callback)
}



// MARK: - Attachments

// create
public func create (attachmentWithId attachmentId: String, contentType: String, andMediaUrl mediaUrl: URL, onDocument documentId: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<Attachment>) -> ()) {
    return DocumentClient.default.create (attachmentWithId: attachmentId, contentType: contentType, andMediaUrl: mediaUrl, onDocument: documentId, inCollection: collectionId, inDatabase: databaseId, callback: callback)
}

public func create (attachmentWithId attachmentId: String, contentType: String, name mediaName: String, with media: Data, onDocument documentId: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<Attachment>) -> ()) {
    return DocumentClient.default.create (attachmentWithId: attachmentId, contentType: contentType, name: mediaName, with: media, onDocument: documentId, inCollection: collectionId, inDatabase: databaseId, callback: callback)
}

public func create (attachmentWithId attachmentId: String, contentType: String, andMediaUrl mediaUrl: URL, onDocument document: Document, callback: @escaping (Response<Attachment>) -> ()) {
    return DocumentClient.default.create (attachmentWithId: attachmentId, contentType: contentType, andMediaUrl: mediaUrl, onDocument: document, callback: callback)
}

public func create (attachmentWithId attachmentId: String, contentType: String, name mediaName: String, with media: Data, onDocument document: Document, callback: @escaping (Response<Attachment>) -> ()) {
    return DocumentClient.default.create (attachmentWithId: attachmentId, contentType: contentType, name: mediaName, with: media, onDocument: document, callback: callback)
}

// list
public func get (attachmentsOn documentId: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (ListResponse<Attachment>) -> ()) {
    return DocumentClient.default.get (attachmentsOn: documentId, inCollection: collectionId, inDatabase: databaseId, callback: callback)
}

public func get (attachmentsOn document: Document, callback: @escaping (ListResponse<Attachment>) -> ()) {
    return DocumentClient.default.get (attachmentsOn: document, callback: callback)
}

// delete
//public func delete (_ attachment: Attachment, onDocument documentId: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (DataResponse) -> ()) {
//    return DocumentClient.default.delete (attachment, onDocument: documentId, inCollection: collectionId, inDatabase: databaseId, callback: callback)
//}
//
//public func delete (_ attachment: Attachment, onDocument document: Document, callback: @escaping (DataResponse) -> ()) {
//    return DocumentClient.default.delete (attachment, onDocument: document, callback: callback)
//}

// replace
public func replace (attachmentWithId attachmentId: String, contentType: String, andMediaUrl mediaUrl: URL, onDocument documentId: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<Attachment>) -> ()) {
    return DocumentClient.default.replace (attachmentWithId: attachmentId, contentType: contentType, andMediaUrl: mediaUrl, onDocument: documentId, inCollection: collectionId, inDatabase: databaseId, callback: callback)
}

public func replace (attachmentWithId attachmentId: String, contentType: String, name mediaName: String, with media: Data, onDocument documentId: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<Attachment>) -> ()) {
    return DocumentClient.default.replace (attachmentWithId: attachmentId, contentType: contentType, name: mediaName, with: media, onDocument: documentId, inCollection: collectionId, inDatabase: databaseId, callback: callback)
}

public func replace (attachmentWithId attachmentId: String, contentType: String, andMediaUrl mediaUrl: URL, onDocument document: Document, callback: @escaping (Response<Attachment>) -> ()) {
    return DocumentClient.default.replace (attachmentWithId: attachmentId, contentType: contentType, andMediaUrl: mediaUrl, onDocument: document, callback: callback)
}

public func replace (attachmentWithId attachmentId: String, contentType: String, name mediaName: String, with media: Data, onDocument document: Document, callback: @escaping (Response<Attachment>) -> ()) {
    return DocumentClient.default.replace (attachmentWithId: attachmentId, contentType: contentType, name: mediaName, with: media, onDocument: document, callback: callback)
}




// MARK: - Stored Procedures

// create
public func create (storedProcedureWithId storedProcedureId: String, andBody procedure: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<StoredProcedure>) -> ()) {
    return DocumentClient.default.create (storedProcedureWithId: storedProcedureId, andBody: procedure, inCollection: collectionId, inDatabase: databaseId, callback: callback)
}

public func create (storedProcedureWithId storedProcedureId: String, andBody procedure: String, in collection: DocumentCollection, callback: @escaping (Response<StoredProcedure>) -> ()) {
    return DocumentClient.default.create (storedProcedureWithId: storedProcedureId, andBody: procedure, in: collection, callback: callback)
}

// list
public func get (storedProceduresIn collectionId: String, inDatabase databaseId: String, callback: @escaping (ListResponse<StoredProcedure>) -> ()) {
    return DocumentClient.default.get (storedProceduresIn: collectionId, inDatabase: databaseId, callback: callback)
}

public func get (storedProceduresIn collection: DocumentCollection, callback: @escaping (ListResponse<StoredProcedure>) -> ()) {
    return DocumentClient.default.get (storedProceduresIn: collection, callback: callback)
}

// delete
//public func delete (_ storedProcedure: StoredProcedure, fromCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (DataResponse) -> ()) {
//    return DocumentClient.default.delete (storedProcedure, fromCollection: collectionId, inDatabase: databaseId, callback: callback)
//}
//
//public func delete (_ storedProcedure: StoredProcedure, from collection: DocumentCollection, callback: @escaping (DataResponse) -> ()) {
//    return DocumentClient.default.delete (storedProcedure, from: collection, callback: callback)
//}

// replace
public func replace (storedProcedureWithId storedProcedureId: String, andBody procedure: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<StoredProcedure>) -> ()) {
    return DocumentClient.default.replace (storedProcedureWithId: storedProcedureId, andBody: procedure, inCollection: collectionId, inDatabase: databaseId, callback: callback)
}

public func replace (storedProcedureWithId storedProcedureId: String, andBody procedure: String, in collection: DocumentCollection, callback: @escaping (Response<StoredProcedure>) -> ()) {
    return DocumentClient.default.replace (storedProcedureWithId: storedProcedureId, andBody: procedure, in: collection, callback: callback)
}

// execute
public func execute (storedProcedureWithId storedProcedureId: String, usingParameters parameters: [String]?, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (DataResponse) -> ()) {
    return DocumentClient.default.execute (storedProcedureWithId: storedProcedureId, usingParameters: parameters, inCollection: collectionId, inDatabase: databaseId, callback: callback)
}

public func execute (storedProcedureWithId storedProcedureId: String, usingParameters parameters: [String]?, in collection: DocumentCollection, callback: @escaping (DataResponse) -> ()) {
    return DocumentClient.default.execute (storedProcedureWithId: storedProcedureId, usingParameters: parameters, in: collection, callback: callback)
}




// MARK: - User Defined Functions

// create
public func create (userDefinedFunctionWithId functionId: String, andBody function: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<UserDefinedFunction>) -> ()) {
    return DocumentClient.default.create (userDefinedFunctionWithId: functionId, andBody: function, inCollection: collectionId, inDatabase: databaseId, callback: callback)
}

public func create (userDefinedFunctionWithId functionId: String, andBody function: String, in collection: DocumentCollection, callback: @escaping (Response<UserDefinedFunction>) -> ()) {
    return DocumentClient.default.create (userDefinedFunctionWithId: functionId, andBody: function, in: collection, callback: callback)
}

// list
public func get (userDefinedFunctionsIn collectionId: String, inDatabase databaseId: String, callback: @escaping (ListResponse<UserDefinedFunction>) -> ()) {
    return DocumentClient.default.get (userDefinedFunctionsIn: collectionId, inDatabase: databaseId, callback: callback)
}

public func get (userDefinedFunctionsIn collection: DocumentCollection, callback: @escaping (ListResponse<UserDefinedFunction>) -> ()) {
    return DocumentClient.default.get (userDefinedFunctionsIn: collection, callback: callback)
}

// delete
//public func delete (_ userDefinedFunction: UserDefinedFunction, fromCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (DataResponse) -> ()) {
//    return DocumentClient.default.delete (userDefinedFunction, fromCollection: collectionId, inDatabase: databaseId, callback: callback)
//}
//
//public func delete (_ userDefinedFunction: UserDefinedFunction, from collection: DocumentCollection, callback: @escaping (DataResponse) -> ()) {
//    return DocumentClient.default.delete (userDefinedFunction, from: collection, callback: callback)
//}

// replace
public func replace (userDefinedFunctionWithId functionId: String, andBody function: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<UserDefinedFunction>) -> ()) {
    return DocumentClient.default.replace (userDefinedFunctionWithId: functionId, andBody: function, inCollection: collectionId, inDatabase: databaseId, callback: callback)
}

public func replace (userDefinedFunctionWithId functionId: String, andBody function: String, from collection: DocumentCollection, callback: @escaping (Response<UserDefinedFunction>) -> ()) {
    return DocumentClient.default.replace (userDefinedFunctionWithId: functionId, andBody: function, from: collection, callback: callback)
}




// MARK: - Triggers

// create
public func create (triggerWithId triggerId: String, operation: Trigger.TriggerOperation, type triggerType: Trigger.TriggerType, andBody triggerBody: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<Trigger>) -> ()) {
    return DocumentClient.default.create (triggerWithId: triggerId, operation: operation, type: triggerType, andBody: triggerBody, inCollection: collectionId, inDatabase: databaseId, callback: callback)
}

public func create (triggerWithId triggerId: String, operation: Trigger.TriggerOperation, type: Trigger.TriggerType, andBody triggerBody: String, in collection: DocumentCollection, callback: @escaping (Response<Trigger>) -> ()) {
    return DocumentClient.default.create (triggerWithId: triggerId, operation: operation, type: type, andBody: triggerBody, in: collection, callback: callback)
}

// list
public func get (triggersIn collectionId: String, inDatabase databaseId: String, callback: @escaping (ListResponse<Trigger>) -> ()) {
    return DocumentClient.default.get (triggersIn: collectionId, inDatabase: databaseId, callback: callback)
}

public func get (triggersIn collection: DocumentCollection, callback: @escaping (ListResponse<Trigger>) -> ()) {
    return DocumentClient.default.get (triggersIn: collection, callback: callback)
}

// delete
//public func delete (_ trigger: Trigger, fromCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (DataResponse) -> ()) {
//    return DocumentClient.default.delete (trigger, fromCollection: collectionId, inDatabase: databaseId, callback: callback)
//}
//
//public func delete (_ trigger: Trigger, from collection: DocumentCollection, callback: @escaping (DataResponse) -> ()) {
//    return DocumentClient.default.delete (trigger, from: collection, callback: callback)
//}

// replace
public func replace (triggerWithId triggerId: String, operation: Trigger.TriggerOperation, type triggerType: Trigger.TriggerType, andBody triggerBody: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<Trigger>) -> ()) {
    return DocumentClient.default.replace (triggerWithId: triggerId, operation: operation, type: triggerType, andBody: triggerBody, inCollection: collectionId, inDatabase: databaseId, callback: callback)
}

public func replace (triggerWithId triggerId: String, operation: Trigger.TriggerOperation, type triggerType: Trigger.TriggerType, andBody triggerBody: String, in collection: DocumentCollection, callback: @escaping (Response<Trigger>) -> ()) {
    return DocumentClient.default.replace (triggerWithId: triggerId, operation: operation, type: triggerType, andBody: triggerBody, in: collection, callback: callback)
}




// MARK: - Users

// create
public func create (userWithId userId: String, inDatabase databaseId: String, callback: @escaping (Response<User>) -> ()) {
    return DocumentClient.default.create (userWithId: userId, inDatabase: databaseId, callback: callback)
}

// list
public func get (usersIn databaseId: String, callback: @escaping (ListResponse<User>) -> ()) {
    return DocumentClient.default.get (usersIn: databaseId, callback: callback)
}

// get
public func get (userWithId userId: String, inDatabase databaseId: String, callback: @escaping (Response<User>) -> ()) {
    return DocumentClient.default.get (userWithId: userId, inDatabase: databaseId, callback: callback)
}

// delete
//public func delete (_ user: User, fromDatabase databaseId: String, callback: @escaping (DataResponse) -> ()) {
//    return DocumentClient.default.delete (user, fromDatabase: databaseId, callback: callback)
//}

// replace
public func replace (userWithId userId: String, with newUserId: String, inDatabase databaseId: String, callback: @escaping (Response<User>) -> ()) {
    return DocumentClient.default.replace (userWithId: userId, with: newUserId, inDatabase: databaseId, callback: callback)
}




// MARK: - Permissions

// create
public func create (permissionWithId permissionId: String, mode permissionMode: PermissionMode, in resource: CodableResource, forUser userId: String, inDatabase databaseId: String, callback: @escaping (Response<Permission>) -> ()) {
    return DocumentClient.default.create (permissionWithId: permissionId, mode: permissionMode, in: resource, forUser: userId, inDatabase: databaseId, callback: callback)
}

public func create (permissionWithId permissionId: String, mode permissionMode: PermissionMode, in resource: CodableResource, forUser user: User, callback: @escaping (Response<Permission>) -> ()) {
    return DocumentClient.default.create (permissionWithId: permissionId, mode: permissionMode, in: resource, forUser: user, callback: callback)
}

// list
public func get (permissionsFor userId: String, inDatabase databaseId: String, callback: @escaping (ListResponse<Permission>) -> ()) {
    return DocumentClient.default.get (permissionsFor: userId, inDatabase: databaseId, callback: callback)
}

public func get (permissionsFor user: User, callback: @escaping (ListResponse<Permission>) -> ()) {
    return DocumentClient.default.get (permissionsFor: user, callback: callback)
}

// get
public func get (permissionWithId permissionId: String, forUser userId: String, inDatabase databaseId: String, callback: @escaping (Response<Permission>) -> ()) {
    return DocumentClient.default.get (permissionWithId: permissionId, forUser: userId, inDatabase: databaseId, callback: callback)
}

public func get (permissionWithId permissionId: String, forUser user: User, callback: @escaping (Response<Permission>) -> ()) {
    return DocumentClient.default.get (permissionWithId: permissionId, forUser: user, callback: callback)
}

// delete
//public func delete (_ permission: Permission, forUser userId: String, inDatabase databaseId: String, callback: @escaping (DataResponse) -> ()) {
//    return DocumentClient.default.delete (permission, forUser: userId, inDatabase: databaseId, callback: callback)
//}
//
//public func delete (_ permission: Permission, forUser user: User, callback: @escaping (DataResponse) -> ()) {
//    return DocumentClient.default.delete (permission, forUser: user, callback: callback)
//}

// replace
public func replace (permissionWithId permissionId: String, mode permissionMode: PermissionMode, in resource: CodableResource, forUser userId: String, inDatabase databaseId: String, callback: @escaping (Response<Permission>) -> ()) {
    return DocumentClient.default.replace (permissionWithId: permissionId, mode: permissionMode, in: resource, forUser: userId, inDatabase: databaseId, callback: callback)
}

public func replace (permissionWithId permissionId: String, mode permissionMode: PermissionMode, in resource: CodableResource, forUser user: User, callback: @escaping (Response<Permission>) -> ()) {
    return DocumentClient.default.replace (permissionWithId: permissionId, mode: permissionMode, in: resource, forUser: user, callback: callback)
}



// MARK: - Offers

// list
public func offers (callback: @escaping (ListResponse<Offer>) -> ()) {
    return DocumentClient.default.offers (callback: callback)
}

// get
public func get (offerWithId offerId: String, callback: @escaping (Response<Offer>) -> ()) {
    return DocumentClient.default.get (offerWithId: offerId, callback: callback)
}

// replace
// TODO: replace

// query
// TODO: query



// MARK: - Resources

// Refresh
public func refresh<T> (_ resource: T, callback: @escaping (Response<T>) -> ()) {
    return DocumentClient.default.refresh(resource, callback: callback)
}


// Delete
public func delete<T:CodableResource>(_ resource: T, callback: @escaping (DataResponse) -> ()) {
    return DocumentClient.default.delete(resource, callback: callback)
}





