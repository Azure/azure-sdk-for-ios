//
//  ADResponseMetadata.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCore

/// https://docs.microsoft.com/en-us/rest/api/cosmos-db/common-cosmosdb-rest-response-headers
@objc(ADResponseMetadata)
public class ADResponseMetadata: NSObject {
    private var responseMetadata: ResponseMetadata

    /// The unique identifier of the operation.
    @objc
    public var activityId: String? { return responseMetadata.activityId }

    /// The alternate path to the resource constructed using
    /// user-supplied IDs.
    @objc
    public var alternateContentPath: String? { return responseMetadata.alternateContentPath }

    /// The Content-Type is always `application/json`.
    @objc
    public var contentType: String? { return responseMetadata.contentType }

    /// Represents the intermediate state of query or read-feed
    /// execution and is returned when there are additional
    /// results aside from what was returned in the response.
    /// Clients can resubmit the request with the request
    /// header `x-ms-continuation` containing this value.
    @objc
    public var continuation: String? { return responseMetadata.continuation }

    /// The date time of the response operation.
    @objc
    public var date: Date? { return responseMetadata.date }

    /// The `etag` of the resource retrieved.
    @objc
    public var etag: String? { return responseMetadata.etag }

    /// The number of items returned for a query or a read-feed request.
    @objc
    public var itemCount: Int { return responseMetadata.itemCount ?? Int.nil }

    /// The number of request units for the operation.
    @objc
    public var requestCharge: Double { return responseMetadata.requestCharge ?? Double.nil }

    /// The allotted quota for a resource in a Azure CosmosDB account.
    @objc
    public var resourceQuota: ADMetrics? { return ADMetrics(responseMetadata.resourceQuota) }

    /// The current usage of a resource in a Azure CosmosDB account.
    @objc
    public var resourceUsage: ADMetrics? { return ADMetrics(responseMetadata.resourceUsage) }

    /// The number of seconds to wait to retry
    /// the operation after an initial operation
    /// received the HTTP status code 429
    /// and was throttled.
    @objc
    public var retryAfter: TimeInterval { return responseMetadata.retryAfter ?? Double.nil }

    /// The resource schema version.
    @objc
    public var schemaVersion: String? { return responseMetadata.schemaVersion }

    /// The service version number.
    @objc
    public var serviceVersion: String? { return responseMetadata.serviceVersion }

    /// The session token of the request.

    @objc
    public var sessionToken: String? { return responseMetadata.sessionToken }

    internal init?(_ responseMetadata: ResponseMetadata? = nil) {
        guard let metadata = responseMetadata else { return nil }
        self.responseMetadata = metadata
    }

    @objc(ADMetrics)
    public class ADMetrics: NSObject {
        private var metrics: ResponseMetadata.Metrics

        /// The number of collections within an Azure CosmosDB account.
        @objc
        public var collections: Int { return metrics.collections ?? Int.nil }

        /// The size of a collection in kilobytes.
        @objc
        public var collectionSize: Int { return metrics.collectionSize ?? Int.nil }

        /// The number of documents within a collection.
        @objc
        public var documents: Int { return metrics.documents ?? Int.nil }

        /// The size of a document within a collection.
        @objc
        public var documentSize: Int { return metrics.documentSize ?? Int.nil }

        /// The size of all the documents within a collection.
        @objc
        public var documentsSize: Int { return metrics.documentsSize ?? Int.nil }

        /// The number of user defined functions within a collection.
        @objc
        public var functions: Int { return metrics.functions ?? Int.nil }

        /// The number of stored procedures within a collection.
        @objc
        public var storedProcedures: Int { return metrics.storedProcedures ?? Int.nil }

        /// The number of triggers within a collection.
        @objc
        public var triggers: Int { return metrics.triggers ?? Int.nil }

        internal init?(_ metrics: ResponseMetadata.Metrics? = nil) {
            guard let metrics = metrics else { return nil }
            self.metrics = metrics
        }
    }
}
