//
//  ADTrigger.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Represents a trigger in the Azure Cosmos DB service.
///
/// - Remark:
///   Azure Cosmos DB supports pre and post triggers written in JavaScript to be executed on creates, updates and deletes.
///   For additional details, refer to the server-side JavaScript API documentation.
@objc(ADTrigger)
public class ADTrigger: NSObject, ADResource, ADSupportsPermissionToken {
    private typealias CodingKeys = Trigger.CodingKeys

    @objc
    public let id: String

    @objc
    public let resourceId: String

    @objc
    public let selfLink: String?

    @objc
    public let etag: String?

    @objc
    public let timestamp: Date?

    @objc
    public let altLink: String?

    /// The body of the trigger for the Azure Cosmos DB service.
    @objc
    public let body: String?

    /// The operation the trigger is associated with for the Azure Cosmos DB service.
    @objc
    public let triggerOperation: ADTriggerOperation

    /// The type of the trigger for the Azure Cosmos DB service.
    @objc
    public let triggerType: ADTriggerType

    /// Specifies the operations on which a trigger should be executed in the Azure Cosmos DB service.
    ///
    /// - ADTriggerOperationAll:      Specifies all operations.
    /// - ADTriggerOperationInsert:   Specifies insert operations only.
    /// - ADTriggerOperationReplace:  Specifies replace operations only.
    /// - ADTriggerOperationDelete:   Specifies delete operations only.
    @objc(ADTriggerOperation)
    public enum ADTriggerOperation: Int {
        @objc(ADTriggerOperationAll)
        case all

        @objc(ADTriggerOperationInsert)
        case insert

        @objc(ADTriggerOperationReplace)
        case replace

        @objc(ADTriggerOperationDelete)
        case delete
    }

    /// Specifies the type of the trigger in the Azure Cosmos DB service.
    ///
    /// - ADTriggerTypePre:  Trigger should be executed after the associated operation(s).
    /// - ADTriggerTypePost: Trigger should be executed before the associated operation(s).
    @objc(ADTriggerType)
    public enum ADTriggerType: Int {
        @objc(ADTriggerTypePre)
        case pre

        @objc(ADTriggerTypePost)
        case post
    }

    @objc
    public convenience init(id: String, body: String, operation: ADTriggerOperation, type: ADTriggerType) {
        self.init(id: id, resourceId: "", selfLink: nil, etag: nil, timestamp: nil, altLink: nil, body: body, operation: operation, type: type)
    }

    // MARK: - ADCodable

    internal init(id: String, resourceId: String, selfLink: String?, etag: String?, timestamp: Date?, altLink: String?, body: String?, operation: ADTriggerOperation, type: ADTriggerType) {
        self.id = id
        self.resourceId = resourceId
        self.selfLink = selfLink
        self.etag = etag
        self.timestamp = timestamp
        self.altLink = altLink
        self.body = body
        self.triggerOperation = operation
        self.triggerType = type
    }

    public required init?(from dictionary: NSDictionary) {
        guard let id = dictionary.value(forKey: Trigger.CodingKeys.id.rawValue) as? String else { return nil }
        guard let resourceId = dictionary.value(forKey: Trigger.CodingKeys.resourceId.rawValue) as? String else { return nil }

        self.id = id
        self.resourceId = resourceId
        self.selfLink = dictionary[CodingKeys.selfLink] as? String
        self.etag = dictionary[CodingKeys.etag] as? String
        self.timestamp = ADDateEncoders.decodeTimestamp(from: dictionary[CodingKeys.timestamp])
        self.altLink = nil
        self.body = dictionary[CodingKeys.body] as? String
        self.triggerOperation = (Trigger.TriggerOperation(rawValue: dictionary[CodingKeys.triggerOperation] as? String ?? "")?.bridgedToObjectiveC) ?? .all
        self.triggerType = (Trigger.TriggerType(rawValue: dictionary[CodingKeys.triggerType] as? String ?? "")?.bridgedToObjectiveC) ?? .pre
    }

    public func encode() -> NSDictionary {
        let dictionary = NSMutableDictionary()

        dictionary[CodingKeys.id] = id
        dictionary[CodingKeys.resourceId] = resourceId
        dictionary[CodingKeys.selfLink] = selfLink
        dictionary[CodingKeys.etag] = etag
        dictionary[CodingKeys.timestamp] = ADDateEncoders.encodeTimestamp(timestamp)
        dictionary[CodingKeys.body] = body
        dictionary[CodingKeys.triggerOperation] = Trigger.TriggerOperation(bridgedFromObjectiveC: triggerOperation)
        dictionary[CodingKeys.triggerType] = Trigger.TriggerType(bridgedFromObjectiveC: triggerType)

        return dictionary
    }
}

// MARK: - ObjectiveCBridging

extension Trigger: ObjectiveCBridgeable {
    typealias ObjectiveCType = ADTrigger

    func bridgeToObjectiveC() -> ADTrigger {
        return ADTrigger(
            id: self.id,
            resourceId: self.resourceId,
            selfLink: self.selfLink,
            etag: self.etag,
            timestamp: self.timestamp,
            altLink: self.altLink,
            body: self.body,
            operation: self.triggerOperation?.bridgedToObjectiveC ?? .all,
            type: self.triggerType?.bridgedToObjectiveC ?? .pre
        )
    }

    init(bridgedFromObjectiveC: ADTrigger) {
        self.init(
            id: bridgedFromObjectiveC.id,
            resourceId: bridgedFromObjectiveC.resourceId,
            selfLink: bridgedFromObjectiveC.selfLink,
            etag: bridgedFromObjectiveC.etag,
            timestamp: bridgedFromObjectiveC.timestamp,
            altLink: bridgedFromObjectiveC.altLink,
            body: bridgedFromObjectiveC.body,
            triggerOperation: TriggerOperation(bridgedFromObjectiveC: bridgedFromObjectiveC.triggerOperation),
            triggerType: TriggerType(bridgedFromObjectiveC: bridgedFromObjectiveC.triggerType)
        )
    }
}

extension Trigger.TriggerOperation {
    var bridgedToObjectiveC: ADTrigger.ADTriggerOperation {
        switch self {
        case .all:     return .all
        case .insert:  return .insert
        case .replace: return .replace
        case .delete:  return .delete
        }
    }

    init(bridgedFromObjectiveC: ADTrigger.ADTriggerOperation) {
        switch bridgedFromObjectiveC {
        case .all:     self = .all
        case .insert:  self = .insert
        case .replace: self = .replace
        case .delete:  self = .delete
        }
    }
}

extension Trigger.TriggerType {
    var bridgedToObjectiveC: ADTrigger.ADTriggerType {
        switch self {
        case .pre:  return .pre
        case .post: return .post
        }
    }

    init(bridgedFromObjectiveC: ADTrigger.ADTriggerType) {
        switch bridgedFromObjectiveC {
        case .pre:  self = .pre
        case .post: self = .post
        }
    }
}
