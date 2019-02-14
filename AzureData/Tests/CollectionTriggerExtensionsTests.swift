//
//  CollectionTriggerExtensionsTests.swift
//  AzureDataTests
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureData
@testable import AzureCore

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
        var listResponse:       Response<Resources<Trigger>>?
        var replaceResponse:    Response<Trigger>?
        var deleteResponse:     Response<Data>?

        // Create
        collection!.create(triggerWithId: resourceId, operation: .all, type: .post, andBody: "function updateMetadata() {}") { r in
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
        if let trigger = createResponse?.resource {
            collection!.replace(triggerWithId: trigger.id, operation: .delete, type: .pre, andBody: "function updateMetadata() {}") { r in
                replaceResponse = r
                self.replaceExpectation.fulfill()
            }

            wait(for: [replaceExpectation], timeout: timeout)

            XCTAssertNotNil(replaceResponse?.resource)
        }

        // Delete
        if let trigger = replaceResponse?.resource ?? createResponse?.resource {
            collection!.delete(triggerWithId: trigger.id) { r in
                deleteResponse = r
                self.deleteExpectation.fulfill()
            }

            wait(for: [deleteExpectation], timeout: timeout)

            XCTAssert(deleteResponse?.result.isSuccess ?? false)
        }
    }
}
