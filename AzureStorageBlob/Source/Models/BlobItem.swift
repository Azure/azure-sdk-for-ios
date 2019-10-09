//
//  BlobItem.swift
//  AzureStorageBlob
//
//  Created by Travis Prescott on 10/8/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import AzureCore
import Foundation

public final class BlobItem: XMLModelProtocol {
    public let name: String
    public let deleted: Bool?
    public let snapshot: Date?
    public let metadata: [String: String]?
    public let properties: BlobProperties

    public init(name: String,
                deleted: Bool? = nil,
                snapshot: Date? = nil,
                metadata: [String: String]? = nil,
                properties: BlobProperties? = nil) {
        self.name = name
        self.deleted = deleted
        self.snapshot = snapshot
        self.metadata = metadata
        self.properties = properties ?? BlobProperties()
    }

    public static func xmlMap() -> XMLMap {
        return XMLMap([
            "Name": XMLMetadata(jsonName: "name"),
            "Deleted": XMLMetadata(jsonName: "deleted"),
            "Snapshot": XMLMetadata(jsonName: "snapshot"),
            "Metadata": XMLMetadata(jsonName: "metadata", jsonType: .anyObject),
            "Properties": XMLMetadata(jsonName: "properties", jsonType: .object(BlobProperties.self)),
        ])
    }
}

extension BlobItem: Codable {
    public convenience init(from decoder: Decoder) throws {
        let root = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            name: try root.decode(String.self, forKey: .name),
            deleted: try root.decodeBoolIfPresent(forKey: .deleted),
            snapshot: try root.decodeIfPresent(Date.self, forKey: .snapshot),
            metadata: try root.decodeIfPresent([String: String].self, forKey: .metadata),
            properties: try root.decodeIfPresent(BlobProperties.self, forKey: .properties)
        )
    }
}
