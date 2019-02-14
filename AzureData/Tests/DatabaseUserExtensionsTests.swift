//
//  DatabaseUserExtensionsTests.swift
//  AzureDataTests
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureData
@testable import AzureCore

class DatabaseUserExtensionsTests: AzureDataTests {

    override func setUp() {
        resourceType = .user
        resourceName = "CollectionUserExtensions"
        ensureDatabase = true
        ensureCollection = true
        super.setUp()
    }

    override func tearDown() { super.tearDown() }
    
    
    func testUserCrud() {
        
        var createResponse:     Response<User>?
        var listResponse:       Response<Resources<User>>?
        var getResponse:        Response<User>?
        var replaceResponse:    Response<User>?
        var deleteResponse:     Response<Data>?

        
        if let database = self.database {
            
            // Create
            database.create(userWithId: resourceId) { r in
                createResponse = r
                self.createExpectation.fulfill()
            }
            
            wait(for: [createExpectation], timeout: timeout)
            
            XCTAssertNotNil(createResponse?.resource)
            
            
            
            // List
            database.getUsers() { r in
                listResponse = r
                self.listExpectation.fulfill()
            }
            
            wait(for: [listExpectation], timeout: timeout)
            
            XCTAssertNotNil(listResponse?.resource)
            
            
            
            // Get
            database.get(userWithId: resourceId) { r in
                getResponse = r
                self.getExpectation.fulfill()
            }
            
            wait(for: [getExpectation], timeout: timeout)

            XCTAssertNotNil(getResponse?.resource)
            
            
            
            // Replace
            if let user = getResponse?.resource  {
                
                database.replace(userWithId: user.id, with: replacedId) { r in
                    replaceResponse = r
                    self.replaceExpectation.fulfill()
                }
                
                wait(for: [replaceExpectation], timeout: timeout)
            }
            
            XCTAssertNotNil(replaceResponse?.resource)
            
            
            
            // Delete
            if let user = replaceResponse?.resource ?? getResponse?.resource {
                
                database.delete(user) { r in
                    deleteResponse = r
                    self.deleteExpectation.fulfill()
                }
                
                wait(for: [deleteExpectation], timeout: timeout)
            }
            
            XCTAssert(deleteResponse?.result.isSuccess ?? false)
        }
    }    
}
