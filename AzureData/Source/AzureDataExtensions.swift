//
//  AzureDataExtensions.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

// MARK: -

public extension CodableResource {
    
    public func delete(_ callback: @escaping (DataResponse) -> ()) {
        DocumentClient.default.delete(self, callback: callback)
    }
}



// MARK: -

public extension Database {
    
    public func refresh(_ callback: @escaping (Response<Database>) -> ()) {
        DocumentClient.default.refresh(self, callback: callback)
    }

    
    // MARK: Document Collection
    
    //create
    public func create (collectionWithId id: String, callback: @escaping (Response<DocumentCollection>) -> ()) {
        return DocumentClient.default.create(collectionWithId: id, inDatabase: self.id, callback: callback)
    }
    
    // list
    public func getCollections (callback: @escaping (ListResponse<DocumentCollection>) -> ()) {
        return DocumentClient.default.get(collectionsIn: self.id, callback: callback)
    }
    
    // get
    public func get (collectionWithId collectionId: String, callback: @escaping (Response<DocumentCollection>) -> ()) {
        return DocumentClient.default.get(collectionWithId: collectionId, inDatabase: self.id, callback: callback)
    }
    
    //delete
    public func delete (_ collection: DocumentCollection, callback: @escaping (DataResponse) -> ()) {
        return self.delete(collectionWithId: collection.id, callback: callback)
    }

    public func delete (collectionWithId collectionId: String, callback: @escaping (DataResponse) -> ()) {
        return DocumentClient.default.delete(collectionWithId: collectionId, fromDatabase: self.id, callback: callback)
    }
    
    
    // MARK: Users
    
    //create
    public func create (userWithId id: String, callback: @escaping (Response<User>) -> ()) {
        return DocumentClient.default.create (userWithId: id, inDatabase: self.id, callback: callback)
    }
    
    // list
    public func getUsers (callback: @escaping (ListResponse<User>) -> ()) {
        return DocumentClient.default.get (usersIn: self.id, callback: callback)
    }
    
    // get
    public func get (userWithId id: String, callback: @escaping (Response<User>) -> ()) {
        return DocumentClient.default.get (userWithId: id, inDatabase: self.id, callback: callback)
    }
    
    //delete
    public func delete (_ user: User, callback: @escaping (DataResponse) -> ()) {
        return DocumentClient.default.delete (user, callback: callback)
    }
    
    // replace
    public func replace (userWithId id: String, with newUserId: String, callback: @escaping (Response<User>) -> ()) {
        return DocumentClient.default.replace (userWithId: id, with: newUserId, inDatabase: self.id, callback: callback)
    }
}



// MARK: -

public extension DocumentCollection {
    
    public func refresh(_ callback: @escaping (Response<DocumentCollection>) -> ()) {
        DocumentClient.default.refresh(self, callback: callback)
    }

    
    // MARK: Documents
    
    // create
    public func create<T: Document> (_ document: T, callback: @escaping (Response<T>) -> ()) {
        return DocumentClient.default.create(document, in: self, callback: callback)
    }
    
    // list
    public func get<T: Document> (documentsAs documentType:T.Type, callback: @escaping (ListResponse<T>) -> ()) {
        return DocumentClient.default.get(documentsAs: documentType, in: self, callback: callback)
    }
    
    // get
    public func get<T: Document> (documentWithResourceId id: String, as documentType:T.Type, callback: @escaping (Response<T>) -> ()) {
        return DocumentClient.default.get(documentWithId: id, as: documentType, in: self, callback: callback)
    }
    
    // delete
    public func delete (_ document: Document, callback: @escaping (DataResponse) -> ()) {
        return DocumentClient.default.delete(document, callback: callback)
    }
    
    // replace
    public func replace<T: Document> (_ document: T, callback: @escaping (Response<T>) -> ()) {
        return DocumentClient.default.replace(document, in: self, callback: callback)
    }
    
    // query
    public func query (documentsWith query: Query, callback: @escaping (ListResponse<Document>) -> ()) {
        return DocumentClient.default.query(documentsIn: self, with: query, callback: callback)
    }

    public func query (documentsWith query: Query, callback: @escaping (ListResponse<DictionaryDocument>) -> ()) {
        return DocumentClient.default.query(documentsIn: self, with: query, callback: callback)
    }

    
    
    // MARK: Stored Procedures
    
    // create
    public func create (storedProcedureWithId id: String, andBody body: String, callback: @escaping (Response<StoredProcedure>) -> ()) {
        return DocumentClient.default.create (storedProcedureWithId: id, andBody: body, in: self, callback: callback)
    }
    
    // list
    public func getStoredProcedures (callback: @escaping (ListResponse<StoredProcedure>) -> ()) {
        return DocumentClient.default.get (storedProceduresIn: self, callback: callback)
    }
    
    // delete
    public func delete (_ storedProcedure: StoredProcedure, callback: @escaping (DataResponse) -> ()) {
        return DocumentClient.default.delete (storedProcedure, callback: callback)
    }
    
    // replace
    public func replace (storedProcedureWithId id: String, andBody body: String, callback: @escaping (Response<StoredProcedure>) -> ()) {
        return DocumentClient.default.replace (storedProcedureWithId: id, andBody: body, in: self, callback: callback)
    }
    
    // execute
    public func execute (storedProcedureWithId id: String, usingParameters parameters: [String]?, callback: @escaping (DataResponse) -> ()) {
        return DocumentClient.default.execute (storedProcedureWithId: id, usingParameters: parameters, in: self, callback: callback)
    }
    
    
    
    // MARK: User Defined Functions
    
    // create
    public func create (userDefinedFunctionWithId id: String, andBody body: String, callback: @escaping (Response<UserDefinedFunction>) -> ()) {
        return DocumentClient.default.create (userDefinedFunctionWithId: id, andBody: body, in: self, callback: callback)
    }
    
    // list
    public func getUserDefinedFunctions (callback: @escaping (ListResponse<UserDefinedFunction>) -> ()) {
        return DocumentClient.default.get (userDefinedFunctionsIn: self, callback: callback)
    }
    
    // delete
    public func delete (_ userDefinedFunction: UserDefinedFunction, callback: @escaping (DataResponse) -> ()) {
        return DocumentClient.default.delete (userDefinedFunction, callback: callback)
    }
    
    // replace
    public func replace (userDefinedFunctionWithId id: String, andBody body: String, callback: @escaping (Response<UserDefinedFunction>) -> ()) {
        return DocumentClient.default.replace (userDefinedFunctionWithId: id, andBody: body, from: self, callback: callback)
    }
    
    
    
    // MARK: Triggers
    
    // create
    public func create (triggerWithId id: String, operation: Trigger.TriggerOperation, type: Trigger.TriggerType, andBody body: String, callback: @escaping (Response<Trigger>) -> ()) {
        return DocumentClient.default.create (triggerWithId: id, operation: operation, type: type, andBody: body, in: self, callback: callback)
    }
    
    // list
    public func getTriggers (callback: @escaping (ListResponse<Trigger>) -> ()) {
        return DocumentClient.default.get (triggersIn: self, callback: callback)
    }
    
    // delete
    public func delete (_ trigger: Trigger, callback: @escaping (DataResponse) -> ()) {
        return DocumentClient.default.delete (trigger, callback: callback)
    }
    
    // replace
    public func replace (triggerWithId id: String, operation: Trigger.TriggerOperation, type: Trigger.TriggerType, andBody body: String, callback: @escaping (Response<Trigger>) -> ()) {
        return DocumentClient.default.replace (triggerWithId: id, operation: operation, type: type, andBody: body, in: self, callback: callback)
    }
}



// MARK: -

public extension Document {
    
    public func refresh(_ callback: @escaping (Response<Document>) -> ()) {
        DocumentClient.default.refresh(self, callback: callback)
    }
    
    
    // MARK: Attachments
    
    // create
    public func create (attachmentWithId attachmentId: String, contentType: String, andMediaUrl mediaUrl: URL, callback: @escaping (Response<Attachment>) -> ()) {
        return DocumentClient.default.create(attachmentWithId: attachmentId, contentType: contentType, andMediaUrl: mediaUrl, onDocument: self, callback: callback)
    }
    
    public func create (attachmentWithId attachmentId: String, contentType: String, name mediaName: String, with media: Data, callback: @escaping (Response<Attachment>) -> ()) {
        return DocumentClient.default.create(attachmentWithId: attachmentId, contentType: contentType, name: mediaName, with: media, onDocument: self, callback: callback)
    }
    
    // list
    public func getAttachemnts (callback: @escaping (ListResponse<Attachment>) -> ()) {
        return DocumentClient.default.get (attachmentsOn: self, callback: callback)
    }
    
    // delete
    public func delete (_ attachment: Attachment, callback: @escaping (DataResponse) -> ()) {
        return DocumentClient.default.delete (attachment, callback: callback)
    }
    
    // replace
    public func replace (attachmentWithId attachmentId: String, contentType: String, andMediaUrl mediaUrl: URL, callback: @escaping (Response<Attachment>) -> ()) {
        return DocumentClient.default.replace(attachmentWithId: attachmentId, contentType: contentType, andMediaUrl: mediaUrl, onDocument: self, callback: callback)
    }
    
    public func replace (attachmentWithId attachmentId: String, contentType: String, name mediaName: String, with media: Data, callback: @escaping (Response<Attachment>) -> ()) {
        return DocumentClient.default.replace(attachmentWithId: attachmentId, contentType: contentType, name: mediaName, with: media, onDocument: self, callback: callback)
    }
}



// MARK: -

public extension User {
    
    public func refresh(_ callback: @escaping (Response<User>) -> ()) {
        DocumentClient.default.refresh(self, callback: callback)
    }

    
    // MARK: Permissions
    
    // create
    public func create (permissionWithId permissionId: String, mode permissionMode: PermissionMode, in resource: CodableResource, callback: @escaping (Response<Permission>) -> ()) {
        return DocumentClient.default.create (permissionWithId: permissionId, mode: permissionMode, in: resource, forUser: self, callback: callback)
    }
    
    // list
    public func getPermissions (callback: @escaping (ListResponse<Permission>) -> ()) {
        return DocumentClient.default.get (permissionsFor: self, callback: callback)
    }
    
    // get
    public func get (permissionWithId permissionId: String, callback: @escaping (Response<Permission>) -> ()) {
        return DocumentClient.default.get (permissionWithId: permissionId, forUser: self, callback: callback)
    }
    
    // delete
    public func delete (_ permission: Permission, callback: @escaping (DataResponse) -> ()) {
        return DocumentClient.default.delete (permission, callback: callback)
    }
    
    // replace
    public func replace (permissionWithId permissionId: String, mode permissionMode: PermissionMode, in resource: CodableResource, callback: @escaping (Response<Permission>) -> ()) {
        return DocumentClient.default.replace (permissionWithId: permissionId, mode: permissionMode, in: resource, forUser: self, callback: callback)
    }
}








