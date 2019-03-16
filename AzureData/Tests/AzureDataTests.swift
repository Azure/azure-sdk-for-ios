//
//  AzureDataTests.swift
//  AzureDataTests
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureData
@testable import AzureCore

extension ResourceType {
    var name: String {
        switch self {
        case .database:          return "Database"
        case .user:              return "User"
        case .permission:        return "Permission"
        case .collection:        return "DocumentCollection"
        case .storedProcedure:   return "StoredProcedure"
        case .trigger:           return "Trigger"
        case .udf:               return "UserDefinedFunction"
        case .document:          return "Document"
        case .attachment:        return "Attachment"
        case .offer:             return "Offer"
        case .partitionKeyRange: return "PartitionKeyRange"
        }
    }
}

class AzureDataTests: XCTestCase {
    typealias DocumentType = TestDocument

    let timeout: TimeInterval = 30.0

    var ensureDatabase:     Bool = false
    var ensureCollection:   Bool = false
    var ensureDocument:     DocumentType? = nil
    var ensureUser:         Bool = false

    fileprivate(set) var database:  Database?
    fileprivate(set) var collection:DocumentCollection?
    fileprivate(set) var document:  DocumentType?
    fileprivate(set) var user: User?
    
    var resourceName: String?
    var resourceType: ResourceType!
    var partitionKey: DocumentCollection.PartitionKeyDefinition? = [DocumentType.partitionKeyDefinition]

    var rname: String { return resourceName ?? resourceType.name }
    
    var databaseId:     String { return "\(rname)TestsDatabase" }
    var collectionId:   String { return "\(rname)TestsCollection" }
    var documentId:     String { return "\(rname)TestsDocument" }
    var userId:         String { return "\(rname)TestsUser" }
    var resourceId:     String { return "\(rname)Tests\(rname)" }
    var replacedId:     String { return "\(rname)Replaced" }


    let random: Int = 12
    
    let customStringKey = "customStringKey"
    let customStringValue = "customStringValue"
    let customNumberKey = "customNumberKey"
    let customNumberValue = 86
    
    let idWith256Chars = "0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345"
    let idWithWhitespace = "id value with spaces"

    
    lazy var createExpectation   = self.expectation(description: "should create and return \(rname)")
    lazy var listExpectation     = self.expectation(description: "should return a list of \(rname)")
    lazy var getExpectation      = self.expectation(description: "should get and return \(rname)")
    lazy var deleteExpectation   = self.expectation(description: "should delete \(rname)")
    lazy var queryExpectation    = self.expectation(description: "should query \(rname)")
    lazy var replaceExpectation  = self.expectation(description: "should replace \(rname)")
    lazy var replaceExpectation2 = self.expectation(description: "should replace \(rname)")
    lazy var refreshExpectation  = self.expectation(description: "should refresh \(rname)")
    lazy var executeExpectation  = self.expectation(description: "should execute \(rname)")
    
    override func setUp() {
        super.setUp()

        AzureData.configure(withPlistNamed: "AzureTests.plist", withPermissionMode: .all)

        if ensureDatabase {
        
            let initGetDatabaseExpectation = self.expectation(description: "Should get database")
            var initGetResponse: Response<Database>?
            

            AzureData.get(databaseWithId: databaseId) { r in
                initGetResponse = r
                initGetDatabaseExpectation.fulfill()
            }
            
            wait(for: [initGetDatabaseExpectation], timeout: timeout)
            
            database = initGetResponse?.resource
            
            if database == nil {
                
                let initCreateDatabaseExpectation = self.expectation(description: "Should initialize database")
                var initCreateResponse: Response<Database>?

                AzureData.create(databaseWithId: databaseId) { r in
                    initCreateResponse = r
                    initCreateDatabaseExpectation.fulfill()
                }
                
                wait(for: [initCreateDatabaseExpectation], timeout: timeout)
                
                database = initCreateResponse?.resource
            }
            
            XCTAssertNotNil(database)
            
            if ensureCollection, let database = database {
                
                let initGetCollectionExpectation = self.expectation(description: "Should get collection")
                var initGetCollectionResponse: Response<DocumentCollection>?
                
                database.get(collectionWithId: collectionId) { r in
                    initGetCollectionResponse = r
                    initGetCollectionExpectation.fulfill()
                }
                
                wait(for: [initGetCollectionExpectation], timeout: timeout)
                
                collection = initGetCollectionResponse?.resource
                
                if collection == nil {
                    
                    let initCreateCollectionExpectation = self.expectation(description: "Should initialize collection")
                    var initCreateCollectionResponse: Response<DocumentCollection>?

                    database.create(collectionWithId: collectionId, andPartitionKey: partitionKey) { r in
                        initCreateCollectionResponse = r
                        initCreateCollectionExpectation.fulfill()
                    }
                    
                    wait(for: [initCreateCollectionExpectation], timeout: timeout)
                    
                    collection = initCreateCollectionResponse?.resource
                }
                
                XCTAssertNotNil(collection)

                if let ensureDocument = ensureDocument, let collection = collection {
                    
                    let initGetDocumentExpectation = self.expectation(description: "Should get document")
                    var initGetDocumentResponse: Response<DocumentType>?
                    
                    AzureData.get(documentWithId: ensureDocument.id, as: DocumentType.self, inCollection: collection.id, inDatabase: database.id) { r in
                        initGetDocumentResponse = r
                        initGetDocumentExpectation.fulfill()
                    }
                    
                    wait(for: [initGetDocumentExpectation], timeout: timeout)
                    
                    document = initGetDocumentResponse?.resource
                    
                    if document == nil {
                        
                        let initCreateDocumentExpectation = self.expectation(description: "Should initialize document")
                        var initCreateDocumentResponse: Response<DocumentType>?
                        
                        collection.create(ensureDocument) { r in
                            initCreateDocumentResponse = r
                            initCreateDocumentExpectation.fulfill()
                        }
                        
                        wait(for: [initCreateDocumentExpectation], timeout: timeout)
                        
                        document = initCreateDocumentResponse?.resource
                    }
                    
                    XCTAssertNotNil(document)

                }

                if ensureUser {
                    let initGetUserExpectation = self.expectation(description: "Should get user")
                    var initGetUserResponse: Response<User>?

                    AzureData.get(userWithId: userId, in: database) { r in
                        initGetUserResponse = r
                        initGetUserExpectation.fulfill()
                    }

                    wait(for: [initGetUserExpectation], timeout: timeout)

                    user = initGetUserResponse?.resource

                    if user == nil {
                        let initCreateUserExpectation = self.expectation(description: "Should create user")
                        var initCreateUserResponse: Response<User>?

                        AzureData.create(userWithId: userId, in: database) { r in
                            initCreateUserResponse = r
                            initCreateUserExpectation.fulfill()
                        }

                        wait(for: [initCreateUserExpectation], timeout: timeout)

                        user = initCreateUserResponse?.resource
                    }

                    XCTAssertNotNil(user)
                }
            }
        }
        
        XCTAssert(AzureData.isConfigured(), "AzureData configure failed")
    }
    
    
    override func tearDown() {
        super.tearDown()
        let expectation = self.expectation(description: "should delete database after tests")

        AzureData.delete(databaseWithId: databaseId) { _ in
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)
    }
}
