//
//  PermissionTests.swift
//  AzureDataTests
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureData

class PermissionTests: AzureDataTests {
    
    override func setUp() {
        resourceType = .permission
        ensureDatabase = true
        ensureCollection = true
        ensureUser = true
        super.setUp()
    }
    
    override func tearDown() { super.tearDown() }
    
    func testPermissionCrud() {

        var createResponse:     Response<Permission>?
        var listResponse:       Response<Resources<Permission>>?
        var getResponse:        Response<Permission>?
        var refreshResponse:    Response<Permission>?
        var replaceResponse:    Response<Permission>?
        var deleteResponse:     Response<Data>?

        // Create
        AzureData.create(permissionWithId: resourceId, mode: .all, in: collection!, for: user!) { r in
            createResponse = r
            self.createExpectation.fulfill()
        }

        wait(for: [createExpectation], timeout: timeout)

        XCTAssertNotNil(createResponse?.resource)

        // List
        AzureData.get(permissionsFor: user!) { r in
            listResponse = r
            self.listExpectation.fulfill()
        }

        wait(for: [listExpectation], timeout: timeout)

        XCTAssertNotNil(listResponse?.resource)

        // Get
        AzureData.get(permissionWithId: resourceId, for: user!) { r in
            getResponse = r
            self.getExpectation.fulfill()
        }

        wait(for: [getExpectation], timeout: timeout)

        XCTAssertNotNil(getResponse?.resource)

        // Refresh
        if let permission = getResponse?.resource {
            permission.refresh { r in
                refreshResponse = r
                self.refreshExpectation.fulfill()
            }

            wait(for: [refreshExpectation], timeout: timeout)
        }

        XCTAssertNotNil(refreshResponse?.resource)

        // Replace
        if let permission = getResponse?.resource {
            AzureData.replace(permissionWithId: permission.id, mode: .read, in: collection!, for: user!) { r in
                replaceResponse = r
                self.replaceExpectation.fulfill()
            }

            wait(for: [replaceExpectation], timeout: timeout)

            XCTAssertNotNil(replaceResponse?.resource)
        }

        // Delete
        if let permission = replaceResponse?.resource ?? getResponse?.resource {
            AzureData.delete(permissionWithId: permission.id, from: user!) { r in
                deleteResponse = r
                self.deleteExpectation.fulfill()
            }

            wait(for: [deleteExpectation], timeout: timeout)

            XCTAssert(deleteResponse?.result.isSuccess ?? false)
        }
    }
}
