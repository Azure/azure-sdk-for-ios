//
//  Geometry.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

public protocol Geometry: Codable {
    var description: String { get }
}

internal enum GeometryCodingKeys: String, CodingKey {
    case type
    case coordinates
}
