//
//  DatabaseAccount.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Represents a DatabaseAccount. A DatabaseAccount is the container for databases in the Azure Cosmos DB service.
public struct DatabaseAccount : CodableResource {
    
    public static var type = "account"
    public static var list = "Accounts"
    
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

    /// Gets the ConsistencyPolicy settings from the Azure Cosmos DB service.
    public private(set) var consistencyPolicy: ConsistencyPolicy?
    
    /// Gets the self-link for Databases in the databaseAccount from the Azure Cosmos DB service.
    public private(set) var databasesLink: String?
    
    /// Gets the storage quota for media storage in the databaseAccount from the Azure Cosmos DB service.
    /// - Remark:
    ///   The value is retrieved from the gateway.
    public private(set) var maxMediaStorageUsageInMB: Int64?
    
    /// Gets the self-link for Media in the databaseAccount from the Azure Cosmos DB service.
    public private(set) var mediaLink: String?
    
    /// Gets the current attachment content (media) usage in MBs from the Azure Cosmos DB service.
    ///
    /// - Remark:
    ///   The value is retrieved from the gateway.
    ///   The value is returned from cached information updated periodically and is not guaranteed to be real time.
    public private(set) var mediaStorageUsageInMB: Int64?
    
    /// Gets the list of locations reprsenting the readable regions of this database account from
    /// the Azure Cosmos DB service.
    public private(set) var readableLocations: [DatabaseAccountLocation]? = nil
    
    /// Gets the list of locations reprsenting the writable regions of this database account from
    /// the Azure Cosmos DB service.
    public private(set) var writableLocation: [DatabaseAccountLocation]? = nil
    
    
    /// Represents the consistency policy of a database account of the Azure Cosmos DB service.
    public struct ConsistencyPolicy : Codable {
        /// Get or set the default consistency level in the Azure Cosmos DB service.
        public private(set) var defaultConsistencyLevel: ConsistencyLevel?
        
        /// For bounded staleness consistency, the maximum allowed staleness in terms time interval in
        /// the Azure Cosmos DB service.
        public private(set) var maxStalenessIntervalInSeconds: Int32?
        
        /// For bounded staleness consistency, the maximum allowed staleness in terms difference in sequence numbers
        /// (aka version) in the Azure Cosmos DB service.
        public private(set) var maxStalenessPrefix: Int32?
        
        public enum CodingKeys: String, CodingKey {
            case defaultConsistencyLevel
            case maxStalenessIntervalInSeconds = "maxIntervalInSeconds"
            case maxStalenessPrefix
        }
    }
    
    
    /// These are the consistency levels supported by the Azure Cosmos DB service.
    ///
    /// - boundedStaleness: Bounded Staleness guarantees that reads are not too out-of-date.
    ///                     This can be configured based on number of operations (MaxStalenessPrefix)
    ///                     or time (MaxStalenessIntervalInSeconds). For more information on MaxStalenessPrefix
    ///                     and MaxStalenessIntervalInSeconds, please see ConsistencyPolicy.
    /// - consistentPrefix: ConsistentPrefix Consistency guarantees that reads will return some prefix of
    ///                     all writes with no gaps. All writes will be eventually be available for reads.
    /// - eventual:         Eventual Consistency guarantees that reads will return a subset of writes.
    ///                     All writes will be eventually be available for reads.
    /// - session:          Session Consistency guarantees monotonic reads (you never read old data, then new,
    ///                     then old again), monotonic writes (writes are ordered) and read your writes (your writes
    ///                     are immediately visible to your reads) within any single session.
    /// - strong:           Strong Consistency guarantees that read operations always return the value that
    ///                     was last written.
    ///
    /// - Remark:
    ///   The requested Consistency Level must match or be weaker than that provisioned for the database account.
    ///   For more information on consistency levels, please see [Consistency Levels article](http://azure.microsoft.com/documentation/articles/documentdb-consistency-levels/).
    public enum ConsistencyLevel : String, Codable {
        case boundedStaleness = "BoundedStaleness"
        case consistentPrefix = "ConsistentPrefix"
        case eventual = "Eventual"
        case session = "Session"
        case strong = "Strong"
    }
    
    
    /// Represents an Azure Cosmos DB database account in a specific region.
    public struct DatabaseAccountLocation : Codable {
        
        /// Gets the Url of the database account location in the Azure Cosmos DB service.
        /// For example, "https://contoso-WestUS.documents.azure.com:443/" as the Url of the database account location
        /// in the West US region.
        public private(set) var databaseAccountEndpoint: String?
        
        /// Gets the name of the database account location in the Azure Cosmos DB service.
        /// For example, "West US" as the name of the database account location in the West US region.
        public private(set) var name: String?
    }
    
    public init (_ id: String) { self.id = id; resourceId = "" }
}


private extension DatabaseAccount {
    
    private enum CodingKeys: String, CodingKey {
        case id
        case resourceId                 = "_rid"
        case selfLink                   = "_self"
        case etag                       = "_etag"
        case timestamp                  = "_ts"
        case consistencyPolicy
        case databasesLink              = "_dbs"
        case maxMediaStorageUsageInMB
        case mediaLink                  = "media"
        case mediaStorageUsageInMB
    }
}
