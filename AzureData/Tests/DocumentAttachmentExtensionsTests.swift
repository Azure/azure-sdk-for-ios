//
//  DocumentAttachmentExtensionsTests.swift
//  AzureDataTests
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureData

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
    
    
    func testAttachmentCrud() {

        var createResponse:     Response<Attachment>?
        var listResponse:       Response<Resources<Attachment>>?
        var replaceResponse:    Response<Attachment>?
        var deleteResponse:     Response<Data>?

        let url: URL! = URL(string: "https://azuredatatests.blob.core.windows.net/attachment-tests/youre%20welcome.jpeg?st=2017-11-07T14%3A00%3A00Z&se=2020-11-08T14%3A00%3A00Z&sp=rl&sv=2017-04-17&sr=c&sig=RAHr6Mee%2Bt7RrDnGHyjgSX3HSqJgj8guhy0IrEMh3KQ%3D")

        // Create
        document!.create (attachmentWithId: resourceId, contentType: "image/jpeg", andMediaUrl: url) { r in
            createResponse = r
            self.createExpectation.fulfill()
        }

        wait(for: [createExpectation], timeout: timeout)

        XCTAssertNotNil(createResponse?.resource)

        // List
        document!.getAttachments { r in
            listResponse = r
            self.listExpectation.fulfill()
        }

        wait(for: [listExpectation], timeout: timeout)

        XCTAssertNotNil(listResponse?.resource)

        // Replace
        if let attachment = createResponse?.resource  {
            document!.replace(attachmentWithId: attachment.id, contentType: "image/jpeg", andMediaUrl: url) { r in
                replaceResponse = r
                self.replaceExpectation.fulfill()
            }

            wait(for: [replaceExpectation], timeout: timeout)
        }

        XCTAssertNotNil(replaceResponse?.resource)

        // Delete
        if let attachment = replaceResponse?.resource ?? createResponse?.resource {
            document!.delete (attachmentWithId: attachment.id) { r in
                deleteResponse = r
                self.deleteExpectation.fulfill()
            }

            wait(for: [deleteExpectation], timeout: timeout)
        }

        XCTAssert(deleteResponse?.result.isSuccess ?? false)
    }
}
