//
//  MSHttpHeader.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

// https://docs.microsoft.com/en-us/rest/api/documentdb/common-documentdb-rest-request-headers
// https://docs.microsoft.com/en-us/rest/api/documentdb/common-documentdb-rest-response-headers
public enum MSHttpHeader : String {
    case aIM                                   = "A-IM"
    case msActivityId                          = "x-ms-activity-id"
    case msAltContentPath                      = "x-ms-alt-content-path"
    case msConsistencyLevel                    = "x-ms-consistency-level"
    case msContentPath                         = "x-ms-content-path"
    case msContinuation                        = "x-ms-continuation"
    case msDate                                = "x-ms-date"
    case msDocumentdbIsQuery                   = "x-ms-documentdb-isquery"
    case msDocumentdbIsUpsert                  = "x-ms-documentdb-is-upsert"
    case msDocumentdbPartitionkey              = "x-ms-documentdb-partitionkey"
    case msDocumentdbPartitionKeyRangeId       = "x-ms-documentdb-partitionkeyrangeid"
    case msDocumentdbQueryEnableCrossPartition = "x-ms-documentdb-query-enablecrosspartition"
    case msItemCount                           = "x-ms-item-count"
    case msLastStateChange                     = "x-ms-last-state-change-utc"
    case msMaxItemCount                        = "x-ms-max-item-count"
    case msRequestCharge                       = "x-ms-request-charge"
    case msResourceQuota                       = "x-ms-resource-quota"
    case msResourceUsage                       = "x-ms-resource-usage"
    case msRetryAfterMs                        = "x-ms-retry-after-ms"
    case msSchemaversion                       = "x-ms-schemaversion"
    case msServiceversion                      = "x-ms-serviceversion"
    case msSessionToken                        = "x-ms-session-token"
    case msVersion                             = "x-ms-version"
    
    var description: String {
        switch self {
        case .msActivityId:     return "x-ms-activity-id: Represents a unique identifier for the operation. This echoes the value of the x-ms-activity-id request header, and commonly used for troubleshooting purposes."
        case .msAltContentPath: return "x-ms-alt-content-path: The alternate path to the resource. Resources can be addressed in REST via system generated IDs or user supplied IDs. x-ms-alt-content-path represents the path constructed using user supplied IDs."
        case .msContinuation:   return "x-ms-continuation: This header represents the intermediate state of query (or read-feed) execution, and is returned when there are additional results aside from what was returned in the response. Clients can resubmitted the request with a request header containingthe value of x-ms-continuation."
        case .msItemCount:      return "x-ms-item-count: The number of items returned for a query or read-feed request."
        case .msRequestCharge:  return "x-ms-request-charge: This is the number of normalized requests a.k.a. request units (RU) for the operation. For more information, see Request units in Azure Cosmos DB."
        case .msResourceQuota:  return "x-ms-resource-quota: Shows the allotted quota for a resource in an account."
        case .msResourceUsage:  return "x-ms-resource-usage: Shows the current usage cout of a resource in an account. When deleting a resource, this shows the number of resources after the deletion."
        case .msRetryAfterMs:   return "x-ms-retry-after-ms: The number of milliseconds to wait to retry the operation after an initial operation received HTTP status code 429 and was throttled."
        case .msSchemaversion:  return "x-ms-schemaversion: Shows the resource schema version number."
        case .msServiceversion: return "x-ms-serviceversion: Shows the service version number."
        case .msSessionToken:   return "x-ms-session-token: The session token of the request. For session consistency, clients must echo this request via the x-ms-session-token request header for subsequent operations made to the corresponding collection."
        default: return ""
        }
    }
}


extension Dictionary where Key == String, Value == Any {
    public subscript (index: MSHttpHeader) -> Any? {
        get {
            return self[index.rawValue]
        }
        set {
            self[index.rawValue] = newValue
        }
    }
}

extension Dictionary where Key == String, Value == String {
    public subscript (index: MSHttpHeader) -> String? {
        get {
            return self[index.rawValue]
        }
        set {
            self[index.rawValue] = newValue
        }
    }
}


extension URLRequest {
    mutating func addValue(_ value: String, forHTTPHeaderField: MSHttpHeader) {
        self.addValue(value, forHTTPHeaderField: forHTTPHeaderField.rawValue)
    }
}
