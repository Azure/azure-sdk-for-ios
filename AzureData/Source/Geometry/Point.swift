//
//  Point.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import CoreLocation

/// Represents a Point geometry.
public struct Point {
    /// The latitude and longitude of this `Point`.
    let coordinate: CLLocationCoordinate2D

    public init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}

extension Point: Equatable {
    public static func == (lhs: Point, rhs: Point) -> Bool {
        return lhs.coordinate.latitude == rhs.coordinate.latitude
            && lhs.coordinate.longitude == rhs.coordinate.longitude
    }
}

extension Point: ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = CLLocationDegrees

    public init(arrayLiteral elements: CLLocationDegrees...) {
        guard elements.count >= 2 else {
            fatalError("an array literal representing a `Point` should have at least 2 elements")
        }

        self.init(coordinate: CLLocationCoordinate2D(latitude: elements[1], longitude: elements[0]))
    }
}

extension Point: Codable {
    enum CodingKeys: String, CodingKey {
        case type
        case coordinates
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        let coordinates = try container.decode([Double].self, forKey: .coordinates)

        guard type == "Point" else {
            throw DecodingError.typeMismatch(Point.self, DecodingError.Context(codingPath: [CodingKeys.type], debugDescription: "expecting a GeoJSON feature of type `Point` but found \(type) instead"))
        }

        guard coordinates.count >= 2 else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [CodingKeys.coordinates], debugDescription: "the `coordinates` array should contain at least 2 values"))
        }

        self.coordinate = CLLocationCoordinate2D(latitude: coordinates[1], longitude: coordinates[0])
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode("Point", forKey: .type)
        try container.encode([coordinate.longitude, coordinate.latitude], forKey: .coordinates)
    }
}
