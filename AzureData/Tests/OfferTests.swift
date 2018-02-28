//
//  OfferTests.swift
//  AzureDataTests
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureData

class OfferTests: AzureDataTests {
    
    override func setUp() {
        resourceType = .offer
        super.setUp()
    }
    
    override func tearDown() { super.tearDown() }

    
    func testOfferCrud() {
        
        var listResponse:       ListResponse<Offer>?
        var getResponse:        Response<Offer>?

        
        // List
        AzureData.offers { r in
            listResponse = r
            self.listExpectation.fulfill()
        }
        
        wait(for: [listExpectation], timeout: timeout)
        
        XCTAssertNotNil(listResponse?.resource)
        
        
        // Get
        if let offer = listResponse?.resource?.items.first {

            AzureData.get(offerWithId: offer.resourceId) { r in
                getResponse = r
                self.getExpectation.fulfill()
            }
            
            wait(for: [getExpectation], timeout: timeout)
        }
        
        XCTAssertNotNil(getResponse?.resource)
        
        
        // Refresh
//        if getResponse?.result.isSuccess ?? false {
//
//            AzureData.refresh(getResponse!.resource!) { r in
//                refreshResponse = r
//                self.refreshExpectation.fulfill()
//            }
//
//            wait(for: [refreshExpectation], timeout: timeout)
//        }
//
//        XCTAssertNotNil(refreshResponse?.resource)
    }
}
