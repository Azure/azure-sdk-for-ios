//
//  TriggerTests.swift
//  AzureDataTests
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureData

class TriggerTests: AzureDataTests {
    
    override func setUp() {
        resourceType = .trigger
        ensureDatabase = true
        ensureCollection = true
        super.setUp()
    }
    
    override func tearDown() { super.tearDown() }
    
    func testTriggerCrud() {

        var createResponse:     Response<Trigger>?
        var listResponse:       ListResponse<Trigger>?
        var replaceResponse:    Response<Trigger>?
        var deleteResponse:     DataResponse?

        // Create
        AzureData.create(
            triggerWithId: resourceId,
            operation: .all,
            type: .post,
            andBody: """
                function updateMetadata() {
                    var context = getContext();
                    var collection = context.getCollection();
                    var response = context.getResponse();
                    var createdDocument = response.getBody();

                    // query for metadata document
                    var filterQuery = 'SELECT * FROM root r WHERE r.id = \"_metadata\"';

                    var accept = collection.queryDocuments(collection.getSelfLink(), filterQuery, updateMetadataCallback);

                    if(!accept) throw \"Unable to update metadata, abort\";

                    function updateMetadataCallback(err, documents, responseOptions) {
                        if(err) throw new Error(\"Error\" + err.message);

                        if(documents.length != 1) throw 'Unable to find metadata document';

                        var metadataDocument = documents[0];

                        // update metadata
                        metadataDocument.createdDocuments += 1;
                        metadataDocument.createdNames += \" \" + createdDocument.id;

                        var accept = collection.replaceDocument(
                            metadataDocument._self,
                            metadataDocument,
                            function(err, docReplaced) {
                                if(err) throw \"Unable to update metadata, abort\";
                            }
                        );

                        if(!accept) throw \"Unable to update metadata, abort\";
                        return;
                }
                """,
            in: collection!
        ) { r in
            createResponse = r
            self.createExpectation.fulfill()
        }

        wait(for: [createExpectation], timeout: timeout)

        XCTAssertNotNil(createResponse?.resource)



        // List
        AzureData.get(triggersIn: collection!) { r in
            listResponse = r
            self.listExpectation.fulfill()
        }

        wait(for: [listExpectation], timeout: timeout)

        XCTAssertNotNil(listResponse?.resource)



        // Replace
        AzureData.replace(triggerWithId: resourceId, operation: .create, type: .pre, andBody: "function updateMetadata()", inCollection: collectionId, inDatabase: databaseId) { r in
            replaceResponse = r
            self.replaceExpectation.fulfill()
        }

        wait(for: [replaceExpectation], timeout: timeout)

        XCTAssertNotNil(replaceResponse?.resource)



        // Delete
        AzureData.delete (triggerWithId: resourceId, fromCollection: collection!) { r in
            deleteResponse = r
            self.deleteExpectation.fulfill()
        }

        wait(for: [deleteExpectation], timeout: timeout)

        XCTAssert(deleteResponse?.result.isSuccess ?? false)
    }
}
