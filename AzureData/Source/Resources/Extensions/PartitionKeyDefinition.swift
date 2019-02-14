//
//  PartitionKeyDefinition.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

extension DocumentCollection.PartitionKeyDefinition: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: String...) {
        self.init(paths: elements)
    }
}

extension DocumentCollection.PartitionKeyDefinition: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(paths: [value])
    }
}
