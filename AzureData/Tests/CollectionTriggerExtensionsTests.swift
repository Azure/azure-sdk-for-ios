//
//  CollectionTriggerExtensionsTests.swift
//  AzureDataTests
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest

class CollectionTriggerExtensionsTests: AzureDataTests {
    
    override func setUp() {
        resourceType = .trigger
        resourceName = "CollectionTriggerExtensions"
        ensureDatabase = true
        ensureCollection = true
        super.setUp()
    }
    
    override func tearDown() { super.tearDown() }
    
    
    //func testTriggerCrud() {
    
    //var createResponse:     Response<Trigger>?
    //var listResponse:       ListResponse<Trigger>?
    //var getResponse:        Response<Trigger>?
    //var replaceResponse:    Response<Trigger>?
    //var queryResponse:      ListResponse<Trigger>?
    
    //}
}
