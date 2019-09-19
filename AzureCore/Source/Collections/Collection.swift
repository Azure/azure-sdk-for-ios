//
//  Collection.swift
//  AzureCore
//
//  Created by Travis Prescott on 9/17/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

// MARK: - Swift Collection<Element>

public struct Collection<T> {

    public var items: [T]

    public init(items: [T]) {
        self.items = items
    }
}

extension Collection {
    public func map<U>(_ transform: @escaping ([T]) throws -> [U]) -> Collection<U> {
        // swiftlint:disable force_try
        let transformed = try! transform(items)
        return Collection<U>(items: transformed)
    }
}

// MARK: - Collection: Codable

extension Collection: Codable where T: Codable {}

// MARK: - Collection: ObjectiveCBridgeable

extension Collection: ObjectiveCBridgeable where T: ObjectiveCBridgeable {

    public typealias ObjectiveCType = AZCCollection

    public func bridgeToObjectiveC() -> AZCCollection {
        return AZCCollection(items: items as [AnyObject])
    }
}

// MARK: - ObjC AZCCollection

@objc(AZCoreCollection)
public class AZCCollection: NSObject {

    @objc public var items: [AnyObject] { return wrapped.items }

    private var wrapped: Collection<AnyObject>

    @objc public init(items: [AnyObject]) {
        self.wrapped = Collection<AnyObject>(items: items)
    }

    internal init(_ collection: Collection<AnyObject>) {
        self.wrapped = collection
    }

    internal init<T: Any>(erasingTypeOf: Collection<T>) {
        self.wrapped = erasingTypeOf.map { $0 as [AnyObject] }
    }
}
