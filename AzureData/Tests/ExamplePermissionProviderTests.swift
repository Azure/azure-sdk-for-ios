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
    
    let databaseId: String
    let collectionId: String
    let documentId: String?
    let tokenDuration: Int
    let permissionMode: PermissionMode
}

public class ExamplePermissionProvider : PermissionProvider {
    
    lazy var encoder: JSONEncoder = getPermissionEncoder()
    
    lazy var decoder: JSONDecoder = getPermissionDecoder()

    
    let session = URLSession.init(configuration: URLSessionConfiguration.default)
    

    public var configuration: PermissionProviderConfiguration!
    
    public func getPermission(forCollectionWithId collectionId: String, inDatabase databaseId: String, withPermissionMode mode: PermissionMode, completion: @escaping (Response<Permission>) -> Void) {
        
        let permissionRequest = PermissionRequest(databaseId: databaseId, collectionId: collectionId, documentId: nil, tokenDuration: Int(configuration.defaultTokenDuration), permissionMode: mode)
        
        let url = URL(string: "")

        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try encoder.encode(permissionRequest)
        } catch {
            completion(Response(PermissionProviderError.getPermissionFailed)); return;
        }
        
        session.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                
                completion(Response(request: request, data: data, response: response as? HTTPURLResponse, result: .failure(error)))
                
            } else if let data = data {
                
                //print(String(data: data, encoding: .utf8) ?? "fail")
                
                do {
                    let permission = try self.decoder.decode(Permission.self, from: data)
                    
                    completion(Response(request: request, data: data, response: response as? HTTPURLResponse, result: .success(permission)))
                    
                } catch {
                    
                    completion(Response(request: request, data: data, response: response as? HTTPURLResponse, result: .failure(error))); return;
                }
            } else {
                
                completion(Response(request: request, data: data, response: response as? HTTPURLResponse, result: .failure(DocumentClientError(withKind: .unknownError)))); return;
            }
        }.resume()
    }

    public func getPermission(forDocumentWithId documentId: String, inCollection collectionId: String, inDatabase databaseId: String, withPermissionMode mode: PermissionMode, completion: @escaping (Response<Permission>) -> Void) {}
    
    public func getPermission(forAttachmentsWithId attachmentId: String, onDocument documentId: String, inCollection collectionId: String, inDatabase databaseId: String, withPermissionMode mode: PermissionMode, completion: @escaping (Response<Permission>) -> Void) {}
    
    public func getPermission(forStoredProcedureWithId storedProcedureId: String, inCollection collectionId: String, inDatabase databaseId: String, withPermissionMode mode: PermissionMode, completion: @escaping (Response<Permission>) -> Void) {}
    
    public func getPermission(forUserDefinedFunctionWithId functionId: String, inCollection collectionId: String, inDatabase databaseId: String, withPermissionMode mode: PermissionMode, completion: @escaping (Response<Permission>) -> Void) {}
    
    public func getPermission(forTriggerWithId triggerId: String, inCollection collectionId: String, inDatabase databaseId: String, withPermissionMode mode: PermissionMode, completion: @escaping (Response<Permission>) -> Void) {}

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
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {

        var getResponse:    Response<DictionaryDocument>?
        var listResponse:   Response<Resources<DictionaryDocument>>?
        var createResponse: Response<DictionaryDocument>?
        var deleteResponse: Response<Data>?
        
        AzureData.get(collectionWithId: "MyCollectionFour", inDatabase: "MyDatabaseFour") { r in
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
