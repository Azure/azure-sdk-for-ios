//
//  Geometry.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Represents a GeoJSON geometry. A `Geometry`
/// can be a `Point`, a `LineString` or a `Polygon`.
public protocol Geometry: Codable {
    /// The description of the `Geometry` in the GeoJSON format.
    var description: String { get }
}

internal enum GeometryCodingKeys: String, CodingKey {
    case type
    case coordinates
}
