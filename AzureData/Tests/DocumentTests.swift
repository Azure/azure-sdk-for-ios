//
//  DocumentTests.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureData
@testable import AzureCore

class DocumentTests: _AzureDataTests {
    override func setUp() {
        super.setUp()
        resourceType = .document
        resourceName = "Person"
        partitionKey = "/birthCity"
    }

    func testCreate() {
        let expectation = self.expectation(description: "should create document")
        let document = TestDocument.stub(documentId)

        ensureCollectionExists { collection in
            AzureData.create(document, in: collection) { r in
                XCTAssertTrue(r.result.isSuccess)
                XCTAssertNotNil(r.resource)
                XCTAssertFalse(r.resource?.resourceId.isEmpty ?? true)
                XCTAssertEqual(r.resource?.firstName, "Faiçal")
                XCTAssertEqual(r.resource?.lastName, "Tchirou")
                XCTAssertEqual(r.resource?.birthCity, "Kharkov")

                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)
    }

    func testCreateOrReplace() {
        let expectation = self.expectation(description: "should replace document")
        let document = TestDocument.stub(documentId)

        ensureDocumentExists(document) { oldDocument in
            let newDocument = TestDocument.stub(oldDocument.id, firstName: "Baba", birthCity: "Lome")

            AzureData.createOrReplace(newDocument, inCollection: self.collectionId, inDatabase: self.databaseId) { r in
                XCTAssertTrue(r.result.isSuccess)
                XCTAssertNotNil(r.resource)
                XCTAssertFalse(r.resource?.resourceId.isEmpty ?? true)
                XCTAssertEqual(r.resource?.id, oldDocument.id)
                XCTAssertEqual(r.resource?.firstName, "Baba")
                XCTAssertEqual(r.resource?.lastName, "Tchirou")
                XCTAssertEqual(r.resource?.birthCity, "Lome")

                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)
    }

    func testGet() {
        let expectation = self.expectation(description: "should get document")
        let document = TestDocument.stub(documentId)

        ensureDocumentExists(document)

        AzureData.get(documentWithId: document.id, as: TestDocument.self, inCollection: collectionId, inDatabase: databaseId) { r in
            XCTAssertTrue(r.result.isSuccess)
            XCTAssertNotNil(r.resource)
            XCTAssertFalse(r.resource?.resourceId.isEmpty ?? true)
            XCTAssertEqual(r.resource?.firstName, document.firstName)
            XCTAssertEqual(r.resource?.lastName, document.lastName)
            XCTAssertEqual(r.resource?.birthCity, document.birthCity)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)
    }

    func testList() {
        let expectation = self.expectation(description: "should list documents")

        let first = TestDocument.stub(documentId + "1")
        let second = TestDocument.stub(documentId + "2", firstName: "Farid", lastName: "Akaya", birthCity: "Lome")

        ensureDocumentExists(first)
        ensureDocumentExists(second)

        AzureData.get(documentsAs: TestDocument.self, inCollection: collectionId, inDatabase: databaseId) { r in
            XCTAssertTrue(r.result.isSuccess)
            XCTAssertNotNil(r.resource)
            XCTAssertEqual(r.resource?.items.count, 2)

            XCTAssertFalse(r.resource?.items.filter({ $0.firstName == first.firstName }).isEmpty ?? true)
            XCTAssertFalse(r.resource?.items.filter({ $0.firstName == second.firstName }).isEmpty ?? true)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)
    }

    func testDelete() {
        let expectation = self.expectation(description: "should delete document")
        let document = TestDocument.stub(documentId)

        ensureDocumentExists(document) { (document: TestDocument) in
            AzureData.delete(document) { r in
                XCTAssertTrue(r.result.isSuccess)

                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)
    }
}
