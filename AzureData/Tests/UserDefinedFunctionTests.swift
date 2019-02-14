//
//  UserDefinedFunctionTests.swift
//  AzureDataTests
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureData
@testable import AzureCore

class UserDefinedFunctionTests: AzureDataTests {

    override func setUp() {
        resourceType = .udf
        ensureDatabase = true
        ensureCollection = true
        super.setUp()
    }

    override func tearDown() { super.tearDown() }
    
    
    func testThatCreateValidatesId() {
    
        AzureData.create (userDefinedFunctionWithId: idWith256Chars, andBody: "", inCollection: collectionId, inDatabase: databaseId) { r in
            XCTAssertTrue(r.clientError.isInvalidIdError)
        }

        AzureData.create (userDefinedFunctionWithId: idWithWhitespace, andBody: "", inCollection: collectionId, inDatabase: databaseId) { r in
            XCTAssertTrue(r.clientError.isInvalidIdError)

        }
    }
    
    func testUserDefinedFunctionCrud() {

        var createResponse:     Response<UserDefinedFunction>?
        var listResponse:       Response<Resources<UserDefinedFunction>>?
        var replaceResponse:    Response<UserDefinedFunction>?
        var deleteResponse:     Response<Data>?

        // Create
        AzureData.create(userDefinedFunctionWithId: resourceId, andBody: "function updateMetadata() {}", inCollection: collectionId, inDatabase: databaseId) { r in
            createResponse = r
            self.createExpectation.fulfill()
        }

        wait(for: [createExpectation], timeout: timeout)

        XCTAssertNotNil(createResponse?.resource)

        // List
        AzureData.get(userDefinedFunctionsIn: collectionId, inDatabase: databaseId) { r in
            listResponse = r
            self.listExpectation.fulfill()
        }

        wait(for: [listExpectation], timeout: timeout)

        XCTAssertNotNil(listResponse?.resource)

        // Replace
        if let udf = createResponse?.resource {
            AzureData.replace(userDefinedFunctionWithId: udf.id, andBody: "function update() {}", inCollection: collectionId, inDatabase: databaseId) { r in
                replaceResponse = r
                self.replaceExpectation.fulfill()
            }

            wait(for: [replaceExpectation], timeout: timeout)

            XCTAssertNotNil(replaceResponse?.resource)
        }

        // Delete
        if let udf = replaceResponse?.resource ?? createResponse?.resource {
            AzureData.delete(userDefinedFunctionWithId: udf.id, fromCollection: collectionId, inDatabase: databaseId) { r in
                deleteResponse = r
                self.deleteExpectation.fulfill()
            }

            wait(for: [deleteExpectation], timeout: timeout)

            XCTAssert(deleteResponse?.result.isSuccess ?? false)
        }
    }
}
