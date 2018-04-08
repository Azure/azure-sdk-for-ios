//
//  ResponseMetadataTests.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureData
@testable import AzureCore

class ResponseMetadataTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testResponseMetadataIsCorrectlyFromHTTPURLResponse() {
        guard let response = HTTPURLResponse(
            url: URL(string: "https://ms.portal.azure.com")!,
            statusCode: 200,
            httpVersion: "1.1",
            headerFields: [
                "Content-Type": "application/json",
                "etag": "00003200-0000-0000-0000-56f9e84d0000",
                "x-ms-continuation": "-RID:K0JYAKIH9QADAAAAAAAAAA==#RT:1#TRC:2",
                "x-ms-item-count": "10",
                "x-ms-resource-quota": "collections=5000;functions=25;storedProcedures=100;triggers=25;documentsCount=-1;documentSize=10240;documentsSize=10485760;collectionSize=10485760;",
                "x-ms-resource-usage": "collections=13;functions=5;storedProcedures=10;triggers=2;documentsCount=0;documentSize=0;documentsSize=1;collectionSize=1;",
                "x-ms-schemaversion": "1.1",
                "x-ms-alt-content-path": "dbs/testdb/colls/testcoll",
                "x-ms-request-charge": "12.38",
                "x-ms-serviceversion": "version=1.6.52.5",
                "x-ms-activity-id": "856acd38-320d-47df-ab6f-9761bb987668",
                "x-ms-session-token": "0:603",
                "x-ms-retry-after-ms": "5000",
                "Date": "Tue, 29 Mar 2016 02:28:30 GMT"
            ]
        ) else {
                return
        }

        let metadata = ResponseMetadata(for: response)

        XCTAssertEqual(metadata.activityId, "856acd38-320d-47df-ab6f-9761bb987668")
        XCTAssertEqual(metadata.alternateContentPath, "dbs/testdb/colls/testcoll")
        XCTAssertEqual(metadata.contentType, "application/json")
        XCTAssertEqual(metadata.continuation, "-RID:K0JYAKIH9QADAAAAAAAAAA==#RT:1#TRC:2")
        XCTAssertNotNil(metadata.date)
        XCTAssertEqual(DateFormat.getRFC1123Formatter().string(from: metadata.date!), "Tue, 29 Mar 2016 02:28:30 GMT")
        XCTAssertEqual(metadata.etag, "00003200-0000-0000-0000-56f9e84d0000")
        XCTAssertEqual(metadata.itemCount, 10)
        XCTAssertNotNil(metadata.requestCharge)
        XCTAssertEqual(metadata.requestCharge!, 12.38, accuracy: 0.000000001)
        XCTAssertEqual(metadata.schemaVersion, "1.1")
        XCTAssertEqual(metadata.serviceVersion, "1.6.52.5")
        XCTAssertEqual(metadata.sessionToken, "0:603")

        XCTAssertNotNil(metadata.resourceQuota)
        let quota = metadata.resourceQuota!

        XCTAssertEqual(quota.collections, 5000)
        XCTAssertEqual(quota.functions, 25)
        XCTAssertEqual(quota.storedProcedures, 100)
        XCTAssertEqual(quota.triggers, 25)
        XCTAssertEqual(quota.documents, -1)
        XCTAssertEqual(quota.documentSize, 10240)
        XCTAssertEqual(quota.documentsSize, 10485760)
        XCTAssertEqual(quota.collectionSize, 10485760)

        XCTAssertNotNil(metadata.resourceUsage)
        let usage = metadata.resourceUsage!

        XCTAssertEqual(usage.collections, 13)
        XCTAssertEqual(usage.functions, 5)
        XCTAssertEqual(usage.storedProcedures, 10)
        XCTAssertEqual(usage.triggers, 2)
        XCTAssertEqual(usage.documents, 0)
        XCTAssertEqual(usage.documentSize, 0)
        XCTAssertEqual(usage.documentsSize, 1)
        XCTAssertEqual(usage.collectionSize, 1)

        XCTAssertNotNil(metadata.retryAfter)
        XCTAssertEqual(metadata.retryAfter!, 5, accuracy: 0.000000001)
    }
}
