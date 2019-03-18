//
//  CollectionUserDefinedFunctionExtensionsTests.swift
//  AzureDataTests
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureData
@testable import AzureCore

class CollectionUserDefinedFunctionExtensionsTests: AzureDataTests {

    override func setUp() {
        resourceType = .udf
        resourceName = "CollectionUserDefinedFunctionExtensions"
        ensureDatabase = true
        ensureCollection = true
        super.setUp()
    }
    
    override func tearDown() { super.tearDown() }
    
    
    func testUserDefinedFunctionCrud() {

        var createResponse:     Response<UserDefinedFunction>?
        var listResponse:       Response<Resources<UserDefinedFunction>>?
        var replaceResponse:    Response<UserDefinedFunction>?
        var deleteResponse:     Response<Data>?

        // Create
        collection!.create(userDefinedFunctionWithId: resourceId, andBody: "function updateMetadata() {}") { r in
            createResponse = r
            self.createExpectation.fulfill()
        }

        wait(for: [createExpectation], timeout: timeout)

        XCTAssertNotNil(createResponse?.resource)

        // List
        collection!.getUserDefinedFunctions { r in
            listResponse = r
            self.listExpectation.fulfill()
        }

        wait(for: [listExpectation], timeout: timeout)

        XCTAssertNotNil(listResponse?.resource)

        // Replace
        if let udf = createResponse?.resource {
            collection!.replace(userDefinedFunctionWithId: udf.id, andBody: "function update() {}") { r in
                replaceResponse = r
                self.replaceExpectation.fulfill()
            }

            wait(for: [replaceExpectation], timeout: timeout)

            XCTAssertNotNil(replaceResponse?.resource)
        }

        // Delete
        if let udf = replaceResponse?.resource ?? createResponse?.resource {
            collection!.delete(userDefinedFunctionWithId: udf.id) { r in
                deleteResponse = r
                self.deleteExpectation.fulfill()
            }

            wait(for: [deleteExpectation], timeout: timeout)

            XCTAssert(deleteResponse?.result.isSuccess ?? false)
        }
    }
}
