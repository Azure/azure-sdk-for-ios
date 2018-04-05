//
//  DatabaseTests.swift
//  AzureDataTests
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureData

class DatabaseTests: AzureDataTests {
    
    override func setUp() {
        resourceType = .database
        super.setUp()
    }

    override func tearDown() { super.tearDown() }

    
    func testDatabaseCrud() {
        
        var createResponse:     Response<Database>?
        var listResponse:       Response<Resources<Database>>?
        var getResponse:        Response<Database>?
        var deleteResponse:     Response<Data>?
        var refreshResponse:    Response<Database>?
        //var replaceResponse:    Response<Database>?
        //var queryResponse:      ListResponse<Database>?

        
        // Create
        AzureData.create(databaseWithId: databaseId) { r in
            createResponse = r
            self.createExpectation.fulfill()
        }
        
        wait(for: [createExpectation], timeout: timeout)
        
        XCTAssertNotNil(createResponse?.resource)

        //createResponse?.response?.printHeaders()
        
        
        
        // List
        AzureData.databases { r in
            listResponse = r
            self.listExpectation.fulfill()
        }
        
        wait(for: [listExpectation], timeout: timeout)
        
        XCTAssertNotNil(listResponse?.resource)

        //listResponse?.response?.printHeaders()

        
        
        // Get
        AzureData.get(databaseWithId: databaseId) { r in
            getResponse = r
            self.getExpectation.fulfill()
        }
        
        wait(for: [getExpectation], timeout: timeout)
        
        XCTAssertNotNil(getResponse?.resource)

        //getResponse?.response?.printHeaders()

        

        // Refresh
        if getResponse?.result.isSuccess ?? false {
            
            AzureData.refresh(getResponse!.resource!) { r in
                refreshResponse = r
                self.refreshExpectation.fulfill()
            }
            
            wait(for: [refreshExpectation], timeout: timeout)
        }
        
        XCTAssertNotNil(refreshResponse?.resource)

        
        
        // Delete
        
        AzureData.delete(databaseWithId: databaseId) { r in
            deleteResponse = r
            self.deleteExpectation.fulfill()
        }
        
        wait(for: [deleteExpectation], timeout: timeout)
        
        XCTAssert(deleteResponse?.result.isSuccess ?? false)
        
        //deleteResponse?.response?.printHeaders()
    }
}
