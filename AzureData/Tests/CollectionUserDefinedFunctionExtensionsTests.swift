//
//  CollectionUserDefinedFunctionExtensionsTests.swift
//  AzureDataTests
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest

class CollectionUserDefinedFunctionExtensionsTests: AzureDataTests {
    
    override func setUp() {
        resourceType = .udf
        resourceName = "CollectionUserDefinedFunctionExtensions"
        ensureDatabase = true
        ensureCollection = true
        super.setUp()
    }
    
    override func tearDown() { super.tearDown() }
    
    
    //func testUserDefinedFunctionCrud() {
    
    //var createResponse:     Response<UserDefinedFunction>?
    //var listResponse:       ListResponse<UserDefinedFunction>?
    //var getResponse:        Response<UserDefinedFunction>?
    //var replaceResponse:    Response<UserDefinedFunction>?
    //var queryResponse:      ListResponse<UserDefinedFunction>?
    
    //}
}
