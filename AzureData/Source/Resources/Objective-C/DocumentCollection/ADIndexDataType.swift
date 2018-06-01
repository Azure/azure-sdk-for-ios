//
//  ADIndexDataType.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

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
