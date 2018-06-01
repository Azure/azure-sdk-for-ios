//
//  ADResource.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

@objc(ADResource)
public protocol ADResource: ADCodable {
    var id: String { get }

    var resourceId: String { get }

    var selfLink: String? { get }

    var etag: String? { get }

    var timestamp: Date? { get }

    var altLink: String? { get }
}
