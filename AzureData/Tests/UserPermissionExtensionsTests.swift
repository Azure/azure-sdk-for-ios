//
//  UserPermissionExtensionsTests.swift
//  AzureDataTests
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest

class UserPermissionExtensionsTests: AzureDataTests {
    
    override func setUp() {
        resourceType = .permission
        resourceName = "UserPermissionExtensions"
        ensureDatabase = true
        ensureCollection = true
        super.setUp()
    }
    
    override func tearDown() { super.tearDown() }
    
    
    //func testPermissionCrud() {
        
        //var createResponse:     Response<Permission>?
        //var listResponse:       ListResponse<Permission>?
        //var getResponse:        Response<Permission>?
        //var replaceResponse:    Response<Permission>?
        //var queryResponse:      ListResponse<Permission>?
    
    //}
}
