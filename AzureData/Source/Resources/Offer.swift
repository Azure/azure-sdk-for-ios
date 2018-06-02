//
//  Offer.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Represents the Standard pricing offer for a resource (collection) in the Azure Cosmos DB service.
///
/// - Remark:
///   Currently, offers are only bound to the collection resource.
public struct Offer : CodableResource {
    
    public static var type = "offers"
    public static var list = "Offers"
    
    public private(set) var id:         String
    public private(set) var resourceId: String
    public private(set) var selfLink:   String?
    public private(set) var etag:       String?
    public private(set) var timestamp:  Date?
    public private(set) var altLink:    String? = nil
    
    public mutating func setAltLink(to link: String) {
        self.altLink = link
    }
    public mutating func setEtag(to tag: String) {
        self.etag = tag
    }

    /// Gets or sets the OfferType for the resource offer in the Azure Cosmos DB service.
    public private(set) var offerType: String?
    
    /// Gets or sets the version of this offer resource in the Azure Cosmos DB service.
    public private(set) var offerVersion: String? = "V2"
    
    /// Gets or sets the self-link of a resource to which the resource offer applies to in the Azure Cosmos DB service.
    public private(set) var resourceLink: String?
    
    
    public private(set) var offerResourceId: String?
    
    /// Gets or sets the OfferContent for the resource offer in the Azure Cosmos DB service.
    public private(set) var content: OfferContent?

    
    /// Represents content properties tied to the Standard pricing tier for the Azure Cosmos DB service.
    public struct OfferContent : Codable {

        /// Represents Request Units(RU)/Minute throughput is enabled/disabled for collection in
        /// the Azure Cosmos DB service.
        public private(set) var offerIsRUPerMinuteThroughputEnabled: Bool?
        
        /// Represents customizable throughput chosen by user for his collection in the Azure Cosmos DB service.
        public private(set) var offerThroughput: Int = 1000

        internal init(offerIsRUPerMinuteThroughputEnabled: Bool, offerThroughput: Int) {
            self.offerIsRUPerMinuteThroughputEnabled = offerIsRUPerMinuteThroughputEnabled
            self.offerThroughput = offerThroughput
        }
    }
    
    public init (_ id: String) { self.id = id; resourceId = "" }
}


extension Offer {
    enum CodingKeys: String, CodingKey {
        case id
        case resourceId         = "_rid"
        case selfLink           = "_self"
        case etag               = "_etag"
        case timestamp          = "_ts"
        case offerType
        case offerVersion
        case resourceLink       = "resource"
        case offerResourceId
        case content
    }

    init(id: String, resourceId: String, selfLink: String?, etag: String?, timestamp: Date?, altLink: String?, offerType: String?, offerVersion: String?, resourceLink: String?, offerResourceId: String?, content: OfferContent?) {
        self.id = id
        self.resourceId = resourceId
        self.selfLink = selfLink
        self.etag = etag
        self.timestamp = timestamp
        self.altLink = altLink
        self.offerType = offerType
        self.offerVersion = offerVersion
        self.resourceLink = resourceLink
        self.offerResourceId = offerResourceId
        self.content = content
    }
}
