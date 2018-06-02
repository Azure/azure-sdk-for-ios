//
//  ObjCDocument.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

extension ADDocument {
    var dictionaryDocument: DictionaryDocument {
        let dictionary = self.encode() as NSDictionary
        let dictionaryDocument = DictionaryDocument(data: CodableDictionary(bridgedFromObjectiveC: dictionary))

        dictionaryDocument.id = self.id
        dictionaryDocument.resourceId = self.resourceId
        dictionaryDocument.selfLink = self.selfLink
        dictionaryDocument.etag = self.etag
        dictionaryDocument.timestamp = self.timestamp
        dictionaryDocument.altLink = self.altLink

        return dictionaryDocument
    }
}

extension CodableDictionary: ObjectiveCBridgeable {
    typealias ObjectiveCType = NSDictionary

    func bridgeToObjectiveC() -> NSDictionary {
        let dictionary: NSMutableDictionary = [:]

        self.forEach { (key, value) in
            dictionary.setValue(value.bridgeToObjectiveC(), forKey: key)
        }

        return dictionary
    }

    init(bridgedFromObjectiveC: NSDictionary) {
        self.init(Dictionary(
                uniqueKeysWithValues: bridgedFromObjectiveC.map { (key, value) in
                    return (key as! String, CodableDictionaryValueType(bridgedFromObjectiveC: value as AnyObject).value)
                }
            )
        )
    }
}

extension CodableDictionaryValueType: ObjectiveCBridgeable {
    typealias ObjectiveCType = AnyObject

    func bridgeToObjectiveC() -> AnyObject {
        switch self {
        case .dictionary(let dict):
            return dict.bridgeToObjectiveC()
        case .array(let array):
            return NSArray(array: array.map { $0.bridgeToObjectiveC() })
        case .uuid(let uuid):
            return NSUUID(uuidString: uuid.uuidString)!
        case .bool(let value):
            return value as AnyObject
        case .int(let value):
            return value as AnyObject
        case .double(let value):
            return value as AnyObject
        case .float(let value):
            return value as AnyObject
        case .date(let value):
            return value as AnyObject
        case .string(let value):
            return NSString(string: value)
        case .empty:
            return NSNull()
        }
    }

    init(bridgedFromObjectiveC: AnyObject) {
        switch bridgedFromObjectiveC {
        case let uuid as NSUUID:
            self.init(UUID(uuidString: uuid.uuidString)!)
        case let boolean as Bool:
            self.init(boolean)
        case let integer as Int:
            self.init(integer)
        case let double as Double:
            self.init(double)
        case let float as Float:
            self.init(float)
        case let date as Date:
            self.init(date)
        case let string as NSString:
            self.init(String(string))
        case let dict as NSDictionary:
            self.init(CodableDictionary(bridgedFromObjectiveC: dict))
        case let array as NSArray:
            self.init(array.map { CodableDictionaryValueType(bridgedFromObjectiveC: $0 as AnyObject) })
        case is NSNull:
            self.init(NSNull())
        default:
            self.init(NSNull())
        }
    }
}

extension DictionaryDocument {
    var dataMergedWithSystemKeysAndValues: [AnyHashable: Any] {
        guard let data = self.data else { return [:] }
        let dictionary = data.bridgeToObjectiveC().swifty
        return dictionary.merging(systemKeysAndValues, uniquingKeysWith: { keep, _ in keep })
    }

    private var systemKeysAndValues: [AnyHashable: Any] {
        var dictionary: [AnyHashable: Any] = [
            Document.CodingKeys.id.rawValue: id,
            Document.CodingKeys.resourceId.rawValue: resourceId
        ]

        if let selfLink = selfLink {
            dictionary[Document.CodingKeys.selfLink.rawValue] = selfLink
        }

        if let etag = etag {
            dictionary[Document.CodingKeys.etag.rawValue] = etag
        }

        if let timestamp = timestamp {
            dictionary[Document.CodingKeys.timestamp.rawValue] = timestamp
        }

        return dictionary
    }
}
