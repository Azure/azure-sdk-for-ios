//
//  DefaultPermissionProviderTests.swift
//  AzureMobile
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
import AzureData
@testable import AzureMobile

class DefaultPermissionProviderTests: XCTestCase {
    
    let timeout: TimeInterval = 30.0
    
    lazy var createExpectation  = self.expectation(description: "should create and return colleciton")
    lazy var listExpectation    = self.expectation(description: "should return a list of colleciton")
    lazy var getExpectation     = self.expectation(description: "should get and return colleciton")
    lazy var getDocExpectation  = self.expectation(description: "should get and return document")
    lazy var deleteExpectation  = self.expectation(description: "should delete colleciton")
    lazy var queryExpectation   = self.expectation(description: "should query colleciton")
    lazy var replaceExpectation = self.expectation(description: "should replace colleciton")
    lazy var refreshExpectation = self.expectation(description: "should refresh colleciton")
    
    fileprivate(set) var collection:DocumentCollection?
    
    let customStringKey = "customStringKey"
    let customStringValue = "customStringValue"
    let customNumberKey = "customNumberKey"
    let customNumberValue = 86
    
    
    var functionUrl: URL? // = your function app url
    var databaseName: String? // = your database name
    
    override func setUp() {
        super.setUp()
        
        functionUrl = URL(string:"")
        databaseName = ""
        
        if let dbname = databaseName, !dbname.isEmpty, let baseUrl = functionUrl {
            AzureData.configure(forAccountNamed: dbname, withPermissionProvider: DefaultPermissionProvider(withBaseUrl: baseUrl))
        }
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        if let dbname = databaseName, !dbname.isEmpty {
            
            var getResponse:    Response<DictionaryDocument>?
            var listResponse:   Response<Resources<DictionaryDocument>>?
            var createResponse: Response<DictionaryDocument>?
            var deleteResponse: Response<Data>?
            
            AzureData.get(collectionWithId: "MyCollectionFive", inDatabase: "MyDatabaseFive") { r in
                self.collection = r.resource
                self.getExpectation.fulfill()
            }
            
            wait(for: [getExpectation], timeout: timeout)
            
            XCTAssertNotNil(collection)
            
            if let collection = collection {
                
                let newDocument = DictionaryDocument("MyDocument")
                
                newDocument[customStringKey] = customStringValue
                newDocument[customNumberKey] = customNumberValue
                
                
                collection.create(newDocument) { r in
                    createResponse = r
                    self.createExpectation.fulfill()
                }
                
                wait(for: [createExpectation], timeout: timeout)
                
                XCTAssertNotNil(createResponse?.resource)
                
                
                
                collection.get(documentsAs: DictionaryDocument.self) { r in
                    listResponse = r
                    self.listExpectation.fulfill()
                }
                
                wait(for: [listExpectation], timeout: timeout)
                
                XCTAssertNotNil(listResponse?.resource)
                
                
                collection.get(documentWithId: newDocument.id, as: DictionaryDocument.self) { r in
                    getResponse = r
                    self.getDocExpectation.fulfill()
                }
                
                wait(for: [getDocExpectation], timeout: timeout)
                
                XCTAssertNotNil(getResponse?.resource)
                
                if let doc = getResponse?.resource ?? createResponse?.resource {
                    
                    collection.delete(doc) { r in
                        deleteResponse = r
                        self.deleteExpectation.fulfill()
                    }
                    
                    wait(for: [deleteExpectation], timeout: timeout)
                    
                }
                
                XCTAssert(deleteResponse?.result.isSuccess ?? false)
            }
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}
