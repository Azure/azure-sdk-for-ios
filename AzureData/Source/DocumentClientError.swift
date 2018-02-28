//
//  DocumentClientError.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

public struct DocumentClientError : Error {
    
    public enum ErrorKind {
        case unknownError
        case internalError
        case configureError
        case invalidId
        case incompleteIds
        case badRequest
        case unauthorized
        case forbidden
        case notFound
        case requestTimeout
        case conflict
        case preconditionFailure
        case entityTooLarge
        case tooManyRequests
        case retryWith
        case internalServerError
        case serviceUnavailable

        var message: String {
            switch self {
            case .unknownError:     return "An unknown error occured."
            case .internalError:    return "An internal error occured."
            case .configureError:   return "AzureData is not configured.  Must call AzureData.configure() before attempting CRUD operations on resources."
            case .invalidId:        return "Cosmos DB Resource IDs must not exceed 255 characters and cannot contain whitespace"
            case .incompleteIds:    return "This resource is missing the selfLink and/or resourceId properties.  Use an override that takes parent resource or ids instead."
            default: return ""
            }
        }
    }
    
    /// Gets the activity ID associated with the request from the Azure Cosmos DB service.
    public private(set) var activityId: String? = nil

    /// Gets the error code associated with the exception in the Azure Cosmos DB service.
    public private(set) var resourceError: ResourceError? = nil
    
    /// Gets a message that describes the current exception from the Azure Cosmos DB service.
    public var message: String? {
        return baseError?.localizedDescription ?? resourceError?.message ?? kind.message
    }
    
    /// Cost of the request in the Azure Cosmos DB service.
    public private(set) var requestCharge: Double? = nil
    
    /// Gets the headers associated with the response from the Azure Cosmos DB service.
    public private(set) var responseHeaders: [HttpResponseHeader:Any]? = nil
    
    /// Gets the recommended time interval after which the client can retry failed requests from
    /// the Azure Cosmos DB service
    public private(set) var retryAfter: TimeInterval? = nil
    
    /// Gets or sets the request status code in the Azure Cosmos DB service.
    public private(set) var statusCode: StatusCode? = nil
    
    /// Kind of error.
    public private(set) var kind: ErrorKind = .unknownError
    
    /// A nested error.
    public private(set) var baseError: Error? = nil
    
    
    init(withError error: Error) {
        self.baseError = error
    }

    init(withKind kind: ErrorKind) {
        self.kind = kind
    }
    
    init(withData data: Data?, response: HTTPURLResponse?, error: Error? = nil) {
        
        if let response = response {
            
            var headers = [HttpResponseHeader:Any]()
            
            for header in response.allHeaderFields {
                if let keyString = header.key as? String, let responseHeader = HttpResponseHeader(rawValue: keyString) {
                    headers[responseHeader] = header.value
                }
            }
            
            self.responseHeaders = headers

            self.activityId = headers[.xMsActivityId] as? String
            self.requestCharge = headers[.xMsRequestCharge] as? Double
            self.retryAfter = headers[.xMsRetryAfterMs] as? Double
            
            if let code = StatusCode(rawValue: response.statusCode) {                
                self.statusCode = code
                self.kind = code.errorKind
            }
        }

        if let data = data, let resourceError = try? ResourceError.decode(data: data) {
            self.resourceError = resourceError
        }
        
        self.baseError = error
    }
}


extension StatusCode {
    public var errorKind: DocumentClientError.ErrorKind {
        switch self {
        case .badRequest:           return .badRequest
        case .unauthorized:         return .unauthorized
        case .forbidden:            return .forbidden
        case .notFound:             return .notFound
        case .requestTimeout:       return .requestTimeout
        case .conflict:             return .conflict
        case .preconditionFailure:  return .preconditionFailure
        case .entityTooLarge:       return .entityTooLarge
        case .tooManyRequests:      return .tooManyRequests
        case .retryWith:            return .retryWith
        case .internalServerError:  return .internalServerError
        case .serviceUnavailable:   return .serviceUnavailable
        default:                    return .unknownError
        }
    }
}


extension DocumentClientError : CustomStringConvertible {
    public var description: String {
        let baseErrorDescription = self.baseError != nil ? "\n\t baseError: \(self.baseError!.localizedDescription)" : ""
        return "\(self.localizedDescription)\(baseErrorDescription)\n"
    }
}

extension DocumentClientError : CustomDebugStringConvertible {
    public var debugDescription: String {
        let baseErrorDescription = self.baseError != nil ? "\n\t baseError: \(self.baseError!.localizedDescription)" : ""
        return "\(self.localizedDescription)\(baseErrorDescription)\n"
    }
}


extension DocumentClientError {
    
    
    
    
    
}
