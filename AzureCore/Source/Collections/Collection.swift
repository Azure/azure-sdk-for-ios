//
//  Collection.swift
//  AzureCore
//
//  Created by Travis Prescott on 9/17/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

// MARK: - Swift Collection<Element>

public struct Collection<T: Codable>: Iterable, Codable {

    public typealias Element = T
    private let items: [T]
    private var iteratorIndex: Int = 0

    public var count: Int {
        return items.count
    }

    public var underestimatedCount: Int {
        return count
    }

    private enum CodingKeys: String, CodingKey {
        case items
    }

    mutating public func next() -> T? {
        guard iteratorIndex < items.count else { return nil }
        let item = items[iteratorIndex]
        iteratorIndex += 1
        return item
    }
}

// MARK: - Collection: ObjectiveCBridgeable

//extension Collection: ObjectiveCBridgeable where T: ObjectiveCBridgeable {
//
//    public typealias ObjectiveCType = AZCCollection
//
//    public func bridgeToObjectiveC() -> AZCCollection {
//        return AZCCollection(items: items as [AnyObject])
//    }
//
//    public init(bridgedFromObjectiveC: ObjectiveCType) {
//        self.items = bridgedFromObjectiveC.items.compactMap { $0 as? T }
//    }
//}

// MARK: - ObjC AZCCollection

//@objc(AZCoreCollection)
//public class AZCCollection: NSObject {
//
//    @objc public var items: [AnyObject] { return wrapped.items }
//
//    private var wrapped: Collection<AnyObject>
//
//    @objc public init(items: [AnyObject]) {
//        self.wrapped = Collection<AnyObject>(items: items)
//    }
//
//    internal init(_ collection: Collection<AnyObject>) {
//        self.wrapped = collection
//    }
//
//    internal init<T: Any>(erasingTypeOf: Collection<T>) {
//        self.wrapped = erasingTypeOf.map { $0 as [AnyObject] }
//    }
//}
