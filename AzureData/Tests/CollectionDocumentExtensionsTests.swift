//
//  CollectionDocumentExtensionsTests.swift
//  AzureDataTests
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureData
@testable import AzureCore

class CollectionDocumentExtensionsTests: _AzureDataTests {
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
            collection.create(document) { r in
                XCTAssertTrue(r.result.isSuccess)
                XCTAssertNotNil(r.resource)
                XCTAssertFalse(r.resource?.resourceId.isEmpty ?? true)
                XCTAssertEqual(r.resource?.firstName, document.firstName)
                XCTAssertEqual(r.resource?.lastName, document.lastName)
                XCTAssertEqual(r.resource?.birthCity, document.birthCity)

                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)
    }

    func testCreateOrReplace() {
        let expectation = self.expectation(description: "should replace document")
        let document = TestDocument.stub(documentId)

        ensureCollectionExists { collection in
            self.ensureDocumentExists(document) { oldDocument in
                let newDocument = TestDocument.stub(oldDocument.id, firstName: "Baba", birthCity: "Lome")

                collection.createOrReplace(newDocument) { r in
                    XCTAssertTrue(r.result.isSuccess)
                    XCTAssertNotNil(r.resource)
                    XCTAssertFalse(r.resource?.resourceId.isEmpty ?? true)
                    XCTAssertEqual(r.resource?.id, oldDocument.id)
                    XCTAssertEqual(r.resource?.firstName, newDocument.firstName)
                    XCTAssertEqual(r.resource?.lastName, newDocument.lastName)
                    XCTAssertEqual(r.resource?.birthCity, newDocument.birthCity)

                    expectation.fulfill()
                }
            }
        }

        wait(for: [expectation], timeout: timeout)
    }

    func testGet() {
        let expectation = self.expectation(description: "should get document")
        let document = TestDocument.stub(documentId)

        ensureCollectionExists { collection in
            self.ensureDocumentExists(document)
            collection.get(documentWithId: document.id, as: TestDocument.self) { r in
                XCTAssertTrue(r.result.isSuccess)
                XCTAssertNotNil(r.resource)
                XCTAssertFalse(r.resource?.resourceId.isEmpty ?? true)
                XCTAssertEqual(r.resource?.firstName, document.firstName)
                XCTAssertEqual(r.resource?.lastName, document.lastName)
                XCTAssertEqual(r.resource?.birthCity, document.birthCity)

                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)
    }

    func testList() {
        let expectation = self.expectation(description: "should list documents")

        ensureCollectionExists { collection in
            let first = TestDocument.stub(self.documentId + "1")
            let second = TestDocument.stub(self.documentId + "2", firstName: "Farid", lastName: "Akaya", birthCity: "Lome")

            self.ensureDocumentExists(first)
            self.ensureDocumentExists(second)

            collection.get(documentsAs: TestDocument.self) { r in
                XCTAssertTrue(r.result.isSuccess)
                XCTAssertNotNil(r.resource)
                XCTAssertEqual(r.resource?.items.count, 2)

                XCTAssertFalse(r.resource?.items.filter({ $0.firstName == first.firstName }).isEmpty ?? true)
                XCTAssertFalse(r.resource?.items.filter({ $0.firstName == second.firstName }).isEmpty ?? true)

                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)
    }

    func testDelete() {
        let expectation = self.expectation(description: "should delete document")
        let document = TestDocument.stub(documentId)

        ensureCollectionExists { collection in
            self.ensureDocumentExists(document) { (document: TestDocument) in
                collection.delete(document) { r in
                    XCTAssertTrue(r.result.isSuccess)

                    expectation.fulfill()
                }
            }
        }

        wait(for: [expectation], timeout: timeout)
    }
}

