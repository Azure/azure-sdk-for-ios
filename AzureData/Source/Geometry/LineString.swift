//
//  LineString.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import CoreLocation

// Represents a GeoJSON LinearString
public struct LineString: Geometry {

    /// The set of points of the `LineString`.
    public let points: [Point]

    public init(points: [Point]) throws {
        guard points.count >= 2 else {
            throw GeometryError.invalidGeometry("a line string should have at least 2 points")
        }

        self.points = points
    }

    public var description: String {
        return "{'type': 'LineString', 'coordinates':"
            + "[" + points.map { "[\($0.coordinate.longitude), \($0.coordinate.latitude)]" }.joined(separator: ",") + "]"
            + "}"
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

        public func build() throws -> LineString {
            return try LineString(points: points)
        }
    }

    // MARK: - Codable

    private typealias CodingKeys = GeometryCodingKeys

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        let coordinates = try container.decode([[Double]].self, forKey: .coordinates)

        guard type == "LineString" else {
            throw DecodingError.typeMismatch(LineString.self, DecodingError.Context(codingPath: [CodingKeys.type], debugDescription: "expecting a GeoJSON feature of type `LinearString` but found `\(type)` instead"))
        }

        guard coordinates.count >= 2 else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [CodingKeys.coordinates], debugDescription: "the `coordinates` array should contain at least 2 values"))
        }

        for coordinate in coordinates {
            if coordinate.count < 2 {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [CodingKeys.coordinates], debugDescription: "each sub-array of the `coordinates` array should contain at least 2 values"))
            }
        }

        self.points = coordinates.map { coordinate in Point(latitude: coordinate[1], longitude: coordinate[0]) }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode("LineString", forKey: .type)
        try container.encode(points.map { [$0.coordinate.longitude, $0.coordinate.latitude] }, forKey: .coordinates)
    }
}

// MARK: - Equatable

extension LineString: Equatable {
    public static func == (lhs: LineString, rhs: LineString) -> Bool {
        return lhs.points == rhs.points
    }
}

// MARK: - ExpressibleByArrayLiteral

extension LineString: ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = Point

    public init(arrayLiteral elements: Point...) {
        guard elements.count >= 2 else {
            fatalError("an array literal representing a `LinearString` should have at least 2 `Point`s")
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
