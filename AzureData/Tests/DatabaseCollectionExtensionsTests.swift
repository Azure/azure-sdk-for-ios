//
//  DatabaseCollectionExtensionsTests.swift
//  AzureDataTests
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureData

class DatabaseCollectionExtensionsTests: AzureDataTests {
    
    override func setUp() {
        resourceType = .collection
        resourceName = "DatabaseCollectionExtensions"
        ensureDatabase = true
        super.setUp()
    }
    
    override func tearDown() { super.tearDown() }

    
    func testDatabaseCrud() {
        
        if let database = self.database {
            
            var createResponse:     Response<DocumentCollection>?
            var listResponse:       Response<Resources<DocumentCollection>>?
            var getResponse:        Response<DocumentCollection>?
            var deleteResponse:     Response<Data>?

            
            
            // Create
            database.create(collectionWithId: collectionId) { r in
                createResponse = r
                self.createExpectation.fulfill()
            }
            
            wait(for: [createExpectation], timeout: timeout)
            
            XCTAssertNotNil(createResponse?.resource)
            
            
            
            // List
            database.getCollections { r in
                listResponse = r
                self.listExpectation.fulfill()
            }
            
            wait(for: [listExpectation], timeout: timeout)
            
            XCTAssertNotNil(listResponse?.resource)
            
            
            
            // Get
                
            database.get(collectionWithId: collectionId) { r in
                getResponse = r
                self.getExpectation.fulfill()
            }
            
            wait(for: [getExpectation], timeout: timeout)

            XCTAssertNotNil(getResponse?.resource)
                
            
            
            
            // Delete
            if let collection = getResponse?.resource {
                
                database.delete(collection) { r in
                //database.delete(collectionWithId: collection.id) { r in
                    deleteResponse = r
                    self.deleteExpectation.fulfill()
                }
                
                wait(for: [deleteExpectation], timeout: timeout)
            }
            
            XCTAssert(deleteResponse?.result.isSuccess ?? false)
            
            
        }
    }
}
