//
//  ADOfferContent.swift
//  AzureData ObjC
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

@objc(ADOfferContent)
public class ADOfferContent: NSObject, ADCodable {
    private enum CodingKeys: String, CodingKey {
        case offerIsRUPerMinuteThroughputEnabled
        case offerThroughput
    }

    public let offerIsRUPerMinuteThroughputEnabled: Bool
    public let offerThroughput: Int

    init(offerIsRUPerMinuteThroughputEnabled: Bool, offerThroughput: Int) {
        self.offerIsRUPerMinuteThroughputEnabled = offerIsRUPerMinuteThroughputEnabled
        self.offerThroughput = offerThroughput
    }

    // MARK: - ADCodable

    public required init?(from dictionary: NSDictionary) {
        self.offerIsRUPerMinuteThroughputEnabled = dictionary[CodingKeys.offerIsRUPerMinuteThroughputEnabled] as? Bool ?? false
        self.offerThroughput = dictionary[CodingKeys.offerThroughput] as? Int ?? 1000
    }

    public func encode() -> NSDictionary {
        let dictionary = NSMutableDictionary()

        dictionary[CodingKeys.offerIsRUPerMinuteThroughputEnabled] = offerIsRUPerMinuteThroughputEnabled
        dictionary[CodingKeys.offerThroughput] = offerThroughput

        return dictionary
    }
}

// MARK: - Objective-C Bridging

extension Offer.OfferContent: ObjectiveCBridgeable {
    typealias ObjectiveCType = ADOfferContent

    func bridgeToObjectiveC() -> ADOfferContent {
        return ADOfferContent(
            offerIsRUPerMinuteThroughputEnabled: self.offerIsRUPerMinuteThroughputEnabled ?? false,
            offerThroughput: self.offerThroughput
        )
    }

    init(bridgedFromObjectiveC: ObjectiveCType) {
        self.init(
            offerIsRUPerMinuteThroughputEnabled: bridgedFromObjectiveC.offerIsRUPerMinuteThroughputEnabled,
            offerThroughput: bridgedFromObjectiveC.offerThroughput
        )
    }
}
