//
//  DocumentAttachmentExtensionsTests.swift
//  AzureDataTests
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest

class DocumentAttachmentExtensionsTests: AzureDataTests {
    
    override func setUp() {
        resourceType = .attachment
        resourceName = "DocumentAttachmentExtensions"
        ensureDatabase = true
        ensureCollection = true
        ensureDocument = true
        super.setUp()
    }
    
    override func tearDown() { super.tearDown() }
    
    
    //func testAttachmentCrud() {
    
    //var createResponse:     Response<Attachment>?
    //var listResponse:       ListResponse<Attachment>?
    //var getResponse:        Response<Attachment>?
    //var replaceResponse:    Response<Attachment>?
    //var queryResponse:      ListResponse<Attachment>?
    
    //}
}
