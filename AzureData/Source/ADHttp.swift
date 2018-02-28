//
//  ADHttp.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

public typealias HTTPHeaders = [String: String]

// https://docs.microsoft.com/en-us/rest/api/documentdb/http-status-codes-for-documentdb
public enum StatusCode : Int {
    case ok                     = 200
    case created                = 201
    case noContent              = 204
    case notModified            = 304
    case badRequest             = 400
    case unauthorized           = 401
    case forbidden              = 403
    case notFound               = 404
    case requestTimeout         = 408
    case conflict               = 409
    case preconditionFailure    = 412
    case entityTooLarge         = 413
    case tooManyRequests        = 429
    case retryWith              = 449
    case internalServerError    = 500
    case serviceUnavailable     = 503
}


public enum HttpMethod : String {
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case delete  = "DELETE"
}


// https://docs.microsoft.com/en-us/rest/api/documentdb/common-documentdb-rest-request-headers
public enum HttpRequestHeader : String {
    case authorization                      = "Authorization"
    case contentType                        = "Content-Type"
    case ifMatch                            = "If-Match"
    case ifNoneMatch                        = "If-None-Match"
    case ifModifiedSince                    = "If-Modified-Since"
    case userAgent                          = "User-Agent"
    case xMSActivityId                      = "x-ms-activity-id"
    case xMSConsistencyLevel                = "x-ms-consistency-level"
    case xMSContinuation                    = "x-ms-continuation"
    case xMSDate                            = "x-ms-date"
    case xMSMaxItemCount                    = "x-ms-max-item-count"
    case xMSDocumentdbPartitionkey          = "x-ms-documentdb-partitionkey"
    case xMSDocumentdbIsQuery               = "x-ms-documentdb-isquery"
    case xMSSessionToken                    = "x-ms-session-token"
    case xMSVersion                         = "x-ms-version"
    case aIM                                = "A-IM"
    case xMSDocumentdbPartitionKeyRangeId   = "x-ms-documentdb-partitionkeyrangeid"
    case acceptEncoding                     = "Accept-Encoding"
    case acceptLanguage                     = "Accept-Language"
    case slug                               = "Slug"    
}

extension Dictionary where Key == HttpRequestHeader, Value == String  {
    var strings: [String:String] {
        return Dictionary<String, String>.init(uniqueKeysWithValues: self.map{ (k, v) in
            (k.rawValue, v)
        })
    }
}


// https://docs.microsoft.com/en-us/rest/api/documentdb/common-documentdb-rest-response-headers
public enum HttpResponseHeader : String {
    case contentType        = "Content-Type"
    case date               = "Date"
    case etag               = "etag"
    case xMsActivityId      = "x-ms-activity-id"
    case xMsAltContentPath  = "x-ms-alt-content-path"
    case xMsContinuation    = "x-ms-continuation"
    case xMsItemCount       = "x-ms-item-count"
    case xMsRequestCharge   = "x-ms-request-charge"
    case xMsResourceQuota   = "x-ms-resource-quota"
    case xMsResourceUsage   = "x-ms-resource-usage"
    case xMsRetryAfterMs    = "x-ms-retry-after-ms"
    case xMsSchemaversion   = "x-ms-schemaversion"
    case xMsServiceversion  = "x-ms-serviceversion"
    case xMsSessionToken    = "x-ms-session-token"
    case xMsContentPath     = "x-ms-content-path"
    case xMsLastStateChange = "x-ms-last-state-change-utc"
    case cacheControl       = "Cache-Control"
    case pragma             = "Pragma"
    case contentLocation    = "Content-Location"
    case contentLength      = "Content-Length"

    var description: String {
        switch self {
        case .contentType:      return "Content-Type: The Content-Type is application/json. The DocumentDB API always returns the response body in standard JSON format."
        case .date:             return "Date: The date time of the response operation. This date time format conforms to the RFC 1123 date time format expressed in Coordinated Universal Time."
        case .etag:             return "etag: The etag header shows the resource etag for the resource retrieved. The etag has the same value as the _etag property in the response body."
        case .xMsActivityId:    return "x-ms-activity-id: Represents a unique identifier for the operation. This echoes the value of the x-ms-activity-id request header, and commonly used for troubleshooting purposes."
        case .xMsAltContentPath:return "x-ms-alt-content-path: The alternate path to the resource. Resources can be addressed in REST via system generated IDs or user supplied IDs. x-ms-alt-content-path represents the path constructed using user supplied IDs."
        case .xMsContinuation:  return "x-ms-continuation: This header represents the intermediate state of query (or read-feed) execution, and is returned when there are additional results aside from what was returned in the response. Clients can resubmitted the request with a request header containingthe value of x-ms-continuation."
        case .xMsItemCount:     return "x-ms-item-count: The number of items returned for a query or read-feed request."
        case .xMsRequestCharge: return "x-ms-request-charge: This is the number of normalized requests a.k.a. request units (RU) for the operation. For more information, see Request units in Azure Cosmos DB."
        case .xMsResourceQuota: return "x-ms-resource-quota: Shows the allotted quota for a resource in an account."
        case .xMsResourceUsage: return "x-ms-resource-usage: Shows the current usage cout of a resource in an account. When deleting a resource, this shows the number of resources after the deletion."
        case .xMsRetryAfterMs:  return "x-ms-retry-after-ms: The number of milliseconds to wait to retry the operation after an initial operation received HTTP status code 429 and was throttled."
        case .xMsSchemaversion: return "x-ms-schemaversion: Shows the resource schema version number."
        case .xMsServiceversion:return "x-ms-serviceversion: Shows the service version number."
        case .xMsSessionToken:  return "x-ms-session-token: The session token of the request. For session consistency, clients must echo this request via the x-ms-session-token request header for subsequent operations made to the corresponding collection."
        default: return ""
        }
    }
}


extension HTTPURLResponse {
    func headerString(for header: HttpResponseHeader) -> String? {
        return self.allHeaderFields[header.rawValue] as? String
    }
    func headerDate(for header: HttpResponseHeader) -> Date? {
        return self.allHeaderFields[header.rawValue] as? Date
    }
    func headerInt(for header: HttpResponseHeader) -> Int? {
        return self.allHeaderFields[header.rawValue] as? Int
    }
    func headerDouble(for header: HttpResponseHeader) -> Double? {
        return self.allHeaderFields[header.rawValue] as? Double
    }

    func printHeaders() {
        print("--")
        print("Headers:")
        for header in self.allHeaderFields {
            print("\t\(header.key) : \(header.value)")
        }
        print("--")
    }
}


extension URLRequest {
    mutating func addValue(_ value: String, forHTTPHeaderField: HttpRequestHeader) {
        self.addValue(value, forHTTPHeaderField: forHTTPHeaderField.rawValue)
    }
    
    var method: HttpMethod? {
        get {
            if let m = self.httpMethod, let adM = HttpMethod(rawValue: m) {
                return adM
            }
            return nil
        }
        set {
            self.httpMethod = newValue?.rawValue
        }
    }
}
