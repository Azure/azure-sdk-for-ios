//
//  _AzureDataTests.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureData

class _AzureDataTests: XCTestCase {

    let timeout: TimeInterval = 30.0

    var resourceName: String?
    var resourceType: ResourceType!

    var rname: String { return resourceName ?? resourceType.name }

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

        // AzureData.configure(forAccountNamed: "<Database Name>", withMasterKey: "<Database Master Key OR Resource Permission Token>", withPermissionMode: "<Master Key Permission Mode>")
        AzureData.offlineDataEnabled = true
    }


    override func tearDown() {
        super.tearDown()
    }

    func ensureDatabaseExists(completion: ((Database) -> ())? = nil) {
        ensureResourceExists(
            type: Database.self,
            get: { AzureData.get(databaseWithId: self.databaseId, callback: $0) },
            create: { AzureData.create(databaseWithId: self.databaseId, callback: $0) },
            completion: completion
        )
    }

    func ensureCollectionExists(completion: ((DocumentCollection) -> ())? = nil) {
        ensureDatabaseExists()
        ensureResourceExists(
            type: DocumentCollection.self,
            get: { AzureData.get(collectionWithId: self.collectionId, inDatabase: self.databaseId, callback: $0) },
            create: { AzureData.create(collectionWithId: self.collectionId, inDatabase: self.databaseId, callback: $0) },
            completion: completion
        )
    }

    func ensureDocumentExists(completion: ((Document) -> ())? = nil) {
        ensureCollectionExists()
        ensureResourceExists(
            type: Document.self,
            get: { AzureData.get(documentWithId: self.documentId, as: Document.self, inCollection: self.collectionId, inDatabase: self.databaseId, callback: $0) },
            create: { AzureData.create(Document(self.documentId), inCollection: self.collectionId, inDatabase: self.databaseId, callback: $0) },
            completion: completion
        )
    }

    // MARK: - Private helpers

    private func ensureResourceExists<T: CodableResource>(
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
}

