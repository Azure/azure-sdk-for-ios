//
//  ADResponseMetadata.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCore

@objc(ADResponseMetadata)
public class ADResponseMetadata: NSObject {
    private var responseMetadata: ResponseMetadata

    @objc
    public var activityId: String? { return responseMetadata.activityId }

    @objc
    public var alternateContentPath: String? { return responseMetadata.alternateContentPath }

    @objc
    public var contentType: String? { return responseMetadata.contentType }

    @objc
    public var continuation: String? { return responseMetadata.continuation }

    @objc
    public var date: Date? { return responseMetadata.date }

    @objc
    public var etag: String? { return responseMetadata.etag }

    @objc
    public var itemCount: Int { return responseMetadata.itemCount ?? Int.nil }

    @objc
    public var requestCharge: Double { return responseMetadata.requestCharge ?? Double.nil }

    @objc
    public var resourceQuota: ObjCMetrics? { return ObjCMetrics(responseMetadata.resourceQuota) }

    @objc
    public var resourceUsage: ObjCMetrics? { return ObjCMetrics(responseMetadata.resourceUsage) }

    @objc
    public var retryAfter: TimeInterval { return responseMetadata.retryAfter ?? Double.nil }

    @objc
    public var schemaVersion: String? { return responseMetadata.schemaVersion }

    @objc
    public var serviceVersion: String? { return responseMetadata.serviceVersion }

    @objc
    public var sessionToken: String? { return responseMetadata.sessionToken }

    internal init?(_ responseMetadata: ResponseMetadata? = nil) {
        guard let metadata = responseMetadata else { return nil }
        self.responseMetadata = metadata
    }

    @objc(ADMetrics)
    public class ObjCMetrics: NSObject {
        private var metrics: ResponseMetadata.Metrics

        @objc
        public var collections: Int { return metrics.collections ?? Int.nil }

        @objc
        public var collectionSize: Int { return metrics.collectionSize ?? Int.nil }

        @objc
        public var documents: Int { return metrics.documents ?? Int.nil }

        @objc
        public var documentSize: Int { return metrics.documentSize ?? Int.nil }

        @objc
        public var documentsSize: Int { return metrics.documentsSize ?? Int.nil }

        @objc
        public var functions: Int { return metrics.functions ?? Int.nil }

        @objc
        public var storedProcedures: Int { return metrics.storedProcedures ?? Int.nil }

        @objc
        public var triggers: Int { return metrics.triggers ?? Int.nil }

        internal init?(_ metrics: ResponseMetadata.Metrics? = nil) {
            guard let metrics = metrics else { return nil }
            self.metrics = metrics
        }
    }
}
