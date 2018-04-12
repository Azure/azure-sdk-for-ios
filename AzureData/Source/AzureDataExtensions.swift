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
    
    public func delete(_ callback: @escaping (Response<Data>) -> ()) {
        return DocumentClient.shared.delete(self, callback: callback)
    }

    public func create(permissionWithId permissionId: String, mode permissionMode: PermissionMode, forUser user: User, callback: @escaping (Response<Permission>) -> ()) {
        return DocumentClient.shared.create(permissionWithId: permissionId, mode: permissionMode, in: self, forUser: user, callback: callback)
    }
}



// MARK: -

public extension Database {
    
    public func refresh(_ callback: @escaping (Response<Database>) -> ()) {
        return DocumentClient.shared.refresh(self, callback: callback)
    }

    
    // MARK: Document Collection
    
    //create
    public func create (collectionWithId id: String, callback: @escaping (Response<DocumentCollection>) -> ()) {
        return DocumentClient.shared.create(collectionWithId: id, inDatabase: self, callback: callback)
    }
    
    // list
    public func getCollections (perPage: Int? = nil, callback: @escaping (Response<Resources<DocumentCollection>>) -> ()) {
        return DocumentClient.shared.get(collectionsIn: self, maxPerPage: perPage, callback: callback)
    }
    
    // get
    public func get (collectionWithId collectionId: String, callback: @escaping (Response<DocumentCollection>) -> ()) {
        return DocumentClient.shared.get(collectionWithId: collectionId, inDatabase: self, callback: callback)
    }
    
    //delete
    public func delete (_ collection: DocumentCollection, callback: @escaping (Response<Data>) -> ()) {
        return DocumentClient.shared.delete(collection, callback: callback)
    }

    public func delete (collectionWithId collectionId: String, callback: @escaping (Response<Data>) -> ()) {
        return DocumentClient.shared.delete(collectionWithId: collectionId, fromDatabase: self, callback: callback)
    }
    
    
    // MARK: Users
    
    //create
    public func create (userWithId id: String, callback: @escaping (Response<User>) -> ()) {
        return DocumentClient.shared.create (userWithId: id, inDatabase: self, callback: callback)
    }
    
    // list
    public func getUsers (maxPerPage: Int? = nil, callback: @escaping (Response<Resources<User>>) -> ()) {
        return DocumentClient.shared.get (usersIn: self, maxPerPage: maxPerPage, callback: callback)
    }
    
    // get
    public func get (userWithId id: String, callback: @escaping (Response<User>) -> ()) {
        return DocumentClient.shared.get (userWithId: id, inDatabase: self, callback: callback)
    }
    
    //delete
    public func delete (_ user: User, callback: @escaping (Response<Data>) -> ()) {
        return DocumentClient.shared.delete (user, callback: callback)
    }

    public func delete(userWithId userId: String, callback: @escaping (Response<Data>) -> ()) {
        return DocumentClient.shared.delete(userWithId: userId, fromDatabase: self, callback: callback)
    }

    // replace
    public func replace (userWithId id: String, with newUserId: String, callback: @escaping (Response<User>) -> ()) {
        return DocumentClient.shared.replace (userWithId: id, with: newUserId, inDatabase: self, callback: callback)
    }
}



// MARK: -

public extension DocumentCollection {
    
    public func refresh(_ callback: @escaping (Response<DocumentCollection>) -> ()) {
        return DocumentClient.shared.refresh(self, callback: callback)
    }

    
    // MARK: Documents
    
    // create
    public func create<T: Document> (_ document: T, callback: @escaping (Response<T>) -> ()) {
        return DocumentClient.shared.create(document, in: self, callback: callback)
    }
    
    // list
    public func get<T: Document> (documentsAs documentType:T.Type, maxPerPage: Int? = nil, callback: @escaping (Response<Resources<T>>) -> ()) {
        return DocumentClient.shared.get(documentsAs: documentType, in: self, maxPerPage: maxPerPage, callback: callback)
    }
    
    // get
    public func get<T: Document> (documentWithResourceId id: String, as documentType:T.Type, callback: @escaping (Response<T>) -> ()) {
        return DocumentClient.shared.get(documentWithId: id, as: documentType, in: self, callback: callback)
    }
    
    // delete
    public func delete (_ document: Document, callback: @escaping (Response<Data>) -> ()) {
        return DocumentClient.shared.delete(document, callback: callback)
    }

    public func delete (documentWithId documentId: String, callback: @escaping (Response<Data>) -> ()) {
        return DocumentClient.shared.delete(documentWithId: documentId, fromCollection: self, callback: callback)
    }

    // replace
    public func replace<T: Document> (_ document: T, callback: @escaping (Response<T>) -> ()) {
        return DocumentClient.shared.replace(document, in: self, callback: callback)
    }
    
    // query
    public func query (documentsWith query: Query, maxPerPage: Int? = nil, callback: @escaping (Response<Resources<Document>>) -> ()) {
        return DocumentClient.shared.query(documentsIn: self, with: query, maxPerPage: maxPerPage, callback: callback)
    }

    public func query (documentsWith query: Query, maxPerPage: Int? = nil, callback: @escaping (Response<Resources<DictionaryDocument>>) -> ()) {
        return DocumentClient.shared.query(documentsIn: self, with: query, maxPerPage: maxPerPage, callback: callback)
    }

    
    
    // MARK: Stored Procedures
    
    // create
    public func create (storedProcedureWithId id: String, andBody body: String, callback: @escaping (Response<StoredProcedure>) -> ()) {
        return DocumentClient.shared.create (storedProcedureWithId: id, andBody: body, in: self, callback: callback)
    }
    
    // list
    public func getStoredProcedures (maxPerPage: Int? = nil, callback: @escaping (Response<Resources<StoredProcedure>>) -> ()) {
        return DocumentClient.shared.get (storedProceduresIn: self, maxPerPage: maxPerPage, callback: callback)
    }
    
    // delete
    public func delete (_ storedProcedure: StoredProcedure, callback: @escaping (Response<Data>) -> ()) {
        return DocumentClient.shared.delete (storedProcedure, callback: callback)
    }

    public func delete (storedProcedureWithId id: String, callback: @escaping (Response<Data>) -> ()) {
        return DocumentClient.shared.delete (storedProcedureWithId: id, fromCollection: self, callback: callback)
    }

    // replace
    public func replace (storedProcedureWithId id: String, andBody body: String, callback: @escaping (Response<StoredProcedure>) -> ()) {
        return DocumentClient.shared.replace (storedProcedureWithId: id, andBody: body, in: self, callback: callback)
    }
    
    // execute
    public func execute (storedProcedureWithId id: String, usingParameters parameters: [String]?, callback: @escaping (Response<Data>) -> ()) {
        return DocumentClient.shared.execute (storedProcedureWithId: id, usingParameters: parameters, in: self, callback: callback)
    }
    
    
    
    // MARK: User Defined Functions
    
    // create
    public func create (userDefinedFunctionWithId id: String, andBody body: String, callback: @escaping (Response<UserDefinedFunction>) -> ()) {
        return DocumentClient.shared.create (userDefinedFunctionWithId: id, andBody: body, in: self, callback: callback)
    }
    
    // list
    public func getUserDefinedFunctions (maxPerPage: Int? = nil, callback: @escaping (Response<Resources<UserDefinedFunction>>) -> ()) {
        return DocumentClient.shared.get (userDefinedFunctionsIn: self, maxPerPage: maxPerPage, callback: callback)
    }
    
    // delete
    public func delete (_ userDefinedFunction: UserDefinedFunction, callback: @escaping (Response<Data>) -> ()) {
        return DocumentClient.shared.delete (userDefinedFunction, callback: callback)
    }

    public func delete (userDefinedFunctionWithId functionId: String, callback: @escaping (Response<Data>) -> ()) {
        return DocumentClient.shared.delete (userDefinedFunctionWithId: functionId, fromCollection: self, callback: callback)
    }

    // replace
    public func replace (userDefinedFunctionWithId id: String, andBody body: String, callback: @escaping (Response<UserDefinedFunction>) -> ()) {
        return DocumentClient.shared.replace (userDefinedFunctionWithId: id, andBody: body, from: self, callback: callback)
    }
    
    
    
    // MARK: Triggers
    
    // create
    public func create (triggerWithId id: String, operation: Trigger.TriggerOperation, type: Trigger.TriggerType, andBody body: String, callback: @escaping (Response<Trigger>) -> ()) {
        return DocumentClient.shared.create (triggerWithId: id, operation: operation, type: type, andBody: body, in: self, callback: callback)
    }
    
    // list
    public func getTriggers (maxPerPage: Int? = nil, callback: @escaping (Response<Resources<Trigger>>) -> ()) {
        return DocumentClient.shared.get (triggersIn: self, maxPerPage: maxPerPage, callback: callback)
    }
    
    // delete
    public func delete (_ trigger: Trigger, callback: @escaping (Response<Data>) -> ()) {
        return DocumentClient.shared.delete (trigger, callback: callback)
    }

    public func delete (triggerWithId triggerId: String, callback: @escaping (Response<Data>) -> ()) {
        return DocumentClient.shared.delete(triggerWithId: triggerId, fromCollection: self, callback: callback)
    }

    // replace
    public func replace (triggerWithId id: String, operation: Trigger.TriggerOperation, type: Trigger.TriggerType, andBody body: String, callback: @escaping (Response<Trigger>) -> ()) {
        return DocumentClient.shared.replace (triggerWithId: id, operation: operation, type: type, andBody: body, in: self, callback: callback)
    }
}



// MARK: -

public extension Document {
    
    public func refresh(_ callback: @escaping (Response<Document>) -> ()) {
        return DocumentClient.shared.refresh(self, callback: callback)
    }
    
    
    // MARK: Attachments
    
    // create
    public func create (attachmentWithId attachmentId: String, contentType: String, andMediaUrl mediaUrl: URL, callback: @escaping (Response<Attachment>) -> ()) {
        return DocumentClient.shared.create(attachmentWithId: attachmentId, contentType: contentType, andMediaUrl: mediaUrl, onDocument: self, callback: callback)
    }
    
    public func create (attachmentWithId attachmentId: String, contentType: String, name mediaName: String, with media: Data, callback: @escaping (Response<Attachment>) -> ()) {
        return DocumentClient.shared.create(attachmentWithId: attachmentId, contentType: contentType, name: mediaName, with: media, onDocument: self, callback: callback)
    }
    
    // list
    public func getAttachments (maxPerPage: Int? = nil, callback: @escaping (Response<Resources<Attachment>>) -> ()) {
        return DocumentClient.shared.get (attachmentsOn: self, maxPerPage: maxPerPage, callback: callback)
    }
    
    // delete
    public func delete (_ attachment: Attachment, callback: @escaping (Response<Data>) -> ()) {
        return DocumentClient.shared.delete (attachment, callback: callback)
    }

    public func delete (attachmentWithId id: String, callback: @escaping (Response<Data>) -> ()) {
        return DocumentClient.shared.delete(attachmentWithId: id, fromDocument: self, callback: callback)
    }

    // replace
    public func replace (attachmentWithId attachmentId: String, contentType: String, andMediaUrl mediaUrl: URL, callback: @escaping (Response<Attachment>) -> ()) {
        return DocumentClient.shared.replace(attachmentWithId: attachmentId, contentType: contentType, andMediaUrl: mediaUrl, onDocument: self, callback: callback)
    }
    
    public func replace (attachmentWithId attachmentId: String, contentType: String, name mediaName: String, with media: Data, callback: @escaping (Response<Attachment>) -> ()) {
        return DocumentClient.shared.replace(attachmentWithId: attachmentId, contentType: contentType, name: mediaName, with: media, onDocument: self, callback: callback)
    }
}



// MARK: -

public extension User {
    
    public func refresh(_ callback: @escaping (Response<User>) -> ()) {
        return DocumentClient.shared.refresh(self, callback: callback)
    }

    
    // MARK: Permissions
    
    // create
    public func create (permissionWithId permissionId: String, mode permissionMode: PermissionMode, in resource: CodableResource, callback: @escaping (Response<Permission>) -> ()) {
        return DocumentClient.shared.create (permissionWithId: permissionId, mode: permissionMode, in: resource, forUser: self, callback: callback)
    }
    
    // list
    public func getPermissions (maxPerPage: Int? = nil, callback: @escaping (Response<Resources<Permission>>) -> ()) {
        return DocumentClient.shared.get (permissionsFor: self, maxPerPage: maxPerPage, callback: callback)
    }
    
    // get
    public func get (permissionWithId permissionId: String, callback: @escaping (Response<Permission>) -> ()) {
        return DocumentClient.shared.get (permissionWithId: permissionId, forUser: self, callback: callback)
    }
    
    // delete
    public func delete (_ permission: Permission, callback: @escaping (Response<Data>) -> ()) {
        return DocumentClient.shared.delete (permission, callback: callback)
    }

    public func delete (permissionWithId permissionId: String, callback: @escaping (Response<Data>) -> ()) {
        return DocumentClient.shared.delete(permissionWithId: permissionId, fromUser: self, callback: callback)
    }

    // replace
    public func replace (permissionWithId permissionId: String, mode permissionMode: PermissionMode, in resource: CodableResource, callback: @escaping (Response<Permission>) -> ()) {
        return DocumentClient.shared.replace (permissionWithId: permissionId, mode: permissionMode, in: resource, forUser: self, callback: callback)
    }
}








