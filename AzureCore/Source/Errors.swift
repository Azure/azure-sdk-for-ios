//
//  AzureErrors.swift
//  DemoAppObjC
//
//  Created by Travis Prescott on 8/14/19.
//  Copyright © 2019 Travis Prescott. All rights reserved.
//

import Foundation

@objc public class AzureError: NSObject, Error {

    @objc public let innerError: String?
//    @objc public let errorType: String
//    @objc public let errorValue: String
//    @objc public let errorTraceback: String
    @objc public let errorMessage: String
    @objc public let message: String?
    
    @objc convenience public init(message: String) {
        self.init(message: message, errorKwargs: nil)
    }
    
    @objc public init(message: String?, errorKwargs: [String:String]?) {
        self.innerError = errorKwargs?["error"]
        // TODO: get error type, value, traceback
        self.errorMessage = "ERROR: \(message)"
        self.message = message
    }
    
    @objc public func throwWithTraceback() throws {
        // TODO: handle traceback
        throw self
    }
}

@objc public class ServiceRequestError: AzureError {}

@objc public class ServiceResponseError: AzureError {}

@objc public class HttpResponseError: AzureError {
    
    @objc public let reason: String?
    @objc public let statusCode: Int
    @objc public var response: HttpResponse?
    
    @objc public init(message: String?, response: HttpResponse?) {
        // TODO: implement response reason
        let reason  = "TBD"
        let statusCode = response?.statusCode ?? -1
        let finalMessage = message ?? "Operation returned an invalid status '\(reason)'"
        // TODO: Add a bunch of crazy error handling code here
        self.reason = reason
        self.statusCode = statusCode
        super.init(message: finalMessage, errorKwargs: nil)
    }
}

@objc public class DecodeError: HttpResponseError {}

@objc public class ResourceExistsError: HttpResponseError {}

@objc public class ResourceNotFoundError: HttpResponseError {}

@objc public class ClientAuthenticationError: HttpResponseError {}

@objc public class ResourceModifiedError: HttpResponseError {}

@objc public class TooManyRedirectsError: HttpResponseError {}
