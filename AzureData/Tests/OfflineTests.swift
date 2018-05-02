//
//  OfflineTests.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureCore
@testable import AzureData

#if !os(watchOS)

class OfflineTests: _AzureDataTests {

    // MARK: - Properties

    private let cacheOperationDuration = 2.0
    private let queue = DispatchQueue(label: "com.azure.data")
    private let cachesDirectoryURL = try! URL(string: "com.azure.data/", relativeTo: FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false))!
    private var reachabilityManager = MockReachabilityManager(.reachable(.ethernetOrWiFi))

    // MARK: -

    override func setUp() {
        resourceName = "Offline"
        reachabilityManager = MockReachabilityManager(.reachable(.ethernetOrWiFi))
        DocumentClient.shared.reachabilityManager = reachabilityManager
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    // MARK: -

    func testFromCacheIsSetToTrueForResourcesFetchedFromLocalCache() {
        ensureDatabaseExists()
        let fromCacheExpectation = self.expectation(description: "fromCache should be set to true for resources fetched from the cache")

        reachabilityManager.networkReachabilityStatus = .notReachable

        AzureData.databases { r in
            XCTAssertTrue(r.result.isSuccess)
            XCTAssertTrue(r.fromCache)

            self.purgeCache()

            fromCacheExpectation.fulfill()
        }

        wait(for: [fromCacheExpectation], timeout: timeout)
    }

    func testFromCacheIsSetToFalseForResourcesFetchedOnline() {
        ensureDatabaseExists()
        let fromCacheExpectation = self.expectation(description: "fromCache should be set to false for resources fetched online")

        reachabilityManager.networkReachabilityStatus = .reachable(.ethernetOrWiFi)

        AzureData.databases { r in
            XCTAssertTrue(r.result.isSuccess)
            XCTAssertFalse(r.fromCache)

            self.purgeCache()

            fromCacheExpectation.fulfill()
        }

        wait(for: [fromCacheExpectation], timeout: timeout)
    }

    func testFromCacheIsSetToTrueForAResourceFetchedFromLocalCache() {
        ensureDatabaseExists()
        let fromCacheExpectation = self.expectation(description: "fromCache should be set to true for a resource fetched from the cache")

        reachabilityManager.networkReachabilityStatus = .notReachable

        AzureData.get(databaseWithId: databaseId) { r in
            XCTAssertTrue(r.result.isSuccess)
            XCTAssertTrue(r.fromCache)

            self.purgeCache()

            fromCacheExpectation.fulfill()
        }

        wait(for: [fromCacheExpectation], timeout: timeout)
    }

    func testFromCacheIsSetToFalseForAResourceFetchedOnline() {
        ensureDatabaseExists()
        let fromCacheExpectation = self.expectation(description: "fromCache should be set to false for a resource fetched online")

        reachabilityManager.networkReachabilityStatus = .reachable(.ethernetOrWiFi)

        AzureData.get(databaseWithId: databaseId) { r in
            XCTAssertTrue(r.result.isSuccess)
            XCTAssertFalse(r.fromCache)

            self.purgeCache()

            fromCacheExpectation.fulfill()
        }

        wait(for: [fromCacheExpectation], timeout: timeout)
    }

    func testDatabasesAreCachedLocallyWhenNetworkIsReachable() {
        ensureDatabaseExists()
        ensureResourcesAreCachedLocallyWhenNetworkIsReachable(
            resourceType: Database.self,
            getResources: { AzureData.databases(callback: $0) },
            localCachePath: "dbs/"
        )
    }

    func testDatabasesAreFetchedFromLocalCacheWhenNetworkIsNotReachable() {
        ensureDatabaseExists()
        ensureResourcesAreFetchedFromLocalCacheWhenNetworkIsNotReachable(
            resourceType: Database.self,
            getResources: { AzureData.databases(callback: $0) }
        )
    }

    func testCollectionsAreCachedLocallyWhenNetworkIsReachable() {
        ensureCollectionExists()
        let mainExpectation = expectation(description: "collections should be cached locally when the network is reachable")

        AzureData.get(databaseWithId: databaseId) { r in
            XCTAssertNotNil(r.resource!)

            let database = r.resource!

            self.ensureResourcesAreCachedLocallyWhenNetworkIsReachable(
                resourceType: DocumentCollection.self,
                getResources: { AzureData.get(collectionsIn: database, callback: $0) },
                localCachePath: "dbs/\(database.resourceId)/colls/",
                completion: { mainExpectation.fulfill() }
            )
        }

        wait(for: [mainExpectation], timeout: timeout)
    }

    func testCollectionsAreFetchedFromLocalCacheWhenNetworkIsNotReachable() {
        ensureCollectionExists()
        let mainExpectation = self.expectation(description: "collections should be fetched from the local cache when the network is not reachable")

        AzureData.get(databaseWithId: databaseId) { r in
            XCTAssertNotNil(r.resource)

            let database = r.resource!

            self.ensureResourcesAreFetchedFromLocalCacheWhenNetworkIsNotReachable(
                resourceType: DocumentCollection.self,
                getResources: { AzureData.get(collectionsIn: database, callback: $0) },
                completion: { mainExpectation.fulfill() }
            )
        }

        wait(for: [mainExpectation], timeout: timeout)
    }

    func testDocumentsAreCachedLocallyWhenNetworkIsReachable() {
        ensureDocumentExists()
        let mainExpectation = self.expectation(description: "documents should be cached locally when the network is reachable")

        AzureData.get(collectionWithId: self.collectionId, inDatabase: self.databaseId) { r in
            XCTAssertNotNil(r.resource)

            let collection = r.resource!

            self.ensureResourcesAreCachedLocallyWhenNetworkIsReachable(
                resourceType: Document.self,
                getResources: { AzureData.get(documentsAs: Document.self, in: collection, callback: $0) },
                localCachePath: "\(collection.selfLink!)docs/)",
                completion: { mainExpectation.fulfill() }
            )
        }

        wait(for: [mainExpectation], timeout: timeout)
    }

    func testDocumentsAreFetchedFromLocalCacheWhenNetworkIsNotReachable() {
        ensureDocumentExists()
        let mainExpectation = self.expectation(description: "documents should be fetched from the local cache when the network is not reachable")

        AzureData.get(collectionWithId: self.collectionId, inDatabase: self.databaseId) { r in
            XCTAssertNotNil(r.resource)

            let collection = r.resource!

            self.ensureResourcesAreFetchedFromLocalCacheWhenNetworkIsNotReachable(
                resourceType: Document.self,
                getResources: { AzureData.get(documentsAs: Document.self, in: collection, callback: $0) },
                completion: { mainExpectation.fulfill() }
            )
        }

        wait(for: [mainExpectation], timeout: timeout)
    }

    func testThatDeletingAResourceRemotelyAlsoDeletesItFromTheCache() {
        let deleteFromCacheExpectation = self.expectation(description: "a resource deleted remotely should also be deleted from the cache")

        ensureDatabaseExists { database in
            AzureData.delete(databaseWithId: database.id) { r in
                XCTAssertTrue(r.result.isSuccess)

                self.waitForCacheToProcessResources {
                    let databasesCachesDirectoryURL = URL(string: "dbs/", relativeTo: self.cachesDirectoryURL)
                    let directoryURL = URL(string: "\(database.resourceId)/", relativeTo: databasesCachesDirectoryURL)!
                    let JSONFileURL = URL(string: "\(database.resourceId).json", relativeTo: directoryURL)!


                    XCTAssertFalse(FileManager.default.fileExists(atPath: directoryURL.path))
                    XCTAssertFalse(FileManager.default.fileExists(atPath: JSONFileURL.path))

                    deleteFromCacheExpectation.fulfill()
                }
            }
        }

        wait(for: [deleteFromCacheExpectation], timeout: timeout)
    }

    func testThatResourcesAreDeletedFromTheCacheIfTheRemoteReturns404() {
        let deleteExpectation = self.expectation(description: "a resource should be deleted from the cache if the remote database returns 404 for it")

        ensureDatabaseExists { database in
            AzureData.delete(databaseWithId: database.id) { r in
                XCTAssertTrue(r.result.isSuccess)

                AzureData.get(databaseWithId: database.id) { r in
                    XCTAssertFalse(r.result.isSuccess)
                    XCTAssertTrue(r.clientError.isNotFoundError)

                    self.waitForCacheToProcessResources {
                        let databasesCachesDirectoryURL = URL(string: "dbs/", relativeTo: self.cachesDirectoryURL)
                        let directoryURL = URL(string: "\(database.resourceId)/", relativeTo: databasesCachesDirectoryURL)!
                        let JSONFileURL = URL(string: "\(database.resourceId).json", relativeTo: directoryURL)!

                        XCTAssertFalse(FileManager.default.fileExists(atPath: directoryURL.path))
                        XCTAssertFalse(FileManager.default.fileExists(atPath: JSONFileURL.path))

                        deleteExpectation.fulfill()
                    }
                }
            }
        }

        wait(for: [deleteExpectation], timeout: timeout)
    }

    // MARK: - Private helpers

    private func ensureResourcesAreCachedLocallyWhenNetworkIsReachable<T: CodableResource>(
        resourceType: T.Type,
        getResources: @escaping (_ completion: @escaping (Response<Resources<T>>) -> ()) -> (),
        localCachePath: String,
        completion: (() -> ())? = nil
    ) {
        var resources = [T]()

        queue.async {
            getResources { r in
                XCTAssertTrue(r.result.isSuccess)
                resources = r.resource?.items ?? []

                self.waitForCacheToProcessResources {
                    self.listExpectation.fulfill()
                }
            }
        }

        DispatchQueue.main.async {
            self.wait(for: [self.listExpectation], timeout: self.timeout)

            XCTAssertFalse(resources.isEmpty)

            let resourcesCacheDirectoryURL = URL(string: localCachePath, relativeTo: self.cachesDirectoryURL)!

            resources.forEach { resource in
                let directoryURL = URL(string: "\(resource.resourceId)/", relativeTo: resourcesCacheDirectoryURL)!
                let JSONFileURL = URL(string: "\(resource.resourceId).json", relativeTo: directoryURL)!
                XCTAssertTrue(FileManager.default.fileExists(atPath: directoryURL.path))
                XCTAssertTrue(FileManager.default.fileExists(atPath: JSONFileURL.path))
            }

            self.purgeCache()

            completion?()
        }
    }

    private func ensureResourcesAreFetchedFromLocalCacheWhenNetworkIsNotReachable<T: CodableResource>(
        resourceType: T.Type,
        getResources: @escaping (_ completion: @escaping (Response<Resources<T>>) -> ()) -> (),
        completion: (() -> ())? = nil
    ) {
        var onlineResources = [T]()
        var offlineResources = [T]()

        queue.async {
            getResources { r in
                onlineResources = r.resource?.items ?? []

                self.waitForCacheToProcessResources {
                    self.reachabilityManager.networkReachabilityStatus = .notReachable

                    getResources { r in
                        offlineResources = r.resource?.items ?? []
                        self.listExpectation.fulfill()
                    }
                }
            }
        }

        DispatchQueue.main.async {
            self.wait(for: [self.listExpectation], timeout: self.timeout)

            XCTAssertFalse(onlineResources.isEmpty)
            XCTAssertFalse(offlineResources.isEmpty)

            offlineResources.forEach { resource in
                XCTAssertTrue(onlineResources.contains(where: { $0.resourceId == resource.resourceId }))
            }

            self.purgeCache()

            completion?()
        }
    }

    private func waitForCacheToProcessResources(_ completion: @escaping () -> Void) {
        queue.asyncAfter(deadline: .now() + self.cacheOperationDuration) {
            completion()
        }
    }

    private func purgeCache() {
        try! ResourceCache.purge()
    }
}

// MARK: -

class MockReachabilityManager: ReachabilityManagerType {
    var networkReachabilityStatus: NetworkReachabilityStatus = .reachable(.ethernetOrWiFi) {
        didSet {
            if isListening { listener?(networkReachabilityStatus) }
        }
    }

    var listener: ReachabilityStatusListener?
    var isListening = false

    init(_ status: NetworkReachabilityStatus) {
        self.networkReachabilityStatus = status
    }

    func registerListener(_ listener: @escaping ReachabilityStatusListener) {
        self.listener = listener
    }

    func startListening() -> Bool {
        isListening = true
        listener?(networkReachabilityStatus)
        return true
    }

    func stopListening() {
        isListening = false
    }
}

#endif
