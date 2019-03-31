//
//  Polygon.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import CoreLocation

/// Represents a GeoJSON Polygon.
/// A polygon is represented by the set of rings. Each ring is closed line.
/// The first ring defines the external ring. All subsequent rings define "holes" in the external ring.
public struct Polygon: Geometry {

    /// The set of rings of the `Polygon`.
    public let rings: [Ring]

    /// Creates a new polygon with a single external ring.
    public init(points: [Point]) throws {
        self.rings = try [Ring(points: points)]
    }

    /// Creates a new polygon with the specified `rings`.
    /// The first ring defines the external ring. All subsequent
    /// rings define holes in the external ring.
    public init(rings: [Ring]) throws {
        guard !rings.isEmpty else {
            throw GeometryError.invalidGeometry("a polygon should have at least one ring")
        }

        self.rings = rings
    }

    public var description: String {
        return "{'type': 'Polygon', 'coordinates':"
            + "[" + rings.map { $0.description }.joined(separator: ",") + "]"
            + "}"
    }

    // MARK: - Builders

    /// Builds a polygon from a single ring.
    public typealias SimpleBuilder = Ring.Builder

    /// Builds a polygon from a set of rings.
    public class Builder {
        private var rings: [Ring] = []

        public init() {
            self.rings = []
        }

        public func add(_ newRing: Ring) -> Builder {
            rings.append(newRing)
            return self
        }

        public func add(_ newRings: [Ring]) -> Builder {
            rings.append(contentsOf: newRings)
            return self
        }

        public func build() throws -> Polygon {
            return try Polygon(rings: rings)
        }
    }

    // MARK: - Ring

    /// Represents a GeoJSON LinearRing.
    /// A ring is closed line with 4 or more points. The first and last points
    /// are equivalent.
    public struct Ring {
        public let points: [Point]

        public init(points: [Point]) throws {
            guard points.count >= 4 else {
                throw GeometryError.invalidGeometry("a polygon's ring should have at least 4 points")
            }

            guard points.last == points.first else {
                throw GeometryError.invalidGeometry("a polygon's ring first and last points should be equivalent")
            }

            self.points = points
        }

        public var description: String {
            return "[" + points.map { "[\($0.coordinate.longitude), \($0.coordinate.latitude)]" }.joined(separator: ",") + "]"
        }

        // MARK: - Builder

        public class Builder {
            private var points: [Point] = []

            public init() {
                self.points = []
            }

            public func add(_ newPoint: Point) -> Builder {
                points.append(newPoint)
                return self
            }

            public func add(_ newPoints: [Point]) -> Builder {
                points.append(contentsOf: newPoints)
                return self
            }

            public func close() -> Builder {
                if let first = points.first, points.last != first {
                    points.append(points[0])
                }

                return self
            }

            public func build() throws -> Ring {
                return try Ring(points: points)
            }

            public func build() throws -> Polygon {
                return try Polygon(points: points)
            }
        }
    }

    // MARK: - Codable

    private typealias CodingKeys = GeometryCodingKeys

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        let coordinates = try container.decode([[[Double]]].self, forKey: .coordinates)

        guard type == "Polygon" else {
            throw DecodingError.typeMismatch(LineString.self, DecodingError.Context(codingPath: [CodingKeys.type], debugDescription: "expecting a GeoJSON feature of type `Polygon` but found `\(type)` instead"))
        }

        var rings: [Ring] = []

        for ring in coordinates {
            guard ring.count >= 4 else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [CodingKeys.coordinates], debugDescription: "a sub-array representing a linear ring should contain at least 4 values"))

            }

            var points: [Point] = []

            for point in ring {
                guard point.count >= 2 else {
                    throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [CodingKeys.coordinates], debugDescription: "a sub-array representing a point should contain at least 2 values"))
                }

                points.append(Point(latitude: point[1], longitude: point[0]))
            }

            guard points.last == points.first else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [CodingKeys.coordinates], debugDescription: "a linear ring's first and last points should be equivalent"))
            }

            try rings.append(Ring(points: points))
        }

        self.rings = rings
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode("Polygon", forKey: .type)
        try container.encode(rings.map { $0.points.map { [$0.coordinate.longitude, $0.coordinate.latitude] } }, forKey: .coordinates)
    }
}

// MARK: - Equatable

extension Polygon.Ring: Equatable {
    public static func == (lhs: Polygon.Ring, rhs: Polygon.Ring) -> Bool {
        return lhs.points == rhs.points
    }
}

extension Polygon: Equatable {
    public static func == (lhs: Polygon, rhs: Polygon) -> Bool {
        return lhs.rings == rhs.rings
    }
}

// MARK: - ExpressibleByArrayLiteral

extension Polygon.Ring: ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = Point

    public init(arrayLiteral elements: Point...) {
        guard elements.count >= 4 else {
            fatalError("an array literal representing a `Polygon.Ring` should have at least 4 `Point`s")
        }

        do {
            try self.init(points: elements)
        } catch {
            if let geometryError = error as? GeometryError {
                if case .invalidGeometry(let message) = geometryError {
                    fatalError(message)
                }
            }

            fatalError()
        }
    }
}

extension Polygon: ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = Polygon.Ring

    public init(arrayLiteral elements: Ring ...) {
        guard !elements.isEmpty else {
            fatalError("an array literal representing a `Polygon` should have at least one element")
        }

        do {
            try self.init(rings: elements)
        } catch {
            if let geometryError = error as? GeometryError {
                if case .invalidGeometry(let message) = geometryError {
                    fatalError(message)
                }
            }

            fatalError()
        }
    }
}
