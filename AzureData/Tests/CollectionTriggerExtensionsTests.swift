//
//  CollectionTriggerExtensionsTests.swift
//  AzureDataTests
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureData

class CollectionTriggerExtensionsTests: AzureDataTests {
    
    override func setUp() {
        resourceType = .trigger
        resourceName = "CollectionTriggerExtensions"
        ensureDatabase = true
        ensureCollection = true
        super.setUp()
    }
    
    override func tearDown() { super.tearDown() }
    
    
    func testTriggerCrud() {

        var createResponse:     Response<Trigger>?
        var listResponse:       ListResponse<Trigger>?
        var replaceResponse:    Response<Trigger>?
        var deleteResponse:     DataResponse?


        // Create
        collection!.create(triggerWithId: resourceId, operation: .all, type: .post, andBody: "function updateMetadata()") { r in
            createResponse = r
            self.createExpectation.fulfill()
        }

        wait(for: [createExpectation], timeout: timeout)

        XCTAssertNotNil(createResponse?.resource)



        // List
        collection!.getTriggers { r in
            listResponse = r
            self.listExpectation.fulfill()
        }

        wait(for: [listExpectation], timeout: timeout)

        XCTAssertNotNil(listResponse?.resource)


        // Replace
        collection!.replace(triggerWithId: resourceId, operation: .create, type: .pre, andBody: "function updateMetadata()", inCollection: collectionId, inDatabase: databaseId) { r in
            replaceResponse = r
            self.replaceExpectation.fulfill()
        }

        wait(for: [replaceExpectation], timeout: timeout)

        XCTAssertNotNil(replaceResponse?.resource)

        // Delete
        collection!.delete(triggerWithId: resourceId) { r in
            deleteResponse = r
            self.deleteExpectation.fulfill()
        }

        wait(for: [deleteExpectation], timeout: timeout)

        XCTAssert(deleteResponse?.result.isSuccess ?? false)

    }
}
