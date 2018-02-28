//
//  AzureDataTests.swift
//  AzureDataTests
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureData

class AzureDataTests: XCTestCase {
    
    let timeout: TimeInterval = 30.0

    var ensureDatabase:     Bool = false
    var ensureCollection:   Bool = false
    var ensureDocument:     Bool = false

    fileprivate(set) var database:  Database?
    fileprivate(set) var collection:DocumentCollection?
    fileprivate(set) var document:  Document?
    
    var resourceName: String?
    var resourceType: ResourceType!
    
    var rname: String { return resourceName ?? resourceType.name }
    
    var databaseId:     String { return "\(rname)TestsDatabase" }
    var collectionId:   String { return "\(rname)TestsCollection" }
    var documentId:     String { return "\(rname)TestsDocument" }
    var resourceId:     String { return "\(rname)Tests\(rname)" }
    var replacedId:     String { return "\(rname)Replaced" }


    let random: Int = 12
    
    let customStringKey = "customStringKey"
    let customStringValue = "customStringValue"
    let customNumberKey = "customNumberKey"
    let customNumberValue = 86
    
    let idWith256Chars = "0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345"
    let idWithWhitespace = "id value with spaces"

    
    lazy var createExpectation  = self.expectation(description: "should create and return \(rname)")
    lazy var listExpectation    = self.expectation(description: "should return a list of \(rname)")
    lazy var getExpectation     = self.expectation(description: "should get and return \(rname)")
    lazy var deleteExpectation  = self.expectation(description: "should delete \(rname)")
    lazy var queryExpectation   = self.expectation(description: "should query \(rname)")
    lazy var replaceExpectation = self.expectation(description: "should replace \(rname)")
    lazy var refreshExpectation = self.expectation(description: "should refresh \(rname)")

    
    override func setUp() {
        super.setUp()
        
        // AzureData.configure(forAccountNamed: "<Database Name>", withKey: "<Database Master Key OR Resource Permission Token>", ofType: "<Master Key or Resource Token>")
        
        
        AzureData.verboseLogging = true
        
        if !AzureData.isConfigured() {
            
            let bundle = Bundle(for: type(of: self))
            
            if let accountName = bundle.infoDictionary?["ADDatabaseAccountName"] as? String, accountName != "AZURE_COSMOS_DB_ACCOUNT_NAME",
                let accountKey = bundle.infoDictionary?["ADDatabaseAccountKey"]  as? String, accountKey  != "AZURE_COSMOS_DB_ACCOUNT_Key" {
            
                AzureData.configure(forAccountNamed: accountName, withKey: accountKey, ofType: .master)
            }
        }
        
        DocumentClient.default.dateEncoder = DocumentClient.roundTripIso8601Encoder
        DocumentClient.default.dateDecoder = DocumentClient.roundTripIso8601Decoder
        
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
                var initGetCollectionResponse: Response<AzureData.DocumentCollection>?
                
                database.get(collectionWithId: collectionId) { r in
                    initGetCollectionResponse = r
                    initGetCollectionExpectation.fulfill()
                }
                
                wait(for: [initGetCollectionExpectation], timeout: timeout)
                
                collection = initGetCollectionResponse?.resource
                
                if collection == nil {
                    
                    let initCreateCollectionExpectation = self.expectation(description: "Should initialize collection")
                    var initCreateCollectionResponse: Response<AzureData.DocumentCollection>?

                    database.create(collectionWithId: collectionId) { r in
                        initCreateCollectionResponse = r
                        initCreateCollectionExpectation.fulfill()
                    }
                    
                    wait(for: [initCreateCollectionExpectation], timeout: timeout)
                    
                    collection = initCreateCollectionResponse?.resource
                }
                
                XCTAssertNotNil(collection)
                
                if ensureDocument, let collection = collection {
                    
                    let initGetDocumentExpectation = self.expectation(description: "Should get document")
                    var initGetDocumentResponse: Response<Document>?
                    
                    AzureData.get(documentWithId: documentId, as: Document.self, inCollection: collection.id, inDatabase: database.id) { r in
                        initGetDocumentResponse = r
                        initGetDocumentExpectation.fulfill()
                    }
                    
                    wait(for: [initGetDocumentExpectation], timeout: timeout)
                    
                    document = initGetDocumentResponse?.resource
                    
                    if document == nil {
                        
                        let initCreateDocumentExpectation = self.expectation(description: "Should initialize document")
                        var initCreateDocumentResponse: Response<Document>?
                        
                        collection.create(Document(documentId)) { r in
                            initCreateDocumentResponse = r
                            initCreateDocumentExpectation.fulfill()
                        }
                        
                        wait(for: [initCreateDocumentExpectation], timeout: timeout)
                        
                        document = initCreateDocumentResponse?.resource
                    }
                    
                    XCTAssertNotNil(document)

                }
            }
        }
        
        XCTAssert(AzureData.isConfigured(), "AzureData configure failed")
    }
    
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
}
