//
//  LineStringTests.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureData
@testable import AzureCore

class LineStringTests: XCTestCase {
    func testEncode() throws {
        let lineString = try LineString(
            points: [
                Point(latitude: 34.4, longitude: 42.12),
                Point(latitude: 12.34, longitude: 87.34)
            ]
        )

        let json = try JSONSerialization.jsonObject(with: JSONEncoder().encode(lineString), options: .allowFragments) as! [String: Any]

        XCTAssertEqual(json["type"] as? String, "LineString")
        XCTAssertEqual(json["coordinates"] as? [[Double]], [[42.12, 34.4], [87.34, 12.34]])
    }

    func testDecode() throws {
        let json =
        """
            {
                "type": "LineString",
                "coordinates": [[42.12, 34.4], [87.34, 12.34]]
            }
        """.data(using: .utf8)!

        let lineString = try LineString(
            points: [
                Point(latitude: 34.4, longitude: 42.12),
                Point(latitude: 12.34, longitude: 87.34)
            ]
        )

        let decoded = try JSONDecoder().decode(LineString.self, from: json)
        XCTAssertEqual(decoded, lineString)
    }

    func testThrowsIfNumberOfPointsIsLessThanTwo() throws {
        XCTAssertThrowsError(try LineString(
            points: [
                Point(latitude: 34.4, longitude: 42.12),
            ]
        ))
    }

    func testExpressibleByArrayLiteral() {
        let lineString: LineString = [Point(latitude: 34.4, longitude: 42.12), Point(latitude: 12.34, longitude: 87.34)]

        XCTAssertEqual(lineString.points.count, 2)
        XCTAssertEqual(lineString.points.first, Point(latitude: 34.4, longitude: 42.12))
        XCTAssertEqual(lineString.points.last, Point(latitude: 12.34, longitude: 87.34))
    }

    func testBuilder() throws {
        let lineString: LineString = try LineString.Builder()
            .add(Point(latitude: 1, longitude: 2))
            .add(Point(latitude: 3, longitude: 3))
            .build()

        XCTAssertEqual(lineString.points.count, 2)
        XCTAssertEqual(lineString.points.first, Point(latitude: 1, longitude: 2))
        XCTAssertEqual(lineString.points.last, Point(latitude: 3, longitude: 3))
    }

    func testDescription() throws {
        let lineString = try LineString.Builder()
            .add(Point(latitude: 1, longitude: 2))
            .add(Point(latitude: 3, longitude: 4))
            .build()

        XCTAssertEqual(lineString.description, "{\'type\': \'LineString\', \'coordinates\':[[2.0, 1.0],[4.0, 3.0]]}")
    }
}
