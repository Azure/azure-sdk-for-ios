//
//  HttpMethod.swift
//  AzureCore
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

public enum HttpMethod : String {
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case delete  = "DELETE"
}


public extension URLRequest {
    
    public var method: HttpMethod? {
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
