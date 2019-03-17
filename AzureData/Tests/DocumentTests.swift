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

        ensureDocumentExists(document) { oldDocument in
            let newDocument = TestDocument.stub(oldDocument.id, firstName: "Baba", birthCity: "Lome")

            AzureData.createOrReplace(newDocument, inCollection: self.collectionId, inDatabase: self.databaseId) { r in
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

    func testGetWithPartitionKey() {
        let expectation = self.expectation(description: "should get document with partition key")
        let document = TestDocument.stub(documentId)
        guard let partitionKey = TestDocument.partitionKey else { return }
        let partitionKeyValue = document[keyPath: partitionKey]

        ensureDocumentExists(document)

        AzureData.get(documentWithId: document.id, as: TestDocument.self, inCollection: collectionId, withPartitionKey: partitionKeyValue, inDatabase: databaseId) { r in
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

    func testQueryWithPartitionKey() {
        let expectation = self.expectation(description: "should query documents in the specified partition")

        let first = TestDocument.stub(documentId + "1")
        let second = TestDocument.stub(documentId + "2", firstName: "Anoura", lastName: "Akaya", birthCity: "Lome")

        ensureDocumentExists(first)
        ensureDocumentExists(second)

        let query = Query().from("TestDocument").orderBy("birthCity")
        AzureData.query(documentsIn: self.collectionId, as: TestDocument.self, inDatabase: self.databaseId, with: query, andPartitionKey: second.birthCity) { r in
            XCTAssertTrue(r.result.isSuccess)
            XCTAssertNotNil(r.resource)
            XCTAssertEqual(r.resource?.items.count, 1)
            XCTAssertEqual(r.resource?.items[0], second)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)
    }

    func testQueryAcrossAllPartitions() {
        let expectation = self.expectation(description: "should query documents across all partitions")

        let first = TestDocument.stub(documentId + "1")
        let second = TestDocument.stub(documentId + "2", firstName: "Anoura", lastName: "Akaya", birthCity: "Lome")

        ensureDocumentExists(first)
        ensureDocumentExists(second)

        let query = Query().from("TestDocument").orderBy("birthCity")
        AzureData.query(documentsAcrossAllPartitionsIn: self.collectionId, as: TestDocument.self, inDatabase: self.databaseId, with: query) { r in
            XCTAssertTrue(r.result.isSuccess)
            XCTAssertNotNil(r.resource)
            XCTAssertEqual(r.resource?.items.count, 2)

            XCTAssertFalse(r.resource?.items.filter({ $0.firstName == first.firstName }).isEmpty ?? true)
            XCTAssertFalse(r.resource?.items.filter({ $0.firstName == second.firstName }).isEmpty ?? true)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)
    }

    func testQueryResultsAreCachedLocally() {
        let expectation = self.expectation(description: "should cache query results locally")

        let first = TestDocument.stub(documentId + "1")
        let second = TestDocument.stub(documentId + "2", firstName: "Anoura", lastName: "Akaya", birthCity: "Lome")

        ensureDocumentExists(first)
        ensureDocumentExists(second)

        var resources: [TestDocument] = []
        let query = Query().from("TestDocument")
        AzureData.query(documentsAcrossAllPartitionsIn: self.collectionId, as: TestDocument.self, inDatabase: self.databaseId, with: query) { r in
            XCTAssertTrue(r.result.isSuccess)
            resources = r.resource?.items ?? []

            self.wait {
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: self.timeout)

        let cachesDirectoryUrl = try! URL(string: "com.azure.data/", relativeTo: FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false))!

        resources.forEach { resource in
            let url = URL(string: "queries/\(query.hashValue)/results/\(resource.resourceId).json", relativeTo: cachesDirectoryUrl)!
            XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
        }
    }

    func testQueryResultsAreFetchedFromLocalCacheWhenNetworkIsNotReachable() {
        let expectation = self.expectation(description: "should fetch query results from the local cache")

        let first = TestDocument.stub(documentId + "1")
        let second = TestDocument.stub(documentId + "2", firstName: "Anoura", lastName: "Akaya", birthCity: "Lome")

        ensureDocumentExists(first)
        ensureDocumentExists(second)

        var onlineResources: [TestDocument] = []
        var offlineResources: [TestDocument] = []

        let query = Query().from("TestDocument")

        AzureData.query(documentsAcrossAllPartitionsIn: self.collectionId, as: TestDocument.self, inDatabase: self.databaseId, with: query) { r in
            XCTAssertTrue(r.result.isSuccess)

            onlineResources = r.resource?.items ?? []

            self.wait {
                self.turnOffInternetConnection()

                AzureData.query(documentsAcrossAllPartitionsIn: self.collectionId, as: TestDocument.self, inDatabase: self.databaseId, with: query) { r in
                    XCTAssertTrue(r.result.isSuccess)
                    XCTAssertTrue(r.fromCache)

                    offlineResources = r.resource?.items ?? []

                    expectation.fulfill()
                }
            }
        }

        wait(for: [expectation], timeout: self.timeout)

        XCTAssertFalse(onlineResources.isEmpty)
        XCTAssertFalse(offlineResources.isEmpty)

        offlineResources.forEach { resource in
            XCTAssertTrue(onlineResources.contains(where: { $0.resourceId == resource.resourceId }))
        }
    }
}
