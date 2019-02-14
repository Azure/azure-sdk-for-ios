//
//  DocumentCollection.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Represents a document collection in the Azure Cosmos DB service.
/// A collection is a named logical container for documents.
///
/// - Remark:
///   A database may contain zero or more named collections and each collection consists of zero or more JSON documents.
///   Being schema-free, the documents in a collection do not need to share the same structure or fields.
///   Since collections are application resources, they can be authorized using either the master key or resource keys.
///   Refer to [collections](http://azure.microsoft.com/documentation/articles/documentdb-resources/#collections) for more details on collections.
public struct DocumentCollection : CodableResource, SupportsPermissionToken {
    
    public static var type = "colls"
    public static var list = "DocumentCollections"
    
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

    /// Gets the self-link for conflicts in a collection from the Azure Cosmos DB service.
    public private(set) var conflictsLink: String?
    
    /// Gets the default time to live in seconds for documents in a collection from the Azure Cosmos DB service.
    public var defaultTimeToLive: Int? = nil

    /// Gets the self-link for documents in a collection from the Azure Cosmos DB service.
    public private(set) var documentsLink: String?
    
    /// Gets the `IndexingPolicy` associated with the collection from the Azure Cosmos DB service.
    public var indexingPolicy: IndexingPolicy?
    
    /// Gets or sets `PartitionKeyDefinition` object in the Azure Cosmos DB service.
    public var partitionKey: PartitionKeyDefinition?

    /// Gets the self-link for stored procedures in a collection from the Azure Cosmos DB service.
    public private(set) var storedProceduresLink: String?
    
    /// Gets the self-link for triggers in a collection from the Azure Cosmos DB service.
    public private(set) var triggersLink: String?
    
    /// Gets the self-link for user defined functions in a collection from the Azure Cosmos DB service.
    public private(set) var userDefinedFunctionsLink: String?
    
    
    /// Represents the indexing policy configuration for a collection in the Azure Cosmos DB service.
    public struct IndexingPolicy : Codable, Equatable {
        
        /// Gets or sets a value that indicates whether automatic indexing is enabled for a collection in
        /// the Azure Cosmos DB service.
        public var automatic: Bool?
        
        /// Gets or sets the collection containing `ExcludedPath` objects in the Azure Cosmos DB service.
        public var excludedPaths: [ExcludedPath] = []
        
        /// Gets or sets the collection containing `IncludedPath` objects in the Azure Cosmos DB service.
        public var includedPaths: [IncludedPath] = []
        
        /// Gets or sets the indexing mode (`.consistent` or `.lazy`) in the Azure Cosmos DB service.
        public var indexingMode: IndexingMode?
        
        
        /// Specifies a path within a JSON document to be excluded while indexing data for the Azure Cosmos DB service.
        public struct ExcludedPath : Codable, Equatable {
            
            /// Gets or sets the path to be excluded from indexing in the Azure Cosmos DB service.
            public var path: String?
        }
        
        
        /// Specifies a path within a JSON document to be included in the Azure Cosmos DB service.
        public struct IncludedPath : Codable, Equatable {
            
            /// Gets or sets the path to be indexed in the Azure Cosmos DB service.
            public var path: String?
            
            /// Gets or sets the collection of `Index` objects to be applied for this included path in
            /// the Azure Cosmos DB service.
            public var indexes: [Index] = []
            
            
            /// Base class for `IndexingPolicy` `Indexes` in the Azure Cosmos DB service,
            /// you should use a concrete `Index` like `HashIndex` or `RangeIndex`.
            public struct Index : Codable, Equatable {
                
                /// Gets or sets the kind of indexing to be applied in the Azure Cosmos DB service.
                public var kind: IndexKind?
                
                /// Specifies the target data type for the index path specification.
                public private(set) var dataType: DataType?
                
                /// Specifies the precision to be used for the data type associated with this index.
                public private(set) var precision: Int16?
                
                
                /// These are the indexing types available for indexing a path in the Azure Cosmos DB service.
                ///
                /// - hash:     The index entries are hashed to serve point look up queries.
                /// - range:    The index entries are ordered. Range indexes are optimized for
                ///             inequality predicate queries with efficient range scans.
                /// - spatial:  The index entries are indexed to serve spatial queries.
                public enum IndexKind: String, Codable {
                    case hash       = "Hash"
                    case range      = "Range"
                    case spatial    = "Spatial"
                }
                
                
                /// Defines the target data type of an index path specification in the Azure Cosmos DB service.
                ///
                /// - lineString:   Represent a line string data type.
                /// - number:       Represent a numeric data type.
                /// - point:        Represent a point data type.
                /// - polygon:      Represent a polygon data type.
                /// - string:       Represent a string data type.
                public enum DataType: String, Codable {
                    case lineString = "LineString"
                    case number     = "Number"
                    case point      = "Point"
                    case polygon    = "Polygon"
                    case string     = "String"
                }
                
                
                /// Returns an instance of the `HashIndex` class with specified `DataType` (and precision) for
                /// the Azure Cosmos DB service.
                public static func hash(withDataType dataType: DataType, andPrecision precision: Int16? = nil) -> Index {
                    return Index(kind: .hash, dataType: dataType, precision: precision)
                }
                
                /// Returns an instance of the `RangeIndex` class with specified `DataType` (and precision) for
                /// the Azure Cosmos DB service.
                public static func range(withDataType dataType: DataType, andPrecision precision: Int16? = nil) -> Index {
                    return Index(kind: .range, dataType: dataType, precision: precision)
                }

                /// Returns an instance of the `SpatialIndex` class with specified `DataType` for
                /// the Azure Cosmos DB service.
                public static func spatial(withDataType dataType: DataType) -> Index {
                    return Index(kind: .spatial, dataType: dataType, precision: nil)
                }
            }
        }
        
        /// Specifies the supported indexing modes in the Azure Cosmos DB service.
        ///
        /// - consistent:   Index is updated synchronously with a create, update or delete operation.
        /// - lazy:         Index is updated asynchronously with respect to a create, update or delete operation.
        /// - none:         No index is provided.
        public enum IndexingMode: String, Codable {
            case consistent = "consistent"
            case lazy       = "lazy"
            case none       = "none"
        }
    }
    
    
    /// Specifies a partition key definition for a particular path in the Azure Cosmos DB service.
    public struct PartitionKeyDefinition : Codable, Equatable {
        
        /// Gets or sets the paths to be partitioned in the Azure Cosmos DB service.
        public var paths: [String] = []
    }
    
    
    public init (_ id: String, partitionKey: PartitionKeyDefinition?) {
        self.id = id
        self.resourceId = ""
        self.partitionKey = partitionKey
    }

    public init (_ id: String, partitionKey: PartitionKeyDefinition?, indexingPolicy: IndexingPolicy) {
        self.id = id
        self.resourceId = ""
        self.partitionKey = partitionKey
        self.indexingPolicy = indexingPolicy
    }
}


extension DocumentCollection {
    enum CodingKeys: String, CodingKey {
        case id
        case resourceId                 = "_rid"
        case selfLink                   = "_self"
        case etag                       = "_etag"
        case timestamp                  = "_ts"
        case conflictsLink              = "_conflicts"
        case documentsLink              = "_docs"
        case indexingPolicy
        case partitionKey
        case storedProceduresLink       = "_sprocs"
        case triggersLink               = "_triggers"
        case userDefinedFunctionsLink   = "_udfs"
    }

    init(id: String, resourceId: String, selfLink: String?, etag: String?, timestamp: Date?, conflictsLink: String?, documentsLink: String?, indexingPolicy: IndexingPolicy?, partitionKey: PartitionKeyDefinition, storedProceduresLink: String?, triggersLink: String?, userDefinedFunctionsLink: String?) {
        self.id = id
        self.resourceId = resourceId
        self.selfLink = selfLink
        self.etag = etag
        self.timestamp = timestamp
        self.conflictsLink = conflictsLink
        self.documentsLink = documentsLink
        self.indexingPolicy = indexingPolicy
        self.partitionKey = partitionKey
        self.storedProceduresLink = storedProceduresLink
        self.triggersLink = triggersLink
        self.userDefinedFunctionsLink = userDefinedFunctionsLink
    }
}


extension DocumentCollection : CustomDebugStringConvertible {
    public var debugDescription: String {
        return "DocumentCollection :\n\tid : \(self.id)\n\tresourceId : \(self.resourceId)\n\tselfLink : \(self.selfLink.valueOrNilString)\n\tetag : \(self.etag.valueOrNilString)\n\ttimestamp : \(self.timestamp.valueOrNilString)\n\taltLink : \(self.altLink.valueOrNilString)\n\tconflictsLink : \(self.conflictsLink.valueOrNilString)\n\tdocumentsLink : \(self.documentsLink.valueOrNilString)\n\tindexingPolicy : ..todo\n\tpartitionKey : ..todo\n\tstoredProceduresLink : \(self.storedProceduresLink.valueOrNilString)\n\ttriggersLink : \(self.triggersLink.valueOrNilString)\n\tuserDefinedFunctionsLink : \(self.userDefinedFunctionsLink.valueOrNilString)\n--"
    }
}

