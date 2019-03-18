//
//  UserPermissionExtensionsTests.swift
//  AzureDataTests
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureData
@testable import AzureCore

class UserPermissionExtensionsTests: AzureDataTests {

    override func setUp() {
        resourceType = .permission
        resourceName = "UserPermissionExtensions"
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
        var replaceResponse:    Response<Permission>?
        var deleteResponse:     Response<Data>?

        // Create
        user!.create(permissionWithId: resourceId, mode: .all, in: collection!) { r in
            createResponse = r
            self.createExpectation.fulfill()
        }

        wait(for: [createExpectation], timeout: timeout)

        XCTAssertNotNil(createResponse?.resource)

        // List
        user!.getPermissions { r in
            listResponse = r
            self.listExpectation.fulfill()
        }

        wait(for: [listExpectation], timeout: timeout)

        XCTAssertNotNil(listResponse?.resource)

        // Get
        user!.get(permissionWithId: resourceId) { r in
            getResponse = r
            self.getExpectation.fulfill()
        }

        wait(for: [getExpectation], timeout: timeout)

        XCTAssertNotNil(getResponse?.resource)

        // Replace
        if let permission = getResponse?.resource {
            user!.replace(permissionWithId: permission.id, mode: .read, in: collection!) { r in
                replaceResponse = r
                self.replaceExpectation.fulfill()
            }

            wait(for: [replaceExpectation], timeout: timeout)

            XCTAssertNotNil(replaceResponse?.resource)
        }

        // Delete
        if let permission = replaceResponse?.resource ?? getResponse?.resource {
            user!.delete(permissionWithId: permission.id) { r in
                deleteResponse = r
                self.deleteExpectation.fulfill()
            }

            wait(for: [deleteExpectation], timeout: timeout)

            XCTAssert(deleteResponse?.result.isSuccess ?? false)
        }
    }
}
