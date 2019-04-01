//
//  WithinTests.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureData
@testable import AzureCore

class WithinTests: XCTestCase {
    func testWithinPoint() {
        let query = Query
            .select()
            .from("Document")
            .where("location", isWithin: Point(latitude: 1, longitude: 2))
            .query


        XCTAssertEqual(query, "SELECT * FROM Document WHERE ST_WITHIN(Document.location, {\'type\': \'Point\', \'coordinates\': [2.0, 1.0]}")
    }

    func testWithinLineString() throws {
        let query = try Query
            .select()
            .from("Document")
            .where("location", isWithin: LineString(points: [Point(latitude: 1, longitude: 2), Point(latitude: 3, longitude: 4)]))
            .query

        XCTAssertEqual(query, "SELECT * FROM Document WHERE ST_WITHIN(Document.location, {\'type\': \'LineString\', \'coordinates\':[[2.0, 1.0],[4.0, 3.0]]}")
    }

    func testWithinPolygon() throws {
        let polygon: Polygon = try Polygon.SimpleBuilder()
            .add(Point(latitude: 1, longitude: 2))
            .add(Point(latitude: 3, longitude: 4))
            .add(Point(latitude: 5, longitude: 6))
            .close()
            .build()

        let query = Query
            .select()
            .from("Document")
            .where("location", isWithin: polygon)
            .query

        XCTAssertEqual(query, "SELECT * FROM Document WHERE ST_WITHIN(Document.location, {\'type\': \'Polygon\', \'coordinates\':[[[2.0, 1.0],[4.0, 3.0],[6.0, 5.0],[2.0, 1.0]]]}")
    }

    func testAndWithinPoint() {
        let query = Query
            .select()
            .from("Document")
            .where("age", is: 42)
            .and("location", isWithin: Point(latitude: 1, longitude: 2))
            .query

        XCTAssertEqual(query, "SELECT * FROM Document WHERE Document.age = 42 AND ST_WITHIN(Document.location, {\'type\': \'Point\', \'coordinates\': [2.0, 1.0]})")
    }

    func testAndWithinLineString() throws {
        let query = try Query
            .select()
            .from("Document")
            .where("age", is: 42)
            .and("location", isWithin: LineString(points: [Point(latitude: 1, longitude: 2), Point(latitude: 3, longitude: 4)]))
            .query

        XCTAssertEqual(query, "SELECT * FROM Document WHERE Document.age = 42 AND ST_WITHIN(Document.location, {\'type\': \'LineString\', \'coordinates\':[[2.0, 1.0],[4.0, 3.0]]})")
    }

    func testAndWithinPolygon() throws {
        let polygon: Polygon = try Polygon.SimpleBuilder()
            .add(Point(latitude: 1, longitude: 2))
            .add(Point(latitude: 3, longitude: 4))
            .add(Point(latitude: 5, longitude: 6))
            .close()
            .build()

        let query = Query
            .select()
            .from("Document")
            .where("age", is: 42)
            .and("location", isWithin: polygon)
            .query

        XCTAssertEqual(query, "SELECT * FROM Document WHERE Document.age = 42 AND ST_WITHIN(Document.location, {\'type\': \'Polygon\', \'coordinates\':[[[2.0, 1.0],[4.0, 3.0],[6.0, 5.0],[2.0, 1.0]]]})")
    }
}
