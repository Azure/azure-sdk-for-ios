//
//  DocumentClientError.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCore

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
        case permissionError
        case noMoreResultsError
        case resourceRequestError(_: ResourceRequestError)
        case noPartitionKeyRange

        var message: String {
            switch self {
            case .unknownError:     return "An unknown error occured."
            case .internalError:    return "An internal error occured."
            case .configureError:   return "AzureData is not configured.  Must call AzureData.configure() before attempting CRUD operations on resources."
            case .invalidId:        return "Cosmos DB Resource IDs must not exceed 255 characters and cannot contain whitespace"
            case .incompleteIds:    return "This resource is missing the selfLink and/or resourceId properties.  Use an override that takes parent resource or ids instead."
            case .permissionError:  return "Configuring AzureData using a PermissionProvider implements access control based on resource-specific Permissions. This authorization model only supports accessing application resources (Collections, Stored Procedures, Triggers, UDFs, Documents, and Attachments). In order to access administrative resources (Database Accounts, Databases, Users, Permission, and Offers) require AzureData is configured using a master key."
            case .noMoreResultsError: return "Response.next() has been called but there are no more results to fetch. Must check that Response.hasMoreResults is true before calling Response.next()."
            case .noPartitionKeyRange: return "The request to get the partition key ranges of a collection didn't return any partition key range. This request was probably executed while performing a cross partition query."
            case .resourceRequestError(let error): return error.localizedDescription
            default: return ""
            }
        }
    }
    
    /// Gets the activity ID associated with the request from the Azure Cosmos DB service.
    public private(set) var activityId: String? = nil

    /// Gets the error code associated with the exception in the Azure Cosmos DB service.
    var resourceError: ErrorMessage? = nil
    
    /// Gets a message that describes the current exception from the Azure Cosmos DB service.
    public var message: String {
        let errorDescription = "❌ \(kind) ❌" + (kind.message.isEmpty ? "" : "   \(kind.message)")
        let baseErrorDescription = baseError != nil ? "\n\(baseError!.localizedDescription)" : ""
        let resourceErrorDescription = resourceError != nil ? "\n\(resourceError!.formattedMessage)" : ""
        return errorDescription + baseErrorDescription + resourceErrorDescription + "\n .........\n"
    }
    
    /// Cost of the request in the Azure Cosmos DB service.
    public private(set) var requestCharge: Double? = nil
    
    /// Gets the headers associated with the response from the Azure Cosmos DB service.
    public private(set) var responseHeaders: [String:Any]? = nil
    
    /// Gets the recommended time interval after which the client can retry failed requests from
    /// the Azure Cosmos DB service
    public private(set) var retryAfter: TimeInterval? = nil
    
    /// Gets or sets the request status code in the Azure Cosmos DB service.
    public private(set) var statusCode: HttpStatusCode? = nil
    
    /// Kind of error.
    public private(set) var kind: ErrorKind = .unknownError
    
    /// A nested error.
    public private(set) var baseError: Error? = nil
    
    /// A URLError
    public var urlError: URLError? { return baseError as? URLError }
    
    public init(withError error: Error) {
        self.baseError = error
    }

    public init(withKind kind: ErrorKind) {
        self.kind = kind
    }
    
    public init(withData data: Data?, response: HTTPURLResponse?, error: Error? = nil) {
        
        if let response = response {
            
            var headers = [String:Any]()
            
            for header in response.allHeaderFields {
                if let keyString = header.key as? String {
                    headers[keyString] = header.value
                }
            }
            
            self.responseHeaders = headers

            self.activityId = headers[.msActivityId] as? String
            self.requestCharge = headers[.msRequestCharge] as? Double
            self.retryAfter = headers[.msRetryAfterMs] as? Double
            
            if let code = HttpStatusCode(rawValue: response.statusCode) {
                self.statusCode = code
                self.kind = code.errorKind
            }
        }

        if let data = data, let errorMessage = try? JSONDecoder().decode(ErrorMessage.self, from: data) {
            self.resourceError = errorMessage
        }
        
        self.baseError = error
    }
}

struct ErrorMessage : Decodable {
    
    let code: String
    let message: String
    
    var formattedMessage: String {
        
        let m = message.replacingOccurrences(of: "Message: {\"Errors\":[\"", with: "")
                       .replacingOccurrences(of: "\",\"", with: " | ")
                       .replacingOccurrences(of: "\"]}", with: "")
                       .replacingOccurrences(of: ", ActivityId:", with: "\nActivityId:")
                       .replacingOccurrences(of: ", Request", with: "\nRequest")
                       .replacingOccurrences(of: ", SDK:", with: "\nSDK:")
        
        return (code.isEmpty ? "" : code + " | ") + (!m.isEmpty ? m : message)
    }
}

extension HttpStatusCode {
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


extension Optional where Wrapped == DocumentClientError {
    public var isConnectivityError: Bool {
        return self?.baseError?.isConnectivityError ?? false
    }
}

extension DocumentClientError : CustomStringConvertible {
    public var description: String {
        return self.message
    }
}

extension DocumentClientError : CustomDebugStringConvertible {
    public var debugDescription: String {
        return self.message
    }
}

extension DocumentClientError {
    public var localizedDescription: String {
        return self.message
    }
}

extension Response {
    
    public var clientError: DocumentClientError? {
        return error as? DocumentClientError
    }
    
    public func logError() {
        
        if let error = clientError?.kind, case .preconditionFailure = error { return }
        
        if let errorMessage = clientError?.localizedDescription ?? error?.localizedDescription {
            Log.error(errorMessage)
        }
    }
}

extension Error {
    var isConnectivityError: Bool {
        return (self as NSError).code == URLError.notConnectedToInternet.rawValue
    }
}
