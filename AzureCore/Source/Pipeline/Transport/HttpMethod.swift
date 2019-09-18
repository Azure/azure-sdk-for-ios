//
//  HttpMethod.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/23/19.
//

import Foundation

@objc public enum HttpMethod: Int, RawRepresentable {
    case GET
    case PUT
    case POST
    case PATCH
    case DELETE
    case HEAD
    case OPTIONS
    case TRACE
    case MERGE

    public typealias RawValue = String

    public var rawValue: RawValue {
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
        case .OPTIONS:
            return "OPTIONS"
        case .TRACE:
            return "TRACE"
        case .MERGE:
            return "MERGE"
        }
    }

    public init?(rawValue: RawValue) {
        let rawUpper = (rawValue as String).uppercased()
        switch rawUpper {
        case "GET":
            self = .GET
        case "PUT":
            self = .PUT
        case "POST":
            self = .POST
        case "PATCH":
            self = .PATCH
        case "DELETE":
            self = .DELETE
        case "HEAD":
            self = .HEAD
        case "OPTIONS":
            self = .OPTIONS
        case "TRACE":
            self = .TRACE
        case "MERGE":
            self = .MERGE
        default:
            fatalError("Unrecognized enum value: \(rawUpper)")
        }
    }
}
