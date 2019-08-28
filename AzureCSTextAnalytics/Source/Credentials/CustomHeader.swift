//
//  HttpHeaders.swift
//  DemoAppObjC
//
//  Created by Travis Prescott on 8/8/19.
//  Copyright © 2019 Travis Prescott. All rights reserved.
//

import Foundation

@objc public enum HttpHeader: Int, RawRepresentable {
    case authorization
    case host
    case date
    case contentHash
    case ocpApimSubscriptionKey
    case ocpApimSubscriptionRegion
    
    public typealias RawValue = String
    
    public var rawValue: RawValue {
        switch self {
        case .authorization:
            return "Authorization"
        case .host:
            return "Host"
        case .date:
            return "x-ms-date"
        case .contentHash:
            return "x-ms-content-sha256"
        case .ocpApimSubscriptionKey:
            return "Ocp-Apim-Subscription-Key"
        case .ocpApimSubscriptionRegion:
            return "Ocp-Apim-Subscription-Region"
        }
    }
    
    public init?(rawValue: RawValue) {
        switch rawValue {
            case "Authorization":
                self = .authorization
            case "Host":
                self = .host
            case "Date":
                self = .date
            case "x-ms-content-sha256":
                self = .contentHash
            case "Ocp-Apim-Subscription-Key":
                self = .ocpApimSubscriptionKey
            case "Ocp-Apim-Subscription-Region":
                self = .ocpApimSubscriptionRegion
            default:
                return nil
        }
    }
}

extension HttpHeader: CaseIterable {}
