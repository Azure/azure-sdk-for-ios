//
//  ExamplePermissionProviderTests.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureData

public struct PermissionRequest : Codable {
    
    let databaseId: String?
    let collectionId: String?
    let tokenDuration: Int
    let permissionMode: PermissionMode
}

public class ExamplePermissionProvider : BasePermissionProvider {
    
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
    let session = URLSession.init(configuration: URLSessionConfiguration.default)
    
    override public func getPermission(forCollectionWithId collectionId: String, inDatabase databaseId: String, withPermissionMode mode: PermissionMode, completion: @escaping (PermissionResult) -> Void) {
        
        let permissionRequest = PermissionRequest(databaseId: databaseId, collectionId: collectionId, tokenDuration: 3600, permissionMode: mode)
        
        let url = URL(string: "")

        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try encoder.encode(permissionRequest)
        } catch {
            completion(PermissionResult(PermissionProviderError.failedToGetPermissionFromServer)); return;
        }
        
        session.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                
                completion(PermissionResult(error))
                
            } else if let data = data {
                
                //print(String(data: data, encoding: .utf8) ?? "fail")
                
                do {
                    let permission = try self.decoder.decode(Permission.self, from: data)
                    
                    completion(PermissionResult(permission))
                    
                } catch {
                    completion(PermissionResult(PermissionProviderError.failedToGetPermissionFromServer)); return;
                }
            } else {
                
                let unknownError = DocumentClientError(withKind: .unknownError)
                
                completion(PermissionResult(unknownError))
            }
        }.resume()
    }
}

class ExamplePermissionProviderTests: XCTestCase {
    
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

    
    override func setUp() {
        super.setUp()
        
        // AzureData.configure(forAccountNamed: "<Database Name>", withPermissionProvider: ExamplePermissionProvider(with: PermissionProviderConfiguration.default))


        //let config = PermissionProviderConfiguration(defaultPermissionMode: .all, defaultResourceLevel: .collection)
        //let provider = ExamplePermissionProvider(with: config)
        //AzureData.configure(forAccountNamed: "databasemao5xlrroux6s", withPermissionProvider: provider)
        
        AzureData.configure(forAccountNamed: "databasemao5xlrroux6s", withPermissionProvider: ExamplePermissionProvider(with: PermissionProviderConfiguration.default))
        
        DocumentClient.default.dateEncoder = DocumentClient.roundTripIso8601Encoder
        DocumentClient.default.dateDecoder = DocumentClient.roundTripIso8601Decoder
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {

        var deleteResponse: DataResponse?
        var createResponse: Response<DictionaryDocument>?
        var getResponse: Response<DictionaryDocument>?
        var listResponse: ListResponse<DictionaryDocument>?
        
        AzureData.get(collectionWithId: "MyCollectionThree", inDatabase: "MyDatabaseThree") { r in
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

            
            
            collection.get(documentWithResourceId: newDocument.id, as: DictionaryDocument.self) { r in
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
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}
