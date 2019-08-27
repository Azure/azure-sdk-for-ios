//
//  HttpMethod.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/23/19.
//

import Foundation

@objc
public enum HttpMethod: UInt {
    case GET
    case PUT
    case POST
    case PATCH
    case DELETE
    case HEAD
    
    func name() -> String {
        switch self {
        case .GET:
            return "GET"
        case .PUT:
            return "PUT"
        case .POST:
            return "POST"
        case .PATCH:
            return "PATCH"
        case .DELETE:
            return "DELETE"
        case .HEAD:
            return "HEAD"
        }
    }
}
