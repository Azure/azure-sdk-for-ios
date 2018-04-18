//
//  DocumentTests.swift
//  AzureDataTests
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureData

class DocumentTests: AzureDataTests {
    
    override func setUp() {
        resourceType = .document
        ensureDatabase = true
        ensureCollection = true
        super.setUp()
    }

    override func tearDown() { super.tearDown() }

    
    func testHandleDate() {
        
        let encoder = AzureData.jsonEncoder
        let decoder = AzureData.jsonDecoder
        
        let now = Date()
        
        let doc = DictionaryDocument()
        
        doc["dateTest"] = now
    
        do {
            
            let data = try encoder.encode(doc)
            
            let doc2 = try decoder.decode(DictionaryDocument.self, from: data)
        
            let date = doc2["dateTest"] as! Date
            
            XCTAssertEqual (date.timeIntervalSinceReferenceDate, now.timeIntervalSinceReferenceDate)
            
        } catch {
            
            print(error)
        }
    }
    
    
    func testThatCreateValidatesId() {
        
        AzureData.create(DictionaryDocument(idWith256Chars), inCollection: collectionId, inDatabase: databaseId) { r in
            XCTAssertTrue(r.clientError.isInvalidIdError)
        }
        
        AzureData.create(DictionaryDocument(idWithWhitespace), inCollection: collectionId, inDatabase: databaseId) { r in
            XCTAssertTrue(r.clientError.isInvalidIdError)
        }
    }


    func testDocumentCrud() {
        
        var createResponse:           Response<DictionaryDocument>?
        var createOrReplaceResponse : Response<DictionaryDocument>?
        var listResponse:             Response<Resources<DictionaryDocument>>?
        var getResponse:              Response<DictionaryDocument>?
        var queryResponse:            Response<Resources<DictionaryDocument>>?
        var refreshResponse:          Response<DictionaryDocument>?
        var replaceResponse:          Response<DictionaryDocument>?
        var replaceResponse2:         Response<DictionaryDocument>?
        var deleteResponse:           Response<Data>?

        
        let newDocument = DictionaryDocument(resourceId)
        
        newDocument[customStringKey] = customStringValue
        newDocument[customNumberKey] = customNumberValue
        
        
        AzureData.register(resolver: { $1 } , for: .document)
        
        
        // Create
        AzureData.create(newDocument, inCollection: collectionId, inDatabase: databaseId) { r in
            createResponse = r
            self.createExpectation.fulfill()
        }
        
        wait(for: [createExpectation], timeout: timeout)
        
        XCTAssertNotNil(createResponse?.resource)
        
        if let document = createResponse?.resource {
            XCTAssertNotNil(document[customStringKey] as? String)
            XCTAssertEqual (document[customStringKey] as! String, customStringValue)
            XCTAssertNotNil(document[customNumberKey] as? Int)
            XCTAssertEqual (document[customNumberKey] as! Int, customNumberValue)
        }

        //createResponse?.response?.printHeaders()
        


        // Create or replace
        let createOrReplaceExpectation = self.expectation(description: "should replace an existing document")
        newDocument["new\(customStringKey)"] = "new\(customStringValue)"
        AzureData.createOrReplace(newDocument, inCollection: collectionId, inDatabase: databaseId) { r in
            createOrReplaceResponse = r
            createOrReplaceExpectation.fulfill()
        }

        wait(for: [createOrReplaceExpectation], timeout: timeout)

        XCTAssertNotNil(createOrReplaceResponse?.resource)

        if let document = createOrReplaceResponse?.resource {
            XCTAssertEqual(document.id, createResponse?.resource?.id)
            XCTAssertNotNil(document[customStringKey] as? String)
            XCTAssertEqual (document[customStringKey] as! String, customStringValue)
            XCTAssertNotNil(document[customNumberKey] as? Int)
            XCTAssertEqual (document[customNumberKey] as! Int, customNumberValue)
            XCTAssertNotNil(document["new\(customStringKey)"] as? String)
            XCTAssertEqual(document["new\(customStringKey)"] as! String, "new\(customStringValue)")
        }

        // List
        AzureData.get(documentsAs: DictionaryDocument.self, inCollection: collectionId, inDatabase: databaseId) { r in
            listResponse = r
            self.listExpectation.fulfill()
        }
        
        wait(for: [listExpectation], timeout: timeout)
        
        XCTAssertNotNil(listResponse?.resource)
        //listResponse?.response?.printHeaders()

        

        
        // Query
        let query = Query.select()
            .from(collectionId)
            .where("\(customStringKey)", is: customStringValue)
            .and("\(customNumberKey)", is: customNumberValue)
            .orderBy("_etag", descending: true)
        
        AzureData.query(documentsIn: collectionId, inDatabase: databaseId, with: query) { (r:Response<Resources<DictionaryDocument>>?) in
            queryResponse = r
            self.queryExpectation.fulfill()
        }
        
        wait(for: [queryExpectation], timeout: timeout)
        
        XCTAssertNotNil(queryResponse?.resource?.items.first)
        
        if let document = queryResponse?.resource?.items.first {
            XCTAssertNotNil(document[customStringKey] as? String)
            XCTAssertEqual (document[customStringKey] as! String, customStringValue)
            XCTAssertNotNil(document[customNumberKey] as? Int)
            XCTAssertEqual (document[customNumberKey] as! Int, customNumberValue)
        }
        
        
        

        // Get
        AzureData.get(documentWithId: resourceId, as: DictionaryDocument.self, inCollection: collectionId, inDatabase: databaseId) { r in
            getResponse = r
            self.getExpectation.fulfill()
        }
        
        wait(for: [getExpectation], timeout: timeout)
        
        XCTAssertNotNil(getResponse?.resource)
        
        if let document = getResponse?.resource {
            XCTAssertNotNil(document[customStringKey] as? String)
            XCTAssertEqual (document[customStringKey] as! String, customStringValue)
            XCTAssertNotNil(document[customNumberKey] as? Int)
            XCTAssertEqual (document[customNumberKey] as! Int, customNumberValue)
        }

        //getResponse?.response?.printHeaders()

        
        
        // Replace
        if getResponse?.result.isSuccess ?? false {
            
            AzureData.replace(getResponse!.resource!, inCollection: collectionId, inDatabase: databaseId) { r in
                replaceResponse = r
                self.replaceExpectation.fulfill()
            }
            
            wait(for: [replaceExpectation], timeout: timeout)
            
            
            AzureData.replace(getResponse!.resource!, inCollection: collectionId, inDatabase: databaseId) { r in
                replaceResponse2 = r
                self.replaceExpectation2.fulfill()
            }
            
            wait(for: [replaceExpectation2], timeout: timeout)
        }
        
        XCTAssertNotNil(replaceResponse?.resource)
        XCTAssertNotNil(replaceResponse2?.resource)
        

        

        // Refresh
        if getResponse?.result.isSuccess ?? false {
            
            AzureData.refresh(getResponse!.resource!) { r in
                refreshResponse = r
                self.refreshExpectation.fulfill()
            }
            
            wait(for: [refreshExpectation], timeout: timeout)
        }
        
        XCTAssertNotNil(refreshResponse?.resource)
        
        if let document = refreshResponse?.resource {
            XCTAssertNotNil(document[customStringKey] as? String)
            XCTAssertEqual (document[customStringKey] as! String, customStringValue)
            XCTAssertNotNil(document[customNumberKey] as? Int)
            XCTAssertEqual (document[customNumberKey] as! Int, customNumberValue)
        }
        
        //refreshResponse?.response?.printHeaders()

        
        
        
        // Delete
        //if getResponse?.result.isSuccess ?? false {
            //AzureData.delete(getResponse!.resource!, fromCollection: collectionId, inDatabase: databaseId) { r in
        getResponse?.resource?.delete { r in
            deleteResponse = r
            self.deleteExpectation.fulfill()
        }
        
        wait(for: [deleteExpectation], timeout: timeout)
        //}
        
        XCTAssert(deleteResponse?.result.isSuccess ?? false)
    }


    func testDocumentListPagination() {
        let noMaxItemCountExpectation = self.expectation(description: "request headers should not contain x-ms-max-item-count header")
        let maxItemCountExpectation = self.expectation(description: "request headers should contain x-ms-max-item-count header")
        let lessThan1ErrorExpectation = self.expectation(description: "should return an error if x-ms-max-item-count is less than 1")
        let greaterThan1000ErrorExpectation = self.expectation(description: "should return an error if x-ms-max-item-count is greater than 1000")
        let continuationExpectation = self.expectation(description: "request headers should contain x-ms-continuation when next is called")

        var listResponse: Response<Resources<Document>>?
        var requestHeaders: [String: String] = [:]
        var continuationHeader: String?


        // The request headers should not contain the header 'x-ms-max-item-count' if 'itemsPerPage' is nil
        AzureData.get(documentsAs: Document.self, in: collection!) { r in
            listResponse = r
            noMaxItemCountExpectation.fulfill()
        }

        wait(for: [noMaxItemCountExpectation], timeout: timeout)

        XCTAssertNotNil(listResponse?.request?.allHTTPHeaderFields)

        requestHeaders = listResponse!.request!.allHTTPHeaderFields!

        XCTAssertNil(requestHeaders[.msMaxItemCount])



        // The request headers should contain the header 'x-mas-max-item-count' if 'itemsPerPage' is not nil
        AzureData.get(documentsAs: Document.self, in: collection!, maxPerPage: 14) { r in
            listResponse = r
            maxItemCountExpectation.fulfill()
        }

        wait(for: [maxItemCountExpectation], timeout: timeout)

        XCTAssertNotNil(listResponse?.request?.allHTTPHeaderFields)

        requestHeaders = listResponse!.request!.allHTTPHeaderFields!

        XCTAssertEqual(requestHeaders[.msMaxItemCount], "14")



        // The request should return an error if the value of 'x-ms-max-item-count' is less than 1
        AzureData.get(documentsAs: Document.self, in: collection!, maxPerPage: 0) { r in
            listResponse = r
            lessThan1ErrorExpectation.fulfill()
        }

        wait(for: [lessThan1ErrorExpectation], timeout: timeout)

        XCTAssertNotNil(listResponse)
        XCTAssertTrue(listResponse!.clientError.isInvalidHeaderError(forHeader: .msMaxItemCount, withMessage: "must be between 1 and 1000."))


        // The request should return an error if x-ms-max-item-count is greater than 1000
        AzureData.get(documentsAs: Document.self, in: collection!, maxPerPage: 2000) { r in
            listResponse = r
            greaterThan1000ErrorExpectation.fulfill()
        }

        wait(for: [greaterThan1000ErrorExpectation], timeout: timeout)

        XCTAssertNotNil(listResponse)
        XCTAssertTrue(listResponse!.clientError.isInvalidHeaderError(forHeader: .msMaxItemCount, withMessage: "must be between 1 and 1000."))



        // When next is called, the request headers should contain a valid value for the header 'x-ms-continuation'
        let id = documentId
        collection!.create(Document("\(id)Next")) { _ in
            self.collection!.create(Document("\(id)NextNext")) { _ in
                AzureData.get(documentsAs: Document.self, in: self.collection!, maxPerPage: 1) { r in
                    continuationHeader = r.response?.allHeaderFields[MSHttpHeader.msContinuation.rawValue] as? String

                    XCTAssertTrue(r.hasMoreResults)

                    r.next { r in
                        listResponse = r
                        continuationExpectation.fulfill()
                    }
                }
            }
        }

        wait(for: [continuationExpectation], timeout: timeout)

        XCTAssertNotNil(continuationHeader)
        XCTAssertNotNil(listResponse?.request?.allHTTPHeaderFields)

        requestHeaders = listResponse!.request!.allHTTPHeaderFields!

        XCTAssertEqual(requestHeaders[.msContinuation], continuationHeader)

        AzureData.delete(documentWithId: "\(id)Next", from: collection!) { _ in
            AzureData.delete(documentWithId: "\(id)NextNext", from: self.collection!) { _ in }
        }
    }
}
