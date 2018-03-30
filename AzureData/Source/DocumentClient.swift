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
    
    fileprivate var host: String?
        
    fileprivate var permissionProvider: PermissionProvider?
    
    fileprivate var resourceTokenProvider: ResourceTokenProvider?
    
    
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
    
    public var isConfigured: Bool {        
        return host != nil && (resourceTokenProvider != nil || permissionProvider != nil)
    }
    
    public func configure (forAccountNamed name: String, withMasterKey key: String, withPermissionMode mode: PermissionMode) {
        host = name + ".documents.azure.com"
        resourceTokenProvider = ResourceTokenProvider(withMasterKey: key, withPermissionMode: mode)
        ResourceOracle.host = host
        ResourceOracle.restore()
    }
    
    public func configure (forAccountAt url: URL, withMasterKey key: String, withPermissionMode mode: PermissionMode) {
        host = url.host
        resourceTokenProvider = ResourceTokenProvider(withMasterKey: key, withPermissionMode: mode)
        ResourceOracle.host = host
        ResourceOracle.restore()
    }

    public func configure (forAccountNamed name: String, withPermissionProvider permissionProvider: PermissionProvider) {
        host = name + ".documents.azure.com"
        self.permissionProvider = permissionProvider
        ResourceOracle.host = host
        ResourceOracle.restore()
    }
    
    public func configure (forAccountAt url: URL, withPermissionProvider permissionProvider: PermissionProvider) {
        host = url.host
        self.permissionProvider = permissionProvider
        ResourceOracle.host = host
        ResourceOracle.restore()
    }

    
    public func reset () {
        host = nil
        permissionProvider = nil
        resourceTokenProvider = nil
    }
    
    
    
    
    // MARK: - Databases
    
    // create
    public func create (databaseWithId databaseId: String, callback: @escaping (Response<Database>) -> ()) {
        
        let resourceLocation: ResourceLocation = .database(id: nil)
        
        return self.create(resourceWithId: databaseId, at: resourceLocation, callback: callback)
    }
    
    // list
    public func databases (callback: @escaping (ListResponse<Database>) -> ()) {
        
        let resourceLocation: ResourceLocation = .database(id: nil)
        
        return self.resources(at: resourceLocation, callback: callback)
    }
    
    // get
    public func get (databaseWithId databaseId: String, callback: @escaping (Response<Database>) -> ()) {
        
        let resourceLocation: ResourceLocation = .database(id: databaseId)
        
        return self.resource(at: resourceLocation, callback: callback)
    }
    
    // delete
    public func delete (databaseWithId databaseId: String, callback: @escaping (DataResponse) -> ()) {

        let resourceLocation: ResourceLocation = .database(id: databaseId)

        return self.delete(Database.self, at: resourceLocation, callback: callback)
    }

    
    
    // MARK: - Collections
    
    // create
    public func create (collectionWithId collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<DocumentCollection>) -> ()) {
        
        let resourceLocation: ResourceLocation = .collection(databaseId: databaseId, id: nil)
        
        return self.create(resourceWithId: collectionId, at: resourceLocation, callback: callback)
    }
    
    // list
    public func get (collectionsIn databaseId: String, callback: @escaping (ListResponse<DocumentCollection>) -> ()) {
        
        let resourceLocation: ResourceLocation = .collection(databaseId: databaseId, id: nil)
        
        return self.resources(at: resourceLocation, callback: callback)
    }
    
    // get
    public func get (collectionWithId collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<DocumentCollection>) -> ()) {
        
        let resourceLocation: ResourceLocation = .collection(databaseId: databaseId, id: collectionId)
        
        return self.resource(at: resourceLocation, callback: callback)
    }
    
    // delete
//    public func delete (_ collection: DocumentCollection, fromDatabase databaseId: String, callback: @escaping (DataResponse) -> ()) {
//
//        return self.delete(DocumentCollection.self, at: resourceLocation, callback: callback)
//    }
    
    // replace
    // TODO: replace
    
    
    
    
    
    // MARK: - Documents
    
    // create
    public func create<T: Document> (_ document: T, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<T>) -> ()) {
        
        let resourceLocation: ResourceLocation = .document(databaseId: databaseId, collectionId: collectionId, id: nil)
        
        return self.create(document, at: resourceLocation, callback: callback)
    }
    
    public func create<T: Document> (_ document: T, in collection: DocumentCollection, callback: @escaping (Response<T>) -> ()) {
        
        let resourceLocation: ResourceLocation = .child(.document, in: collection, resourceId: nil)
        
        return self.create(document, at: resourceLocation, callback: callback)
    }
    
    // list
    public func get<T: Document> (documentsAs documentType:T.Type, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (ListResponse<T>) -> ()) {
        
        let resourceLocation: ResourceLocation = .document(databaseId: databaseId, collectionId: collectionId, id: nil)
        
        return self.resources(at: resourceLocation, callback: callback)
    }
    
    public func get<T: Document> (documentsAs documentType:T.Type, in collection: DocumentCollection, callback: @escaping (ListResponse<T>) -> ()) {
        
        let resourceLocation: ResourceLocation = .child(.document, in: collection, resourceId: nil)
        
        return self.resources(at: resourceLocation, callback: callback)
    }
    
    // get
    public func get<T: Document> (documentWithId documentId: String, as documentType:T.Type, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<T>) -> ()) {
        
        let resourceLocation: ResourceLocation = .document(databaseId: databaseId, collectionId: collectionId, id: documentId)
        
        return self.resource(at: resourceLocation, callback: callback)
    }
    
    public func get<T: Document> (documentWithId resourceId: String, as documentType:T.Type, in collection: DocumentCollection, callback: @escaping (Response<T>) -> ()) {
        
        let resourceLocation: ResourceLocation = .child(.document, in: collection, resourceId: resourceId)
        
        return self.resource(at: resourceLocation, callback: callback)
    }
    
    // delete
//    public func delete (_ document: Document, fromCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (DataResponse) -> ()) {
//
//        return self.delete(Document.self, at: resourceLocation, callback: callback)
//    }
//
//    public func delete (_ document: Document, from collection: DocumentCollection, callback: @escaping (DataResponse) -> ()) {
//
//        return self.delete(Document.self, at: resourceLocation, callback: callback)
//    }
    
    // replace
    public func replace<T: Document> (_ document: T, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<T>) -> ()) {
        
        let resourceLocation: ResourceLocation = .document(databaseId: databaseId, collectionId: collectionId, id: document.id)
        
        return self.replace(document, at: resourceLocation, callback: callback)
    }
    
    public func replace<T: Document> (_ document: T, in collection: DocumentCollection, callback: @escaping (Response<T>) -> ()) {
        
        let resourceLocation: ResourceLocation = .child(.document, in: collection, resourceId: document.resourceId)
        
        return self.replace(document, at: resourceLocation, callback: callback)
    }
    
    // query
    public func query (documentsIn collectionId: String, inDatabase databaseId: String, with query: Query, callback: @escaping (ListResponse<Document>) -> ()) {
        
        let resourceLocation: ResourceLocation = .document(databaseId: databaseId, collectionId: collectionId, id: nil)
     
        return self.query(query, at: resourceLocation, callback: callback)
    }
    
    public func query (documentsIn collection: DocumentCollection, with query: Query, callback: @escaping (ListResponse<Document>) -> ()) {
        
        let resourceLocation: ResourceLocation = .child(.document, in: collection, resourceId: nil)
        
        return self.query(query, at: resourceLocation, callback: callback)
    }

    
    public func query (documentsIn collectionId: String, inDatabase databaseId: String, with query: Query, callback: @escaping (ListResponse<DictionaryDocument>) -> ()) {
        
        let resourceLocation: ResourceLocation = .document(databaseId: databaseId, collectionId: collectionId, id: nil)
        
        return self.query(query, at: resourceLocation, callback: callback)
    }
    
    public func query (documentsIn collection: DocumentCollection, with query: Query, callback: @escaping (ListResponse<DictionaryDocument>) -> ()) {
        
        let resourceLocation: ResourceLocation = .child(.document, in: collection, resourceId: nil)
        
        return self.query(query, at: resourceLocation, callback: callback)
    }
    
    

    
    // MARK: - Attachments
    
    // create
    public func create(attachmentWithId attachmentId: String, contentType: String, andMediaUrl mediaUrl: URL, onDocument documentId: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<Attachment>) -> ()) {

        let resourceLocation: ResourceLocation = .attachment(databaseId: databaseId, collectionId: collectionId, documentId: documentId, id: nil)
        
        return self.create(Attachment(withId: attachmentId, contentType: contentType, url: mediaUrl.absoluteString), at: resourceLocation, callback: callback)
    }
    
    public func create(attachmentWithId attachmentId: String, contentType: String, name mediaName: String, with media: Data, onDocument documentId: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<Attachment>) -> ()) {

        let resourceLocation: ResourceLocation = .attachment(databaseId: databaseId, collectionId: collectionId, documentId: documentId, id: nil)
        
        return self.createOrReplace(media, at: resourceLocation, additionalHeaders: [ HttpHeader.contentType.rawValue: contentType, HttpHeader.slug.rawValue: mediaName ], callback: callback)
    }
    
    public func create(attachmentWithId attachmentId: String, contentType: String, andMediaUrl mediaUrl: URL, onDocument document: Document, callback: @escaping (Response<Attachment>) -> ()) {

        let resourceLocation: ResourceLocation = .child(.attachment, in: document, resourceId: nil)
        
        return self.create(Attachment(withId: attachmentId, contentType: contentType, url: mediaUrl.absoluteString), at: resourceLocation, callback: callback)
    }
    
    public func create(attachmentWithId attachmentId: String, contentType: String, name mediaName: String, with media: Data, onDocument document: Document, callback: @escaping (Response<Attachment>) -> ()) {

        let resourceLocation: ResourceLocation = .child(.attachment, in: document, resourceId: nil)
        
        return self.createOrReplace(media, at: resourceLocation, additionalHeaders: [ HttpHeader.contentType.rawValue: contentType, HttpHeader.slug.rawValue: mediaName ], callback: callback)
    }
    
    // list
    public func get (attachmentsOn documentId: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (ListResponse<Attachment>) -> ()) {

        let resourceLocation: ResourceLocation = .attachment(databaseId: databaseId, collectionId: collectionId, documentId: documentId, id: nil)
        
        return self.resources(at: resourceLocation, callback: callback)
    }
    
    public func get (attachmentsOn document: Document, callback: @escaping (ListResponse<Attachment>) -> ()) {

        let resourceLocation: ResourceLocation = .child(.attachment, in: document, resourceId: nil)
        
        return self.resources(at: resourceLocation, callback: callback)
    }
    
    // delete
//    public func delete (_ attachment: Attachment, onDocument documentId: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (DataResponse) -> ()) {
//
//        return self.delete(Attachment.self, at: resourceLocation, callback: callback)
//    }
//
//    public func delete (_ attachment: Attachment, onDocument document: Document, callback: @escaping (DataResponse) -> ()) {
//
//        return self.delete(Attachment.self, at: resourceLocation, callback: callback)
//    }
    
    // replace
    public func replace(attachmentWithId attachmentId: String, contentType: String, andMediaUrl mediaUrl: URL, onDocument documentId: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<Attachment>) -> ()) {

        let resourceLocation: ResourceLocation = .attachment(databaseId: databaseId, collectionId: collectionId, documentId: documentId, id: attachmentId)
        
        return self.replace(Attachment(withId: attachmentId, contentType: contentType, url: mediaUrl.absoluteString), at: resourceLocation, callback: callback)
    }
    
    public func replace(attachmentWithId attachmentId: String, contentType: String, name mediaName: String, with media: Data, onDocument documentId: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<Attachment>) -> ()) {

        let resourceLocation: ResourceLocation = .attachment(databaseId: databaseId, collectionId: collectionId, documentId: documentId, id: attachmentId)
        
        return self.createOrReplace(media, at: resourceLocation, replacing: true, additionalHeaders: [ HttpHeader.contentType.rawValue: contentType, HttpHeader.slug.rawValue: mediaName ], callback: callback)
    }
    
    public func replace(attachmentWithId attachmentId: String, contentType: String, andMediaUrl mediaUrl: URL, onDocument document: Document, callback: @escaping (Response<Attachment>) -> ()) {

        let resourceLocation: ResourceLocation = .child(.attachment, in: document, resourceId: attachmentId)
        
        return self.replace(Attachment(withId: attachmentId, contentType: contentType, url: mediaUrl.absoluteString), at: resourceLocation, callback: callback)
    }
    
    public func replace(attachmentWithId attachmentId: String, contentType: String, name mediaName: String, with media: Data, onDocument document: Document, callback: @escaping (Response<Attachment>) -> ()) {

        let resourceLocation: ResourceLocation = .child(.attachment, in: document, resourceId: attachmentId)

        return self.createOrReplace(media, at: resourceLocation, replacing: true, additionalHeaders: [ HttpHeader.contentType.rawValue: contentType, HttpHeader.slug.rawValue: mediaName ], callback: callback)
    }

    
    
    
    
    // MARK: - Stored Procedures
    
    // create
    public func create (storedProcedureWithId storedProcedureId: String, andBody procedure: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<StoredProcedure>) -> ()) {

        let resourceLocation: ResourceLocation = .storedProcedure(databaseId: databaseId, collectionId: collectionId, id: nil)
        
        return self.create(resourceWithId: storedProcedureId, andData: ["body":procedure], at: resourceLocation, callback: callback)
    }
    
    public func create (storedProcedureWithId storedProcedureId: String, andBody procedure: String, in collection: DocumentCollection, callback: @escaping (Response<StoredProcedure>) -> ()) {

        let resourceLocation: ResourceLocation = .child(.storedProcedure, in: collection, resourceId: nil)
        
        return self.create(resourceWithId: storedProcedureId, andData: ["body":procedure], at: resourceLocation, callback: callback)
    }
    
    // list
    public func get (storedProceduresIn collectionId: String, inDatabase databaseId: String, callback: @escaping (ListResponse<StoredProcedure>) -> ()) {

        let resourceLocation: ResourceLocation = .storedProcedure(databaseId: databaseId, collectionId: collectionId, id: nil)
        
        return self.resources(at: resourceLocation, callback: callback)
    }
    
    public func get (storedProceduresIn collection: DocumentCollection, callback: @escaping (ListResponse<StoredProcedure>) -> ()) {

        let resourceLocation: ResourceLocation = .child(.storedProcedure, in: collection, resourceId: nil)
        
        return self.resources(at: resourceLocation, callback: callback)
    }
    
    // delete
//    public func delete (_ storedProcedure: StoredProcedure, fromCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (DataResponse) -> ()) {

//        let resourceLocation: ResourceLocation = .storedProcedure(databaseId: databaseId, collectionId: collectionId, id: storedProcedure.id) 
//        
//        return self.delete(StoredProcedure.self, at: resourceLocation, callback: callback)
//    }
//    
//    public func delete (_ storedProcedure: StoredProcedure, from collection: DocumentCollection, callback: @escaping (DataResponse) -> ()) {

//       let resourceLocation: ResourceLocation = .child(.storedProcedure, in: collection, resourceId: storedProcedure.id)
//        
//        return self.delete(StoredProcedure.self, at: resourceLocation, callback: callback)
//    }
    
    // replace
    public func replace (storedProcedureWithId storedProcedureId: String, andBody procedure: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<StoredProcedure>) -> ()) {

        let resourceLocation: ResourceLocation = .storedProcedure(databaseId: databaseId, collectionId: collectionId, id: storedProcedureId)
        
        return self.replace(resourceWithId: storedProcedureId, andData: ["body":procedure], at: resourceLocation, callback: callback)
    }
    
    public func replace (storedProcedureWithId storedProcedureId: String, andBody procedure: String, in collection: DocumentCollection, callback: @escaping (Response<StoredProcedure>) -> ()) {

        let resourceLocation: ResourceLocation = .child(.storedProcedure, in: collection, resourceId: storedProcedureId)
        
        return self.replace(resourceWithId: storedProcedureId, andData: ["body":procedure], at: resourceLocation, callback: callback)
    }
    
    // execute
    public func execute (storedProcedureWithId storedProcedureId: String, usingParameters parameters: [String]?, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (DataResponse) -> ()) {

        let resourceLocation: ResourceLocation = .storedProcedure(databaseId: databaseId, collectionId: collectionId, id: storedProcedureId)
        
        return self.execute(StoredProcedure.self, withBody: parameters, at: resourceLocation, callback: callback)
    }
    
    public func execute (storedProcedureWithId storedProcedureId: String, usingParameters parameters: [String]?, in collection: DocumentCollection, callback: @escaping (DataResponse) -> ()) {

        let resourceLocation: ResourceLocation = .child(.storedProcedure, in: collection, resourceId: storedProcedureId)
        
        return self.execute(StoredProcedure.self, withBody: parameters, at: resourceLocation, callback: callback)
    }

    
    

    
    // MARK: - User Defined Functions
    
    // create
    public func create (userDefinedFunctionWithId functionId: String, andBody function: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<UserDefinedFunction>) -> ()) {

        let resourceLocation: ResourceLocation = .udf(databaseId: databaseId, collectionId: collectionId, id: nil)
        
        return self.create(resourceWithId: functionId, andData: ["body":function], at: resourceLocation, callback: callback)
    }
    
    public func create (userDefinedFunctionWithId functionId: String, andBody function: String, in collection: DocumentCollection, callback: @escaping (Response<UserDefinedFunction>) -> ()) {

        let resourceLocation: ResourceLocation = .child(.udf, in: collection, resourceId: functionId)
        
        return self.create(resourceWithId: functionId, andData: ["body":function], at: resourceLocation, callback: callback)
    }
    
    // list
    public func get (userDefinedFunctionsIn collectionId: String, inDatabase databaseId: String, callback: @escaping (ListResponse<UserDefinedFunction>) -> ()) {

        let resourceLocation: ResourceLocation = .udf(databaseId: databaseId, collectionId: collectionId, id: nil)
        
        return self.resources(at: resourceLocation, callback: callback)
    }
    
    public func get (userDefinedFunctionsIn collection: DocumentCollection, callback: @escaping (ListResponse<UserDefinedFunction>) -> ()) {

        let resourceLocation: ResourceLocation = .child(.udf, in: collection, resourceId: nil)
        
        return self.resources(at: resourceLocation, callback: callback)
    }
    
    // delete
//    public func delete (_ userDefinedFunction: UserDefinedFunction, fromCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (DataResponse) -> ()) {

//        let resourceLocation: ResourceLocation = .udf(databaseId: databaseId, collectionId: collectionId, id: userDefinedFunction.id)
//
//        return self.delete(UserDefinedFunction.self, at: resourceLocation, callback: callback)
//    }
//
//    public func delete (_ userDefinedFunction: UserDefinedFunction, from collection: DocumentCollection, callback: @escaping (DataResponse) -> ()) {

//        let resourceLocation: ResourceLocation = .child(.udf, in: collection, resourceId: userDefinedFunction.id)
//
//        return self.delete(UserDefinedFunction.self, at: resourceLocation, callback: callback)
//    }
    
    // replace
    public func replace (userDefinedFunctionWithId functionId: String, andBody function: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<UserDefinedFunction>) -> ()) {

        let resourceLocation: ResourceLocation = .udf(databaseId: databaseId, collectionId: collectionId, id: functionId)
        
        return self.replace(resourceWithId: functionId, andData: ["body":function], at: resourceLocation, callback: callback)
    }
    
    public func replace (userDefinedFunctionWithId functionId: String, andBody function: String, from collection: DocumentCollection, callback: @escaping (Response<UserDefinedFunction>) -> ()) {

        let resourceLocation: ResourceLocation = .child(.udf, in: collection, resourceId: functionId)
        
        return self.replace(resourceWithId: functionId, andData: ["body":function], at: resourceLocation, callback: callback)
    }
    
    
    
    
    
    // MARK: - Triggers
    
    // create
    public func create (triggerWithId triggerId: String, operation: Trigger.TriggerOperation, type triggerType: Trigger.TriggerType, andBody triggerBody: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<Trigger>) -> ()) {

        let resourceLocation: ResourceLocation = .trigger(databaseId: databaseId, collectionId: collectionId, id: nil)
        
        return self.create(Trigger(withId: triggerId, body: triggerBody, operation: operation, type: triggerType), at: resourceLocation, callback: callback)
    }
    
    public func create (triggerWithId triggerId: String, operation: Trigger.TriggerOperation, type triggerType: Trigger.TriggerType, andBody triggerBody: String, in collection: DocumentCollection, callback: @escaping (Response<Trigger>) -> ()) {

        let resourceLocation: ResourceLocation = .child(.trigger, in: collection, resourceId: triggerId)
        
        return self.create(Trigger(withId: triggerId, body: triggerBody, operation: operation, type: triggerType), at: resourceLocation, callback: callback)
    }
    
    // list
    public func get (triggersIn collectionId: String, inDatabase databaseId: String, callback: @escaping (ListResponse<Trigger>) -> ()) {

        let resourceLocation: ResourceLocation = .trigger(databaseId: databaseId, collectionId: collectionId, id: nil)
        
        return self.resources(at: resourceLocation, callback: callback)
    }
    
    public func get (triggersIn collection: DocumentCollection, callback: @escaping (ListResponse<Trigger>) -> ()) {

        let resourceLocation: ResourceLocation = .child(.trigger, in: collection, resourceId: nil)
        
        return self.resources(at: resourceLocation, callback: callback)
    }
    
    // delete
//    public func delete (_ trigger: Trigger, fromCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (DataResponse) -> ()) {

//        let resourceLocation: ResourceLocation = .trigger(databaseId: databaseId, collectionId: collectionId, id: trigger.id)
//
//        return self.delete(Trigger.self, at: resourceLocation, callback: callback)
//    }
    
//    public func delete (_ trigger: Trigger, from collection: DocumentCollection, callback: @escaping (DataResponse) -> ()) {

//        let resourceLocation: ResourceLocation = .child(.trigger, in: collection, resourceId: trigger.id)
//
//        return self.delete(Trigger.self, at: resourceLocation, callback: callback)
//    }
    
    // replace
    public func replace (triggerWithId triggerId: String, operation: Trigger.TriggerOperation, type triggerType: Trigger.TriggerType, andBody triggerBody: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<Trigger>) -> ()) {

        let resourceLocation: ResourceLocation = .trigger(databaseId: databaseId, collectionId: collectionId, id: triggerId)
        
        return self.replace(Trigger(withId: triggerId, body: triggerBody, operation: operation, type: triggerType), at: resourceLocation, callback: callback)
    }
    
    public func replace (triggerWithId triggerId: String, operation: Trigger.TriggerOperation, type triggerType: Trigger.TriggerType, andBody triggerBody: String, in collection: DocumentCollection, callback: @escaping (Response<Trigger>) -> ()) {

        let resourceLocation: ResourceLocation = .child(.trigger, in: collection, resourceId: triggerId)
        
        return self.replace(Trigger(withId: triggerId, body: triggerBody, operation: operation, type: triggerType), at: resourceLocation, callback: callback)
    }

    
    
    
    
    // MARK: - Users
    
    // create
    public func create (userWithId userId: String, inDatabase databaseId: String, callback: @escaping (Response<User>) -> ()) {

        let resourceLocation: ResourceLocation = .user(databaseId: databaseId, id: nil)
        
        return self.create(resourceWithId: userId, at: resourceLocation, callback: callback)
    }
    
    // list
    public func get (usersIn databaseId: String, callback: @escaping (ListResponse<User>) -> ()) {

        let resourceLocation: ResourceLocation = .user(databaseId: databaseId, id: nil)
        
        return self.resources(at: resourceLocation, callback: callback)
    }
    
    // get
    public func get (userWithId userId: String, inDatabase databaseId: String, callback: @escaping (Response<User>) -> ()) {

        let resourceLocation: ResourceLocation = .user(databaseId: databaseId, id: userId)
        
        return self.resource(at: resourceLocation, callback: callback)
    }
    
    // delete
//    public func delete (_ user: User, fromDatabase databaseId: String, callback: @escaping (DataResponse) -> ()) {

//        let resourceLocation: ResourceLocation = .user(databaseId: databaseId, id: user.id)
//
//        return self.delete(User.self, at: resourceLocation, callback: callback)
//    }
    
    // replace
    public func replace (userWithId userId: String, with newUserId: String, inDatabase databaseId: String, callback: @escaping (Response<User>) -> ()) {

        let resourceLocation: ResourceLocation = .user(databaseId: databaseId, id: userId)
        
        return self.replace(resourceWithId: userId, at: resourceLocation, callback: callback)
    }
    
    
    
    
    
    // MARK: - Permissions
    
    // create
    public func create (permissionWithId permissionId: String, mode permissionMode: PermissionMode, in resource: CodableResource, forUser userId: String, inDatabase databaseId: String, callback: @escaping (Response<Permission>) -> ()) {

        let resourceLocation: ResourceLocation = .permission(databaseId: databaseId, userId: userId, id: nil)
        
        let permission = Permission(withId: permissionId, mode: permissionMode, forResource: resource.selfLink!)
        
        return self.create(permission, at: resourceLocation, callback: callback)
    }
    
    public func create (permissionWithId permissionId: String, mode permissionMode: PermissionMode, in resource: CodableResource, forUser user: User, callback: @escaping (Response<Permission>) -> ()) {

        let resourceLocation: ResourceLocation = .child(.permission, in: user, resourceId: permissionId)

        let permission = Permission(withId: permissionId, mode: permissionMode, forResource: resource.selfLink!)
        
        return self.create(permission, at: resourceLocation, callback: callback)
    }
    
    // list
    public func get (permissionsFor userId: String, inDatabase databaseId: String, callback: @escaping (ListResponse<Permission>) -> ()) {

        let resourceLocation: ResourceLocation = .permission(databaseId: databaseId, userId: userId, id: nil)
        
        return self.resources(at: resourceLocation, callback: callback)
    }
    
    public func get (permissionsFor user: User, callback: @escaping (ListResponse<Permission>) -> ()) {

        let resourceLocation: ResourceLocation = .child(.permission, in: user, resourceId: nil)
        
        return self.resources(at: resourceLocation, callback: callback)
    }
    
    // get
    public func get (permissionWithId permissionId: String, forUser userId: String, inDatabase databaseId: String, callback: @escaping (Response<Permission>) -> ()) {

        let resourceLocation: ResourceLocation = .permission(databaseId: databaseId, userId: userId, id: permissionId)
        
        return self.resource(at: resourceLocation, callback: callback)
    }
    
    public func get (permissionWithId permissionId: String, forUser user: User, callback: @escaping (Response<Permission>) -> ()) {

        let resourceLocation: ResourceLocation = .child(.permission, in: user, resourceId: permissionId)
        
        return self.resource(at: resourceLocation, callback: callback)
    }
    
    // delete
//    public func delete (_ permission: Permission, forUser userId: String, inDatabase databaseId: String, callback: @escaping (DataResponse) -> ()) {

//        let resourceLocation: ResourceLocation = .permission(databaseId: databaseId, userId: userId, id: permission.id)
//
//        return self.delete(Permission.self, at: resourceLocation, callback: callback)
//    }
//
//    public func delete (_ permission: Permission, forUser user: User, callback: @escaping (DataResponse) -> ()) {

//        let resourceLocation: ResourceLocation = .child(.permission, in: user, resourceId: permission.id)
//
//        return self.delete(Permission.self, at: resourceLocation, callback: callback)
//    }
    
    // replace
    public func replace (permissionWithId permissionId: String, mode permissionMode: PermissionMode, in resource: CodableResource, forUser userId: String, inDatabase databaseId: String, callback: @escaping (Response<Permission>) -> ()) {

        let resourceLocation: ResourceLocation = .permission(databaseId: databaseId, userId: userId, id: permissionId)
        
        let permission = Permission(withId: permissionId, mode: permissionMode, forResource: resource.selfLink!)
        
        return self.create(permission, at: resourceLocation, callback: callback)
    }
    
    public func replace (permissionWithId permissionId: String, mode permissionMode: PermissionMode, in resource: CodableResource, forUser user: User, callback: @escaping (Response<Permission>) -> ()) {

        let resourceLocation: ResourceLocation = .child(.permission, in: user, resourceId: permissionId)
        
        let permission = Permission(withId: permissionId, mode: permissionMode, forResource: resource.selfLink!)
        
        return self.create(permission, at: resourceLocation, callback: callback)
    }
    
    
    
    
    
    // MARK: - Offers
    
    // list
    public func offers (callback: @escaping (ListResponse<Offer>) -> ()) {

        let resourceLocation: ResourceLocation = .offer(id: nil)
        
        return self.resources(at: resourceLocation, callback: callback)
    }
    
    // get
    public func get (offerWithId offerId: String, callback: @escaping (Response<Offer>) -> ()) {

        let resourceLocation: ResourceLocation = .offer(id: offerId)
        
        return self.resource(at: resourceLocation, callback: callback)
    }
    
    // replace
    // TODO: replace
    
    // query
    // TODO: query
    
    
    
    
    
    // MARK: - Resources
    
    // create
    fileprivate func create<T> (_ resource: T, at resourceLocation: ResourceLocation, additionalHeaders: HttpHeaders? = nil, callback: @escaping (Response<T>) -> ()) {
        
        guard resource.hasValidId else { callback(Response(DocumentClientError(withKind: .invalidId))); return }
        
        return self.createOrReplace(resource, at: resourceLocation, additionalHeaders: additionalHeaders, callback: callback)
    }

    fileprivate func create<T> (resourceWithId resourceId: String, andData data: [String:String?]? = nil, at resourceLocation: ResourceLocation, additionalHeaders: HttpHeaders? = nil, callback: @escaping (Response<T>) -> ()) {
        
        guard resourceId.isValidIdForResource else { callback(Response(DocumentClientError(withKind: .invalidId))); return }
        
        var dict = data ?? [:]
        
        dict["id"] = resourceId

        return self.createOrReplace(dict, at: resourceLocation, additionalHeaders: additionalHeaders, callback: callback)
    }
    
    // list
    fileprivate func resources<T> (at resourceLocation: ResourceLocation, callback: @escaping (ListResponse<T>) -> ()) {
        
        guard isConfigured else { callback(ListResponse<T>(DocumentClientError(withKind: .configureError))); return }
        
        let request = dataRequest(T.self, .get, resourceLocation: resourceLocation)
        
        return self.sendRequest(request, callback: callback)
    }
    
    // get
    fileprivate func resource<T>(at resourceLocation: ResourceLocation, callback: @escaping (Response<T>) -> ()) {
        
        guard isConfigured else { callback(Response<T>(DocumentClientError(withKind: .configureError))); return }
        
        let request = dataRequest(T.self, .get, resourceLocation: resourceLocation)
        
        return self.sendRequest(request, callback: callback)
    }
    
    // refresh
    func refresh<T>(_ resource: T, callback: @escaping (Response<T>) -> ()) {
        
        guard isConfigured else { callback(Response(DocumentClientError(withKind: .configureError))); return }
        
        guard !resource.selfLink.isNilOrEmpty && !resource.resourceId.isEmpty
            else { callback(Response(DocumentClientError(withKind: .incompleteIds))); return }
        
        let resourceLocation: ResourceLocation = .resource(resource: resource)
        
        let request = dataRequest(T.self, .get, resourceLocation: resourceLocation, additionalHeaders: [ HttpHeader.ifNoneMatch.rawValue : resource.etag! ])
        
        return self.sendRequest(request, currentResource: resource, callback: callback)
    }
    
    // delete
    fileprivate func delete<T:CodableResource>(_ type: T.Type, at resourceLocation: ResourceLocation, callback: @escaping (DataResponse) -> ()) {

        guard isConfigured else { callback(DataResponse(DocumentClientError(withKind: .configureError))); return }

        guard !resourceLocation.link.isEmpty else { callback(DataResponse(DocumentClientError(withKind: .incompleteIds))); return }

        ResourceOracle.removeLinks(forResourceWithLink: resourceLocation.link)

        let request = dataRequest(T.self, .delete, resourceLocation: resourceLocation)

        return self.sendRequest(request, callback: callback)
    }

    func delete<T:CodableResource>(_ resource: T, callback: @escaping (DataResponse) -> ()) {
        
        guard isConfigured else { callback(DataResponse(DocumentClientError(withKind: .configureError))); return }
        
        guard !resource.selfLink.isNilOrEmpty && !resource.resourceId.isEmpty
            else { callback(DataResponse(DocumentClientError(withKind: .incompleteIds))); return }
        
        ResourceOracle.removeLinks(forResource: resource)
        
        let resourceLocation: ResourceLocation = .resource(resource: resource)
        
        let request = dataRequest(T.self, .delete, resourceLocation: resourceLocation)
        
        return self.sendRequest(request, callback: callback)
    }
    
    // replace
    fileprivate func replace<T> (_ resource: T, at resourceLocation: ResourceLocation, additionalHeaders: HttpHeaders? = nil, callback: @escaping (Response<T>) -> ()) {
        
        guard resource.hasValidId else { callback(Response(DocumentClientError(withKind: .invalidId))); return }
        
        return self.createOrReplace(resource, at: resourceLocation, replacing: true, additionalHeaders: additionalHeaders, callback: callback)
    }

    fileprivate func replace<T> (resourceWithId resourceId: String, andData data: [String:String]? = nil, at resourceLocation: ResourceLocation, additionalHeaders: HttpHeaders? = nil, callback: @escaping (Response<T>) -> ()) {
        
        guard resourceId.isValidIdForResource else { callback(Response(DocumentClientError(withKind: .invalidId))); return }
        
        var dict = data ?? [:]
        
        dict["id"] = resourceId

        return self.createOrReplace(dict, at: resourceLocation, replacing: true, additionalHeaders: additionalHeaders, callback: callback)
    }

    // query
    fileprivate func query<T> (_ query: Query, at resourceLocation: ResourceLocation, callback: @escaping (ListResponse<T>) -> ()) {
        
        guard isConfigured else { callback(ListResponse<T>(DocumentClientError(withKind: .configureError))); return }
        
        log?.debugMessage(query.query)
        
        do {
            
            var request = dataRequest(T.self, .post, resourceLocation: resourceLocation, forQuery: true)
        
            request.httpBody = try jsonEncoder.encode(query)
            
            return self.sendRequest(request, callback: callback)
            
        } catch {
            callback(ListResponse(error)); return
        }
    }
    
    // execute
    fileprivate func execute<T:CodableResource, R: Encodable>(_ type: T.Type, withBody body: R? = nil, at resourceLocation: ResourceLocation, callback: @escaping (DataResponse) -> ()) {
        
        guard isConfigured else { callback(DataResponse(DocumentClientError(withKind: .configureError))); return }
        
        do {
            
            var request = dataRequest(type.self, .post, resourceLocation: resourceLocation)
            
            request.httpBody = body == nil ? try jsonEncoder.encode([String]()) : try jsonEncoder.encode(body)

            return self.sendRequest(request, callback: callback)
            
        } catch {
            callback(DataResponse(error)); return
        }
    }
    
    // create or replace
    fileprivate func createOrReplace<T, R:Encodable> (_ body: R, at resourceLocation: ResourceLocation, replacing: Bool = false, additionalHeaders: HttpHeaders? = nil, callback: @escaping (Response<T>) -> ()) {
        
        guard isConfigured else { callback(Response<T>(DocumentClientError(withKind: .configureError))); return }
        
        do {
            
            var request = dataRequest(T.self, replacing ? .put : .post, resourceLocation: resourceLocation, additionalHeaders: additionalHeaders)
            
            request.httpBody = try jsonEncoder.encode(body)
            
            return self.sendRequest(request, callback: callback)
            
        } catch {
            
            callback(Response(error)); return
        }
    }
    
    fileprivate func createOrReplace<T> (_ body: Data, at resourceLocation: ResourceLocation, replacing: Bool = false, additionalHeaders: HttpHeaders? = nil, callback: @escaping (Response<T>) -> ()) {
        
        guard isConfigured else { callback(Response<T>(DocumentClientError(withKind: .configureError))); return }
        
        var request = dataRequest(T.self, replacing ? .put : .post, resourceLocation: resourceLocation, additionalHeaders: additionalHeaders)
        
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
    
    
    fileprivate func dataRequest<T:CodableResource>(_ type: T.Type = T.self, _ method: HttpMethod, resourceLocation: ResourceLocation, additionalHeaders:HttpHeaders? = nil, forQuery: Bool = false) -> URLRequest {
        
        let resourceToken = resourceTokenProvider!.getToken(type, verb: method, resourceLink: resourceLocation.link)!
        
        let url = URL.init(string: "https://" + host! + "/" + resourceLocation.path)
        
        var request = URLRequest(url: url!)
        
        request.method = method
        
        request.addValue(resourceToken.date, forHTTPHeaderField: .msDate)
        request.addValue(resourceToken.token, forHTTPHeaderField: .authorization)
        
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
