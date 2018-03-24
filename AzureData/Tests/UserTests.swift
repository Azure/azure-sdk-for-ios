//
//  UserTests.swift
//  AzureDataTests
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureData

class UserTests: AzureDataTests {
    
    override func setUp() {
        resourceType = .user
        ensureDatabase = true
        super.setUp()
    }
    
    override func tearDown() { super.tearDown() }

    
    func testUserCrud() {
        
        var createResponse:     Response<User>?
        var listResponse:       ListResponse<User>?
        var getResponse:        Response<User>?
        var replaceResponse:    Response<User>?
        var refreshResponse:    Response<User>?
        var deleteResponse:     DataResponse?


        // Create
        AzureData.create(userWithId: resourceId, inDatabase: databaseId) { r in
            createResponse = r
            self.createExpectation.fulfill()
        }
        
        wait(for: [createExpectation], timeout: timeout)
        
        XCTAssertNotNil(createResponse?.resource)
        
        
        
        // List
        AzureData.get(usersIn: databaseId) { r in
            listResponse = r
            self.listExpectation.fulfill()
        }
        
        wait(for: [listExpectation], timeout: timeout)
        
        XCTAssertNotNil(listResponse?.resource)
        
        
        
        // Get
        if createResponse?.result.isSuccess ?? false {
            
            AzureData.get(userWithId: resourceId, inDatabase: databaseId) { r in
                getResponse = r
                self.getExpectation.fulfill()
            }
            
            wait(for: [getExpectation], timeout: timeout)
        }
        
        XCTAssertNotNil(getResponse?.resource)
        
        
        
        // Refresh
        if getResponse?.result.isSuccess ?? false {
            
            AzureData.refresh(getResponse!.resource!) { r in
                refreshResponse = r
                self.refreshExpectation.fulfill()
            }
            
            wait(for: [refreshExpectation], timeout: timeout)
        }
        
        XCTAssertNotNil(refreshResponse?.resource)

        
        
        // Replace
        if let user = createResponse?.resource  {
         
            AzureData.replace(userWithId: user.id, with: replacedId, inDatabase: databaseId) { r in
                replaceResponse = r
                self.replaceExpectation.fulfill()
            }
            
            wait(for: [replaceExpectation], timeout: timeout)
        }
        
        XCTAssertNotNil(replaceResponse?.resource)
        
        
        
        // Delete
        if let user = replaceResponse?.resource ?? createResponse?.resource {
            
            AzureData.delete(user) { r in
                deleteResponse = r
                self.deleteExpectation.fulfill()
            }
            
            wait(for: [deleteExpectation], timeout: timeout)
        }
        
        XCTAssert(deleteResponse?.result.isSuccess ?? false)
    }
}
