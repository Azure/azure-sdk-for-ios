//
//  ResponseMetadata.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCore

/// https://docs.microsoft.com/en-us/rest/api/cosmos-db/common-cosmosdb-rest-response-headers
public struct ResponseMetadata {
    /// The unique identifier of the operation.
    public let activityId: String?

    /// The alternate path to the resource constructed using
    /// user-supplied IDs.
    public let alternateContentPath: String?

    /// The Content-Type is always `application/json`.
    public let contentType: String?

    /// Represents the intermediate state of query or read-feed
    /// execution and is returned when there are additional
    /// results aside from what was returned in the response.
    /// Clients can resubmit the request with the request
    /// header `x-ms-continuation` containing this value.
    public let continuation: String?

    /// The date time of the response operation.
    public let date: Date?

    /// The `etag` of the resource retrieved.
    public let etag: String?

    /// The number of items returned for a query or a read-feed request.
    public let itemCount: Int?

    /// The number of request units for the operation.
    public let requestCharge: Double?

    /// The allotted quota for a resource in a Azure CosmosDB account.
    public let resourceQuota: Metrics?

    /// The current usage of a resource in a Azure CosmosDB account.
    public let resourceUsage: Metrics?

    /// The number of seconds to wait to retry
    /// the operation after an initial operation
    /// received the HTTP status code 429
    /// and was throttled.
    public let retryAfter: TimeInterval?

    /// The resource schema version.
    public let schemaVersion: String?

    /// The service version number.
    public let serviceVersion: String?

    /// The session token of the request.
    public let sessionToken: String?

    internal init(for response: HTTPURLResponse) {
        let headers = response.allHeaderFields

        self.activityId = headers[.msActivityId]
        self.alternateContentPath = headers[.msAltContentPath]
        self.contentType = headers[HttpHeader.contentType.rawValue] as? String
        self.continuation = headers[.msContinuation]
        self.date = DateFormat.getRFC1123Formatter().date(from: (headers[HttpHeader.date.rawValue] as? String) ?? "")
        self.etag = headers[HttpHeader.etag.rawValue] as? String
        self.itemCount = headers[.msItemCount]
        self.requestCharge = headers[.msRequestCharge]
        self.resourceQuota = Metrics(headers[.msResourceQuota] ?? "")
        self.resourceUsage = Metrics(headers[.msResourceUsage] ?? "")
        self.retryAfter = (headers[.msRetryAfterMs] ?? 0) / 1000
        self.schemaVersion = headers[.msSchemaversion]?.valueIfKeyValuePairElseSelf
        self.serviceVersion = headers[.msServiceversion]?.valueIfKeyValuePairElseSelf
        self.sessionToken = headers[.msSessionToken]
    }

    //  MARK: - Metrics

    public struct Metrics {
        /// The number of collections within an Azure CosmosDB account.
        public var collections: Int?

        /// The size of a collection in kilobytes.
        public var collectionSize: Int?

        /// The number of documents within a collection.
        public var documents: Int?

        /// The size of a document within a collection.
        public var documentSize: Int?

        /// The size of all the documents within a collection.
        public var documentsSize: Int?

        /// The number of user defined functions within a collection.
        public var functions: Int?

        /// The number of stored procedures within a collection.
        public var storedProcedures: Int?

        /// The number of triggers within a collection.
        public var triggers: Int?

        // Metrics("functions=25;storedProcedures=100;triggers=25;documentSize=10240;")
        fileprivate init(_ metricsString: String) {
            let keyValuePairs = metricsString.parsedKeyValuePairs()
            for (key, value) in keyValuePairs {
                switch key.trimmed {
                case "collections":
                    self.collections = value
                case "collectionSize":
                    self.collectionSize = value
                case "documentsCount":
                    self.documents = value
                case "documentSize":
                    self.documentSize = value
                case "documentsSize":
                    self.documentsSize = value
                case "functions":
                    self.functions = value
                case "storedProcedures":
                    self.storedProcedures = value
                case "triggers":
                    self.triggers = value
                default:
                    break
                }
            }
        }
    }
}

// MARK: -

fileprivate extension Dictionary where Key == AnyHashable, Value == Any {
    subscript(key: MSHttpHeader) -> String? {
        return self[key.rawValue] as? String
    }

    subscript(key: MSHttpHeader) -> Int? {
        return Int((self[key.rawValue] as? String) ?? "")
    }

    subscript(key: MSHttpHeader) -> Double? {
        return Double((self[key.rawValue] as? String) ?? "")
    }
}

// MARK: -

fileprivate extension StringProtocol {
    /// "functions=25;storedProcedures=100;"parsedKeyValuePairs() -> [("functions", 25), ("storedProcedures", 100)]
    func parsedKeyValuePairs() -> [(String, Int)] {
        return self.split(separator: ";").compactMap { $0.parsedKeyValuePair() }
    }

    /// "functions=25".parsedKeyValuePairString() -> ("functions", 25)
    func parsedKeyValuePair() -> (String, Int)? {
        let pair = self.split(separator: "=")
        guard pair.count == 2 else { return nil }
        let key = String(pair[0])
        guard let value = Int(pair[1]) else { return nil }
        return (key, value)
    }

    /// "version=1.6.52.5".valueIfKeyValuePairElseSelf -> "1.6.52.5"
    /// "1.6.52.5".valueIfKeyValuePairElseSelf -> "1.6.52.5"
    var valueIfKeyValuePairElseSelf: String {
        let pair = self.split(separator: "=")
        guard pair.count == 2 else { return String(self) }
        return String(pair[1])
    }
}

// MARK: -

fileprivate extension String {
    var trimmed: String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
