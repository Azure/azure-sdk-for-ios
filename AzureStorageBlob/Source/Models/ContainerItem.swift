//
//  ContainerItem.swift
//  AzureStorageBlob
//
//  Created by Travis Prescott on 9/27/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import AzureCore
import Foundation

// MARK: - Model

public final class ContainerItem: Codable, XMLModelProtocol {
    public let name: String
    public let properties: ContainerProperties?

    public init(name: String,
                properties: ContainerProperties? = nil) {
        self.name = name
        self.properties = properties
    }

    public static func xmlMap() -> XMLMap {
        return XMLMap([
            "Name": XMLMetadata(jsonName: "name"),
            "Properties": XMLMetadata(jsonName: "properties", jsonType: .object(ContainerProperties.self)),
        ])
    }
}
