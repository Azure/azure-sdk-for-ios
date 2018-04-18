//
//  DocumentClient.swift
//  AzureData iOS
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCore

class DocumentClient {
    
    static let shared: DocumentClient = DocumentClient()
    
    fileprivate var host: String!
    
    fileprivate var isOffline: Bool = false
        
    fileprivate var permissionProvider: PermissionProvider?
    
    fileprivate var resourceTokenProvider: ResourceTokenProvider?
    
    fileprivate var configuredWithMasterKey: Bool { return resourceTokenProvider != nil }
    
    #if !os(watchOS)
    fileprivate var reachabilityManager: ReachabilityManager! {
        willSet {
            newValue.listener = networkReachabilityChanged
            newValue.startListening()
        }
    }
    
    func networkReachabilityChanged(status: ReachabilityManager.NetworkReachabilityStatus) {
        Log.debug("Network Status Changed: \(status)")
        self.isOffline = false
    }
    #endif
    

    fileprivate let session: URLSession


    fileprivate init(configuration: URLSessionConfiguration = URLSessionConfiguration.default) {

        configuration.httpAdditionalHeaders = DocumentClient.defaultHttpHeaders
        
        self.session = URLSession(configuration: configuration)
    }
    
    
    // MARK: - JSONEncoder & JSONDecoder
    
    var dateDecoder: ((Decoder) throws -> Date)? = nil
    
    var dateEncoder: ((Date, Encoder) throws -> Void)? = nil
    
    lazy var jsonEncoder: JSONEncoder = {
        
        let encoder = JSONEncoder()
        
        if self.dateEncoder == nil {
            self.dateEncoder = DocumentClient.roundTripIso8601Encoder
        }
        
        encoder.dateEncodingStrategy = .custom(self.dateEncoder!)
        
        Log.debug {
            encoder.outputFormatting = .prettyPrinted
            return "encoder.outputFormatting = .prettyPrinted"
        }
        
        return encoder
    }()
    
    lazy var jsonDecoder: JSONDecoder = {
        
        if self.dateDecoder == nil {
            self.dateDecoder = DocumentClient.roundTripIso8601Decoder
        }
        
        let decoder = JSONDecoder()
        
        decoder.dateDecodingStrategy = .custom(self.dateDecoder!)
        
        return decoder
    }()
    
    
    // MARK: - Setup
    
    var isConfigured: Bool {
        return host != nil && (resourceTokenProvider != nil || permissionProvider != nil)
    }
    
    func configure (forAccountNamed name: String, withMasterKey key: String, withPermissionMode mode: PermissionMode) {
        resourceTokenProvider = ResourceTokenProvider(withMasterKey: key, withPermissionMode: mode)
        commonConfigure(withHost: name + ".documents.azure.com")
    }
    
    func configure (forAccountAt url: URL, withMasterKey key: String, withPermissionMode mode: PermissionMode) {
        resourceTokenProvider = ResourceTokenProvider(withMasterKey: key, withPermissionMode: mode)
        commonConfigure(withHost: url.host)
    }

    func configure (forAccountNamed name: String, withPermissionProvider provider: PermissionProvider) {
        permissionProvider = provider
        commonConfigure(withHost: name + ".documents.azure.com")
    }
    
    func configure (forAccountAt url: URL, withPermissionProvider provider: PermissionProvider) {
        permissionProvider = provider
        commonConfigure(withHost: url.host)
    }

    fileprivate func commonConfigure(withHost host: String?) {
        guard
            let host = host, !host.isEmpty
        else { fatalError("Host is invalid") }
        self.host = host
        #if !os(watchOS)
        reachabilityManager = ReachabilityManager(host: host)
        #endif
        ResourceOracle.host = host
        ResourceOracle.restore()
    }
    
    
    func reset () {
        host = nil
        permissionProvider = nil
        resourceTokenProvider = nil
    }
    
    
    
    // MARK: - Conflict Strategy
    
    var conflictStrategies: [ResourceType:ConflictStrategy] = [:]
        
    func register(strategy: ConflictStrategy, for resourceTypes: [ResourceType]) {
        for type in resourceTypes {
            conflictStrategies[type] = strategy
        }
    }
    
    
    
    // MARK: - Databases
    
    // create
    func create (databaseWithId databaseId: String, callback: @escaping (Response<Database>) -> ()) {
        return self.create(Database(databaseId), at: .database(id: nil), callback: callback)
    }
    
    // list
    public func databases (maxPerPage: Int? = nil, callback: @escaping (Response<Resources<Database>>) -> ()) {
        return self.resources(at: .database(id: nil), maxPerPage: maxPerPage, callback: callback)
    }
    
    // get
    func get (databaseWithId databaseId: String, callback: @escaping (Response<Database>) -> ()) {
        return self.resource(at: .database(id: databaseId), callback: callback)
    }
    
    // delete
    func delete (databaseWithId databaseId: String, callback: @escaping (Response<Data>) -> ()) {
        return self.delete(resourceAt: .database(id: databaseId), callback: callback)
    }

    
    
    // MARK: - Collections
    
    // create
    func create (collectionWithId collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<DocumentCollection>) -> ()) {
        return self.create(DocumentCollection(collectionId), at: .collection(databaseId: databaseId, id: nil), callback: callback)
    }

    func create (collectionWithId collectionId: String, in database: Database, callback: @escaping (Response<DocumentCollection>) -> ()) {
        return self.create(DocumentCollection(collectionId), at: .child(.collection, in: database, id: nil), callback: callback)
    }

    // list
    func get (collectionsIn databaseId: String, maxPerPage: Int? = nil, callback: @escaping (Response<Resources<DocumentCollection>>) -> ()) {
        return self.resources(at: .collection(databaseId: databaseId, id: nil), maxPerPage: maxPerPage, callback: callback)
    }

    func get (collectionsIn database: Database, maxPerPage: Int? = nil, callback: @escaping (Response<Resources<DocumentCollection>>) -> ()) {
        return self.resources(at: .child(.collection, in: database, id: nil), maxPerPage: maxPerPage, callback: callback)
    }

    // get
    func get (collectionWithId collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<DocumentCollection>) -> ()) {
        return self.resource(at: .collection(databaseId: databaseId, id: collectionId), callback: callback)
    }

    func get (collectionWithId collectionId: String, inDatabase database: Database, callback: @escaping (Response<DocumentCollection>) -> ()) {
        return self.resource(at: .child(.collection, in: database, id: collectionId), callback: callback)
    }

    // delete
    func delete (collectionWithId collectionId: String, fromDatabase databaseId: String, callback: @escaping (Response<Data>) -> ()) {
        return self.delete(resourceAt: .collection(databaseId: databaseId, id: collectionId), callback: callback)
    }
    
    func delete (collectionWithId collectionId: String, from database: Database, callback: @escaping (Response<Data>) -> ()) {
        return self.delete(resourceAt: .child(.collection, in: database, id: collectionId), callback: callback)
    }

    // replace
    func replace (collectionWithId collectionId: String, inDatabase databaseId: String, usingPolicy policy: DocumentCollection.IndexingPolicy, callback: @escaping (Response<DocumentCollection>) -> ()) {
        return self.replace(DocumentCollection(collectionId, indexingPolicy: policy), at: .collection(databaseId: databaseId, id: collectionId), callback: callback)
    }
    
    
    
    
    
    // MARK: - Documents
    
    // create
    func create<T: Document> (_ document: T, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<T>) -> ()) {
        return self.create(document, at: .document(databaseId: databaseId, collectionId: collectionId, id: nil), callback: callback)
    }
    
    func create<T: Document> (_ document: T, in collection: DocumentCollection, callback: @escaping (Response<T>) -> ()) {
        return self.create(document, at: .child(.document, in: collection, id: nil), callback: callback)
    }

    func createOrReplace<T: Document> (_ document: T, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<T>) -> ()) {
        return self.create(document, at: .document(databaseId: databaseId, collectionId: collectionId, id: nil), additionalHeaders: [MSHttpHeader.msDocumentdbIsUpsert.rawValue: "true"], callback: callback)
    }

    func createOrReplace<T: Document> (_ document: T, in collection: DocumentCollection, callback: @escaping (Response<T>) -> ()) {
        return self.create(document, at: .child(.document, in: collection, id: nil), additionalHeaders: [MSHttpHeader.msDocumentdbIsUpsert.rawValue: "true"], callback: callback)
    }

    // list
    func get<T: Document> (documentsAs documentType:T.Type, inCollection collectionId: String, inDatabase databaseId: String, maxPerPage: Int? = nil, callback: @escaping (Response<Resources<T>>) -> ()) {
        return self.resources(at: .document(databaseId: databaseId, collectionId: collectionId, id: nil), maxPerPage: maxPerPage, callback: callback)
    }
    
    func get<T: Document> (documentsAs documentType:T.Type, in collection: DocumentCollection, maxPerPage: Int? = nil, callback: @escaping (Response<Resources<T>>) -> ()) {
        return self.resources(at: .child(.document, in: collection, id: nil), maxPerPage: maxPerPage, callback: callback)
    }
    
    // get
    func get<T: Document> (documentWithId documentId: String, as documentType:T.Type, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<T>) -> ()) {
        return self.resource(at: .document(databaseId: databaseId, collectionId: collectionId, id: documentId), callback: callback)
    }
    
    func get<T: Document> (documentWithId documentId: String, as documentType:T.Type, in collection: DocumentCollection, callback: @escaping (Response<T>) -> ()) {
        return self.resource(at: .child(.document, in: collection, id: documentId), callback: callback)
    }
    
    // delete
    func delete (documentWithId documentId: String, fromCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<Data>) -> ()) {
        return self.delete(resourceAt: .document(databaseId: databaseId, collectionId: collectionId, id: documentId), callback: callback)
    }
    
    func delete (documentWithId documentId: String, from collection: DocumentCollection, callback: @escaping (Response<Data>) -> ()) {
        return self.delete(resourceAt: .child(.document, in: collection, id: documentId), callback: callback)
    }
    
    // replace
    func replace<T: Document> (_ document: T, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<T>) -> ()) {
        return self.replace(document, at: .document(databaseId: databaseId, collectionId: collectionId, id: document.id), callback: callback)
    }
    
    func replace<T: Document> (_ document: T, in collection: DocumentCollection, callback: @escaping (Response<T>) -> ()) {
        return self.replace(document, at: .child(.document, in: collection, id: document.id), callback: callback)
    }
    
    // query
    func query<T: Document> (documentsIn collectionId: String, as documentType: T.Type, inDatabase databaseId: String, with query: Query, maxPerPage: Int? = nil, callback: @escaping (Response<Resources<T>>) -> ()) {
        return self.query(query, at: .document(databaseId: databaseId, collectionId: collectionId, id: nil), maxPerPage: maxPerPage, callback: callback)
    }
    
    func query<T: Document> (documentsIn collection: DocumentCollection, as documentType: T.Type, with query: Query, maxPerPage: Int? = nil, callback: @escaping (Response<Resources<T>>) -> ()) {
        return self.query(query, at: .child(.document, in: collection, id: nil), maxPerPage: maxPerPage, callback: callback)
    }

    func query (documentsIn collectionId: String, inDatabase databaseId: String, with query: Query, maxPerPage: Int? = nil, callback: @escaping (Response<Resources<DictionaryDocument>>) -> ()) {
        return self.query(query, at: .document(databaseId: databaseId, collectionId: collectionId, id: nil), maxPerPage: maxPerPage, callback: callback)
    }
    
    func query (documentsIn collection: DocumentCollection, with query: Query, maxPerPage: Int? = nil, callback: @escaping (Response<Resources<DictionaryDocument>>) -> ()) {
        return self.query(query, at: .child(.document, in: collection, id: nil), maxPerPage: maxPerPage, callback: callback)
    }
    
    

    
    // MARK: - Attachments
    
    // create
    func create(attachmentWithId attachmentId: String, contentType: String, andMediaUrl mediaUrl: URL, onDocument documentId: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<Attachment>) -> ()) {
        return self.create(Attachment(attachmentId, contentType: contentType, url: mediaUrl.absoluteString), at: .attachment(databaseId: databaseId, collectionId: collectionId, documentId: documentId, id: nil), callback: callback)
    }
    
    func create(attachmentWithId attachmentId: String, contentType: String, name mediaName: String, with media: Data, onDocument documentId: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<Attachment>) -> ()) {
        return self.createOrReplace(media, at: .attachment(databaseId: databaseId, collectionId: collectionId, documentId: documentId, id: nil), additionalHeaders: [ HttpHeader.contentType.rawValue: contentType, HttpHeader.slug.rawValue: mediaName ], callback: callback)
    }
    
    func create(attachmentWithId attachmentId: String, contentType: String, andMediaUrl mediaUrl: URL, on document: Document, callback: @escaping (Response<Attachment>) -> ()) {
        return self.create(Attachment(attachmentId, contentType: contentType, url: mediaUrl.absoluteString), at: .child(.attachment, in: document, id: nil), callback: callback)
    }
    
    func create(attachmentWithId attachmentId: String, contentType: String, name mediaName: String, with media: Data, on document: Document, callback: @escaping (Response<Attachment>) -> ()) {
        return self.createOrReplace(media, at: .child(.attachment, in: document, id: nil), additionalHeaders: [ HttpHeader.contentType.rawValue: contentType, HttpHeader.slug.rawValue: mediaName ], callback: callback)
    }
    
    // list
    func get (attachmentsOn documentId: String, inCollection collectionId: String, inDatabase databaseId: String, maxPerPage: Int? = nil, callback: @escaping (Response<Resources<Attachment>>) -> ()) {
        return self.resources(at: .attachment(databaseId: databaseId, collectionId: collectionId, documentId: documentId, id: nil), maxPerPage: maxPerPage, callback: callback)
    }

    func get (attachmentsOn document: Document, maxPerPage: Int? = nil, callback: @escaping (Response<Resources<Attachment>>) -> ()) {
        return self.resources(at: .child(.attachment, in: document, id: nil), maxPerPage: maxPerPage, callback: callback)
    }
    
    // delete
    func delete (attachmentWithId attachmentId: String, fromDocument documentId: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<Data>) -> ()) {
        return self.delete(resourceAt: .attachment(databaseId: databaseId, collectionId: collectionId, documentId: documentId, id: attachmentId), callback: callback)
    }
    
    func delete (attachmentWithId attachmentId: String, from document: Document, callback: @escaping (Response<Data>) -> ()) {
        return self.delete(resourceAt: .child(.attachment, in: document, id: attachmentId), callback: callback)
    }
    
    // replace
    func replace(attachmentWithId attachmentId: String, contentType: String, andMediaUrl mediaUrl: URL, onDocument documentId: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<Attachment>) -> ()) {
        return self.replace(Attachment(attachmentId, contentType: contentType, url: mediaUrl.absoluteString), at: .attachment(databaseId: databaseId, collectionId: collectionId, documentId: documentId, id: attachmentId), callback: callback)
    }
    
    func replace(attachmentWithId attachmentId: String, contentType: String, name mediaName: String, with media: Data, onDocument documentId: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<Attachment>) -> ()) {
        return self.createOrReplace(media, at: .attachment(databaseId: databaseId, collectionId: collectionId, documentId: documentId, id: attachmentId), replacing: true, additionalHeaders: [ HttpHeader.contentType.rawValue: contentType, HttpHeader.slug.rawValue: mediaName ], callback: callback)
    }
    
    func replace(attachmentWithId attachmentId: String, contentType: String, andMediaUrl mediaUrl: URL, on document: Document, callback: @escaping (Response<Attachment>) -> ()) {
        return self.replace(Attachment(attachmentId, contentType: contentType, url: mediaUrl.absoluteString), at: .child(.attachment, in: document, id: attachmentId), callback: callback)
    }
    
    func replace(attachmentWithId attachmentId: String, contentType: String, name mediaName: String, with media: Data, on document: Document, callback: @escaping (Response<Attachment>) -> ()) {
        return self.createOrReplace(media, at: .child(.attachment, in: document, id: attachmentId), replacing: true, additionalHeaders: [ HttpHeader.contentType.rawValue: contentType, HttpHeader.slug.rawValue: mediaName ], callback: callback)
    }

    
    
    
    
    // MARK: - Stored Procedures
    
    // create
    func create (storedProcedureWithId storedProcedureId: String, andBody procedure: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<StoredProcedure>) -> ()) {
        return self.create(StoredProcedure(storedProcedureId, body: procedure), at: .storedProcedure(databaseId: databaseId, collectionId: collectionId, id: nil), callback: callback)
    }
    
    func create (storedProcedureWithId storedProcedureId: String, andBody procedure: String, in collection: DocumentCollection, callback: @escaping (Response<StoredProcedure>) -> ()) {
        return self.create(StoredProcedure(storedProcedureId, body: procedure), at: .child(.storedProcedure, in: collection, id: nil), callback: callback)
    }
    
    // list
    func get (storedProceduresIn collectionId: String, inDatabase databaseId: String, maxPerPage: Int? = nil, callback: @escaping (Response<Resources<StoredProcedure>>) -> ()) {
        return self.resources(at: .storedProcedure(databaseId: databaseId, collectionId: collectionId, id: nil), maxPerPage: maxPerPage, callback: callback)
    }
    
    func get (storedProceduresIn collection: DocumentCollection, maxPerPage: Int? = nil, callback: @escaping (Response<Resources<StoredProcedure>>) -> ()) {
        return self.resources(at: .child(.storedProcedure, in: collection, id: nil), maxPerPage: maxPerPage, callback: callback)
    }
    
    // delete
    func delete (storedProcedureWithId storedProcedureId: String, fromCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<Data>) -> ()) {
        return self.delete(resourceAt: .storedProcedure(databaseId: databaseId, collectionId: collectionId, id: storedProcedureId), callback: callback)
    }
    
    func delete (storedProcedureWithId storedProcedureId: String, from collection: DocumentCollection, callback: @escaping (Response<Data>) -> ()) {
        return self.delete(resourceAt: .child(.storedProcedure, in: collection, id: storedProcedureId), callback: callback)
    }
    
    // replace
    func replace (storedProcedureWithId storedProcedureId: String, andBody procedure: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<StoredProcedure>) -> ()) {
        return self.replace(StoredProcedure(storedProcedureId, body: procedure), at: .storedProcedure(databaseId: databaseId, collectionId: collectionId, id: storedProcedureId), callback: callback)
    }
    
    func replace (storedProcedureWithId storedProcedureId: String, andBody procedure: String, in collection: DocumentCollection, callback: @escaping (Response<StoredProcedure>) -> ()) {
        return self.replace(StoredProcedure(storedProcedureId, body: procedure), at: .child(.storedProcedure, in: collection, id: storedProcedureId), callback: callback)
    }
    
    // execute
    func execute (_ storedProcedure: StoredProcedure, usingParameters parameters: [String]?, callback: @escaping (Response<Data>) -> ()) {
        return self.execute(StoredProcedure.self, withBody: parameters, at: .resource(resource: storedProcedure), callback: callback)
    }

    func execute (storedProcedureWithId storedProcedureId: String, usingParameters parameters: [String]?, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<Data>) -> ()) {
        return self.execute(StoredProcedure.self, withBody: parameters, at: .storedProcedure(databaseId: databaseId, collectionId: collectionId, id: storedProcedureId), callback: callback)
    }
    
    func execute (storedProcedureWithId storedProcedureId: String, usingParameters parameters: [String]?, in collection: DocumentCollection, callback: @escaping (Response<Data>) -> ()) {
        return self.execute(StoredProcedure.self, withBody: parameters, at: .child(.storedProcedure, in: collection, id: storedProcedureId), callback: callback)
    }

    
    

    
    // MARK: - User Defined Functions
    
    // create
    func create (userDefinedFunctionWithId functionId: String, andBody function: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<UserDefinedFunction>) -> ()) {
        return self.create(UserDefinedFunction(functionId, body: function), at: .udf(databaseId: databaseId, collectionId: collectionId, id: nil), callback: callback)
    }
    
    func create (userDefinedFunctionWithId functionId: String, andBody function: String, in collection: DocumentCollection, callback: @escaping (Response<UserDefinedFunction>) -> ()) {
        return self.create(UserDefinedFunction(functionId, body: function), at: .child(.udf, in: collection, id: nil), callback: callback)
    }
    
    // list
    func get (userDefinedFunctionsIn collectionId: String, inDatabase databaseId: String, maxPerPage: Int? = nil, callback: @escaping (Response<Resources<UserDefinedFunction>>) -> ()) {
        return self.resources(at: .udf(databaseId: databaseId, collectionId: collectionId, id: nil), maxPerPage: maxPerPage, callback: callback)
    }
    
    func get (userDefinedFunctionsIn collection: DocumentCollection, maxPerPage: Int? = nil, callback: @escaping (Response<Resources<UserDefinedFunction>>) -> ()) {
        return self.resources(at: .child(.udf, in: collection, id: nil), maxPerPage: maxPerPage, callback: callback)
    }
    
    // delete
    func delete (userDefinedFunctionWithId functionId: String, fromCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<Data>) -> ()) {
        return self.delete(resourceAt: .udf(databaseId: databaseId, collectionId: collectionId, id: functionId), callback: callback)
    }
    
    func delete (userDefinedFunctionWithId functionId: String, from collection: DocumentCollection, callback: @escaping (Response<Data>) -> ()) {
        return self.delete(resourceAt: .child(.udf, in: collection, id: functionId), callback: callback)
    }
    
    // replace
    func replace (userDefinedFunctionWithId functionId: String, andBody function: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<UserDefinedFunction>) -> ()) {
        return self.replace(UserDefinedFunction(functionId, body: function), at: .udf(databaseId: databaseId, collectionId: collectionId, id: functionId), callback: callback)
    }
    
    func replace (userDefinedFunctionWithId functionId: String, andBody function: String, from collection: DocumentCollection, callback: @escaping (Response<UserDefinedFunction>) -> ()) {
        return self.replace(UserDefinedFunction(functionId, body: function), at: .child(.udf, in: collection, id: functionId), callback: callback)
    }
    
    
    
    
    
    // MARK: - Triggers
    
    // create
    func create (triggerWithId triggerId: String, operation: Trigger.TriggerOperation, type triggerType: Trigger.TriggerType, andBody triggerBody: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<Trigger>) -> ()) {
        return self.create(Trigger(triggerId, body: triggerBody, operation: operation, type: triggerType), at: .trigger(databaseId: databaseId, collectionId: collectionId, id: nil), callback: callback)
    }
    
    func create (triggerWithId triggerId: String, operation: Trigger.TriggerOperation, type triggerType: Trigger.TriggerType, andBody triggerBody: String, in collection: DocumentCollection, callback: @escaping (Response<Trigger>) -> ()) {
        return self.create(Trigger(triggerId, body: triggerBody, operation: operation, type: triggerType), at: .child(.trigger, in: collection, id: nil), callback: callback)
    }
    
    // list
    func get (triggersIn collectionId: String, inDatabase databaseId: String, maxPerPage: Int? = nil, callback: @escaping (Response<Resources<Trigger>>) -> ()) {
        return self.resources(at: .trigger(databaseId: databaseId, collectionId: collectionId, id: nil), maxPerPage: maxPerPage, callback: callback)
    }
    
    func get (triggersIn collection: DocumentCollection, maxPerPage: Int? = nil, callback: @escaping (Response<Resources<Trigger>>) -> ()) {
        return self.resources(at: .child(.trigger, in: collection, id: nil), maxPerPage: maxPerPage, callback: callback)
    }
    
    // delete
    func delete (triggerWithId triggerId: String, fromCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<Data>) -> ()) {
        return self.delete(resourceAt: .trigger(databaseId: databaseId, collectionId: collectionId, id: triggerId), callback: callback)
    }

    func delete (triggerWithId triggerId: String, from collection: DocumentCollection, callback: @escaping (Response<Data>) -> ()) {
        return self.delete(resourceAt: .child(.trigger, in: collection, id: triggerId), callback: callback)
    }
    
    // replace
    func replace (triggerWithId triggerId: String, operation: Trigger.TriggerOperation, type triggerType: Trigger.TriggerType, andBody triggerBody: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<Trigger>) -> ()) {
        return self.replace(Trigger(triggerId, body: triggerBody, operation: operation, type: triggerType), at: .trigger(databaseId: databaseId, collectionId: collectionId, id: triggerId), callback: callback)
    }
    
    func replace (triggerWithId triggerId: String, operation: Trigger.TriggerOperation, type triggerType: Trigger.TriggerType, andBody triggerBody: String, in collection: DocumentCollection, callback: @escaping (Response<Trigger>) -> ()) {
        return self.replace(Trigger(triggerId, body: triggerBody, operation: operation, type: triggerType), at: .child(.trigger, in: collection, id: triggerId), callback: callback)
    }

    
    
    
    
    // MARK: - Users
    
    // create
    func create (userWithId userId: String, inDatabase databaseId: String, callback: @escaping (Response<User>) -> ()) {
        return self.create(User(userId), at: .user(databaseId: databaseId, id: nil), callback: callback)
    }

    func create (userWithId userId: String, in database: Database, callback: @escaping (Response<User>) -> ()) {
        return self.create(User(userId), at: .child(.user, in: database, id: nil), callback: callback)
    }

    // list
    func get (usersIn databaseId: String, maxPerPage: Int? = nil, callback: @escaping (Response<Resources<User>>) -> ()) {
        return self.resources(at: .user(databaseId: databaseId, id: nil), maxPerPage: maxPerPage, callback: callback)
    }

    func get (usersIn database: Database, maxPerPage: Int? = nil, callback: @escaping (Response<Resources<User>>) -> ()) {
        return self.resources(at: .child(.user, in: database, id: nil), maxPerPage: maxPerPage, callback: callback)
    }

    // get
    func get (userWithId userId: String, inDatabase databaseId: String, callback: @escaping (Response<User>) -> ()) {
        return self.resource(at: .user(databaseId: databaseId, id: userId), callback: callback)
    }

    func get (userWithId userId: String, in database: Database, callback: @escaping (Response<User>) -> ()) {
        return self.resource(at: .child(.user, in: database, id: userId), callback: callback)
    }

    // delete
    func delete (userWithId userId: String, fromDatabase databaseId: String, callback: @escaping (Response<Data>) -> ()) {
        return self.delete(resourceAt: .user(databaseId: databaseId, id: userId), callback: callback)
    }
    
    func delete (userWithId userId: String, from database: Database, callback: @escaping (Response<Data>) -> ()) {
        return self.delete(resourceAt: .child(.user, in: database, id: userId), callback: callback)
    }
    
    // replace
    func replace (userWithId userId: String, with newUserId: String, inDatabase databaseId: String, callback: @escaping (Response<User>) -> ()) {
        return self.replace(User(userId), at: .user(databaseId: databaseId, id: userId), callback: callback)
    }

    func replace (userWithId userId: String, with newUserId: String, in database: Database, callback: @escaping (Response<User>) -> ()) {
        return self.replace(User(userId), at: .child(.user, in: database, id: userId), callback: callback)
    }

    
    
    // MARK: - Permissions
    
    // create
    func create (permissionWithId permissionId: String, mode permissionMode: PermissionMode, in resource: CodableResource & SupportsPermissionToken, forUser userId: String, inDatabase databaseId: String, callback: @escaping (Response<Permission>) -> ()) {
        return self.create(Permission(permissionId, mode: permissionMode, forResource: resource.selfLink!), at: .permission(databaseId: databaseId, userId: userId, id: nil), callback: callback)
    }
    
    func create (permissionWithId permissionId: String, mode permissionMode: PermissionMode, in resource: CodableResource & SupportsPermissionToken, for user: User, callback: @escaping (Response<Permission>) -> ()) {
        return self.create(Permission(permissionId, mode: permissionMode, forResource: resource.selfLink!), at: .child(.permission, in: user, id: nil), callback: callback)
    }
    
    // list
    func get (permissionsFor userId: String, inDatabase databaseId: String, maxPerPage: Int? = nil, callback: @escaping (Response<Resources<Permission>>) -> ()) {
        return self.resources(at: .permission(databaseId: databaseId, userId: userId, id: nil), maxPerPage: maxPerPage, callback: callback)
    }
    
    func get (permissionsFor user: User, maxPerPage: Int? = nil, callback: @escaping (Response<Resources<Permission>>) -> ()) {
        return self.resources(at: .child(.permission, in: user, id: nil), maxPerPage: maxPerPage, callback: callback)
    }
    
    // get
    func get (permissionWithId permissionId: String, forUser userId: String, inDatabase databaseId: String, callback: @escaping (Response<Permission>) -> ()) {
        return self.resource(at: .permission(databaseId: databaseId, userId: userId, id: permissionId), callback: callback)
    }
    
    func get (permissionWithId permissionId: String, for user: User, callback: @escaping (Response<Permission>) -> ()) {
        return self.resource(at: .child(.permission, in: user, id: permissionId), callback: callback)
    }
    
    // delete
    func delete (permissionWithId permissionId: String, fromUser userId: String, inDatabase databaseId: String, callback: @escaping (Response<Data>) -> ()) {
        return self.delete(resourceAt: .permission(databaseId: databaseId, userId: userId, id: permissionId), callback: callback)
    }
    
    func delete (permissionWithId permissionId: String, from user: User, callback: @escaping (Response<Data>) -> ()) {
        return self.delete(resourceAt: .child(.permission, in: user, id: permissionId), callback: callback)
    }
    
    // replace
    func replace (permissionWithId permissionId: String, mode permissionMode: PermissionMode, in resource: CodableResource & SupportsPermissionToken, forUser userId: String, inDatabase databaseId: String, callback: @escaping (Response<Permission>) -> ()) {
        return self.replace(Permission(permissionId, mode: permissionMode, forResource: resource.selfLink!), at: .permission(databaseId: databaseId, userId: userId, id: permissionId), callback: callback)
    }
    
    func replace (permissionWithId permissionId: String, mode permissionMode: PermissionMode, in resource: CodableResource & SupportsPermissionToken, for user: User, callback: @escaping (Response<Permission>) -> ()) {
        return self.replace(Permission(permissionId, mode: permissionMode, forResource: resource.selfLink!), at: .child(.permission, in: user, id: permissionId), callback: callback)
    }
    
    
    
    
    
    // MARK: - Offers
    
    // list
    func offers (maxPerPage: Int? = nil, callback: @escaping (Response<Resources<Offer>>) -> ()) {
        return self.resources(at: .offer(id: nil), maxPerPage: maxPerPage, callback: callback)
    }
    
    // get
    func get (offerWithId offerId: String, callback: @escaping (Response<Offer>) -> ()) {
        return self.resource(at: .offer(id: offerId), callback: callback)
    }
    
    // replace
    // TODO: replace
    
    // query
    // TODO: query
    
    
    
    
    
    // MARK: - Resources
    
    // create
    fileprivate func create<T:CodableResource> (_ resource: T, at resourceLocation: ResourceLocation, additionalHeaders: HttpHeaders? = nil, callback: @escaping (Response<T>) -> ()) {
        
        guard resource.hasValidId else {
            callback(Response(DocumentClientError(withKind: .invalidId))); return
        }
        
        return self.createOrReplace(resource, at: resourceLocation, additionalHeaders: additionalHeaders, callback: callback)
    }
    
    // refresh
    func refresh<T:CodableResource>(_ resource: T, callback: @escaping (Response<T>) -> ()) {
        
        let resourceLocation: ResourceLocation = .resource(resource: resource)
        
        if let etag = resource.etag {
            
            return self.resource(at: resourceLocation, currentResource: resource, additionalHeaders: [ HttpHeader.ifNoneMatch.rawValue : etag ], callback: callback)
        }

        return self.resource(at: resourceLocation, currentResource: resource, callback: callback)
    }
    
    // get
    fileprivate func resource<T:CodableResource>(at resourceLocation: ResourceLocation, currentResource current: T? = nil, additionalHeaders: HttpHeaders? = nil, callback: @escaping (Response<T>) -> ()) {
        
        guard !isOffline else { return cachedResource(at: resourceLocation, callback: callback) }

        dataRequest(forResourceAt: resourceLocation, withMethod: .get, andAdditionalHeaders: additionalHeaders) { r in
            
            if let request = r.resource {
            
                self.sendRequest(request, currentResource: current) { (response:Response<T>) in
                    
                    self.isOffline = response.clientError.isConnectivityError
                    
                    if self.isOffline {

                        return self.cachedResource(at: resourceLocation, withResponse: response, callback: callback)

                    } else {

                        // response.logError()
                        
                        callback(response)
                    
                        if let resource = response.resource {
                            ResourceCache.cache(resource)
                        }
                    }
                }
            } else {
                callback(Response(request: r.request, data: r.data, response: r.response, result: .failure(r.error ?? DocumentClientError(withKind: .unknownError))))
            }
        }
    }
    
    // list
    fileprivate func resources<T> (at resourceLocation: ResourceLocation, maxPerPage: Int? = nil, callback: @escaping (Response<Resources<T>>) -> ()) {
        
        guard !isOffline else { return cachedResources(at: resourceLocation, callback: callback) }
        
        dataRequest(forResourceAt: resourceLocation, withMethod: .get, andAdditionalHeaders: HttpHeaders.forMaxItemCount(maxPerPage)) { r in
            
            if let request = r.resource {
                
                self.sendRequest(request) { (response:Response<Resources<T>>) in
                    
                    self.isOffline = response.clientError.isConnectivityError
                    
                    if self.isOffline {

                        return self.cachedResources(at: resourceLocation, withResponse: response, callback: callback)
                        
                    } else {
                        
                        //response.logError()
                        
                        callback(response)
                        
                        if let resource = response.resource {
                            ResourceCache.cache(resource)
                        }
                    }
                }
            } else {
                callback(Response(request: r.request, data: r.data, response: r.response, result: .failure(r.error ?? DocumentClientError(withKind: .unknownError))))
            }
        }
    }

    // delete
    fileprivate func delete(resourceAt resourceLocation: ResourceLocation, callback: @escaping (Response<Data>) -> ()) {
        
        guard !isOffline else { callback(Response(DocumentClientError(withKind: .serviceUnavailable))); return }
        
        dataRequest(forResourceAt: resourceLocation, withMethod: .delete) { r in
            
            if let request = r.resource {
            
                self.sendRequest(request) { (response:Response<Data>) in
                    
                    //response.logError()
                    
                    self.isOffline = response.clientError.isConnectivityError

                    callback(response)
                    
                    if response.result.isSuccess {
                        ResourceCache.remove(resourceAt: resourceLocation)
                    }
                }
            } else {
                callback(Response(request: r.request, data: r.data, response: r.response, result: .failure(r.error ?? DocumentClientError(withKind: .unknownError))))
            }
        }
    }

    func delete<T:CodableResource>(_ resource: T, callback: @escaping (Response<Data>) -> ()) {
        
        return self.delete(resourceAt: .resource(resource: resource), callback: callback)
    }
    
    // replace
    fileprivate func replace<T:CodableResource> (_ resource: T, at resourceLocation: ResourceLocation, additionalHeaders: HttpHeaders? = nil, callback: @escaping (Response<T>) -> ()) {
        
        if resource.etag.isNilOrEmpty {
            return self.createOrReplace(resource, at: resourceLocation, replacing: true, additionalHeaders: additionalHeaders, callback: callback)
        }
        
        let strategy = conflictStrategies[resourceLocation.resourceType] ?? .none
        
        if case .overwrite = strategy {
            return self.createOrReplace(resource, at: resourceLocation, replacing: true, additionalHeaders: additionalHeaders, callback: callback)
        }
        
        var headers = additionalHeaders ?? [:]; headers[.ifMatch] = resource.etag!

        if case .none = strategy {
        
            return self.createOrReplace(resource, at: resourceLocation, replacing: true, additionalHeaders: headers, callback: callback)
            
        } else if case let .custom(resolver) = strategy {
            
            self.createOrReplace(resource, at: resourceLocation, replacing: true, additionalHeaders: headers) { (replaceResponse:Response<T>) in
                
                if let error = replaceResponse.clientError?.kind, case .preconditionFailure = error {
                    
                    self.resource(at: resourceLocation) { (getResponse:Response<T>) in
                    
                        if let remote = getResponse.resource, let remoteEtag = remote.etag, var resolved: T = resolver(resource, remote) as? T {
                            
                            resolved.setEtag(to: remoteEtag)
                            
                            return self.replace(resolved, at: resourceLocation, additionalHeaders: additionalHeaders, callback: callback)
                        }
                        
                        callback(replaceResponse)
                    }
                } else {
                    callback(replaceResponse)
                }
            }
        }
    }

    // query
    fileprivate func query<T:CodableResource> (_ query: Query, at resourceLocation: ResourceLocation, maxPerPage: Int? = nil, callback: @escaping (Response<Resources<T>>) -> ()) {
        
        guard !isOffline else { callback(Response(DocumentClientError(withKind: .serviceUnavailable))); return }
        
        dataRequest(forResourceAt: resourceLocation, withMethod: .post, andAdditionalHeaders: HttpHeaders.forMaxItemCount(maxPerPage), forQuery: true) { r in

            if var request = r.resource {
                
                do {
                    request.httpBody = try self.jsonEncoder.encode(query)
                } catch {
                    callback(Response(error)); return
                }
                
                self.sendRequest(request) { (response:Response<Resources<T>>) in
                    
                    //response.logError()
                    
                    self.isOffline = response.clientError.isConnectivityError
                    
                    callback(response)
                    
                    if let resource = response.resource {
                        ResourceCache.cache(resource)
                    }
                }
            } else {
                callback(Response(request: r.request, data: r.data, response: r.response, result: .failure(r.error ?? DocumentClientError(withKind: .unknownError))))
            }
        }
    }
    
    // execute
    fileprivate func execute<T:CodableResource, R: Encodable>(_ type: T.Type, withBody body: R? = nil, at resourceLocation: ResourceLocation, callback: @escaping (Response<Data>) -> ()) {
        
        guard !isOffline else { callback(Response(DocumentClientError(withKind: .serviceUnavailable))); return }
        
        dataRequest(forResourceAt: resourceLocation, withMethod: .post) { r in
            
            if var request = r.resource {
                
                do {
                    request.httpBody = body == nil ? try self.jsonEncoder.encode([String]()) : try self.jsonEncoder.encode(body)
                } catch {
                    callback(Response<Data>(error)); return
                }
                
                return self.sendRequest(request, callback: callback)
                
            } else {
                callback(Response(request: r.request, data: r.data, response: r.response, result: .failure(r.error ?? DocumentClientError(withKind: .unknownError))))
            }
        }
    }
    
    // create or replace
    fileprivate func createOrReplace<T:CodableResource, R:Encodable> (_ body: R, at resourceLocation: ResourceLocation, replacing: Bool = false, additionalHeaders: HttpHeaders? = nil, callback: @escaping (Response<T>) -> ()) {
        
        do {
            let data = try self.jsonEncoder.encode(body)
            
            return createOrReplace(data, at: resourceLocation, replacing: replacing, additionalHeaders: additionalHeaders, callback: callback)

        } catch {
            callback(Response(error)); return
        }
    }
    
    fileprivate func createOrReplace<T:CodableResource> (_ body: Data, at resourceLocation: ResourceLocation, replacing: Bool = false, additionalHeaders: HttpHeaders? = nil, callback: @escaping (Response<T>) -> ()) {
        
        guard !isOffline else { callback(Response(DocumentClientError(withKind: .serviceUnavailable))); return }
        
        dataRequest(forResourceAt: resourceLocation, withMethod: replacing ? .put : .post, andAdditionalHeaders: additionalHeaders) { r in
            
            if var request = r.resource {
                
                request.httpBody = body
                
                self.sendRequest(request) { (response:Response<T>) in
                    
                    //response.logError()
                    
                    self.isOffline = response.clientError.isConnectivityError
                    
                    callback(response)
                    
                    if let resource = response.resource {
                        
                        if replacing {
                            ResourceCache.replace(resource, at: resourceLocation)
                        } else {
                            ResourceCache.cache(resource)
                        }
                    }
                }
            } else {
                callback(Response(request: r.request, data: r.data, response: r.response, result: .failure(r.error ?? DocumentClientError(withKind: .unknownError))))
            }
        }
    }

    // cached
    fileprivate func cachedResource<T:CodableResource>(at resourceLocation: ResourceLocation, withResponse response: Response<T>? = nil, callback: @escaping (Response<T>) -> ()) {
        
        if let resource: T = ResourceCache.get(resourceAt: resourceLocation) {
            var cacheResponse = Response(request: response?.request, data: response?.data, response: response?.response, result: .success(resource))
            cacheResponse.fromCache = true
            callback(cacheResponse)
        } else {
            callback(Response(request: response?.request, data: response?.data, response: response?.response, result: .failure(DocumentClientError(withKind: .serviceUnavailable))))
        }
    }
    
    fileprivate func cachedResources<T:CodableResource>(at resourceLocation: ResourceLocation, withResponse response: Response<Resources<T>>? = nil, callback: @escaping (Response<Resources<T>>) -> ()) {
        
        if let resources: Resources<T> = ResourceCache.get(resourcesAt: resourceLocation) {
            callback(Response(request: response?.request, data: response?.data, response: response?.response, result: .success(resources)))
        } else {
            callback(Response(request: response?.request, data: response?.data, response: response?.response, result: .failure(DocumentClientError(withKind: .serviceUnavailable))))
        }
    }

    
    // MARK: - Request
    
    fileprivate func sendRequest<T:CodableResource> (_ request: URLRequest, currentResource: T? = nil, callback: @escaping (Response<T>) -> ()) {
        
        logRequest(request, for: T.self)
        
        session.dataTask(with: request) { (data, response, error) in
            
            let httpResponse = response as? HTTPURLResponse
            
            if let error = error {
                
                callback(Response(request: request, data: data, response: httpResponse, result: .failure(DocumentClientError(withData: data, response: httpResponse, error: error))))
            
            } else if let data = data, let httpResponse = httpResponse, let statusCode = HttpStatusCode(rawValue: httpResponse.statusCode) {
                
                do {

                    switch statusCode {
                    //case .created: // cache locally
                    //case .noContent: // DELETEing a resource remotely should delete the cached version (if the delete was successful indicated by a response status code of 204 No Content)
                    //case .unauthorized:
                    //case .forbidden: // reauth
                    //case .conflict: // conflict callback
                    //case .notFound: // (indicating the resource has been deleted/no longer exists in the remote database), confirm that resource does not exist locally, and if it does, delete it
                    //case .preconditionFailure: // The operation specified an eTag that is different from the version available at the server, that is, an optimistic concurrency error. Retry the request after reading the latest version of the resource and updating the eTag on the request.
                        
                    case .notModified:
                        
                        callback(Response(request: request, data: data, response: httpResponse, result: .success(currentResource!)))

                    case .ok, .created, .accepted, .noContent:

                        var resource = try self.jsonDecoder.decode(T.self, from: data)
                        
                        resource.setAltLink(withContentPath: httpResponse.msAltContentPathHeader)
                        
                        callback(Response(request: request, data: data, response: httpResponse, result: .success(resource)))
                        
                    default:
                        
                        callback(Response(request: request, data: data, response: httpResponse, result: .failure(DocumentClientError(withData: data, response: httpResponse))))
                    }
                } catch let error {
                    
                    callback(Response(request: request, data: data, response: httpResponse, result: .failure(DocumentClientError(withData: data, response: httpResponse, error: error))))
                }
                
            } else {
                
                callback(Response(request: request, data: data, response: httpResponse, result: .failure(DocumentClientError(withKind: .unknownError))))
            }
        }.resume()
    }

    
    internal func sendRequest<T: CodableResources> (_ request: URLRequest, callback: @escaping (Response<T>) -> ()) {
        
        logRequest(request, for: T.self)

        session.dataTask(with: request) { (data, response, error) in
            
            let httpResponse = response as? HTTPURLResponse
            
            if let error = error {
                
                callback(Response(request: request, data: data, response: httpResponse, result: .failure(DocumentClientError(withData: data, response: httpResponse, error: error))))
                
            } else if let data = data, let httpResponse = httpResponse, let statusCode = HttpStatusCode(rawValue: httpResponse.statusCode) {
                
                do {
                    
                    switch statusCode {
                    //case .created: // cache locally
                    //case .noContent: // DELETEing a resource remotely should delete the cached version (if the delete was successful indicated by a response status code of 204 No Content)
                    case .ok, .created, .accepted, .noContent, .notModified:
                        
                        var resource = try self.jsonDecoder.decode(T.self, from: data)
                        
                        resource.setAltLinks(withContentPath: httpResponse.msAltContentPathHeader)

                        //log?.debugMessage("\(resource)")
                        
                        callback(Response(request: request, data: data, response: httpResponse, result: .success(resource)))


                        //case .unauthorized:
                        //case .forbidden: // reauth
                        //case .conflict: // conflict callback
                        //case .notFound: // (indicating the resource has been deleted/no longer exists in the remote database), confirm that resource does not exist locally, and if it does, delete it
                        //case .preconditionFailure: // The operation specified an eTag that is different from the version available at the server, that is, an optimistic concurrency error. Retry the request after reading the latest version of the resource and updating the eTag on the request.
                    //case .badRequest, .requestTimeout, .entityTooLarge, .tooManyRequests, .retryWith, .internalServerError, .serviceUnavailable:
                    default:

                        callback(Response(request: request, data: data, response: httpResponse, result: .failure(DocumentClientError(withData: data, response: httpResponse))))
                    }
                } catch let error {
                    
                    callback(Response(request: request, data: data, response: httpResponse, result: .failure(DocumentClientError(withData: data, response: httpResponse, error: error))))
                }
            } else {
                
                callback(Response(request: request, data: data, response: httpResponse, result: .failure(DocumentClientError(withKind: .unknownError))))
            }
        }.resume()
    }
    
    
    // currently only used by delete and execute operations
    fileprivate func sendRequest (_ request: URLRequest, callback: @escaping (Response<Data>) -> ()) {
        
        logRequest(request, for: Data.self)
        
        session.dataTask(with: request) { (data, response, error) in
            
            let httpResponse = response as? HTTPURLResponse
            
            if let error = error {
                
                callback(Response(request: request, data: data, response: httpResponse, result: .failure(DocumentClientError(withData: data, response: httpResponse, error: error))))

            } else if let data = data, let code = httpResponse?.statusCode, let statusCode = HttpStatusCode(rawValue: code) {
                
                //Log.debugMessage(String(data: data, encoding: .utf8) ?? "nil")
                
                switch statusCode {
                //case .created: // cache locally
                //case .noContent: // DELETEing a resource remotely should delete the cached version (if the delete was successful indicated by a response status code of 204 No Content)
                case .ok, .created, .accepted, .noContent, .notModified:
                    callback(Response(request: request, data: data, response: httpResponse, result: .success(data)))
                //case .unauthorized:
                //case .forbidden: // reauth
                //case .conflict: // conflict callback
                //case .notFound: // (indicating the resource has been deleted/no longer exists in the remote database), confirm that resource does not exist locally, and if it does, delete it
                //case .preconditionFailure: // The operation specified an eTag that is different from the version available at the server, that is, an optimistic concurrency error. Retry the request after reading the latest version of the resource and updating the eTag on the request.
                //case .badRequest, .requestTimeout, .entityTooLarge, .tooManyRequests, .retryWith, .internalServerError, .serviceUnavailable:
                default:
                    
                    callback(Response(request: request, data: data, response: httpResponse, result: .failure(DocumentClientError(withData: data, response: httpResponse))))
                }

            } else {
                
                callback(Response(request: request, data: data, response: httpResponse, result: .failure(DocumentClientError(withKind: .unknownError))))
            }
        }.resume()
    }


    fileprivate func dataRequest(forResourceAt resourceLocation: ResourceLocation, withMethod method: HttpMethod, andAdditionalHeaders additionalHeaders: HttpHeaders? = nil, forQuery: Bool = false, callback: @escaping (Response<URLRequest>) -> ()) {

        if let error = additionalHeaders?.validate() {

            Log.error(error.description)

            callback(Response(DocumentClientError(withKind: .resourceRequestError(error))))

            return
        }

        getToken(forResourceAt: resourceLocation, withMethod: method) { r in
        
            if let resourceToken = r.resource {
                
                let url = URL(string: "https://" + self.host + "/" + resourceLocation.path)
                
                var request = URLRequest(url: url!)
                
                request.method = method
                
                request.addValue(resourceToken.date, forHTTPHeaderField: .msDate)
                request.addValue(resourceToken.token, forHTTPHeaderField: .authorization)
                
                if forQuery {
                    
                    request.addValue ("true", forHTTPHeaderField: .msDocumentdbIsQuery)
                    request.addValue("application/query+json", forHTTPHeaderField: .contentType)
                    
                } else if (method == .post || method == .put) && resourceLocation.resourceType != .attachment {
                    // For POST on query operations, it must be application/query+json
                    // For attachments, must be set to the Mime type of the attachment.
                    // For all other tasks, must be application/json.
                    request.addValue("application/json", forHTTPHeaderField: .contentType)
                }
                
                if let additionalHeaders = additionalHeaders {
                    for header in additionalHeaders {
                        request.addValue(header.value, forHTTPHeaderField: header.key)
                    }
                }
                
                callback(Response(request))

            } else if let error = r.error {

                callback(Response(request: r.request, data: r.data, response: r.response, result: .failure(error)))

            } else {
                
                callback(Response(DocumentClientError(withKind: .unknownError)))
            }
        }
    }
    
    
    fileprivate let httpDateFormatter: DateFormatter = DateFormat.getHttpDateFormatter()

    fileprivate func getToken(forResourceAt resourceLocation: ResourceLocation, withMethod method: HttpMethod, callback: @escaping (Response<ResourceToken>) -> ()) {

        guard isConfigured else {
            callback(Response(DocumentClientError(withKind: .configureError))); return
        }

        guard resourceLocation.id?.isValidIdForResource ?? true else {
            callback(Response(DocumentClientError(withKind: .invalidId))); return
        }
        
        
        if let resourceTokenProvider = resourceTokenProvider {
            
            let resourceToken = resourceTokenProvider.getToken(forResourceAt: resourceLocation, andMethod: method)!
            
            callback(Response(resourceToken))
            
        } else if let permissionProvider = permissionProvider {
            
            guard resourceLocation.supportsPermissionToken else {
                callback(Response(DocumentClientError(withKind: .permissionError))); return
            }
            
            permissionProvider.getPermission(forResourceAt: resourceLocation, withPermissionMode: method.write ? .all : .read) { r in
             
                //Log.debugMessage(result.error?.localizedDescription ?? result.permission?.token ?? "nope")
                
                if let token = r.resource?.token?.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics)! {
                    
                    let resourceToken = ResourceToken(date: self.httpDateFormatter.string(from: Date()), token: token)
                    
                    callback(Response(resourceToken))
                
                } else if let error = r.error {
                    
                    callback(Response(request: r.request, data: r.data, response: r.response, result: .failure(error)))
                
                } else {
                    
                    callback(Response(DocumentClientError(withKind: .unknownError)))
                }
            }
        }
    }
    
    fileprivate func logRequest<T>(_ request: URLRequest, for type: T.Type) {
        Log.debug {
            let methodString = request.httpMethod ?? ""
            let urlString = request.url?.absoluteString ?? ""
            //let bodyString = request.httpBody != nil ? String(data: request.httpBody!, encoding: .utf8) ?? "empty" : "empty"
            return "Sending \(methodString) request for \(T.self) to \(urlString)" // "\n\tBody : \(bodyString)"
        }
    }
}

// MARK: - HttpHeaders

fileprivate extension Dictionary where Key == String, Value == String {
    /// HttpHeaders.forMaxItemCount(100) -> ["x-ms-max-item-count": "100"]
    /// HttpHeaders.forMaxItemCount(nil) -> nil
    static func forMaxItemCount(_ value: Int?) -> HttpHeaders? {
        guard let value = value else { return nil }
        return [MSHttpHeader.msMaxItemCount.rawValue: "\(value)"]
    }

    func validate() -> ResourceRequestError? {
        if let maxItemCount = Int(self[.msMaxItemCount].valueOrEmpty), !(1...1000).contains(maxItemCount) {
            return .invalidValue(forHeader: MSHttpHeader.msMaxItemCount.rawValue, message: "must be between 1 and 1000.")
        }

        return nil
    }
}
