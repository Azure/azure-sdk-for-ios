//
//  PolygonTests.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureData
@testable import AzureCore

class PolygonTests: XCTestCase {
    func testEncodeSimplePolygon() throws {
        let polygon = try Polygon(
            rings: [
                Polygon.Ring(
                    points: [
                        Point(latitude: 1, longitude: 2),
                        Point(latitude: 3, longitude: 4),
                        Point(latitude: 5, longitude: 6),
                        Point(latitude: 1, longitude: 2),
                    ]
                )
            ]
        )

        let json = try JSONSerialization.jsonObject(with: JSONEncoder().encode(polygon), options: .allowFragments) as! [String: Any]

        XCTAssertEqual(json["type"] as? String, "Polygon")
        XCTAssertEqual(json["coordinates"] as? [[[Double]]], [[[2, 1], [4, 3], [6, 5], [2, 1]]])
    }

    func testEncodePolygonWithHole() throws {
        let polygon = try Polygon(
            rings: [
                Polygon.Ring(
                    points: [
                        Point(latitude: 1, longitude: 2),
                        Point(latitude: 3, longitude: 4),
                        Point(latitude: 5, longitude: 6),
                        Point(latitude: 1, longitude: 2),
                    ]
                ),
                Polygon.Ring(
                    points: [
                        Point(latitude: 10, longitude: 11),
                        Point(latitude: 12, longitude: 13),
                        Point(latitude: 14, longitude: 15),
                        Point(latitude: 10, longitude: 11),
                    ]
                )
            ]
        )

        let json = try JSONSerialization.jsonObject(with: JSONEncoder().encode(polygon), options: .allowFragments) as! [String: Any]

        XCTAssertEqual(json["type"] as? String, "Polygon")
        XCTAssertEqual(json["coordinates"] as? [[[Double]]], [[[2, 1], [4, 3], [6, 5], [2, 1]], [[11, 10], [13, 12], [15, 14], [11, 10]]])
    }

    func testEncodePolygonWithMultipleHoles() throws {
        let polygon = try Polygon(
            rings: [
                Polygon.Ring(
                    points: [
                        Point(latitude: 1, longitude: 2),
                        Point(latitude: 3, longitude: 4),
                        Point(latitude: 5, longitude: 6),
                        Point(latitude: 1, longitude: 2),
                        ]
                ),
                Polygon.Ring(
                    points: [
                        Point(latitude: 10, longitude: 11),
                        Point(latitude: 12, longitude: 13),
                        Point(latitude: 14, longitude: 15),
                        Point(latitude: 10, longitude: 11),
                        ]
                ),
                Polygon.Ring(
                    points: [
                        Point(latitude: 16, longitude: 17),
                        Point(latitude: 18, longitude: 19),
                        Point(latitude: 20, longitude: 21),
                        Point(latitude: 16, longitude: 17),
                        ]
                ),
            ]
        )

        let json = try JSONSerialization.jsonObject(with: JSONEncoder().encode(polygon), options: .allowFragments) as! [String: Any]

        XCTAssertEqual(json["type"] as? String, "Polygon")
        XCTAssertEqual(json["coordinates"] as? [[[Double]]], [[[2, 1], [4, 3], [6, 5], [2, 1]], [[11, 10], [13, 12], [15, 14], [11, 10]], [[17, 16], [19, 18], [21, 20], [17, 16]]])
    }

    func testDecodeSimplePolygon() throws {
        let json =
        """
            {
                "type": "Polygon",
                "coordinates": [[[2, 1], [4, 3], [6, 5], [2, 1]]]
            }
        """.data(using: .utf8)!


        let polygon = try Polygon(
            rings: [
                Polygon.Ring(
                    points: [
                        Point(latitude: 1, longitude: 2),
                        Point(latitude: 3, longitude: 4),
                        Point(latitude: 5, longitude: 6),
                        Point(latitude: 1, longitude: 2),
                    ]
                )
            ]
        )

        let decoded = try JSONDecoder().decode(Polygon.self, from: json)
        XCTAssertEqual(decoded, polygon)
    }

    func testDecodePolygonWithHole() throws {
        let json =
        """
            {
                "type": "Polygon",
                "coordinates": [[[2, 1], [4, 3], [6, 5], [2, 1]], [[11, 10], [13, 12], [15, 14], [11, 10]]]
            }
        """.data(using: .utf8)!

        let polygon = try Polygon(
            rings: [
                Polygon.Ring(
                    points: [
                        Point(latitude: 1, longitude: 2),
                        Point(latitude: 3, longitude: 4),
                        Point(latitude: 5, longitude: 6),
                        Point(latitude: 1, longitude: 2),
                    ]
                ),
                Polygon.Ring(
                    points: [
                        Point(latitude: 10, longitude: 11),
                        Point(latitude: 12, longitude: 13),
                        Point(latitude: 14, longitude: 15),
                        Point(latitude: 10, longitude: 11),
                    ]
                ),
            ]
        )

        let decoded = try JSONDecoder().decode(Polygon.self, from: json)
        XCTAssertEqual(decoded, polygon)
    }

    func testDecodePolygonWithMultipleHoles() throws {
        let json =
        """
            {
                "type": "Polygon",
                "coordinates": [[[2, 1], [4, 3], [6, 5], [2, 1]], [[11, 10], [13, 12], [15, 14], [11, 10]], [[17, 16], [19, 18], [21, 20], [17, 16]]]
            }
        """.data(using: .utf8)!

        let polygon = try Polygon(
            rings: [
                Polygon.Ring(
                    points: [
                        Point(latitude: 1, longitude: 2),
                        Point(latitude: 3, longitude: 4),
                        Point(latitude: 5, longitude: 6),
                        Point(latitude: 1, longitude: 2),
                    ]
                ),
                Polygon.Ring(
                    points: [
                        Point(latitude: 10, longitude: 11),
                        Point(latitude: 12, longitude: 13),
                        Point(latitude: 14, longitude: 15),
                        Point(latitude: 10, longitude: 11),
                    ]
                ),
                Polygon.Ring(
                    points: [
                        Point(latitude: 16, longitude: 17),
                        Point(latitude: 18, longitude: 19),
                        Point(latitude: 20, longitude: 21),
                        Point(latitude: 16, longitude: 17),
                    ]
                ),
            ]
        )

        let decoded = try JSONDecoder().decode(Polygon.self, from: json)
        XCTAssertEqual(decoded, polygon)
    }

    func testExpressibleByArrayLiteral() {
        let externalRing: Polygon.Ring =
            [
                Point(latitude: 1, longitude: 2),
                Point(latitude: 3, longitude: 4),
                Point(latitude: 5, longitude: 6),
                Point(latitude: 1, longitude: 2),
            ]

        let hole: Polygon.Ring =
            [
                Point(latitude: 10, longitude: 11),
                Point(latitude: 12, longitude: 13),
                Point(latitude: 14, longitude: 15),
                Point(latitude: 10, longitude: 11),
            ]

        let polygon: Polygon = [externalRing, hole]

        XCTAssertEqual(polygon.rings.count, 2)
        XCTAssertEqual(polygon.rings.first, externalRing)
        XCTAssertEqual(polygon.rings.last, hole)
    }

    func testThrowsIfNoRingIsProvided() throws {
        XCTAssertThrowsError(try Polygon(rings: []))
    }

    func testThrowsIfARingWithLessThan4PointsIsProvided() throws {
        XCTAssertThrowsError(try Polygon(rings: [
            Polygon.Ring(points: [
                Point(latitude: 1, longitude: 2),
                Point(latitude: 3, longitude: 4),
                Point(latitude: 1, longitude: 2),
            ])
        ]))
    }

    func testThrowsIfFirstAndLastPointsOfARingAreNotEquivalent() throws {
        XCTAssertThrowsError(try Polygon(rings: [
            Polygon.Ring(points: [
                Point(latitude: 1, longitude: 2),
                Point(latitude: 3, longitude: 4),
                Point(latitude: 5, longitude: 6),
                Point(latitude: 7, longitude: 8),
            ])
        ]))
    }

    func testSimpleBuilder() throws {
        let polygon: Polygon = try Polygon.SimpleBuilder()
            .add(Point(latitude: 1, longitude: 2))
            .add(Point(latitude: 3, longitude: 4))
            .add(Point(latitude: 5, longitude: 6))
            .close()
            .build()

        XCTAssertEqual(polygon.rings.count, 1)
        try XCTAssertEqual(polygon.rings.first, Polygon.Ring(points: [
            Point(latitude: 1, longitude: 2),
            Point(latitude: 3, longitude: 4),
            Point(latitude: 5, longitude: 6),
            Point(latitude: 1, longitude: 2),
        ]))
    }

    func testComplexBuilder() throws {
        let polygon: Polygon = try Polygon.Builder()
            .add(Polygon.Ring(points: [
                Point(latitude: 1, longitude: 2),
                Point(latitude: 3, longitude: 4),
                Point(latitude: 5, longitude: 6),
                Point(latitude: 1, longitude: 2),
            ]))
            .add(Polygon.Ring(points: [
                Point(latitude: 7, longitude: 8),
                Point(latitude: 9, longitude: 10),
                Point(latitude: 11, longitude: 12),
                Point(latitude: 7, longitude: 8),
            ]))
            .build()

        XCTAssertEqual(polygon.rings.count, 2)
        try XCTAssertEqual(polygon.rings.first, Polygon.Ring(points: [
            Point(latitude: 1, longitude: 2),
            Point(latitude: 3, longitude: 4),
            Point(latitude: 5, longitude: 6),
            Point(latitude: 1, longitude: 2),
        ]))
        try XCTAssertEqual(polygon.rings.last, Polygon.Ring(points: [
            Point(latitude: 7, longitude: 8),
            Point(latitude: 9, longitude: 10),
            Point(latitude: 11, longitude: 12),
            Point(latitude: 7, longitude: 8),
        ]))
    }

    func testSimplePolygonDescription() throws {
        let polygon: Polygon = try Polygon.SimpleBuilder()
            .add(Point(latitude: 1, longitude: 2))
            .add(Point(latitude: 3, longitude: 4))
            .add(Point(latitude: 5, longitude: 6))
            .close()
            .build()

        XCTAssertEqual(polygon.description, "{\'type\': \'Polygon\', \'coordinates\':[[[2.0, 1.0],[4.0, 3.0],[6.0, 5.0],[2.0, 1.0]]]}")
    }

    func testPolygonWithHoleDescription() throws {
        let polygon = try Polygon.Builder()
            .add(
                Polygon.Ring.Builder()
                    .add(Point(latitude: 1, longitude: 2))
                    .add(Point(latitude: 3, longitude: 4))
                    .add(Point(latitude: 5, longitude: 6))
                    .close()
                    .build()
            )
            .add(
                Polygon.Ring.Builder()
                    .add(Point(latitude: 7, longitude: 8))
                    .add(Point(latitude: 9, longitude: 10))
                    .add(Point(latitude: 11, longitude: 12))
                    .close()
                    .build()
            )
            .build()

        XCTAssertEqual(polygon.description, "{\'type\': \'Polygon\', \'coordinates\':[[[2.0, 1.0],[4.0, 3.0],[6.0, 5.0],[2.0, 1.0]],[[8.0, 7.0],[10.0, 9.0],[12.0, 11.0],[8.0, 7.0]]]}")
    }

    func testPolygonWithMultipleHolesDescription() throws {
        let polygon = try Polygon.Builder()
            .add(
                Polygon.Ring.Builder()
                    .add(Point(latitude: 1, longitude: 2))
                    .add(Point(latitude: 3, longitude: 4))
                    .add(Point(latitude: 5, longitude: 6))
                    .close()
                    .build()
            )
            .add(
                Polygon.Ring.Builder()
                    .add(Point(latitude: 7, longitude: 8))
                    .add(Point(latitude: 9, longitude: 10))
                    .add(Point(latitude: 11, longitude: 12))
                    .close()
                    .build()
            )
            .add(
                Polygon.Ring.Builder()
                    .add(Point(latitude: 13, longitude: 14))
                    .add(Point(latitude: 15, longitude: 16))
                    .add(Point(latitude: 17, longitude: 18))
                    .close()
                    .build()
            )
            .build()

        XCTAssertEqual(polygon.description, "{\'type\': \'Polygon\', \'coordinates\':[[[2.0, 1.0],[4.0, 3.0],[6.0, 5.0],[2.0, 1.0]],[[8.0, 7.0],[10.0, 9.0],[12.0, 11.0],[8.0, 7.0]],[[14.0, 13.0],[16.0, 15.0],[18.0, 17.0],[14.0, 13.0]]]}")
    }
}
