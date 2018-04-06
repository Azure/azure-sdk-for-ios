//
//  CollectionStoredProcedureExtensionsTests.swift
//  AzureDataTests
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureData

class CollectionStoredProcedureExtensionsTests: AzureDataTests {
    
    override func setUp() {
        resourceType = .storedProcedure
        resourceName = "CollectionStoredProcedureExtensions"
        ensureDatabase = true
        ensureCollection = true
        super.setUp()
    }
    
    override func tearDown() { super.tearDown() }
    
    
    func testStoredProcedureCrud() {

        var createResponse:     Response<StoredProcedure>?
        var listResponse:       Response<Resources<StoredProcedure>>?
        var replaceResponse:    Response<StoredProcedure>?
        var deleteResponse:     Response<Data>?

        // Create
        collection!.create(storedProcedureWithId: resourceId, andBody: "function () {}") { r in
            createResponse = r
            self.createExpectation.fulfill()
        }

        wait(for: [createExpectation], timeout: timeout)

        XCTAssertNotNil(createResponse?.resource)

        // List
        collection!.getStoredProcedures { r in
            listResponse = r
            self.listExpectation.fulfill()
        }

        wait(for: [listExpectation], timeout: timeout)

        XCTAssertNotNil(listResponse?.resource)

        // Replace
        if let storedProcedure = createResponse?.resource {
            collection!.replace(storedProcedureWithId: storedProcedure.id, andBody: "function procedure() {}") { r in
                replaceResponse = r
                self.replaceExpectation.fulfill()
            }

            wait(for: [replaceExpectation], timeout: timeout)

            XCTAssertNotNil(replaceResponse?.resource)
        }

        // Delete
        if let storedProcedure = replaceResponse?.resource ?? createResponse?.resource {
            collection!.delete(storedProcedureWithId: storedProcedure.id) { r in
                deleteResponse = r
                self.deleteExpectation.fulfill()
            }

            wait(for: [deleteExpectation], timeout: timeout)

            XCTAssert(deleteResponse?.result.isSuccess ?? false)
        }
    }
}
