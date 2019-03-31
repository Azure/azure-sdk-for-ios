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
    func testEncode() throws {
        let point = Point(latitude: 1, longitude: 2)
        let json = try JSONSerialization.jsonObject(with: JSONEncoder().encode(point), options: .allowFragments) as! [String: Any]

        XCTAssertEqual(json["type"] as? String, "Point")
        XCTAssertEqual(json["coordinates"] as? [Double], [2.0, 1.0])
    }

    func testDecode() throws {
        let json =
        """
            {
                "type": "Point",
                "coordinates": [1, 2]
            }
        """.data(using: .utf8)!

        let point = try JSONDecoder().decode(Point.self, from: json)
        XCTAssertEqual(point, Point(latitude: 2, longitude: 1))
    }

    func testExpressibleByArrayLiteral() {
        let point: Point = [1, 2]

        XCTAssertEqual(point.coordinate.latitude, 2)
        XCTAssertEqual(point.coordinate.longitude, 1)
    }

    func testDescription() {
        let point = Point(latitude: 1, longitude: 2)
        XCTAssertEqual(point.description, "{\'type\': \'Point\', \'coordinates\': [2.0, 1.0]}")
    }
}
