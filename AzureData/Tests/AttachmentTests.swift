//
//  AttachmentTests.swift
//  AzureDataTests
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureData

class AttachmentTests: AzureDataTests {

    override func setUp() {
        resourceType = .attachment
        ensureDatabase = true
        ensureCollection = true
        ensureDocument = true
        super.setUp()
    }

    override func tearDown() { super.tearDown() }
    
    
    func testAttachmentCrud() {
        
        var createResponse:     Response<Attachment>?
        var listResponse:       Response<Resources<Attachment>>?
        //var getResponse:        Response<Attachment>?
        var replaceResponse:    Response<Attachment>?
        var deleteResponse:     Response<Data>?
        //var queryResponse:    Response<Resources<Attachment>>?

        let url: URL! = URL(string: "https://azuredatatests.blob.core.windows.net/attachment-tests/youre%20welcome.jpeg?st=2017-11-07T14%3A00%3A00Z&se=2020-11-08T14%3A00%3A00Z&sp=rl&sv=2017-04-17&sr=c&sig=RAHr6Mee%2Bt7RrDnGHyjgSX3HSqJgj8guhy0IrEMh3KQ%3D")
        
        
        // Create
        AzureData.create (attachmentWithId: resourceId, contentType: "image/jpeg", andMediaUrl: url, onDocument: documentId, inCollection: collectionId, inDatabase: databaseId) { r in
            createResponse = r
            self.createExpectation.fulfill()
        }
        
        wait(for: [createExpectation], timeout: timeout)
        
        XCTAssertNotNil(createResponse?.resource)
        
        
        // List
        AzureData.get(attachmentsOn: documentId, inCollection: collectionId, inDatabase: databaseId) { r in
            listResponse = r
            self.listExpectation.fulfill()
        }
        
        wait(for: [listExpectation], timeout: timeout)
        
        XCTAssertNotNil(listResponse?.resource)
        
        
        // Replace
        if let attachment = createResponse?.resource  {
            
            AzureData.replace(attachmentWithId: attachment.id, contentType: "image/jpeg", andMediaUrl: url, onDocument: documentId, inCollection: collectionId, inDatabase: databaseId) { r in
                replaceResponse = r
                self.replaceExpectation.fulfill()
            }
            
            wait(for: [replaceExpectation], timeout: timeout)
        }
        
        XCTAssertNotNil(replaceResponse?.resource)
        
        
        // Delete
        if let attachment = replaceResponse?.resource ?? createResponse?.resource {
            
            AzureData.delete (attachment) { r in
                deleteResponse = r
                self.deleteExpectation.fulfill()
            }
            
            wait(for: [deleteExpectation], timeout: timeout)
        }
        
        XCTAssert(deleteResponse?.result.isSuccess ?? false)
    }
}
