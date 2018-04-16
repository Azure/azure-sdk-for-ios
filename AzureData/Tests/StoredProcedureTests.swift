//
//  StoredProcedureTests.swift
//  AzureDataTests
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureData

class StoredProcedureTests: AzureDataTests {
    
    override func setUp() {
        resourceType = .storedProcedure
        ensureDatabase = true
        ensureCollection = true
        super.setUp()
    }
    
    override func tearDown() { super.tearDown() }
    
    
    func testThatCreateValidatesId() {
        
        AzureData.create (storedProcedureWithId: idWith256Chars, andBody: "", inCollection: collectionId, inDatabase: databaseId) { r in
            XCTAssertTrue(r.clientError.isInvalidIdError)
        }
        
        AzureData.create (storedProcedureWithId: idWithWhitespace, andBody: "", inCollection: collectionId, inDatabase: databaseId) { r in
            XCTAssertTrue(r.clientError.isInvalidIdError)
        }
    }

    
    func testStoredProcedureCrud() {

        var createResponse:     Response<StoredProcedure>?
        var listResponse:       Response<Resources<StoredProcedure>>?
        var replaceResponse:    Response<StoredProcedure>?
        var deleteResponse:     Response<Data>?

        // Create
        AzureData.create(storedProcedureWithId: resourceId, andBody: "function () {}", inCollection: collectionId, inDatabase: databaseId) { r in
            createResponse = r
            self.createExpectation.fulfill()
        }

        wait(for: [createExpectation], timeout: timeout)

        XCTAssertNotNil(createResponse?.resource)

        // List
        AzureData.get(storedProceduresIn: collectionId, inDatabase: databaseId) { r in
            listResponse = r
            self.listExpectation.fulfill()
        }

        wait(for: [listExpectation], timeout: timeout)

        XCTAssertNotNil(listResponse?.resource)

        // Replace
        if let storedProcedure = createResponse?.resource {
            AzureData.replace(storedProcedureWithId: storedProcedure.id, andBody: "function procedure() {}", inCollection: collectionId, inDatabase: databaseId) { r in
                replaceResponse = r
                self.replaceExpectation.fulfill()
            }

            wait(for: [replaceExpectation], timeout: timeout)

            XCTAssertNotNil(replaceResponse?.resource)
        }

        // Delete
        if let storedProcedure = replaceResponse?.resource ?? createResponse?.resource {
            AzureData.delete(storedProcedureWithId: storedProcedure.id, fromCollection: collectionId, inDatabase: databaseId) { r in
                deleteResponse = r
                self.deleteExpectation.fulfill()
            }

            wait(for: [deleteExpectation], timeout: timeout)

            XCTAssert(deleteResponse?.result.isSuccess ?? false)
        }
    }
}
