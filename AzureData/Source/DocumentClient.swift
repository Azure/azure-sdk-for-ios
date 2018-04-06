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
    
    fileprivate var host: String!
        
    fileprivate var permissionProvider: PermissionProvider?
    
    fileprivate var resourceTokenProvider: ResourceTokenProvider?
    
    fileprivate var configuredWithMasterKey: Bool { return resourceTokenProvider != nil }
    
    fileprivate var reachabilityManager: ReachabilityManager! {
        willSet {
            newValue.listener = networkReachabilityChanged
            newValue.startListening()
        }
    }
    
    func networkReachabilityChanged(status: ReachabilityManager.NetworkReachabilityStatus) {
        print("Network Status Changed: \(status)")
    }
    
    /// The underlying session.
    open let session: URLSession


    public init(configuration: URLSessionConfiguration = URLSessionConfiguration.default/*, delegate: SessionDelegate = SessionDelegate(), serverTrustPolicyManager: ServerTrustPolicyManager? = nil*/) {
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
        resourceTokenProvider = ResourceTokenProvider(withMasterKey: key, withPermissionMode: mode)
        commonConfigure(withHost: name + ".documents.azure.com")
    }
    
    public func configure (forAccountAt url: URL, withMasterKey key: String, withPermissionMode mode: PermissionMode) {
        resourceTokenProvider = ResourceTokenProvider(withMasterKey: key, withPermissionMode: mode)
        commonConfigure(withHost: url.host)
    }

    public func configure (forAccountNamed name: String, withPermissionProvider provider: PermissionProvider) {
        permissionProvider = provider
        commonConfigure(withHost: name + ".documents.azure.com")
    }
    
    public func configure (forAccountAt url: URL, withPermissionProvider provider: PermissionProvider) {
        permissionProvider = provider
        commonConfigure(withHost: url.host)
    }

    fileprivate func commonConfigure(withHost host: String?) {
        guard
            let host = host, !host.isEmpty
        else { fatalError("Host is invalid") }
        self.host = host
        reachabilityManager = ReachabilityManager(host: host)
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
    public func databases (callback: @escaping (Response<Resources<Database>>) -> ()) {
        
        let resourceLocation: ResourceLocation = .database(id: nil)
        
        return self.resources(at: resourceLocation, callback: callback)
    }
    
    // get
    public func get (databaseWithId databaseId: String, callback: @escaping (Response<Database>) -> ()) {
        
        let resourceLocation: ResourceLocation = .database(id: databaseId)
        
        return self.resource(at: resourceLocation, callback: callback)
    }
    
    // delete
    public func delete (databaseWithId databaseId: String, callback: @escaping (Response<Data>) -> ()) {

        let resourceLocation: ResourceLocation = .database(id: databaseId)

        return self.delete(resourceAt: resourceLocation, callback: callback)
    }

    
    
    // MARK: - Collections
    
    // create
    public func create (collectionWithId collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<DocumentCollection>) -> ()) {
        
        let resourceLocation: ResourceLocation = .collection(databaseId: databaseId, id: nil)
        
        return self.create(resourceWithId: collectionId, at: resourceLocation, callback: callback)
    }

    public func create (collectionWithId collectionId: String, inDatabase database: Database, callback: @escaping (Response<DocumentCollection>) -> ()) {
        
        let resourceLocation: ResourceLocation = .child(.collection, in: database, id: nil)

        return self.create(resourceWithId: collectionId, at: resourceLocation, callback: callback)
    }

    // list
    public func get (collectionsIn databaseId: String, callback: @escaping (Response<Resources<DocumentCollection>>) -> ()) {
        
        let resourceLocation: ResourceLocation = .collection(databaseId: databaseId, id: nil)
        
        return self.resources(at: resourceLocation, callback: callback)
    }

    public func get (collectionsIn database: Database, callback: @escaping (Response<Resources<DocumentCollection>>) -> ()) {
        
        let resourceLocation: ResourceLocation = .child(.collection, in: database, id: nil)
        
        return self.resources(at: resourceLocation, callback: callback)
    }

    // get
    public func get (collectionWithId collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<DocumentCollection>) -> ()) {
        
        let resourceLocation: ResourceLocation = .collection(databaseId: databaseId, id: collectionId)
        
        return self.resource(at: resourceLocation, callback: callback)
    }

    public func get (collectionWithId collectionId: String, inDatabase database: Database, callback: @escaping (Response<DocumentCollection>) -> ()) {
        
        let resourceLocation: ResourceLocation = .child(.collection, in: database, id: collectionId)
        
        return self.resource(at: resourceLocation, callback: callback)
    }

    // delete
    public func delete (collectionWithId collectionId: String, fromDatabase databaseId: String, callback: @escaping (Response<Data>) -> ()) {

        let resourceLocation: ResourceLocation = .collection(databaseId: databaseId, id: collectionId)

        return self.delete(resourceAt: resourceLocation, callback: callback)
    }
    
    public func delete (collectionWithId collectionId: String, fromDatabase database: Database, callback: @escaping (Response<Data>) -> ()) {
        
        let resourceLocation: ResourceLocation = .child(.collection, in: database, id: collectionId)
        
        return self.delete(resourceAt: resourceLocation, callback: callback)
    }


    // replace
    // TODO: replace
    
    
    
    
    
    // MARK: - Documents
    
    // create
    public func create<T: Document> (_ document: T, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<T>) -> ()) {
        
        let resourceLocation: ResourceLocation = .document(databaseId: databaseId, collectionId: collectionId, id: nil)
        
        return self.create(document, at: resourceLocation, callback: callback)
    }
    
    public func create<T: Document> (_ document: T, in collection: DocumentCollection, callback: @escaping (Response<T>) -> ()) {
        
        let resourceLocation: ResourceLocation = .child(.document, in: collection, id: nil)
        
        return self.create(document, at: resourceLocation, callback: callback)
    }
    
    // list
    public func get<T: Document> (documentsAs documentType:T.Type, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<Resources<T>>) -> ()) {
        
        let resourceLocation: ResourceLocation = .document(databaseId: databaseId, collectionId: collectionId, id: nil)
        
        return self.resources(at: resourceLocation, callback: callback)
    }
    
    public func get<T: Document> (documentsAs documentType:T.Type, in collection: DocumentCollection, callback: @escaping (Response<Resources<T>>) -> ()) {
        
        let resourceLocation: ResourceLocation = .child(.document, in: collection, id: nil)
        
        return self.resources(at: resourceLocation, callback: callback)
    }
    
    // get
    public func get<T: Document> (documentWithId documentId: String, as documentType:T.Type, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<T>) -> ()) {
        
        let resourceLocation: ResourceLocation = .document(databaseId: databaseId, collectionId: collectionId, id: documentId)
        
        return self.resource(at: resourceLocation, callback: callback)
    }
    
    public func get<T: Document> (documentWithId resourceId: String, as documentType:T.Type, in collection: DocumentCollection, callback: @escaping (Response<T>) -> ()) {
        
        let resourceLocation: ResourceLocation = .child(.document, in: collection, id: resourceId)
        
        return self.resource(at: resourceLocation, callback: callback)
    }
    
    // delete
    public func delete (documentWithId documentId: String, fromCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<Data>) -> ()) {
        
        let resourceLocation: ResourceLocation = .document(databaseId: databaseId, collectionId: collectionId, id: documentId)
        
        return self.delete(resourceAt: resourceLocation, callback: callback)
    }
    
    public func delete (documentWithId documentId: String, fromCollection collection: DocumentCollection, callback: @escaping (Response<Data>) -> ()) {
        
        let resourceLocation: ResourceLocation = .child(.document, in: collection, id: documentId)
        
        return self.delete(resourceAt: resourceLocation, callback: callback)
    }
    
    // replace
    public func replace<T: Document> (_ document: T, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<T>) -> ()) {
        
        let resourceLocation: ResourceLocation = .document(databaseId: databaseId, collectionId: collectionId, id: document.id)
        
        return self.replace(document, at: resourceLocation, callback: callback)
    }
    
    public func replace<T: Document> (_ document: T, in collection: DocumentCollection, callback: @escaping (Response<T>) -> ()) {
        
        let resourceLocation: ResourceLocation = .child(.document, in: collection, id: document.resourceId)
        
        return self.replace(document, at: resourceLocation, callback: callback)
    }
    
    // query
    public func query (documentsIn collectionId: String, inDatabase databaseId: String, with query: Query, callback: @escaping (Response<Resources<Document>>) -> ()) {
        
        let resourceLocation: ResourceLocation = .document(databaseId: databaseId, collectionId: collectionId, id: nil)
     
        return self.query(query, at: resourceLocation, callback: callback)
    }
    
    public func query (documentsIn collection: DocumentCollection, with query: Query, callback: @escaping (Response<Resources<Document>>) -> ()) {
        
        let resourceLocation: ResourceLocation = .child(.document, in: collection, id: nil)
        
        return self.query(query, at: resourceLocation, callback: callback)
    }

    
    public func query (documentsIn collectionId: String, inDatabase databaseId: String, with query: Query, callback: @escaping (Response<Resources<DictionaryDocument>>) -> ()) {
        
        let resourceLocation: ResourceLocation = .document(databaseId: databaseId, collectionId: collectionId, id: nil)
        
        return self.query(query, at: resourceLocation, callback: callback)
    }
    
    public func query (documentsIn collection: DocumentCollection, with query: Query, callback: @escaping (Response<Resources<DictionaryDocument>>) -> ()) {
        
        let resourceLocation: ResourceLocation = .child(.document, in: collection, id: nil)
        
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

        let resourceLocation: ResourceLocation = .child(.attachment, in: document, id: nil)
        
        return self.create(Attachment(withId: attachmentId, contentType: contentType, url: mediaUrl.absoluteString), at: resourceLocation, callback: callback)
    }
    
    public func create(attachmentWithId attachmentId: String, contentType: String, name mediaName: String, with media: Data, onDocument document: Document, callback: @escaping (Response<Attachment>) -> ()) {

        let resourceLocation: ResourceLocation = .child(.attachment, in: document, id: nil)
        
        return self.createOrReplace(media, at: resourceLocation, additionalHeaders: [ HttpHeader.contentType.rawValue: contentType, HttpHeader.slug.rawValue: mediaName ], callback: callback)
    }
    
    // list
    public func get (attachmentsOn documentId: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<Resources<Attachment>>) -> ()) {

        let resourceLocation: ResourceLocation = .attachment(databaseId: databaseId, collectionId: collectionId, documentId: documentId, id: nil)
        
        return self.resources(at: resourceLocation, callback: callback)
    }
    
    public func get (attachmentsOn document: Document, callback: @escaping (Response<Resources<Attachment>>) -> ()) {

        let resourceLocation: ResourceLocation = .child(.attachment, in: document, id: nil)
        
        return self.resources(at: resourceLocation, callback: callback)
    }
    
    // delete
    public func delete (attachmentWithId attachmentId: String, fromDocument documentId: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<Data>) -> ()) {
        
        let resourceLocation: ResourceLocation = .attachment(databaseId: databaseId, collectionId: collectionId, documentId: documentId, id: attachmentId)
        
        return self.delete(resourceAt: resourceLocation, callback: callback)
    }
    
    public func delete (attachmentWithId attachmentId: String, fromDocument document: Document, callback: @escaping (Response<Data>) -> ()) {
        
        let resourceLocation: ResourceLocation = .child(.document, in: document, id: attachmentId)
        
        return self.delete(resourceAt: resourceLocation, callback: callback)
    }
    
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

        let resourceLocation: ResourceLocation = .child(.attachment, in: document, id: attachmentId)
        
        return self.replace(Attachment(withId: attachmentId, contentType: contentType, url: mediaUrl.absoluteString), at: resourceLocation, callback: callback)
    }
    
    public func replace(attachmentWithId attachmentId: String, contentType: String, name mediaName: String, with media: Data, onDocument document: Document, callback: @escaping (Response<Attachment>) -> ()) {

        let resourceLocation: ResourceLocation = .child(.attachment, in: document, id: attachmentId)

        return self.createOrReplace(media, at: resourceLocation, replacing: true, additionalHeaders: [ HttpHeader.contentType.rawValue: contentType, HttpHeader.slug.rawValue: mediaName ], callback: callback)
    }

    
    
    
    
    // MARK: - Stored Procedures
    
    // create
    public func create (storedProcedureWithId storedProcedureId: String, andBody procedure: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<StoredProcedure>) -> ()) {

        let resourceLocation: ResourceLocation = .storedProcedure(databaseId: databaseId, collectionId: collectionId, id: nil)
        
        return self.create(resourceWithId: storedProcedureId, andData: ["body":procedure], at: resourceLocation, callback: callback)
    }
    
    public func create (storedProcedureWithId storedProcedureId: String, andBody procedure: String, in collection: DocumentCollection, callback: @escaping (Response<StoredProcedure>) -> ()) {

        let resourceLocation: ResourceLocation = .child(.storedProcedure, in: collection, id: nil)
        
        return self.create(resourceWithId: storedProcedureId, andData: ["body":procedure], at: resourceLocation, callback: callback)
    }
    
    // list
    public func get (storedProceduresIn collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<Resources<StoredProcedure>>) -> ()) {

        let resourceLocation: ResourceLocation = .storedProcedure(databaseId: databaseId, collectionId: collectionId, id: nil)
        
        return self.resources(at: resourceLocation, callback: callback)
    }
    
    public func get (storedProceduresIn collection: DocumentCollection, callback: @escaping (Response<Resources<StoredProcedure>>) -> ()) {

        let resourceLocation: ResourceLocation = .child(.storedProcedure, in: collection, id: nil)
        
        return self.resources(at: resourceLocation, callback: callback)
    }
    
    // delete
    public func delete (storedProcedureWithId storedProcedureId: String, fromCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<Data>) -> ()) {
        
        let resourceLocation: ResourceLocation = .storedProcedure(databaseId: databaseId, collectionId: collectionId, id: storedProcedureId)
        
        return self.delete(resourceAt: resourceLocation, callback: callback)
    }
    
    public func delete (storedProcedureWithId storedProcedureId: String, fromCollection collection: DocumentCollection, callback: @escaping (Response<Data>) -> ()) {
        
        let resourceLocation: ResourceLocation = .child(.storedProcedure, in: collection, id: storedProcedureId)
        
        return self.delete(resourceAt: resourceLocation, callback: callback)
    }
    
    // replace
    public func replace (storedProcedureWithId storedProcedureId: String, andBody procedure: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<StoredProcedure>) -> ()) {

        let resourceLocation: ResourceLocation = .storedProcedure(databaseId: databaseId, collectionId: collectionId, id: storedProcedureId)
        
        return self.replace(resourceWithId: storedProcedureId, andData: ["body":procedure], at: resourceLocation, callback: callback)
    }
    
    public func replace (storedProcedureWithId storedProcedureId: String, andBody procedure: String, in collection: DocumentCollection, callback: @escaping (Response<StoredProcedure>) -> ()) {

        let resourceLocation: ResourceLocation = .child(.storedProcedure, in: collection, id: storedProcedureId)
        
        return self.replace(resourceWithId: storedProcedureId, andData: ["body":procedure], at: resourceLocation, callback: callback)
    }
    
    // execute
    public func execute (storedProcedureWithId storedProcedureId: String, usingParameters parameters: [String]?, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<Data>) -> ()) {

        let resourceLocation: ResourceLocation = .storedProcedure(databaseId: databaseId, collectionId: collectionId, id: storedProcedureId)
        
        return self.execute(StoredProcedure.self, withBody: parameters, at: resourceLocation, callback: callback)
    }
    
    public func execute (storedProcedureWithId storedProcedureId: String, usingParameters parameters: [String]?, in collection: DocumentCollection, callback: @escaping (Response<Data>) -> ()) {

        let resourceLocation: ResourceLocation = .child(.storedProcedure, in: collection, id: storedProcedureId)
        
        return self.execute(StoredProcedure.self, withBody: parameters, at: resourceLocation, callback: callback)
    }

    
    

    
    // MARK: - User Defined Functions
    
    // create
    public func create (userDefinedFunctionWithId functionId: String, andBody function: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<UserDefinedFunction>) -> ()) {

        let resourceLocation: ResourceLocation = .udf(databaseId: databaseId, collectionId: collectionId, id: nil)
        
        return self.create(resourceWithId: functionId, andData: ["body":function], at: resourceLocation, callback: callback)
    }
    
    public func create (userDefinedFunctionWithId functionId: String, andBody function: String, in collection: DocumentCollection, callback: @escaping (Response<UserDefinedFunction>) -> ()) {

        let resourceLocation: ResourceLocation = .child(.udf, in: collection, id: nil)
        
        return self.create(resourceWithId: functionId, andData: ["body":function], at: resourceLocation, callback: callback)
    }
    
    // list
    public func get (userDefinedFunctionsIn collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<Resources<UserDefinedFunction>>) -> ()) {

        let resourceLocation: ResourceLocation = .udf(databaseId: databaseId, collectionId: collectionId, id: nil)
        
        return self.resources(at: resourceLocation, callback: callback)
    }
    
    public func get (userDefinedFunctionsIn collection: DocumentCollection, callback: @escaping (Response<Resources<UserDefinedFunction>>) -> ()) {

        let resourceLocation: ResourceLocation = .child(.udf, in: collection, id: nil)
        
        return self.resources(at: resourceLocation, callback: callback)
    }
    
    // delete
    public func delete (userDefinedFunctionWithId functionId: String, fromCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<Data>) -> ()) {
        
        let resourceLocation: ResourceLocation = .udf(databaseId: databaseId, collectionId: collectionId, id: functionId)
        
        return self.delete(resourceAt: resourceLocation, callback: callback)
    }
    
    public func delete (userDefinedFunctionWithId functionId: String, fromCollection collection: DocumentCollection, callback: @escaping (Response<Data>) -> ()) {
        
        let resourceLocation: ResourceLocation = .child(.udf, in: collection, id: functionId)
        
        return self.delete(resourceAt: resourceLocation, callback: callback)
    }
    
    // replace
    public func replace (userDefinedFunctionWithId functionId: String, andBody function: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<UserDefinedFunction>) -> ()) {

        let resourceLocation: ResourceLocation = .udf(databaseId: databaseId, collectionId: collectionId, id: functionId)
        
        return self.replace(resourceWithId: functionId, andData: ["body":function], at: resourceLocation, callback: callback)
    }
    
    public func replace (userDefinedFunctionWithId functionId: String, andBody function: String, from collection: DocumentCollection, callback: @escaping (Response<UserDefinedFunction>) -> ()) {

        let resourceLocation: ResourceLocation = .child(.udf, in: collection, id: functionId)
        
        return self.replace(resourceWithId: functionId, andData: ["body":function], at: resourceLocation, callback: callback)
    }
    
    
    
    
    
    // MARK: - Triggers
    
    // create
    public func create (triggerWithId triggerId: String, operation: Trigger.TriggerOperation, type triggerType: Trigger.TriggerType, andBody triggerBody: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<Trigger>) -> ()) {

        let resourceLocation: ResourceLocation = .trigger(databaseId: databaseId, collectionId: collectionId, id: nil)
        
        return self.create(Trigger(withId: triggerId, body: triggerBody, operation: operation, type: triggerType), at: resourceLocation, callback: callback)
    }
    
    public func create (triggerWithId triggerId: String, operation: Trigger.TriggerOperation, type triggerType: Trigger.TriggerType, andBody triggerBody: String, in collection: DocumentCollection, callback: @escaping (Response<Trigger>) -> ()) {

        let resourceLocation: ResourceLocation = .child(.trigger, in: collection, id: nil)
        
        return self.create(Trigger(withId: triggerId, body: triggerBody, operation: operation, type: triggerType), at: resourceLocation, callback: callback)
    }
    
    // list
    public func get (triggersIn collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<Resources<Trigger>>) -> ()) {

        let resourceLocation: ResourceLocation = .trigger(databaseId: databaseId, collectionId: collectionId, id: nil)
        
        return self.resources(at: resourceLocation, callback: callback)
    }
    
    public func get (triggersIn collection: DocumentCollection, callback: @escaping (Response<Resources<Trigger>>) -> ()) {

        let resourceLocation: ResourceLocation = .child(.trigger, in: collection, id: nil)
        
        return self.resources(at: resourceLocation, callback: callback)
    }
    
    // delete
    public func delete (triggerWithId triggerId: String, fromCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<Data>) -> ()) {
        
        let resourceLocation: ResourceLocation = .trigger(databaseId: databaseId, collectionId: collectionId, id: triggerId)
        
        return self.delete(resourceAt: resourceLocation, callback: callback)
    }

    public func delete (triggerWithId triggerId: String, fromCollection collection: DocumentCollection, callback: @escaping (Response<Data>) -> ()) {
        
        let resourceLocation: ResourceLocation = .child(.trigger, in: collection, id: triggerId)
        
        return self.delete(resourceAt: resourceLocation, callback: callback)
    }
    
    // replace
    public func replace (triggerWithId triggerId: String, operation: Trigger.TriggerOperation, type triggerType: Trigger.TriggerType, andBody triggerBody: String, inCollection collectionId: String, inDatabase databaseId: String, callback: @escaping (Response<Trigger>) -> ()) {

        let resourceLocation: ResourceLocation = .trigger(databaseId: databaseId, collectionId: collectionId, id: triggerId)
        
        return self.replace(Trigger(withId: triggerId, body: triggerBody, operation: operation, type: triggerType), at: resourceLocation, callback: callback)
    }
    
    public func replace (triggerWithId triggerId: String, operation: Trigger.TriggerOperation, type triggerType: Trigger.TriggerType, andBody triggerBody: String, in collection: DocumentCollection, callback: @escaping (Response<Trigger>) -> ()) {

        let resourceLocation: ResourceLocation = .child(.trigger, in: collection, id: triggerId)
        
        return self.replace(Trigger(withId: triggerId, body: triggerBody, operation: operation, type: triggerType), at: resourceLocation, callback: callback)
    }

    
    
    
    
    // MARK: - Users
    
    // create
    public func create (userWithId userId: String, inDatabase databaseId: String, callback: @escaping (Response<User>) -> ()) {

        let resourceLocation: ResourceLocation = .user(databaseId: databaseId, id: nil)
        
        return self.create(resourceWithId: userId, at: resourceLocation, callback: callback)
    }

    public func create (userWithId userId: String, inDatabase database: Database, callback: @escaping (Response<User>) -> ()) {
        
        let resourceLocation: ResourceLocation = .child(.user, in: database, id: nil)
        
        return self.create(resourceWithId: userId, at: resourceLocation, callback: callback)
    }

    // list
    public func get (usersIn databaseId: String, callback: @escaping (Response<Resources<User>>) -> ()) {

        let resourceLocation: ResourceLocation = .user(databaseId: databaseId, id: nil)
        
        return self.resources(at: resourceLocation, callback: callback)
    }

    public func get (usersIn database: Database, callback: @escaping (Response<Resources<User>>) -> ()) {
        
        let resourceLocation: ResourceLocation = .child(.user, in: database, id: nil)
        
        return self.resources(at: resourceLocation, callback: callback)
    }

    // get
    public func get (userWithId userId: String, inDatabase databaseId: String, callback: @escaping (Response<User>) -> ()) {

        let resourceLocation: ResourceLocation = .user(databaseId: databaseId, id: userId)
        
        return self.resource(at: resourceLocation, callback: callback)
    }

    public func get (userWithId userId: String, inDatabase database: Database, callback: @escaping (Response<User>) -> ()) {
        
        let resourceLocation: ResourceLocation = .child(.user, in: database, id: userId)
        
        return self.resource(at: resourceLocation, callback: callback)
    }

    // delete
    public func delete (userWithId userId: String, fromDatabase databaseId: String, callback: @escaping (Response<Data>) -> ()) {

        let resourceLocation: ResourceLocation = .user(databaseId: databaseId, id: userId)

        return self.delete(resourceAt: resourceLocation, callback: callback)
    }
    
    public func delete (userWithId userId: String, fromDatabase database: Database, callback: @escaping (Response<Data>) -> ()) {
        
        let resourceLocation: ResourceLocation = .child(.user, in: database, id: userId)
        
        return self.delete(resourceAt: resourceLocation, callback: callback)
    }
    
    // replace
    public func replace (userWithId userId: String, with newUserId: String, inDatabase databaseId: String, callback: @escaping (Response<User>) -> ()) {

        let resourceLocation: ResourceLocation = .user(databaseId: databaseId, id: userId)
        
        return self.replace(resourceWithId: newUserId, at: resourceLocation, callback: callback)
    }

    public func replace (userWithId userId: String, with newUserId: String, inDatabase database: Database, callback: @escaping (Response<User>) -> ()) {
        
        let resourceLocation: ResourceLocation = .child(.user, in: database, id: userId)
        
        return self.replace(resourceWithId: newUserId, at: resourceLocation, callback: callback)
    }

    
    
    // MARK: - Permissions
    
    // create
    public func create (permissionWithId permissionId: String, mode permissionMode: PermissionMode, in resource: CodableResource, forUser userId: String, inDatabase databaseId: String, callback: @escaping (Response<Permission>) -> ()) {

        let resourceLocation: ResourceLocation = .permission(databaseId: databaseId, userId: userId, id: nil)
        
        let permission = Permission(withId: permissionId, mode: permissionMode, forResource: resource.selfLink!)
        
        return self.create(permission, at: resourceLocation, callback: callback)
    }
    
    public func create (permissionWithId permissionId: String, mode permissionMode: PermissionMode, in resource: CodableResource, forUser user: User, callback: @escaping (Response<Permission>) -> ()) {

        let resourceLocation: ResourceLocation = .child(.permission, in: user, id: nil)

        let permission = Permission(withId: permissionId, mode: permissionMode, forResource: resource.selfLink!)
        
        return self.create(permission, at: resourceLocation, callback: callback)
    }
    
    // list
    public func get (permissionsFor userId: String, inDatabase databaseId: String, callback: @escaping (Response<Resources<Permission>>) -> ()) {

        let resourceLocation: ResourceLocation = .permission(databaseId: databaseId, userId: userId, id: nil)
        
        return self.resources(at: resourceLocation, callback: callback)
    }
    
    public func get (permissionsFor user: User, callback: @escaping (Response<Resources<Permission>>) -> ()) {

        let resourceLocation: ResourceLocation = .child(.permission, in: user, id: nil)
        
        return self.resources(at: resourceLocation, callback: callback)
    }
    
    // get
    public func get (permissionWithId permissionId: String, forUser userId: String, inDatabase databaseId: String, callback: @escaping (Response<Permission>) -> ()) {

        let resourceLocation: ResourceLocation = .permission(databaseId: databaseId, userId: userId, id: permissionId)
        
        return self.resource(at: resourceLocation, callback: callback)
    }
    
    public func get (permissionWithId permissionId: String, forUser user: User, callback: @escaping (Response<Permission>) -> ()) {

        let resourceLocation: ResourceLocation = .child(.permission, in: user, id: permissionId)
        
        return self.resource(at: resourceLocation, callback: callback)
    }
    
    // delete
    public func delete (permissionWithId permissionId: String, fromUser userId: String, inDatabase databaseId: String, callback: @escaping (Response<Data>) -> ()) {

        let resourceLocation: ResourceLocation = .permission(databaseId: databaseId, userId: userId, id: permissionId)

        return self.delete(resourceAt: resourceLocation, callback: callback)
    }
    
    public func delete (permissionWithId permissionId: String, fromUser user: User, callback: @escaping (Response<Data>) -> ()) {
        
        let resourceLocation: ResourceLocation = .child(.permission, in: user, id: permissionId)
        
        return self.delete(resourceAt: resourceLocation, callback: callback)
    }
    
    // replace
    public func replace (permissionWithId permissionId: String, mode permissionMode: PermissionMode, in resource: CodableResource, forUser userId: String, inDatabase databaseId: String, callback: @escaping (Response<Permission>) -> ()) {

        let resourceLocation: ResourceLocation = .permission(databaseId: databaseId, userId: userId, id: permissionId)
        
        let permission = Permission(withId: permissionId, mode: permissionMode, forResource: resource.selfLink!)
        
        return self.replace(permission, at: resourceLocation, callback: callback)
    }
    
    public func replace (permissionWithId permissionId: String, mode permissionMode: PermissionMode, in resource: CodableResource, forUser user: User, callback: @escaping (Response<Permission>) -> ()) {

        let resourceLocation: ResourceLocation = .child(.permission, in: user, id: permissionId)
        
        let permission = Permission(withId: permissionId, mode: permissionMode, forResource: resource.selfLink!)
        
        return self.replace(permission, at: resourceLocation, callback: callback)
    }
    
    
    
    
    
    // MARK: - Offers
    
    // list
    public func offers (callback: @escaping (Response<Resources<Offer>>) -> ()) {

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
    fileprivate func create<T:CodableResource> (_ resource: T, at resourceLocation: ResourceLocation, additionalHeaders: HttpHeaders? = nil, callback: @escaping (Response<T>) -> ()) {
        
        return self.createOrReplace(resource, at: resourceLocation, additionalHeaders: additionalHeaders, callback: callback)
    }

    fileprivate func create<T:CodableResource> (resourceWithId resourceId: String, andData data: [String:String?]? = nil, at resourceLocation: ResourceLocation, additionalHeaders: HttpHeaders? = nil, callback: @escaping (Response<T>) -> ()) {
        
        var dict = data ?? [:]
        
        dict["id"] = resourceId

        return self.createOrReplace(dict, at: resourceLocation, additionalHeaders: additionalHeaders, callback: callback)
    }
    
    // list
    fileprivate func resources<T> (at resourceLocation: ResourceLocation, callback: @escaping (Response<Resources<T>>) -> ()) {
        
        dataRequest(forResourceAt: resourceLocation, withMethod: .get) { r in
    
            if let request = r.resource {
                
                self.sendRequest(request) { (response:Response<Resources<T>>) in
                    
                    callback(response)
                    
                    if let resource = response.resource {
                        ResourceCache.cache(resource)
                    }
                }
            } else if let error = r.error {
                
                callback(Response(request: r.request, data: r.data, response: r.response, result: .failure(error)))
                
            } else {
                
                callback(Response(DocumentClientError(withKind: .unknownError)))
            }
        }
    }
    
    // get
    fileprivate func resource<T:CodableResource>(at resourceLocation: ResourceLocation, callback: @escaping (Response<T>) -> ()) {
        
        dataRequest(forResourceAt: resourceLocation, withMethod: .get) { r in
            
            if let request = r.resource {
            
                self.sendRequest(request) { (response:Response<T>) in
                    
                    callback(response)
                    
                    if let resource = response.resource {
                        ResourceCache.cache(resource)
                    }
                }
            } else if let error = r.error {
                
                callback(Response(request: r.request, data: r.data, response: r.response, result: .failure(error)))
                
            } else {
                
                callback(Response(DocumentClientError(withKind: .unknownError)))
            }
        }
    }
    
    // refresh
    func refresh<T:CodableResource>(_ resource: T, callback: @escaping (Response<T>) -> ()) {
        
        let resourceLocation: ResourceLocation = .resource(resource: resource)
        
        dataRequest(forResourceAt: resourceLocation, withMethod: .get, andAdditionalHeaders: [ HttpHeader.ifNoneMatch.rawValue : resource.etag! ]) { r in
            
            if let request = r.resource {
            
                self.sendRequest(request, currentResource: resource) { (response:Response<T>) in
                    
                    callback(response)
                    
                    if let resource = response.resource {
                        ResourceCache.cache(resource)
                    }
                }
            } else if let error = r.error {
                
                callback(Response(request: r.request, data: r.data, response: r.response, result: .failure(error)))
                
            } else {
                
                callback(Response(DocumentClientError(withKind: .unknownError)))
            }
        }
    }
    
    // delete
    fileprivate func delete(resourceAt resourceLocation: ResourceLocation, callback: @escaping (Response<Data>) -> ()) {
        
        dataRequest(forResourceAt: resourceLocation, withMethod: .delete) { r in
            
            if let request = r.resource {
            
                self.sendRequest(request) { (response:Response<Data>) in
                    
                    callback(response)
                    
                    if response.result.isSuccess {
                        ResourceCache.remove(resourceAt: resourceLocation)
                    }
                }
            } else if let error = r.error {
                
                callback(Response(request: r.request, data: r.data, response: r.response, result: .failure(error)))
                
            } else {
                
                callback(Response(DocumentClientError(withKind: .unknownError)))
            }
        }
    }

    func delete<T:CodableResource>(_ resource: T, callback: @escaping (Response<Data>) -> ()) {
        
        return self.delete(resourceAt: .resource(resource: resource), callback: callback)
    }
    
    // replace
    fileprivate func replace<T:CodableResource> (_ resource: T, at resourceLocation: ResourceLocation, additionalHeaders: HttpHeaders? = nil, callback: @escaping (Response<T>) -> ()) {
        
        return self.createOrReplace(resource, at: resourceLocation, replacing: true, additionalHeaders: additionalHeaders, callback: callback)
    }

    fileprivate func replace<T:CodableResource> (resourceWithId resourceId: String, andData data: [String:String]? = nil, at resourceLocation: ResourceLocation, additionalHeaders: HttpHeaders? = nil, callback: @escaping (Response<T>) -> ()) {
        
        var dict = data ?? [:]
        
        dict["id"] = resourceId

        return self.createOrReplace(dict, at: resourceLocation, replacing: true, additionalHeaders: additionalHeaders, callback: callback)
    }

    // query
    fileprivate func query<T:CodableResource> (_ query: Query, at resourceLocation: ResourceLocation, callback: @escaping (Response<Resources<T>>) -> ()) {
        
        dataRequest(forResourceAt: resourceLocation, withMethod: .post, forQuery: true) { r in
                
            if var request = r.resource {
                
                do {
                    request.httpBody = try self.jsonEncoder.encode(query)
                } catch {
                    callback(Response(error)); return
                }
                
                self.sendRequest(request) { (response:Response<Resources<T>>) in
                    
                    callback(response)
                    
                    if let resource = response.resource {
                        ResourceCache.cache(resource)
                    }
                }
            } else if let error = r.error {
                
                callback(Response(request: r.request, data: r.data, response: r.response, result: .failure(error)))
                
            } else {
                
                callback(Response(DocumentClientError(withKind: .unknownError)))
            }
        }
    }
    
    // execute
    fileprivate func execute<T:CodableResource, R: Encodable>(_ type: T.Type, withBody body: R? = nil, at resourceLocation: ResourceLocation, callback: @escaping (Response<Data>) -> ()) {
        
        dataRequest(forResourceAt: resourceLocation, withMethod: .post, forQuery: true) { r in
            
            if var request = r.resource {
                
                do {
                    request.httpBody = body == nil ? try self.jsonEncoder.encode([String]()) : try self.jsonEncoder.encode(body)
                } catch {
                    callback(Response<Data>(error)); return
                }
                
                return self.sendRequest(request, callback: callback)
                
            } else if let error = r.error {
                
                callback(Response(request: r.request, data: r.data, response: r.response, result: .failure(error)))
                
            } else {
                
                callback(Response(DocumentClientError(withKind: .unknownError)))
            }
        }
    }
    
    // create or replace
    fileprivate func createOrReplace<T:CodableResource, R:Encodable> (_ body: R, at resourceLocation: ResourceLocation, replacing: Bool = false, additionalHeaders: HttpHeaders? = nil, callback: @escaping (Response<T>) -> ()) {
        
        dataRequest(forResourceAt: resourceLocation, withMethod: replacing ? .put : .post, andAdditionalHeaders: additionalHeaders) { r in
            
            if var request = r.resource {
                
                do {
                    request.httpBody = try self.jsonEncoder.encode(body)
                } catch {
                    callback(Response(error)); return
                }
                
                self.sendRequest(request) { (response:Response<T>) in
                    
                    callback(response)
                    
                    if let resource = response.resource {
                        
                        if replacing {
                            ResourceCache.replace(resource, at: resourceLocation)
                        } else {
                            ResourceCache.cache(resource)
                        }
                    }
                }
            } else if let error = r.error {
                
                callback(Response(request: r.request, data: r.data, response: r.response, result: .failure(error)))
                
            } else {
                
                callback(Response(DocumentClientError(withKind: .unknownError)))
            }
        }
    }
    
    fileprivate func createOrReplace<T:CodableResource> (_ body: Data, at resourceLocation: ResourceLocation, replacing: Bool = false, additionalHeaders: HttpHeaders? = nil, callback: @escaping (Response<T>) -> ()) {
        
        dataRequest(forResourceAt: resourceLocation, withMethod: replacing ? .put : .post, andAdditionalHeaders: additionalHeaders) { r in
            
            if var request = r.resource {
                
                request.httpBody = body
                
                self.sendRequest(request) { (response:Response<T>) in
                    
                    callback(response)
                    
                    if let resource = response.resource {
                        
                        if replacing {
                            ResourceCache.replace(resource, at: resourceLocation)
                        } else {
                            ResourceCache.cache(resource)
                        }
                    }
                }
            } else if let error = r.error {
                
                callback(Response(request: r.request, data: r.data, response: r.response, result: .failure(error)))
                
            } else {
                
                callback(Response(DocumentClientError(withKind: .unknownError)))
            }
        }
    }

    
    // MARK: - Request
    
    fileprivate func sendRequest<T:CodableResource> (_ request: URLRequest, currentResource: T? = nil, callback: @escaping (Response<T>) -> ()) {
        
        log?.debugMessage {
            let methodString = request.httpMethod ?? ""
            let urlString = request.url?.absoluteString ?? ""
            let bodyString = request.httpBody != nil ? String(data: request.httpBody!, encoding: .utf8) ?? "empty" : "empty"
            return "***\nSending \(methodString) request for \(T.self) to \(urlString)\n\tBody : \(bodyString)"
        }
        
        session.dataTask(with: request) { (data, response, error) in
            
            let httpResponse = response as? HTTPURLResponse
            
            if let error = error {
                
                let clientError = DocumentClientError(withData: data, response: httpResponse, error: error)
                
                log?.errorMessage(clientError.message)
                
                callback(Response(request: request, data: data, response: httpResponse, result: .failure(clientError)))
            
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
                        
                        log?.debugMessage ("\(currentResource!)")
                        
                        callback(Response(request: request, data: data, response: httpResponse, result: .success(currentResource!)))

                    case .ok, .created, .accepted, .noContent:

                        var resource = try self.jsonDecoder.decode(T.self, from: data)
                        
                        resource.setAltLink(withContentPath: httpResponse.msAltContentPathHeader)
                        
                        log?.debugMessage ("\(resource)")
                        
                        callback(Response(request: request, data: data, response: httpResponse, result: .success(resource)))
                        
                    default:
                        
                        let clientError = DocumentClientError(withData: data, response: httpResponse)
                        
                        log?.errorMessage(clientError.message)
                        
                        callback(Response(request: request, data: data, response: httpResponse, result: .failure(clientError)))
                    }
                } catch let error {
                    
                    let clientError = DocumentClientError(withData: data, response: httpResponse, error: error)
                    
                    log?.errorMessage(clientError.message)
                    
                    callback(Response(request: request, data: data, response: httpResponse, result: .failure(clientError)))
                }
                
            } else {
                
                let unknownError = DocumentClientError(withKind: .unknownError)
                
                log?.errorMessage(unknownError.message)
                
                callback(Response(request: request, data: data, response: httpResponse, result: .failure(unknownError)))
            }
        }.resume()
    }

    
    fileprivate func sendRequest<T> (_ request: URLRequest, callback: @escaping (Response<Resources<T>>) -> ()) {
        
        log?.debugMessage {
            let methodString = request.httpMethod ?? ""
            let urlString = request.url?.absoluteString ?? ""
            let bodyString = request.httpBody != nil ? String(data: request.httpBody!, encoding: .utf8) ?? "empty" : "empty"
            return "***\nSending \(methodString) request for \(T.self) to \(urlString)\n\tBody : \(bodyString)"
        }

        session.dataTask(with: request) { (data, response, error) in
            
            let httpResponse = response as? HTTPURLResponse
            
            if let error = error {
                
                log?.errorMessage(error.localizedDescription)
                
                callback(Response(request: request, data: data, response: httpResponse, result: .failure(error)))
                
            } else if let data = data, let httpResponse = httpResponse, let statusCode = HttpStatusCode(rawValue: httpResponse.statusCode) {
                
                do {
                    
                    switch statusCode {
                    //case .created: // cache locally
                    //case .noContent: // DELETEing a resource remotely should delete the cached version (if the delete was successful indicated by a response status code of 204 No Content)
                    case .ok, .created, .accepted, .noContent, .notModified:
                        
                        var resource = try self.jsonDecoder.decode(Resources<T>.self, from: data)
                        
                        resource.setAltLinks(withContentPath: httpResponse.msAltContentPathHeader)
                        
                        log?.debugMessage("\(resource)")
                        
                        callback(Response(request: request, data: data, response: httpResponse, result: .success(resource)))


                        //case .unauthorized:
                        //case .forbidden: // reauth
                        //case .conflict: // conflict callback
                        //case .notFound: // (indicating the resource has been deleted/no longer exists in the remote database), confirm that resource does not exist locally, and if it does, delete it
                        //case .preconditionFailure: // The operation specified an eTag that is different from the version available at the server, that is, an optimistic concurrency error. Retry the request after reading the latest version of the resource and updating the eTag on the request.
                    //case .badRequest, .requestTimeout, .entityTooLarge, .tooManyRequests, .retryWith, .internalServerError, .serviceUnavailable:
                    default:
                        
                        let clientError = DocumentClientError(withData: data, response: httpResponse)
                        
                        log?.errorMessage(clientError.message)

                        callback(Response(request: request, data: data, response: httpResponse, result: .failure(clientError)))
                    }
                } catch let error {
                    
                    let clientError = DocumentClientError(withData: data, response: httpResponse, error: error)
                    
                    log?.errorMessage(clientError.message)
                    
                    callback(Response(request: request, data: data, response: httpResponse, result: .failure(clientError)))
                }
            } else {
                
                let unknownError = DocumentClientError(withKind: .unknownError)
                
                log?.errorMessage(unknownError.message)
                
                callback(Response(request: request, data: data, response: httpResponse, result: .failure(unknownError)))
            }
        }.resume()
    }
    
    
    // currently only used by delete and execute operations
    fileprivate func sendRequest (_ request: URLRequest, callback: @escaping (Response<Data>) -> ()) {
        
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
                
                callback(Response(request: request, data: data, response: httpResponse, result: .failure(error)))

            } else if let data = data, let code = httpResponse?.statusCode, let statusCode = HttpStatusCode(rawValue: code) {
                
                log?.debugMessage(String(data: data, encoding: .utf8) ?? "nil")
                
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
                    
                    let clientError = DocumentClientError(withData: data, response: httpResponse)
                    
                    log?.errorMessage(clientError.message)
                    
                    callback(Response(request: request, data: data, response: httpResponse, result: .failure(clientError)))
                }

            } else {
                
                let unknownError = DocumentClientError(withKind: .unknownError)
                
                log?.errorMessage(unknownError.message)
                
                callback(Response(request: request, data: data, response: httpResponse, result: .failure(unknownError)))
            }
        }.resume()
    }


    fileprivate func dataRequest(forResourceAt resourceLocation: ResourceLocation, withMethod method: HttpMethod, andAdditionalHeaders additionalHeaders: HttpHeaders? = nil, forQuery: Bool = false, callback: @escaping (Response<URLRequest>) -> ()) {
        
        getToken(forResourceAt: resourceLocation, withMethod: method) { r in
        
            if let resourceToken = r.resource {
                
                let url = URL.init(string: "https://" + self.host + "/" + resourceLocation.path)
                
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
             
                //log?.debugMessage(result.error?.localizedDescription ?? result.permission?.token ?? "nope")
                
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
}
