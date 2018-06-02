//
//  ADIndexDataType.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Defines the target data type of an index path specification in the Azure Cosmos DB service.
///
/// - ADIndexDataTypeLineString:   Represent a line string data type.
/// - ADIndexDataTypeNumber:       Represent a numeric data type.
/// - ADIndexDataTypePoint:        Represent a point data type.
/// - ADIndexDataTypePolygon:      Represent a polygon data type.
/// - ADIndexDataTypeString:       Represent a string data type.
@objc(ADIndexDataType)
public enum ADIndexDataType: Int {
    @objc(ADIndexDataTypeLineString)
    case lineString

    @objc(ADIndexDataTypeNumber)
    case number

    @objc(ADIndexDataTypePoint)
    case point

    @objc(ADIndexDataTypePolygon)
    case polygon

    @objc(ADIndexDataTypeString)
    case string
}

// MARK: - Objective-C Bridging

extension DocumentCollection.IndexingPolicy.IncludedPath.Index.DataType {
    var bridgedToObjectiveC: ADIndexDataType {
        switch self {
        case .lineString: return .lineString
        case .number:     return .number
        case .point:      return .point
        case .polygon:    return .polygon
        case .string:     return .string
        }
    }

    init(bridgedFromObjectiveC: ADIndexDataType) {
        switch bridgedFromObjectiveC {
        case .lineString: self = .lineString
        case .number:     self = .number
        case .point:      self = .point
        case .polygon:    self = .polygon
        case .string:     self = .string
        }
    }
}
