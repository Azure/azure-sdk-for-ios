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
    
    public var lowercased: String {
        switch self {
        case .get:      return "get"
        case .head:     return "head"
        case .post:     return "post"
        case .put:      return "put"
        case .delete:   return "delete"
        }
    }
    
    public var read: Bool {
        switch self {
        case .get, .head:           return true
        case .post, .put, .delete:  return false
        }
    }
    
    public var write: Bool {
        return !read
    }
}


extension URLRequest {
    
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
