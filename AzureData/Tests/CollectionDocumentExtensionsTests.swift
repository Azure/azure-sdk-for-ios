//
//  CollectionDocumentExtensionsTests.swift
//  AzureDataTests
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureData

class CollectionDocumentExtensionsTests: AzureDataTests {
    
    override func setUp() {
        resourceType = .document
        resourceName = "CollectionDocumentExtensions"
        ensureDatabase = true
        ensureCollection = true
        super.setUp()
    }

    override func tearDown() { super.tearDown() }

    
    func testCollectionCrud() {
        
        var createResponse:     Response<DictionaryDocument>?
        var listResponse:       ListResponse<DictionaryDocument>?
        var getResponse:        Response<DictionaryDocument>?
        var deleteResponse:     DataResponse?
        var queryResponse:      ListResponse<DictionaryDocument>?

        
        if let collection = self.collection {
        
            let newDocument = DictionaryDocument(resourceId)
            
            newDocument[customStringKey] = customStringValue
            newDocument[customNumberKey] = customNumberValue
            
            
            // Create
            collection.create(newDocument) { r in
                createResponse = r
                self.createExpectation.fulfill()
            }
            
            wait(for: [createExpectation], timeout: timeout)
            
            XCTAssertNotNil(createResponse?.resource)
            
            if let document = createResponse?.resource {
                
                XCTAssertNotNil(document[customStringKey] as? String)
                XCTAssertEqual (document[customStringKey] as! String, customStringValue)
                XCTAssertNotNil(document[customNumberKey] as? Int)
                XCTAssertEqual (document[customNumberKey] as! Int, customNumberValue)
            }
            
            
            // List
            collection.get(documentsAs: DictionaryDocument.self) { r in
                listResponse = r
                self.listExpectation.fulfill()
            }
            
            wait(for: [listExpectation], timeout: timeout)
            
            XCTAssertNotNil(listResponse?.resource)
            
            
            // Query
            let query = Query.select()
                .from(collectionId)
                .where("\(customStringKey)", is: customStringValue)
                .and("\(customNumberKey)", is: customNumberValue)
                .orderBy("_etag", descending: true)
            
            collection.query(documentsWith: query) { (r:ListResponse<DictionaryDocument>?) in
                queryResponse = r
                self.queryExpectation.fulfill()
            }
            
            wait(for: [queryExpectation], timeout: timeout)
            
            XCTAssertNotNil(queryResponse?.resource?.items.first)
            
            if let document = queryResponse?.resource?.items.first {
                
                XCTAssertNotNil(document[customStringKey] as? String)
                XCTAssertEqual (document[customStringKey] as! String, customStringValue)
                XCTAssertNotNil(document[customNumberKey] as? Int)
                XCTAssertEqual (document[customNumberKey] as! Int, customNumberValue)
            }
            
            
            // Get
            if let document = createResponse?.resource {
                
                collection.get(documentWithResourceId: document.id, as: DictionaryDocument.self) { r in
                    getResponse = r
                    self.getExpectation.fulfill()
                }
                
                wait(for: [getExpectation], timeout: timeout)
            }
            
            XCTAssertNotNil(getResponse?.resource)
            
            if let document = getResponse?.resource {
                
                XCTAssertNotNil(document[customStringKey] as? String)
                XCTAssertEqual (document[customStringKey] as! String, customStringValue)
                XCTAssertNotNil(document[customNumberKey] as? Int)
                XCTAssertEqual (document[customNumberKey] as! Int, customNumberValue)
            }

            
            // Delete
            if let document = createResponse?.resource {
                
                collection.delete(document) { r in
                    deleteResponse = r
                    self.deleteExpectation.fulfill()
                }
                
                wait(for: [deleteExpectation], timeout: timeout)
            }
            
            XCTAssert(deleteResponse?.result.isSuccess ?? false)
        }
    }
}

