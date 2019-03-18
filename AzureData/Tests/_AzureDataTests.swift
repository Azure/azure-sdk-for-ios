//
//  _AzureDataTests.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureData
@testable import AzureCore

class _AzureDataTests: XCTestCase {

    let timeout: TimeInterval = 30.0
    let waitTime = 2.0

    var resourceName: String?
    var resourceType: ResourceType!
    var partitionKey: DocumentCollection.PartitionKeyDefinition = []

    var rname: String { return resourceName ?? resourceType.path.capitalized }

    var databaseId:     String { return "\(rname)TestsDatabase" }
    var collectionId:   String { return "\(rname)TestsCollection" }
    var documentId:     String { return "\(rname)TestsDocument" }
    var userId:         String { return "\(rname)TestsUser" }
    var resourceId:     String { return "\(rname)Tests\(rname)" }
    var replacedId:     String { return "\(rname)Replaced" }

    lazy var createExpectation   = self.expectation(description: "should create and return \(rname)")
    lazy var listExpectation     = self.expectation(description: "should return a list of \(rname)")
    lazy var getExpectation      = self.expectation(description: "should get and return \(rname)")
    lazy var deleteExpectation   = self.expectation(description: "should delete \(rname)")
    lazy var queryExpectation    = self.expectation(description: "should query \(rname)")
    lazy var replaceExpectation  = self.expectation(description: "should replace \(rname)")
    lazy var replaceExpectation2 = self.expectation(description: "should replace \(rname)")
    lazy var refreshExpectation  = self.expectation(description: "should refresh \(rname)")
    lazy var executeExpectation  = self.expectation(description: "should execute \(rname)")

    override func setUp() {
        super.setUp()

        AzureData.configure(withPlistNamed: "AzureTests.plist", withPermissionMode: .all)
        AzureData.offlineDataEnabled = true

        turnOnInternetConnection()
    }


    override func tearDown() {
        super.tearDown()

        let expectation = self.expectation(description: "should clean up")

        self.cleanUp {
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)
    }

    func ensureDatabaseExists(withId id: String? = nil, completion: ((Database) -> ())? = nil) {
        ensureResourceExists(
            type: Database.self,
            get: { AzureData.get(databaseWithId: id ?? self.databaseId, callback: $0) },
            create: { AzureData.create(databaseWithId: id ?? self.databaseId, callback: $0) },
            completion: completion
        )
    }

    func ensureCollectionExists(withId id: String? = nil, completion: ((DocumentCollection) -> ())? = nil) {
        ensureDatabaseExists()
        ensureResourceExists(
            type: DocumentCollection.self,
            get: { AzureData.get(collectionWithId: id ?? self.collectionId, inDatabase: self.databaseId, callback: $0) },
            create: { AzureData.create(collectionWithId: id ?? self.collectionId, andPartitionKey: self.partitionKey, inDatabase: self.databaseId, callback: $0) },
            completion: completion
        )
    }

    func ensureDocumentExists<T: Document>(_ document: T, completion: ((T) -> ())? = nil) {
        ensureCollectionExists()
        ensureResourceExists(
            type: T.self,
            get: { AzureData.get(documentWithId: document.id, as: T.self, inCollection: self.collectionId, inDatabase: self.databaseId, callback: $0) },
            create: { AzureData.create(document, inCollection: self.collectionId, inDatabase: self.databaseId, callback: $0) },
            completion: completion
        )
    }

    func ensureUserExists(completion: ((User) -> ())? = nil) {
        ensureDatabaseExists()
        ensureResourceExists(
            type: User.self,
            get: { AzureData.get(userWithId: self.userId, inDatabase: self.databaseId, callback: $0) },
            create: { AzureData.create(userWithId: self.userId, inDatabase: self.databaseId, callback: $0) },
            completion: completion
        )
    }

    func ensureDatabaseIsDeleted() {
        ensureResourceIsDeleted(Database.self, delete: { AzureData.delete(databaseWithId: self.databaseId, callback: $0) })
    }

    func purgeCache(completion: @escaping () -> Void) {
        try? ResourceCache.purge()
        ResourceWriteOperationQueue.shared.purge()
        ResourceOracle.purge()

        // Because cache operations are done asynchronously, we wait
        // a bit (for them to complete) before we return.
        wait {
            completion()
        }
    }

    func wait(_ completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + waitTime) {
            completion()
        }
    }

    func turnOffInternetConnection() {
        let session = MockURLSession()
        session.shouldReturnError(NSError(domain: NSURLErrorDomain, code: URLError.notConnectedToInternet.rawValue, userInfo: nil))
        DocumentClient.shared.session = session

        let reachabilityManager = MockReachabilityManager(.notReachable)
        DocumentClient.shared.reachabilityManager = reachabilityManager

        DocumentClient.shared.isOffline = true
    }

    func turnOnInternetConnection() {
        precondition(AzureData.isConfigured(), "AzureData should be configured. Make sure that the keys in AzureTests.plist are set to valid values.")

        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = DocumentClient.defaultHttpHeaders

        let session = URLSession(configuration: configuration)
        DocumentClient.shared.session = session

        let reachabilityManager = ReachabilityManager(host: DocumentClient.shared.host)
        DocumentClient.shared.reachabilityManager = reachabilityManager

        DocumentClient.shared.isOffline = false
    }

    // MARK: - Private helpers

    private func ensureResourceExists<T>(
        type: T.Type,
        get: @escaping (_ completion: @escaping (Response<T>) -> ()) -> (),
        create: @escaping (_ completion: @escaping (Response<T>) -> ()) -> (),
        completion: ((T) -> ())? = nil
    ) {
        let ensureExpectation = expectation(description: "\(String(describing: type).lowercased()) should exist")
        var resource: T? = nil

        func setResource(from response: Response<T>) {
            resource = response.resource
            ensureExpectation.fulfill()
        }

        get { r in
            if r.result.isSuccess { setResource(from: r) ; return }
            create { r in setResource(from: r) }
        }

        wait(for: [ensureExpectation], timeout: timeout)

        precondition(resource != nil, "\(String(describing: type).lowercased()) should exist")

        completion?(resource!)
    }

    func cleanUp(completion: @escaping () -> Void) {
        AzureData.delete(databaseWithId: self.databaseId) { _ in
            completion()
        }
    }

    private func ensureResourceIsDeleted<T: CodableResource>(_ type: T.Type, delete: @escaping (_ completion: @escaping (Response<Data>) -> ()) -> ()) {
        let ensureExpectation = expectation(description: "\(String(describing: type).lowercased()) should be deleted")

        delete { r in
            ensureExpectation.fulfill()
        }

        wait(for: [ensureExpectation], timeout: timeout)
    }
}

