//
//  ADExcludedPath.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

@objc(ADExcludedPath)
public class ADExcludedPath: NSObject, ADCodable {
    private enum CodingKeys: String, CodingKey {
        case path
    }

    @objc
    public let path: String?

    @objc
    public init(path: String?) {
        self.path = path
    }

    public required init?(from dictionary: NSDictionary) {
        self.path = dictionary[CodingKeys.path] as? String
    }

    public func encode() -> NSDictionary {
        let dictionary = NSMutableDictionary()
        dictionary[CodingKeys.path] = path

        return dictionary
    }
}

extension DocumentCollection.IndexingPolicy.ExcludedPath: ObjectiveCBridgeable {
    typealias ObjectiveCType = ADExcludedPath

    func bridgeToObjectiveC() -> ADExcludedPath {
        return ADExcludedPath(path: self.path)
    }

    init?(bridgedFromObjectiveC: ADExcludedPath) {
        self.init(path: bridgedFromObjectiveC.path)
    }
}
