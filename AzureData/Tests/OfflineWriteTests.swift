//
//  OfflineWriteTests.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureCore
@testable import AzureData

#if !os(watchOS)

class OfflineWriteTests: _AzureDataTests {

    // MARK: -

    override func setUp() {
        resourceName = "OfflineWrite"
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: - Tests

    func testResourceIsCreatedLocallyWhenTheNetworkIsNotReachable() {
        turnOffInternetConnection()

        AzureData.create(databaseWithId: databaseId) { r in
            XCTAssertTrue(r.result.isSuccess)
            XCTAssertTrue(r.fromCache)

            self.createExpectation.fulfill()
        }

        wait(for: [createExpectation], timeout: timeout)

        AzureData.databases { r in
            XCTAssertTrue(r.result.isSuccess)
            XCTAssertTrue(r.fromCache)
            XCTAssertNotNil(r.resource)
            XCTAssertTrue(r.resource!.items.contains(where: { $0.id == self.databaseId }))

            self.purgeCache {
                self.listExpectation.fulfill()
            }
        }

        wait(for: [listExpectation], timeout: timeout)
    }

    func testConflictIsReturnedWhenTheSameResourceIsCreatedTwiceWhileOffline() {
        turnOffInternetConnection()

        let conflictExpectation = self.expectation(description: "should return a response with the client error Conflict")

        AzureData.create(databaseWithId: databaseId) { r in
            XCTAssertTrue(r.result.isSuccess)
            XCTAssertTrue(r.fromCache)

            self.createExpectation.fulfill()
        }

        wait(for: [createExpectation], timeout: timeout)

        AzureData.create(databaseWithId: databaseId) { r in
            XCTAssertTrue(r.result.isFailure)
            XCTAssertTrue(r.clientError.isConflictError)

            self.purgeCache {
                conflictExpectation.fulfill()
            }
        }

        wait(for: [conflictExpectation], timeout: timeout)
    }

    func testNotFoundIsReturnedWhenTryingToReplaceANonExistingResourceWhileOffline() {
        turnOffInternetConnection()

        let notFoundExpectation = self.expectation(description: "should return a response with the client error NotFound")

        ensureCollectionExists { collection in
            AzureData.replace(Document(self.documentId), in: collection) { r in
                XCTAssertTrue(r.result.isFailure)
                XCTAssertTrue(r.clientError.isNotFoundError)

                self.purgeCache {
                    notFoundExpectation.fulfill()
                }
            }
        }

        wait(for: [notFoundExpectation], timeout: timeout)
    }

    func testNotFoundIsReturnedWhenTryingToDeleteANonExistingResourceWhileOffline() {
        turnOffInternetConnection()

        AzureData.delete(databaseWithId: databaseId) { r in
            XCTAssertTrue(r.result.isFailure)
            XCTAssertTrue(r.clientError.isNotFoundError)

            self.purgeCache {
                self.deleteExpectation.fulfill()
            }
        }

        wait(for: [deleteExpectation], timeout: timeout)
    }

    func testPendingWritesArePerformedOnlineOnceTheNetworkIsReachable() {
        turnOffInternetConnection()

        let onlineCreateExpectation = self.expectation(description: "should create the resource online")

        AzureData.create(databaseWithId: databaseId) { r in
            XCTAssertTrue(r.result.isSuccess)
            XCTAssertTrue(r.fromCache)

            self.createExpectation.fulfill()
        }

        wait(for: [createExpectation], timeout: timeout)

        NotificationCenter.default.addObserver(forName: .OfflineResourceSyncSucceeded, object: nil, queue: nil) { notification in
            XCTAssertNotNil(notification.userInfo)
            XCTAssertNotNil(notification.userInfo!["data"] as? Data)

            let database = try? JSONDecoder().decode(Database.self, from: notification.userInfo!["data"] as! Data)

            XCTAssertNotNil(database)
            XCTAssertEqual(database!.id, self.databaseId)
            XCTAssertFalse(database!.resourceId.isEmpty)

            self.purgeCache {
                onlineCreateExpectation.fulfill()
            }
        }

        turnOnInternetConnection()

        wait(for: [onlineCreateExpectation], timeout: timeout)

        ensureDatabaseIsDeleted()
    }
}
#endif
