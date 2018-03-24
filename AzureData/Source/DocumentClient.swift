//
//  DocumentClient.swift
//  AzureData iOS
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCore

public class DocumentClient {
    
    open static let `default`: DocumentClient = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = DocumentClient.defaultHttpHeaders
        
        return DocumentClient(configuration: configuration)
    }()
    

    fileprivate var baseUri: ResourceUri?
    
    fileprivate var tokenProvider: TokenProvider!

    
    
    /// The underlying session.
    open let session: URLSession


    public init(configuration: URLSessionConfiguration = URLSessionConfiguration.default/*, delegate: SessionDelegate = SessionDelegate(), serverTrustPolicyManager: ServerTrustPolicyManager? = nil*/)
    {
        //self.delegate = delegate
        self.session = URLSession.init(configuration: configuration)
        //self.session = URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
    }
    
    
    
    
    // MARK: - JSONEncoder & JSONDecoder
    
    public var dateDecoder: ((Decoder) throws -> Date)? = nil
    
    public var dateEncoder: ((Date, Encoder) throws -> Void)? = nil
    
    public lazy var jsonEncoder: JSONEncoder = {
        
        let encoder = JSONEncoder()
        
        if self.dateEncoder == nil {
            self.dateEncoder = DocumentClient.roundTripIso8601Encoder
        }
        
        encoder.dateEncodingStrategy = .custom(self.dateEncoder!)
        
        log?.debugMessage {
            encoder.outputFormatting = .prettyPrinted
            return "encoder.outputFormatting = .prettyPrinted"
        }
        
        return encoder
    }()
    
    public lazy var jsonDecoder: JSONDecoder = {
        
        if self.dateDecoder == nil {
            self.dateDecoder = DocumentClient.roundTripIso8601Decoder
        }
        
        let decoder = JSONDecoder()
        
        decoder.dateDecodingStrategy = .custom(self.dateDecoder!)
        
        return decoder
    }()

    
    
    
    
    // MARK: - Setup
    
    public var isConfigured: Bool { return baseUri != nil }
    
    public func configure (forAccountNamed name: String, withKey key: String, ofType keyType: TokenType) {
        baseUri = ResourceUri(forAccountNamed: name)
        tokenProvider = TokenProvider(key: key, keyType: keyType, tokenVersion: "1.0")
        ResourceOracle.host = baseUri?.host
        ResourceOracle.restore()
    }
    
    public func configure (forAccountAt url: URL, withKey key: String, ofType keyType: TokenType) {
        baseUri = ResourceUri(forAccountAt: url)
        tokenProvider = TokenProvider(key: key, keyType: keyType, tokenVersion: "1.0")
        ResourceOracle.host = baseUri?.host
        ResourceOracle.restore()
    }
    
    public func reset () {
        baseUri = nil
        tokenProvider = nil
    }
    
    
    
    
    // MARK: - Databases
    
    // create
    public func create (databaseWithId databaseId: String, callback: @escaping (Response<Database>) -> ()) {
        
        let resourceUri = baseUri?.database()
        
        return self.create(resourceWithId: databaseId, at: resourceUri, callback: callback)
    }
    
    // list
    public func databases (callback: @escaping (ListResponse<Database>) -> ()) {
        
        let resourceUri = baseUri?.database()
        
        return self.resources(resourceUri: resourceUri, callback: callback)
    }
    
    // get
    public func get (databaseWithId databaseId: String, callback: @escaping (Response<Database>) -> ()) {
        
        let resourceUri = baseUri?.database(databaseId)
        
        return self.resource(resourceUri: resourceUri, callback: callback)
    }
    
    // delete
//    public func delete (_ database: Database, callback: @escaping (DataResponse) -> ()) {
//
//        let resourceUri = baseUri?.database(database.id)
//
//        return self.delete(Database.self, resourceUri: resourceUri, callback: callback)
//    }
    
    
    
    
    
    // MARK: - Collections
    
    // create
    public func create (collectionWithId collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<DocumentCollection>) -> ()) {
        
        let resourceUri = baseUri?.collection(databaseId)
        
        return self.create(resourceWithId: collectionId, at: resourceUri, callback: callback)
    }
    
    // list
    public func get (collectionsIn databaseId: String, callback: @escaping (ListResponse<DocumentCollection>) -> ()) {
        
        let resourceUri = baseUri?.collection(databaseId)
        
        return self.resources(resourceUri: resourceUri, callback: callback)
    }
    
    // get
    public func get (collectionWithId collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<DocumentCollection>) -> ()) {
        
        let resourceUri = baseUri?.collection(databaseId, collectionId: collectionId)
        
        return self.resource(resourceUri: resourceUri, callback: callback)
    }
    
    // delete
//    public func delete (_ collection: DocumentCollection, fromDatabase databaseId: String, callback: @escaping (DataResponse) -> ()) {
//
//        let resourceUri = baseUri?.collection(databaseId, collectionId: collection.id)
//
//        return self.delete(DocumentCollection.self, resourceUri: resourceUri, callback: callback)
//    }
    
    // replace
    // TODO: replace
    
    
    
    
    
    // MARK: - Documents
    
    // create
    public func create<T: Document> (_ document: T, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<T>) -> ()) {
        
        let resourceUri = baseUri?.document(inDatabase: databaseId, inCollection: collectionId)
        
        return self.create(document, at: resourceUri, callback: callback)
    }
    
    public func create<T: Document> (_ document: T, in collection: DocumentCollection, callback: @escaping (Response<T>) -> ()) {
        
        let resourceUri = baseUri?.document(atLink: collection.selfLink!)
        
        return self.create(document, at: resourceUri, callback: callback)
    }
    
    // list
    public func get<T: Document> (documentsAs documentType:T.Type, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (ListResponse<T>) -> ()) {
        
        let resourceUri = baseUri?.document(inDatabase: databaseId, inCollection: collectionId)
        
        return self.resources(resourceUri: resourceUri, callback: callback)
    }
    
    public func get<T: Document> (documentsAs documentType:T.Type, in collection: DocumentCollection, callback: @escaping (ListResponse<T>) -> ()) {
        
        let resourceUri = baseUri?.document(atLink: collection.selfLink!)
        
        return self.resources(resourceUri: resourceUri, callback: callback)
    }
    
    // get
    public func get<T: Document> (documentWithId documentId: String, as documentType:T.Type, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<T>) -> ()) {
        
        let resourceUri = baseUri?.document(inDatabase: databaseId, inCollection: collectionId, withId: documentId)
        
        return self.resource(resourceUri: resourceUri, callback: callback)
    }
    
    public func get<T: Document> (documentWithId resourceId: String, as documentType:T.Type, in collection: DocumentCollection, callback: @escaping (Response<T>) -> ()) {
        
        let resourceUri = baseUri?.document(atLink: collection.selfLink!, withResourceId: resourceId)
        
        return self.resource(resourceUri: resourceUri, callback: callback)
    }
    
    // delete
//    public func delete (_ document: Document, fromCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (DataResponse) -> ()) {
//
//        let resourceUri = baseUri?.document(inDatabase: databaseId, inCollection: collectionId, withId: document.id)
//
//        return self.delete(Document.self, resourceUri: resourceUri, callback: callback)
//    }
//
//    public func delete (_ document: Document, from collection: DocumentCollection, callback: @escaping (DataResponse) -> ()) {
//
//        let resourceUri = baseUri?.document(atLink: collection.selfLink!, withResourceId: document.resourceId)
//
//        return self.delete(Document.self, resourceUri: resourceUri, callback: callback)
//    }
    
    // replace
    public func replace<T: Document> (_ document: T, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<T>) -> ()) {
        
        let resourceUri = baseUri?.document(inDatabase: databaseId, inCollection: collectionId, withId: document.id)
        
        return self.replace(document, at: resourceUri, callback: callback)
    }
    
    public func replace<T: Document> (_ document: T, in collection: DocumentCollection, callback: @escaping (Response<T>) -> ()) {
        
        let resourceUri = baseUri?.document(atLink: collection.selfLink!, withResourceId: document.resourceId)
        
        return self.replace(document, at: resourceUri, callback: callback)
    }
    
    // query
    public func query (documentsIn collectionId: String, inDatabase databaseId: String, with query: Query, callback: @escaping (ListResponse<Document>) -> ()) {
        
        let resourceUri = baseUri?.document(inDatabase: databaseId, inCollection: collectionId)
     
        return self.query(query, at: resourceUri, callback: callback)
    }
    
    public func query (documentsIn collection: DocumentCollection, with query: Query, callback: @escaping (ListResponse<Document>) -> ()) {
        
        let resourceUri = baseUri?.document(atLink: collection.selfLink!)
        
        return self.query(query, at: resourceUri, callback: callback)
    }

    
    public func query (documentsIn collectionId: String, inDatabase databaseId: String, with query: Query, callback: @escaping (ListResponse<DictionaryDocument>) -> ()) {
        
        let resourceUri = baseUri?.document(inDatabase: databaseId, inCollection: collectionId)
        
        return self.query(query, at: resourceUri, callback: callback)
    }
    
    public func query (documentsIn collection: DocumentCollection, with query: Query, callback: @escaping (ListResponse<DictionaryDocument>) -> ()) {
        
        let resourceUri = baseUri?.document(atLink: collection.selfLink!)
        
        return self.query(query, at: resourceUri, callback: callback)
    }
    
    

    
    // MARK: - Attachments
    
    // create
    public func create(attachmentWithId attachmentId: String, contentType: String, andMediaUrl mediaUrl: URL, onDocument documentId: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<Attachment>) -> ()) {
        
        let resourceUri = baseUri?.attachment(databaseId, collectionId: collectionId, documentId: documentId)
        
        return self.create(Attachment(withId: attachmentId, contentType: contentType, url: mediaUrl.absoluteString), at: resourceUri, callback: callback)
    }
    
    public func create(attachmentWithId attachmentId: String, contentType: String, name mediaName: String, with media: Data, onDocument documentId: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<Attachment>) -> ()) {
        
        let resourceUri = baseUri?.attachment(databaseId, collectionId: collectionId, documentId: documentId)
        
        return self.createOrReplace(media, at: resourceUri, additionalHeaders: [ HttpHeader.contentType.rawValue: contentType, HttpHeader.slug.rawValue: mediaName ], callback: callback)
    }
    
    public func create(attachmentWithId attachmentId: String, contentType: String, andMediaUrl mediaUrl: URL, onDocument document: Document, callback: @escaping (Response<Attachment>) -> ()) {
        
        let resourceUri = baseUri?.attachment(atLink: document.selfLink!)
        
        return self.create(Attachment(withId: attachmentId, contentType: contentType, url: mediaUrl.absoluteString), at: resourceUri, callback: callback)
    }
    
    public func create(attachmentWithId attachmentId: String, contentType: String, name mediaName: String, with media: Data, onDocument document: Document, callback: @escaping (Response<Attachment>) -> ()) {
        
        let resourceUri = baseUri?.attachment(atLink: document.selfLink!)
        
        return self.createOrReplace(media, at: resourceUri, additionalHeaders: [ HttpHeader.contentType.rawValue: contentType, HttpHeader.slug.rawValue: mediaName ], callback: callback)
    }
    
    // list
    public func get (attachmentsOn documentId: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (ListResponse<Attachment>) -> ()) {
        
        let resourceUri = baseUri?.attachment(databaseId, collectionId: collectionId, documentId: documentId)
        
        return self.resources(resourceUri: resourceUri, callback: callback)
    }
    
    public func get (attachmentsOn document: Document, callback: @escaping (ListResponse<Attachment>) -> ()) {
        
        let resourceUri = baseUri?.attachment(atLink: document.selfLink!)
        
        return self.resources(resourceUri: resourceUri, callback: callback)
    }
    
    // delete
//    public func delete (_ attachment: Attachment, onDocument documentId: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (DataResponse) -> ()) {
//
//        let resourceUri = baseUri?.attachment(databaseId, collectionId: collectionId, documentId: documentId, attachmentId: attachment.id)
//
//        return self.delete(Attachment.self, resourceUri: resourceUri, callback: callback)
//    }
//
//    public func delete (_ attachment: Attachment, onDocument document: Document, callback: @escaping (DataResponse) -> ()) {
//
//        let resourceUri = baseUri?.attachment(atLink: document.selfLink!, withResourceId: attachment.id)
//
//        return self.delete(Attachment.self, resourceUri: resourceUri, callback: callback)
//    }
    
    // replace
    public func replace(attachmentWithId attachmentId: String, contentType: String, andMediaUrl mediaUrl: URL, onDocument documentId: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<Attachment>) -> ()) {
        
        let resourceUri = baseUri?.attachment(databaseId, collectionId: collectionId, documentId: documentId, attachmentId: attachmentId)
        
        return self.replace(Attachment(withId: attachmentId, contentType: contentType, url: mediaUrl.absoluteString), at: resourceUri, callback: callback)
    }
    
    public func replace(attachmentWithId attachmentId: String, contentType: String, name mediaName: String, with media: Data, onDocument documentId: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<Attachment>) -> ()) {
        
        let resourceUri = baseUri?.attachment(databaseId, collectionId: collectionId, documentId: documentId, attachmentId: attachmentId)
        
        return self.createOrReplace(media, at: resourceUri, replacing: true, additionalHeaders: [ HttpHeader.contentType.rawValue: contentType, HttpHeader.slug.rawValue: mediaName ], callback: callback)
    }
    
    public func replace(attachmentWithId attachmentId: String, contentType: String, andMediaUrl mediaUrl: URL, onDocument document: Document, callback: @escaping (Response<Attachment>) -> ()) {
        
        let resourceUri = baseUri?.attachment(atLink: document.selfLink!, withResourceId: attachmentId)
        
        
        return self.replace(Attachment(withId: attachmentId, contentType: contentType, url: mediaUrl.absoluteString), at: resourceUri, callback: callback)
    }
    
    public func replace(attachmentWithId attachmentId: String, contentType: String, name mediaName: String, with media: Data, onDocument document: Document, callback: @escaping (Response<Attachment>) -> ()) {
        
        let resourceUri = baseUri?.attachment(atLink: document.selfLink!, withResourceId: attachmentId)

        return self.createOrReplace(media, at: resourceUri, replacing: true, additionalHeaders: [ HttpHeader.contentType.rawValue: contentType, HttpHeader.slug.rawValue: mediaName ], callback: callback)
    }

    
    
    
    
    // MARK: - Stored Procedures
    
    // create
    public func create (storedProcedureWithId storedProcedureId: String, andBody procedure: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<StoredProcedure>) -> ()) {
        
        let resourceUri = baseUri?.storedProcedure(databaseId, collectionId: collectionId)
        
        return self.create(resourceWithId: storedProcedureId, andData: ["body":procedure], at: resourceUri, callback: callback)
    }
    
    public func create (storedProcedureWithId storedProcedureId: String, andBody procedure: String, in collection: DocumentCollection, callback: @escaping (Response<StoredProcedure>) -> ()) {
        
        let resourceUri = baseUri?.storedProcedure(atLink: collection.selfLink!)
        
        return self.create(resourceWithId: storedProcedureId, andData: ["body":procedure], at: resourceUri, callback: callback)
    }
    
    // list
    public func get (storedProceduresIn collectionId: String, inDatabase databaseId: String, callback: @escaping (ListResponse<StoredProcedure>) -> ()) {
        
        let resourceUri = baseUri?.storedProcedure(databaseId, collectionId: collectionId)
        
        return self.resources(resourceUri: resourceUri, callback: callback)
    }
    
    public func get (storedProceduresIn collection: DocumentCollection, callback: @escaping (ListResponse<StoredProcedure>) -> ()) {
        
        let resourceUri = baseUri?.storedProcedure(atLink: collection.selfLink!)
        
        return self.resources(resourceUri: resourceUri, callback: callback)
    }
    
    // delete
//    public func delete (_ storedProcedure: StoredProcedure, fromCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (DataResponse) -> ()) {
//        
//        let resourceUri = baseUri?.storedProcedure(databaseId, collectionId: collectionId, storedProcedureId: storedProcedure.id)
//        
//        return self.delete(StoredProcedure.self, resourceUri: resourceUri, callback: callback)
//    }
//    
//    public func delete (_ storedProcedure: StoredProcedure, from collection: DocumentCollection, callback: @escaping (DataResponse) -> ()) {
//        
//        let resourceUri = baseUri?.storedProcedure(atLink: collection.selfLink!, withResourceId: storedProcedure.id)
//        
//        return self.delete(StoredProcedure.self, resourceUri: resourceUri, callback: callback)
//    }
    
    // replace
    public func replace (storedProcedureWithId storedProcedureId: String, andBody procedure: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<StoredProcedure>) -> ()) {
        
        let resourceUri = baseUri?.storedProcedure(databaseId, collectionId: collectionId, storedProcedureId: storedProcedureId)
        
        return self.replace(resourceWithId: storedProcedureId, andData: ["body":procedure], at: resourceUri, callback: callback)
    }
    
    public func replace (storedProcedureWithId storedProcedureId: String, andBody procedure: String, in collection: DocumentCollection, callback: @escaping (Response<StoredProcedure>) -> ()) {
        
        let resourceUri = baseUri?.storedProcedure(atLink: collection.selfLink!, withResourceId: storedProcedureId)
        
        return self.replace(resourceWithId: storedProcedureId, andData: ["body":procedure], at: resourceUri, callback: callback)
    }
    
    // execute
    public func execute (storedProcedureWithId storedProcedureId: String, usingParameters parameters: [String]?, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (DataResponse) -> ()) {
        
        let resourceUri = baseUri?.storedProcedure(databaseId, collectionId: collectionId, storedProcedureId: storedProcedureId)
        
        return self.execute(StoredProcedure.self, withBody: parameters, resourceUri: resourceUri, callback: callback)
    }
    
    public func execute (storedProcedureWithId storedProcedureId: String, usingParameters parameters: [String]?, in collection: DocumentCollection, callback: @escaping (DataResponse) -> ()) {
        
        let resourceUri = baseUri?.storedProcedure(atLink: collection.selfLink!, withResourceId: storedProcedureId)
        
        return self.execute(StoredProcedure.self, withBody: parameters, resourceUri: resourceUri, callback: callback)
    }

    
    

    
    // MARK: - User Defined Functions
    
    // create
    public func create (userDefinedFunctionWithId functionId: String, andBody function: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<UserDefinedFunction>) -> ()) {
        
        let resourceUri = baseUri?.udf(databaseId, collectionId: collectionId)
        
        return self.create(resourceWithId: functionId, andData: ["body":function], at: resourceUri, callback: callback)
    }
    
    public func create (userDefinedFunctionWithId functionId: String, andBody function: String, in collection: DocumentCollection, callback: @escaping (Response<UserDefinedFunction>) -> ()) {
        
        let resourceUri = baseUri?.udf(atLink: collection.selfLink!, withResourceId: functionId)
        
        return self.create(resourceWithId: functionId, andData: ["body":function], at: resourceUri, callback: callback)
    }
    
    // list
    public func get (userDefinedFunctionsIn collectionId: String, inDatabase databaseId: String, callback: @escaping (ListResponse<UserDefinedFunction>) -> ()) {
        
        let resourceUri = baseUri?.udf(databaseId, collectionId: collectionId)
        
        return self.resources(resourceUri: resourceUri, callback: callback)
    }
    
    public func get (userDefinedFunctionsIn collection: DocumentCollection, callback: @escaping (ListResponse<UserDefinedFunction>) -> ()) {
        
        let resourceUri = baseUri?.udf(atLink: collection.selfLink!)
        
        return self.resources(resourceUri: resourceUri, callback: callback)
    }
    
    // delete
//    public func delete (_ userDefinedFunction: UserDefinedFunction, fromCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (DataResponse) -> ()) {
//
//        let resourceUri = baseUri?.udf(databaseId, collectionId: collectionId, udfId: userDefinedFunction.id)
//
//        return self.delete(UserDefinedFunction.self, resourceUri: resourceUri, callback: callback)
//    }
//
//    public func delete (_ userDefinedFunction: UserDefinedFunction, from collection: DocumentCollection, callback: @escaping (DataResponse) -> ()) {
//
//        let resourceUri = baseUri?.udf(atLink: collection.selfLink!, withResourceId: userDefinedFunction.id)
//
//        return self.delete(UserDefinedFunction.self, resourceUri: resourceUri, callback: callback)
//    }
    
    // replace
    public func replace (userDefinedFunctionWithId functionId: String, andBody function: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<UserDefinedFunction>) -> ()) {
        
        let resourceUri = baseUri?.udf(databaseId, collectionId: collectionId, udfId: functionId)
        
        return self.replace(resourceWithId: functionId, andData: ["body":function], at: resourceUri, callback: callback)
    }
    
    public func replace (userDefinedFunctionWithId functionId: String, andBody function: String, from collection: DocumentCollection, callback: @escaping (Response<UserDefinedFunction>) -> ()) {
        
        let resourceUri = baseUri?.udf(atLink: collection.selfLink!, withResourceId: functionId)
        
        return self.replace(resourceWithId: functionId, andData: ["body":function], at: resourceUri, callback: callback)
    }
    
    
    
    
    
    // MARK: - Triggers
    
    // create
    public func create (triggerWithId triggerId: String, operation: Trigger.TriggerOperation, type triggerType: Trigger.TriggerType, andBody triggerBody: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<Trigger>) -> ()) {
        
        let resourceUri = baseUri?.trigger(databaseId, collectionId: collectionId)
        
        return self.create(Trigger(withId: triggerId, body: triggerBody, operation: operation, type: triggerType), at: resourceUri, callback: callback)
    }
    
    public func create (triggerWithId triggerId: String, operation: Trigger.TriggerOperation, type triggerType: Trigger.TriggerType, andBody triggerBody: String, in collection: DocumentCollection, callback: @escaping (Response<Trigger>) -> ()) {
        
        let resourceUri = baseUri?.trigger(atLink: collection.selfLink!, withResourceId: triggerId)
        
        return self.create(Trigger(withId: triggerId, body: triggerBody, operation: operation, type: triggerType), at: resourceUri, callback: callback)
    }
    
    // list
    public func get (triggersIn collectionId: String, inDatabase databaseId: String, callback: @escaping (ListResponse<Trigger>) -> ()) {
        
        let resourceUri = baseUri?.trigger(databaseId, collectionId: collectionId)
        
        return self.resources(resourceUri: resourceUri, callback: callback)
    }
    
    public func get (triggersIn collection: DocumentCollection, callback: @escaping (ListResponse<Trigger>) -> ()) {
        
        let resourceUri = baseUri?.trigger(atLink: collection.selfLink!)
        
        return self.resources(resourceUri: resourceUri, callback: callback)
    }
    
    // delete
//    public func delete (_ trigger: Trigger, fromCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (DataResponse) -> ()) {
//
//        let resourceUri = baseUri?.trigger(databaseId, collectionId: collectionId, triggerId: trigger.id)
//
//        return self.delete(Trigger.self, resourceUri: resourceUri, callback: callback)
//    }
    
//    public func delete (_ trigger: Trigger, from collection: DocumentCollection, callback: @escaping (DataResponse) -> ()) {
//
//        let resourceUri = baseUri?.trigger(atLink: collection.selfLink!, withResourceId: trigger.id)
//
//        return self.delete(Trigger.self, resourceUri: resourceUri, callback: callback)
//    }
    
    // replace
    public func replace (triggerWithId triggerId: String, operation: Trigger.TriggerOperation, type triggerType: Trigger.TriggerType, andBody triggerBody: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<Trigger>) -> ()) {
        
        let resourceUri = baseUri?.trigger(databaseId, collectionId: collectionId, triggerId: triggerId)
        
        return self.replace(Trigger(withId: triggerId, body: triggerBody, operation: operation, type: triggerType), at: resourceUri, callback: callback)
    }
    
    public func replace (triggerWithId triggerId: String, operation: Trigger.TriggerOperation, type triggerType: Trigger.TriggerType, andBody triggerBody: String, in collection: DocumentCollection, callback: @escaping (Response<Trigger>) -> ()) {
        
        let resourceUri = baseUri?.trigger(atLink: collection.selfLink!, withResourceId: triggerId)
        
        return self.replace(Trigger(withId: triggerId, body: triggerBody, operation: operation, type: triggerType), at: resourceUri, callback: callback)
    }

    
    
    
    
    // MARK: - Users
    
    // create
    public func create (userWithId userId: String, inDatabase databaseId: String, callback: @escaping (Response<User>) -> ()) {
        
        let resourceUri = baseUri?.user(databaseId)
        
        return self.create(resourceWithId: userId, at: resourceUri, callback: callback)
    }
    
    // list
    public func get (usersIn databaseId: String, callback: @escaping (ListResponse<User>) -> ()) {
        
        let resourceUri = baseUri?.user(databaseId)
        
        return self.resources(resourceUri: resourceUri, callback: callback)
    }
    
    // get
    public func get (userWithId userId: String, inDatabase databaseId: String, callback: @escaping (Response<User>) -> ()) {
        
        let resourceUri = baseUri?.user(databaseId, userId: userId)
        
        return self.resource(resourceUri: resourceUri, callback: callback)
    }
    
    // delete
//    public func delete (_ user: User, fromDatabase databaseId: String, callback: @escaping (DataResponse) -> ()) {
//
//        let resourceUri = baseUri?.user(databaseId, userId: user.id)
//
//        return self.delete(User.self, resourceUri: resourceUri, callback: callback)
//    }
    
    // replace
    public func replace (userWithId userId: String, with newUserId: String, inDatabase databaseId: String, callback: @escaping (Response<User>) -> ()) {
        
        let resourceUri = baseUri?.user(databaseId, userId: userId)
        
        return self.replace(resourceWithId: userId, at: resourceUri, callback: callback)
    }
    
    
    
    
    
    // MARK: - Permissions
    
    // create
    public func create (permissionWithId permissionId: String, mode permissionMode: PermissionMode, in resource: CodableResource, forUser userId: String, inDatabase databaseId: String, callback: @escaping (Response<Permission>) -> ()) {
        
        let resourceUri = baseUri?.permission(databaseId, userId: userId)
        
        let permission = Permission(withId: permissionId, mode: permissionMode, forResource: resource.selfLink!)
        
        return self.create(permission, at: resourceUri, callback: callback)
    }
    
    public func create (permissionWithId permissionId: String, mode permissionMode: PermissionMode, in resource: CodableResource, forUser user: User, callback: @escaping (Response<Permission>) -> ()) {
        
        let resourceUri = baseUri?.permission(atLink: user.selfLink!, withResourceId: permissionId)

        let permission = Permission(withId: permissionId, mode: permissionMode, forResource: resource.selfLink!)
        
        return self.create(permission, at: resourceUri, callback: callback)
    }
    
    // list
    public func get (permissionsFor userId: String, inDatabase databaseId: String, callback: @escaping (ListResponse<Permission>) -> ()) {
        
        let resourceUri = baseUri?.permission(databaseId, userId: userId)
        
        return self.resources(resourceUri: resourceUri, callback: callback)
    }
    
    public func get (permissionsFor user: User, callback: @escaping (ListResponse<Permission>) -> ()) {
        
        let resourceUri = baseUri?.permission(atLink: user.selfLink!)
        
        return self.resources(resourceUri: resourceUri, callback: callback)
    }
    
    // get
    public func get (permissionWithId permissionId: String, forUser userId: String, inDatabase databaseId: String, callback: @escaping (Response<Permission>) -> ()) {
        
        let resourceUri = baseUri?.permission(databaseId, userId: userId, permissionId: permissionId)
        
        return self.resource(resourceUri: resourceUri, callback: callback)
    }
    
    public func get (permissionWithId permissionId: String, forUser user: User, callback: @escaping (Response<Permission>) -> ()) {
        
        let resourceUri = baseUri?.permission(atLink: user.selfLink!, withResourceId: permissionId)
        
        return self.resource(resourceUri: resourceUri, callback: callback)
    }
    
    // delete
//    public func delete (_ permission: Permission, forUser userId: String, inDatabase databaseId: String, callback: @escaping (DataResponse) -> ()) {
//
//        let resourceUri = baseUri?.permission(databaseId, userId: userId, permissionId: permission.id)
//
//        return self.delete(Permission.self, resourceUri: resourceUri, callback: callback)
//    }
//
//    public func delete (_ permission: Permission, forUser user: User, callback: @escaping (DataResponse) -> ()) {
//
//        let resourceUri = baseUri?.permission(atLink: user.selfLink!, withResourceId: permission.id)
//
//        return self.delete(Permission.self, resourceUri: resourceUri, callback: callback)
//    }
    
    // replace
    public func replace (permissionWithId permissionId: String, mode permissionMode: PermissionMode, in resource: CodableResource, forUser userId: String, inDatabase databaseId: String, callback: @escaping (Response<Permission>) -> ()) {
        
        let resourceUri = baseUri?.permission(databaseId, userId: userId, permissionId: permissionId)
        
        let permission = Permission(withId: permissionId, mode: permissionMode, forResource: resource.selfLink!)
        
        return self.create(permission, at: resourceUri, callback: callback)
    }
    
    public func replace (permissionWithId permissionId: String, mode permissionMode: PermissionMode, in resource: CodableResource, forUser user: User, callback: @escaping (Response<Permission>) -> ()) {
        
        let resourceUri = baseUri?.permission(atLink: user.selfLink!, withResourceId: permissionId)
        
        let permission = Permission(withId: permissionId, mode: permissionMode, forResource: resource.selfLink!)
        
        return self.create(permission, at: resourceUri, callback: callback)
    }
    
    
    
    
    
    // MARK: - Offers
    
    // list
    public func offers (callback: @escaping (ListResponse<Offer>) -> ()) {
        
        let resourceUri = baseUri?.offer()
        
        return self.resources(resourceUri: resourceUri, callback: callback)
    }
    
    // get
    public func get (offerWithId offerId: String, callback: @escaping (Response<Offer>) -> ()) {
        
        let resourceUri = baseUri?.offer(offerId)
        
        return self.resource(resourceUri: resourceUri, callback: callback)
    }
    
    // replace
    // TODO: replace
    
    // query
    // TODO: query
    
    
    
    
    
    // MARK: - Resources
    
    // create
    fileprivate func create<T> (_ resource: T, at resourceUri: (URL, String)?, additionalHeaders: HttpHeaders? = nil, callback: @escaping (Response<T>) -> ()) {
        
        guard resource.hasValidId else { callback(Response(DocumentClientError(withKind: .invalidId))); return }
        
        return self.createOrReplace(resource, at: resourceUri, additionalHeaders: additionalHeaders, callback: callback)
    }

    fileprivate func create<T> (resourceWithId resourceId: String, andData data: [String:String?]? = nil, at resourceUri: (URL, String)?, additionalHeaders: HttpHeaders? = nil, callback: @escaping (Response<T>) -> ()) {
        
        guard resourceId.isValidIdForResource else { callback(Response(DocumentClientError(withKind: .invalidId))); return }
        
        var dict = data ?? [:]
        
        dict["id"] = resourceId

        return self.createOrReplace(dict, at: resourceUri, additionalHeaders: additionalHeaders, callback: callback)
    }
    
    // list
    fileprivate func resources<T> (resourceUri: (URL, String)?, callback: @escaping (ListResponse<T>) -> ()) {
        
        guard isConfigured else { callback(ListResponse<T>(DocumentClientError(withKind: .configureError))); return }
        
        let request = dataRequest(T.self, .get, resourceUri: resourceUri!)
        
        return self.sendRequest(request, callback: callback)
    }
    
    // get
    fileprivate func resource<T>(resourceUri: (URL, String)?, callback: @escaping (Response<T>) -> ()) {
        
        guard isConfigured else { callback(Response<T>(DocumentClientError(withKind: .configureError))); return }
        
        let request = dataRequest(T.self, .get, resourceUri: resourceUri!)
        
        return self.sendRequest(request, callback: callback)
    }
    
    // refresh
    func refresh<T>(_ resource: T, callback: @escaping (Response<T>) -> ()) {
        
        guard isConfigured else { callback(Response(DocumentClientError(withKind: .configureError))); return }
        
        guard !resource.selfLink.isNilOrEmpty && !resource.resourceId.isEmpty
            else { callback(Response(DocumentClientError(withKind: .incompleteIds))); return }
        
        let resourceUri = (URL(string: "\(baseUri!.baseUri)/\(resource.selfLink!)")!, resource.resourceId.lowercased())
        
        let request = dataRequest(T.self, .get, resourceUri: resourceUri, additionalHeaders: [ HttpHeader.ifNoneMatch.rawValue : resource.etag! ])
        
        return self.sendRequest(request, currentResource: resource, callback: callback)
    }
    
    // delete
//    fileprivate func delete<T:CodableResource>(_ type: T.Type = T.self, resourceUri: (URL, String)?, callback: @escaping (DataResponse) -> ()) {
//        
//        guard isConfigured else { callback(DataResponse(DocumentClientError(withKind: .configureError))); return }
//        
//        print("delete aaa \(resourceUri!.1)")
//        
//        let request = dataRequest(T.self, .delete, resourceUri: resourceUri!)
//        
//        return self.sendRequest(request, callback: callback)
//    }

    func delete<T:CodableResource>(_ resource: T, callback: @escaping (DataResponse) -> ()) {
        
        guard isConfigured else { callback(DataResponse(DocumentClientError(withKind: .configureError))); return }
        
        guard !resource.selfLink.isNilOrEmpty && !resource.resourceId.isEmpty
            else { callback(DataResponse(DocumentClientError(withKind: .incompleteIds))); return }
        
        ResourceOracle.removeLinks(forResource: resource)
        
        let resourceUri = (URL(string: "\(baseUri!.baseUri)/\(resource.selfLink!)")!, resource.resourceId.lowercased())
        
        let request = dataRequest(T.self, .delete, resourceUri: resourceUri)
        
        return self.sendRequest(request, callback: callback)
    }
    
    // replace
    fileprivate func replace<T> (_ resource: T, at resourceUri: (URL, String)?, additionalHeaders: HttpHeaders? = nil, callback: @escaping (Response<T>) -> ()) {
        
        guard resource.hasValidId else { callback(Response(DocumentClientError(withKind: .invalidId))); return }
        
        return self.createOrReplace(resource, at: resourceUri, replacing: true, additionalHeaders: additionalHeaders, callback: callback)
    }

    fileprivate func replace<T> (resourceWithId resourceId: String, andData data: [String:String]? = nil, at resourceUri: (URL, String)?, additionalHeaders: HttpHeaders? = nil, callback: @escaping (Response<T>) -> ()) {
        
        guard resourceId.isValidIdForResource else { callback(Response(DocumentClientError(withKind: .invalidId))); return }
        
        var dict = data ?? [:]
        
        dict["id"] = resourceId

        return self.createOrReplace(dict, at: resourceUri, replacing: true, additionalHeaders: additionalHeaders, callback: callback)
    }

    // query
    fileprivate func query<T> (_ query: Query, at resourceUri: (URL, String)?, callback: @escaping (ListResponse<T>) -> ()) {
        
        guard isConfigured else { callback(ListResponse<T>(DocumentClientError(withKind: .configureError))); return }
        
        log?.debugMessage(query.query)
        
        do {
            
            var request = dataRequest(T.self, .post, resourceUri: resourceUri!, forQuery: true)
        
            request.httpBody = try jsonEncoder.encode(query)
            
            return self.sendRequest(request, callback: callback)
            
        } catch {
            callback(ListResponse(error)); return
        }
    }
    
    // execute
    fileprivate func execute<T:CodableResource, R: Encodable>(_ type: T.Type, withBody body: R? = nil, resourceUri: (URL, String)?, callback: @escaping (DataResponse) -> ()) {
        
        guard isConfigured else { callback(DataResponse(DocumentClientError(withKind: .configureError))); return }
        
        do {
            
            var request = dataRequest(type.self, .post, resourceUri: resourceUri!)
            
            request.httpBody = body == nil ? try jsonEncoder.encode([String]()) : try jsonEncoder.encode(body)

            return self.sendRequest(request, callback: callback)
            
        } catch {
            callback(DataResponse(error)); return
        }
    }
    
    // create or replace
    fileprivate func createOrReplace<T, R:Encodable> (_ body: R, at resourceUri: (URL, String)?, replacing: Bool = false, additionalHeaders: HttpHeaders? = nil, callback: @escaping (Response<T>) -> ()) {
        
        guard isConfigured else { callback(Response<T>(DocumentClientError(withKind: .configureError))); return }
        
        do {
            
            var request = dataRequest(T.self, replacing ? .put : .post, resourceUri: resourceUri!, additionalHeaders: additionalHeaders)
            
            request.httpBody = try jsonEncoder.encode(body)
            
            return self.sendRequest(request, callback: callback)
            
        } catch {
            
            callback(Response(error)); return
        }
    }
    
    fileprivate func createOrReplace<T> (_ body: Data, at resourceUri: (URL, String)?, replacing: Bool = false, additionalHeaders: HttpHeaders? = nil, callback: @escaping (Response<T>) -> ()) {
        
        guard isConfigured else { callback(Response<T>(DocumentClientError(withKind: .configureError))); return }
        
        var request = dataRequest(T.self, replacing ? .put : .post, resourceUri: resourceUri!, additionalHeaders: additionalHeaders)
        
        request.httpBody = body
        
        return self.sendRequest(request, callback: callback)
    }


    

    
    // MARK: - Request
    
    fileprivate func sendRequest<T> (_ request: URLRequest, currentResource: T? = nil, callback: @escaping (Response<T>) -> ()) {
        
        log?.debugMessage {
            let methodString = request.httpMethod ?? ""
            let urlString = request.url?.absoluteString ?? ""
            let bodyString = request.httpBody != nil ? String(data: request.httpBody!, encoding: .utf8) ?? "empty" : "empty"
            return "***\nSending \(methodString) request for \(T.self) to \(urlString)\n\tBody : \(bodyString)"
        }
        
        session.dataTask(with: request) { (data, response, error) in
            
            let httpResponse = response as! HTTPURLResponse
            
            if let error = error {
                
                log?.errorMessage(error.localizedDescription)
                
                callback(Response(request: request, data: data, response: httpResponse, result: .failure(error)))
            
            } else if let data = data {
                
                if var current = currentResource, let statusCode = HttpStatusCode(rawValue: httpResponse.statusCode), statusCode == .notModified {
                    
                    let altContentPath = httpResponse.allHeaderFields[MSHttpHeader.msAltContentPath.rawValue] as? String
                    
                    current.setAltLink(withContentPath: altContentPath)
                    
                    ResourceOracle.storeLinks(forResource: current)

                    log?.debugMessage ("\(current)")
                    
                    callback(Response(request: request, data: data, response: httpResponse, result: .success(current)))
                
                } else {
                
                    do {
                        
                        var resource = try self.jsonDecoder.decode(T.self, from: data)
                        
                        let altContentPath = httpResponse.allHeaderFields[MSHttpHeader.msAltContentPath.rawValue] as? String
                        
                        resource.setAltLink(withContentPath: altContentPath)
                        
                        ResourceOracle.storeLinks(forResource: resource)
                        
                        log?.debugMessage ("\(resource)")
                        
                        callback(Response(request: request, data: data, response: httpResponse, result: .success(resource)))
                        
                    } catch let decodeError as DecodingError {
                        
                        log?.errorMessage(decodeError.logMessage)
                        log?.debugMessage(String(data: data, encoding: .utf8) ?? "nil")
                        
                        let docError = DocumentClientError(withData: data, response: httpResponse, error: decodeError)
                        
                        callback(Response(request: request, data: data, response: httpResponse, result: .failure(docError)))
                        
                    } catch let otherError {
                        
                        log?.errorMessage(otherError.localizedDescription)
                        
                        let docError = DocumentClientError(withData: data, response: httpResponse, error: otherError)
                        
                        callback(Response(request: request, data: data, response: httpResponse, result: .failure(docError)))
                    }
                }
            } else {
                
                let unknownError = DocumentClientError(withKind: .unknownError)
                
                log?.errorMessage(unknownError.message!)
                
                callback(Response(request: request, data: data, response: httpResponse, result: .failure(unknownError)))
            }
        }.resume()
    }

    
    fileprivate func sendRequest<T> (_ request: URLRequest, callback: @escaping (ListResponse<T>) -> ()) {
        
        log?.debugMessage {
            let methodString = request.httpMethod ?? ""
            let urlString = request.url?.absoluteString ?? ""
            let bodyString = request.httpBody != nil ? String(data: request.httpBody!, encoding: .utf8) ?? "empty" : "empty"
            return "***\nSending \(methodString) request for \(T.self) to \(urlString)\n\tBody : \(bodyString)"
        }

        session.dataTask(with: request) { (data, response, error) in
            
            let httpResponse = response as! HTTPURLResponse
            
            if let error = error {
                
                log?.errorMessage(error.localizedDescription)
                
                callback(ListResponse(request: request, data: data, response: httpResponse, result: .failure(error)))
                
            } else if let data = data {
                
                do {
                    
                    var resource = try self.jsonDecoder.decode(Resources<T>.self, from: data)
                    
                    let altContentPath = httpResponse.allHeaderFields[MSHttpHeader.msAltContentPath.rawValue] as? String
                    
                    resource.setAltLinks(withContentPath: altContentPath)
                    
                    for item in resource.items {
                        ResourceOracle.storeLinks(forResource: item)
                    }
                    
                    log?.debugMessage("\(resource)")
                    
                    callback(ListResponse(request: request, data: data, response: httpResponse, result: .success(resource)))
                    
                } catch let decodeError as DecodingError {
                    
                    log?.errorMessage(decodeError.logMessage)
                    log?.debugMessage(String(data: data, encoding: .utf8) ?? "nil")

                    
                    let docError = DocumentClientError(withData: data, response: httpResponse, error: decodeError)
                    
                    callback(ListResponse(request: request, data: data, response: httpResponse, result: .failure(docError)))
                
                } catch let otherError {
                    
                    log?.errorMessage(otherError.localizedDescription)
                    
                    let docError = DocumentClientError(withData: data, response: httpResponse, error: otherError)
                    
                    callback(ListResponse(request: request, data: data, response: httpResponse, result: .failure(docError)))
                }
            } else {
                
                let unknownError = DocumentClientError(withKind: .unknownError)
                
                log?.errorMessage(unknownError.message!)
                
                callback(ListResponse(request: request, data: data, response: httpResponse, result: .failure(unknownError)))
            }
        }.resume()
    }
    
    
    fileprivate func sendRequest (_ request: URLRequest, callback: @escaping (DataResponse) -> ()) {
        
        log?.debugMessage {
            let methodString = request.httpMethod ?? ""
            let urlString = request.url?.absoluteString ?? ""
            let bodyString = request.httpBody != nil ? String(data: request.httpBody!, encoding: .utf8) ?? "empty" : "empty"
            return "***\nSending \(methodString) request for Data to \(urlString)\n\tBody : \(bodyString)"
        }

        session.dataTask(with: request) { (data, response, error) in
            
            let httpResponse = response as? HTTPURLResponse
            
            if let error = error {
                
                log?.errorMessage(error.localizedDescription)
                
                callback(DataResponse(request: request, data: data, response: httpResponse, result: .failure(error)))

            } else if let data = data {
                
                log?.debugMessage(String(data: data, encoding: .utf8) ?? "nil")
                
                callback(DataResponse.init(request: request, data: data, response: httpResponse, result: .success(data)))
                
            } else {
                
                let unknownError = DocumentClientError(withKind: .unknownError)
                
                log?.errorMessage(unknownError.message!)
                
                callback(DataResponse(request: request, data: data, response: httpResponse, result: .failure(unknownError)))
            }
        }.resume()
    }
    
    
    fileprivate func dataRequest<T:CodableResource>(_ type: T.Type = T.self, _ method: HttpMethod, resourceUri: (url:URL, link:String),  additionalHeaders:HttpHeaders? = nil, forQuery: Bool = false) -> URLRequest {
        
        let (token, date) = tokenProvider.getToken(type, verb: method, resourceLink: resourceUri.link)
        
        var request = URLRequest(url: resourceUri.url)
        
        request.method = method
        
        request.addValue(date, forHTTPHeaderField: .msDate)
        request.addValue(token, forHTTPHeaderField: .authorization)
        
        if forQuery {
            
            request.addValue ("true", forHTTPHeaderField: .msDocumentdbIsQuery)
            request.addValue("application/query+json", forHTTPHeaderField: .contentType)
            
        } else if (method == .post || method == .put) && type.type != Attachment.type {
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
        
        return request
    }
}
