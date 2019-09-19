//
//  AzureErrors.swift
//  DemoAppObjC
//
//  Created by Travis Prescott on 8/14/19.
//  Copyright © 2019 Travis Prescott. All rights reserved.
//

import Foundation

//public class ErrorUtil {
//
//    internal static func createNSError<T: RawRepresentable>(_ errorType: T, withMessage message: String,
//                                                            userInfo: [String: AnyObject]? = nil) -> NSError {
//        var combinedUserInfo: [String: AnyObject] = [
//            NSLocalizedDescriptionKey: "ERROR: \(message)" as AnyObject
//        ]
//        if let extraUserInfo = userInfo {
//            combinedUserInfo = combinedUserInfo.merging(extraUserInfo, uniquingKeysWith: { (_, last) in last })
//        }
//        let domain = String(reflecting: errorType.self)
//        let code = errorType.rawValue as? Int ?? -1
//        let error = NSError(domain: "\(domain)", code: code, userInfo: combinedUserInfo)
//        return error
//    }
//
//    public static func makeNSError(_ errorType: AzureError, withMessage message: String,
//                                         parameters: [String: String]? = nil) -> NSError {
//        return ErrorUtil.createNSError(errorType, withMessage: message)
//    }
//
//    public static func makeNSError(_ errorType: HttpResponseError, withMessage message: String,
//                                         response: HttpResponse?) -> NSError {
//        let userInfo = ["response": response as AnyObject]
//        return ErrorUtil.createNSError(errorType, withMessage: message, userInfo: userInfo)
//    }
//}

public enum AzureError: Error {
    case general
    case serviceRequest
    case serviceResponse
}

public enum HttpResponseError: Error {
    case general
    case decode
    case resourceExists
    case resourceNotFound
    case clientAuthentication
    case resourceModified
    case tooManyRedirects
}
