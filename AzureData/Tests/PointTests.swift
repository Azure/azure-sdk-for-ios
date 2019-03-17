//
//  PointTests.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureData
@testable import AzureCore

class PointTests: XCTestCase {
    func testExpressibleByArrayLiteral() {
        let point: Point = [42.12, 34.4]

        XCTAssertEqual(point.coordinate.latitude, 34.4)
        XCTAssertEqual(point.coordinate.longitude, 42.12)
    }

    func testEncode() throws {
        let point: Point = [42.12, 34.4]
        let json = try JSONSerialization.jsonObject(with: JSONEncoder().encode(point), options: .allowFragments) as! [String: Any]

        XCTAssertEqual(json["type"] as? String, "Point")
        XCTAssertEqual(json["coordinates"] as? [Double], [42.12, 34.4])
    }

    func testDecode() throws {
        let json =
        """
            {
                "type": "Point",
                "coordinates": [42.12, 34.4]
            }
        """.data(using: .utf8)!

        let point = try JSONDecoder().decode(Point.self, from: json)
        XCTAssertEqual(point, [42.12, 34.4])
    }

    func testLessThanDistanceQuery() {
        let query = Query().from("Document")
            .where("location", to: [42.12, 34.4], isLessThan: 3000)
            .query

        XCTAssertEqual(query, "SELECT * FROM Document WHERE ST_DISTANCE(Document.location, {\'type\': \'Point\', \'coordinates\':[42.12, 34.4]}) < 3000.0")
    }

    func testLessThanOrEqualToDistanceQuery() {
        let query = Query().from("Document")
            .where("location", to: [42.12, 34.4], isLessThanOrEqualTo: 3000)
            .query

        XCTAssertEqual(query, "SELECT * FROM Document WHERE ST_DISTANCE(Document.location, {\'type\': \'Point\', \'coordinates\':[42.12, 34.4]}) <= 3000.0")
    }

    func testEqualToDistanceQuery() {
        let query = Query().from("Document")
            .where("location", to: [42.12, 34.4], is: 3000)
            .query

        XCTAssertEqual(query, "SELECT * FROM Document WHERE ST_DISTANCE(Document.location, {\'type\': \'Point\', \'coordinates\':[42.12, 34.4]}) = 3000.0")
    }

    func testGreaterThanDistanceQuery() {
        let query = Query().from("Document")
            .where("location", to: [42.12, 34.4], isGreaterThan: 3000)
            .query

        XCTAssertEqual(query, "SELECT * FROM Document WHERE ST_DISTANCE(Document.location, {\'type\': \'Point\', \'coordinates\':[42.12, 34.4]}) > 3000.0")
    }

    func testGreatherThanOrEqualToDistanceQuery() {
        let query = Query().from("Document")
            .where("location", to: [42.12, 34.4], isGreaterThanOrEqualTo: 3000)
            .query

        XCTAssertEqual(query, "SELECT * FROM Document WHERE ST_DISTANCE(Document.location, {\'type\': \'Point\', \'coordinates\':[42.12, 34.4]}) >= 3000.0")
    }
}
