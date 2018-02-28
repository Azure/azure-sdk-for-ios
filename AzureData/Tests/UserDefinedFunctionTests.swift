//
//  UserDefinedFunctionTests.swift
//  AzureDataTests
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureData

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
            XCTAssertNotNil(r.error)
        }

        AzureData.create (userDefinedFunctionWithId: idWithWhitespace, andBody: "", inCollection: collectionId, inDatabase: databaseId) { r in
            XCTAssertNotNil(r.error)
        }
    }
    
    //func testUserDefinedFunctionCrud() {

        //var createResponse:     Response<UserDefinedFunction>?
        //var listResponse:       ListResponse<UserDefinedFunction>?
        //var getResponse:        Response<UserDefinedFunction>?
        //var replaceResponse:    Response<UserDefinedFunction>?
        //var queryResponse:      ListResponse<UserDefinedFunction>?

    //}
        
}
