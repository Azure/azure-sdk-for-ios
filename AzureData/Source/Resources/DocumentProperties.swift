//
//  DocumentDictionary.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

public final class DocumentProperties: Document {
    public static let partitionKey: PartitionKey? = nil

    private let contents: CodableDictionary
    private lazy var dictionary: [String: Any] = contents.dictionary.compactMapValues { $0 }

    public var id: String {
        return contents["id"] as? String ?? ""
    }

    internal init(id: String) {
        self.contents = [:]
    }

    subscript(index: String) -> Any? {
        return dictionary[index]
    }

    public init(from decoder: Decoder) throws {
        self.contents = try CodableDictionary(from: decoder)
    }

    public func encode(to encoder: Encoder) throws {
        try self.contents.encode(to: encoder)
    }
}
