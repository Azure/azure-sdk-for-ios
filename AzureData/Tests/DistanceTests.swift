//
//  DistanceTests.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureData
@testable import AzureCore

class DistanceTests: XCTestCase {
    func testLessThanDistanceQuery() {
        let query = Query().from("Document")
            .where(distanceFrom: "location", to: Point(latitude: 1, longitude: 2), isLessThan: 3000)
            .query

        XCTAssertEqual(query, "SELECT * FROM Document WHERE ST_DISTANCE(Document.location, {\'type\': \'Point\', \'coordinates\': [2.0, 1.0]}) < 3000.0")
    }

    func testLessThanOrEqualToDistanceQuery() {
        let query = Query().from("Document")
            .where(distanceFrom: "location", to: Point(latitude: 1, longitude: 2), isLessThanOrEqualTo: 3000)
            .query

        XCTAssertEqual(query, "SELECT * FROM Document WHERE ST_DISTANCE(Document.location, {\'type\': \'Point\', \'coordinates\': [2.0, 1.0]}) <= 3000.0")
    }

    func testEqualToDistanceQuery() {
        let query = Query().from("Document")
            .where(distanceFrom: "location", to: Point(latitude: 1, longitude: 2), is: 3000)
            .query

        XCTAssertEqual(query, "SELECT * FROM Document WHERE ST_DISTANCE(Document.location, {\'type\': \'Point\', \'coordinates\': [2.0, 1.0]}) = 3000.0")
    }

    func testGreaterThanDistanceQuery() {
        let query = Query().from("Document")
            .where(distanceFrom: "location", to: Point(latitude: 1, longitude: 2), isGreaterThan: 3000)
            .query

        XCTAssertEqual(query, "SELECT * FROM Document WHERE ST_DISTANCE(Document.location, {\'type\': \'Point\', \'coordinates\': [2.0, 1.0]}) > 3000.0")
    }

    func testGreatherThanOrEqualToDistanceQuery() {
        let query = Query().from("Document")
            .where(distanceFrom: "location", to: Point(latitude: 1, longitude: 2), isGreaterThanOrEqualTo: 3000)
            .query

        XCTAssertEqual(query, "SELECT * FROM Document WHERE ST_DISTANCE(Document.location, {\'type\': \'Point\', \'coordinates\': [2.0, 1.0]}) >= 3000.0")
    }

    func testAndDistanceLessThanQuery() {
        let query = Query().from("Document")
            .where("age", isLessThan: 42)
            .and(distanceFrom: "location", to: Point(latitude: 1, longitude: 2), isLessThan: 3000)
            .query

        XCTAssertEqual(query, "SELECT * FROM Document WHERE Document.age < 42 AND ST_DISTANCE(Document.location, {\'type\': \'Point\', \'coordinates\': [2.0, 1.0]}) < 3000.0")
    }

    func testAndDistanceLessThanOrEqualToQuery() {
        let query = Query().from("Document")
            .where("age", isLessThan: 42)
            .and(distanceFrom: "location", to: Point(latitude: 1, longitude: 2), isLessThanOrEqualTo: 3000)
            .query

        XCTAssertEqual(query, "SELECT * FROM Document WHERE Document.age < 42 AND ST_DISTANCE(Document.location, {\'type\': \'Point\', \'coordinates\': [2.0, 1.0]}) <= 3000.0")
    }

    func testAndDistanceisEqualToQuery() {
        let query = Query().from("Document")
            .where("age", isLessThan: 42)
            .and(distanceFrom: "location", to: Point(latitude: 1, longitude: 2), is: 3000)
            .query

        XCTAssertEqual(query, "SELECT * FROM Document WHERE Document.age < 42 AND ST_DISTANCE(Document.location, {\'type\': \'Point\', \'coordinates\': [2.0, 1.0]}) = 3000.0")
    }

    func testAndDistanceIsGreaterThanQuery() {
        let query = Query().from("Document")
            .where("age", isLessThan: 42)
            .and(distanceFrom: "location", to: Point(latitude: 1, longitude: 2), isGreaterThan: 3000)
            .query

        XCTAssertEqual(query, "SELECT * FROM Document WHERE Document.age < 42 AND ST_DISTANCE(Document.location, {\'type\': \'Point\', \'coordinates\': [2.0, 1.0]}) > 3000.0")
    }

    func testAndDistanceIsGreaterThanOrEqualToQuery() {
        let query = Query().from("Document")
            .where("age", isLessThan: 42)
            .and(distanceFrom: "location", to: Point(latitude: 1, longitude: 2), isGreaterThanOrEqualTo: 3000)
            .query

        XCTAssertEqual(query, "SELECT * FROM Document WHERE Document.age < 42 AND ST_DISTANCE(Document.location, {\'type\': \'Point\', \'coordinates\': [2.0, 1.0]}) >= 3000.0")
    }
}
