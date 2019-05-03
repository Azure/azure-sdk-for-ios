//
//  _StoredProcedureTests.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureData
@testable import AzureCore

class _StoredProcedureTests: _AzureDataTests {
    override func setUp() {
        resourceType = .storedProcedure
        resourceName = "StoredProcedure"
        partitionKey = "/birthCity"
        super.setUp()
        super.tearDown()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testStoredProcedureWithQuery() {
        let expectation = self.expectation(description: "should execute stored procedure with a query")

        let document1 = TestDocument.stub(documentId + "1")
        let document2 = TestDocument.stub(documentId + "2")
        let document3 = TestDocument.stub(documentId + "3")

        ensureDocumentExists(document1)
        ensureDocumentExists(document2)
        ensureDocumentExists(document3)

        let body =
            """
                function (arg) {
                    var collection = getContext().getCollection();
                    var isAccepted = collection.queryDocuments(
                        collection.getSelfLink(),
                        `SELECT * FROM collectionId`,
                        function (err, feed, options) {
                            if (err) throw err;
                            if (!feed || !feed.length) {
                                var response = getContext().getResponse();
                                var body = { feed: feed };
                                response.setBody(JSON.stringify(body));
                            }
                        }
                    );

                    if (!isAccepted) throw new Error('The query was not accepted by the server.');
                }
            """

        AzureData.create(storedProcedureWithId: storedProcedureId, andBody: body, inCollection: collectionId, inDatabase: databaseId) { r in
            XCTAssertTrue(r.result.isSuccess)

            let partitionKey = document1[keyPath: TestDocument.partitionKey!]
            AzureData.execute(storedProcedureWithId: self.storedProcedureId, usingParameters: nil, andPartitionKey: partitionKey, inCollection: self.collectionId, inDatabase: self.databaseId) { r in
                XCTAssertTrue(r.result.isSuccess)

                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)
    }
}
