//
//  AzureErrors.swift
//  DemoAppObjC
//
//  Created by Travis Prescott on 8/14/19.
//  Copyright © 2019 Travis Prescott. All rights reserved.
//

import Foundation

@objc public class ErrorUtil: NSObject {
    
    internal static func _makeNSError<T: RawRepresentable>(_ errorType: T, withMessage message: String, userInfo: [String:AnyObject]? = nil) -> NSError {
        var combinedUserInfo: [String:AnyObject] = [
            NSLocalizedDescriptionKey: "ERROR: \(message)" as AnyObject,
        ]
        if let extraUserInfo = userInfo {
            combinedUserInfo = combinedUserInfo.merging(extraUserInfo, uniquingKeysWith: { (_, last) in last })
        }
        let domain = String(reflecting: errorType.self)
        let error = NSError(domain: "\(domain)", code: errorType.rawValue as! Int, userInfo: combinedUserInfo)
        return error
    }
    
    @objc public static func makeNSError(_ errorType: AzureError, withMessage message: String, parameters: [String:String]? = nil) -> NSError {
        return ErrorUtil._makeNSError(errorType, withMessage: message)
    }
    
    @objc public static func makeNSError(_ errorType: HttpResponseError, withMessage message: String, response: HttpResponse?) -> NSError {
        let userInfo = ["response": response as AnyObject]
        return ErrorUtil._makeNSError(errorType, withMessage: message, userInfo: userInfo)
    }
}

@objc public enum AzureError: Int, Error {
    case General
    case ServiceRequest
    case ServiceResponse
}

@objc public enum HttpResponseError: Int, Error {
    case General
    case Decode
    case ResourceExists
    case ResourceNotFound
    case ClientAuthentication
    case ResourceModified
    case TooManyRedirects
}
