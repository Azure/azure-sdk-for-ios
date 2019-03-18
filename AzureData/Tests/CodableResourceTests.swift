//
//  CodableResourceTests.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureData

class CodableResourceTests: XCTestCase {
    
    let jsonEncoder: JSONEncoder = {
        let encoder = AzureData.jsonEncoder
        encoder.outputFormatting = .prettyPrinted
        return encoder
    }()

    let jsonDecoder: JSONDecoder = {
        let decoder = AzureData.jsonDecoder
        return decoder
    }()

    let collectionJSON =
        """
            {
                "id":"CodableResourceTestsCollections",
                "_rid":"TC1AAMDvwgB4AAAAAAAAAA==",
                "customNumberKey":86,
                "customStringKey":"customStringValue",
                "customBoolKey":true,
                "_self":"dbs/TC1AAA==/colls/TC1AAMDvwgA=",
                "_etag":"\\\"88005b65-0000-0000-0000-5a0dfabb0000\\\"",
                "_ts":1510865595
            }
        """.data(using: .utf8)!

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }


    func testCollectionDecode() {
    
        var collection: DocumentCollection?
    
        collection = try? jsonDecoder.decode(DocumentCollection.self, from: collectionJSON)
    
        XCTAssertNotNil(collection)
    
    }
}
