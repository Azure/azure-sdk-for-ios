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

class QueryDistanceTests: XCTestCase {
    func testLessThanDistanceQuery() {
        let query = Query().from("Document")
            .where(distanceFrom: "location", to: [42.12, 34.4], isLessThan: 3000)
            .query

        XCTAssertEqual(query, "SELECT * FROM Document WHERE ST_DISTANCE(Document.location, {\'type\': \'Point\', \'coordinates\':[42.12, 34.4]}) < 3000.0")
    }

    func testLessThanOrEqualToDistanceQuery() {
        let query = Query().from("Document")
            .where(distanceFrom: "location", to: [42.12, 34.4], isLessThanOrEqualTo: 3000)
            .query

        XCTAssertEqual(query, "SELECT * FROM Document WHERE ST_DISTANCE(Document.location, {\'type\': \'Point\', \'coordinates\':[42.12, 34.4]}) <= 3000.0")
    }

    func testEqualToDistanceQuery() {
        let query = Query().from("Document")
            .where(distanceFrom: "location", to: [42.12, 34.4], is: 3000)
            .query

        XCTAssertEqual(query, "SELECT * FROM Document WHERE ST_DISTANCE(Document.location, {\'type\': \'Point\', \'coordinates\':[42.12, 34.4]}) = 3000.0")
    }

    func testGreaterThanDistanceQuery() {
        let query = Query().from("Document")
            .where(distanceFrom: "location", to: [42.12, 34.4], isGreaterThan: 3000)
            .query

        XCTAssertEqual(query, "SELECT * FROM Document WHERE ST_DISTANCE(Document.location, {\'type\': \'Point\', \'coordinates\':[42.12, 34.4]}) > 3000.0")
    }

    func testGreatherThanOrEqualToDistanceQuery() {
        let query = Query().from("Document")
            .where(distanceFrom: "location", to: [42.12, 34.4], isGreaterThanOrEqualTo: 3000)
            .query

        XCTAssertEqual(query, "SELECT * FROM Document WHERE ST_DISTANCE(Document.location, {\'type\': \'Point\', \'coordinates\':[42.12, 34.4]}) >= 3000.0")
    }

    func testAndDistanceLessThanQuery() {
        let query = Query().from("Document")
            .where("age", isLessThan: 42)
            .and(distanceFrom: "location", to: [42.12, 34.4], isLessThan: 3000)
            .query

        XCTAssertEqual(query, "SELECT * FROM Document WHERE Document.age < 42 AND ST_DISTANCE(Document.location, {\'type\': \'Point\', \'coordinates\':[42.12, 34.4]}) < 3000.0")
    }

    func testAndDistanceLessThanOrEqualToQuery() {
        let query = Query().from("Document")
            .where("age", isLessThan: 42)
            .and(distanceFrom: "location", to: [42.12, 34.4], isLessThanOrEqualTo: 3000)
            .query

        XCTAssertEqual(query, "SELECT * FROM Document WHERE Document.age < 42 AND ST_DISTANCE(Document.location, {\'type\': \'Point\', \'coordinates\':[42.12, 34.4]}) <= 3000.0")
    }

    func testAndDistanceisEqualToQuery() {
        let query = Query().from("Document")
            .where("age", isLessThan: 42)
            .and(distanceFrom: "location", to: [42.12, 34.4], is: 3000)
            .query

        XCTAssertEqual(query, "SELECT * FROM Document WHERE Document.age < 42 AND ST_DISTANCE(Document.location, {\'type\': \'Point\', \'coordinates\':[42.12, 34.4]}) = 3000.0")
    }

    func testAndDistanceIsGreaterThanQuery() {
        let query = Query().from("Document")
            .where("age", isLessThan: 42)
            .and(distanceFrom: "location", to: [42.12, 34.4], isGreaterThan: 3000)
            .query

        XCTAssertEqual(query, "SELECT * FROM Document WHERE Document.age < 42 AND ST_DISTANCE(Document.location, {\'type\': \'Point\', \'coordinates\':[42.12, 34.4]}) > 3000.0")
    }

    func testAndDistanceIsGreaterThanOrEqualToQuery() {
        let query = Query().from("Document")
            .where("age", isLessThan: 42)
            .and(distanceFrom: "location", to: [42.12, 34.4], isGreaterThanOrEqualTo: 3000)
            .query

        XCTAssertEqual(query, "SELECT * FROM Document WHERE Document.age < 42 AND ST_DISTANCE(Document.location, {\'type\': \'Point\', \'coordinates\':[42.12, 34.4]}) >= 3000.0")
    }
}
