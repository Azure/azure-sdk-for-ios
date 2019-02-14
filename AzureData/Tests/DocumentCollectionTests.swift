//
//  DocumentCollectionTests.swift
//  AzureDataTests
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureData
@testable import AzureCore

class DocumentCollectionTests: _AzureDataTests {
    override func setUp() {
        super.setUp()
        resourceType = .collection
        partitionKey = "/birthCity"
    }

    func testCreate() {
        let expectation = self.expectation(description: "should create collection")

        ensureDatabaseExists()
        AzureData.create(collectionWithId: collectionId, andPartitionKey: partitionKey, inDatabase: databaseId) { r in
            XCTAssertTrue(r.result.isSuccess)
            XCTAssertNotNil(r.resource)
            XCTAssertEqual(r.resource?.id, self.collectionId)
            XCTAssertEqual(r.resource?.partitionKey, self.partitionKey)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)
    }

    func testReplace() {
        let expectation = self.expectation(description: "should replace collection")

        ensureCollectionExists { collection in
            let policy = DocumentCollection.IndexingPolicy(
                automatic: false,
                excludedPaths: [
                    .init(path: "/test/*")
                ],
                includedPaths: [
                    .init(
                        path: "/*",
                        indexes: [
                            .hash(withDataType: .string, andPrecision: 2),
                        ]
                    )
                ],
                indexingMode: .lazy
            )

            AzureData.replace(collectionWithId: collection.id, andPartitionKey: self.partitionKey, inDatabase: self.databaseId, usingPolicy: policy) { r in
                XCTAssertTrue(r.result.isSuccess)
                XCTAssertNotNil(r.resource)
                XCTAssertEqual(r.resource?.id, self.collectionId)
                XCTAssertEqual(r.resource?.partitionKey, self.partitionKey)
                //                XCTAssertEqual(r.resource?.indexingPolicy, policy)

                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)
    }

    func testGet() {
        let expectation = self.expectation(description: "should get collection")

        ensureCollectionExists()

        AzureData.get(collectionWithId: collectionId, inDatabase: databaseId) { r in
            XCTAssertTrue(r.result.isSuccess)
            XCTAssertNotNil(r.resource)
            XCTAssertEqual(r.resource?.id, self.collectionId)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)
    }

    func testList() {
        let expectation = self.expectation(description: "should list collections")

        let first = collectionId + "1"
        let second = collectionId + "2"

        ensureCollectionExists(withId: first)
        ensureCollectionExists(withId: second)

        AzureData.get(collectionsIn: databaseId) { r in
            XCTAssertTrue(r.result.isSuccess)
            XCTAssertNotNil(r.resource)
            XCTAssertEqual(r.resource?.items.count, 2)
            XCTAssertFalse(r.resource?.items.filter({ $0.id == first }).isEmpty ?? true)
            XCTAssertFalse(r.resource?.items.filter({ $0.id == second }).isEmpty ?? true)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)
    }

    func testDelete() {
        let expectation = self.expectation(description: "should delete document")

        ensureCollectionExists()

        AzureData.delete(collectionWithId: collectionId, fromDatabase: databaseId) { r in
            XCTAssertTrue(r.result.isSuccess)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)
    }
}

