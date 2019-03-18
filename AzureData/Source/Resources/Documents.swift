//
//  Documents.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

public struct Documents<T: Document> {
    public let resourceId: String
    public let count: Int
    public let items: [T]

    internal init(_ resources: Resources<DocumentContainer<T>>) {
        self.resourceId = resources.resourceId
        self.count = resources.count
        self.items = resources.items.map { $0.document }
    }
}
