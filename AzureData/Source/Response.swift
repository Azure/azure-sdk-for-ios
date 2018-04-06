//
//  Response.swift
//  AzureData iOS
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

public struct Response<T> {
    
    public let request: URLRequest?
    
    public let response: HTTPURLResponse?
    
    public let data: Data?
    
    public let result: Result<T>
    
    public var error: Error? { return result.error }
    
    public var resource: T?  { return result.resource }
    
    public init(request: URLRequest?, data: Data?, response: HTTPURLResponse?, result: Result<T>) {
        self.request = request
        self.data = data
        self.response = response
        self.result = result
    }
    
    public init (_ resource: T) {
        self.init(request: nil, data: nil, response: nil, result: .success(resource))
    }
    
    public init (_ error: Error) {
        self.init(request: nil, data: nil, response: nil, result: .failure(error))
    }
}


public enum Result<T> {
    case success(T)
    case failure(Error)
    
    public var isSuccess: Bool {
        switch self {
        case .success: return true
        case .failure: return false
        }
    }
    
    public var isFailure: Bool { return !isSuccess }
    
    public var resource: T? {
        switch self {
        case .success(let resource): return resource
        case .failure: return nil
        }
    }
    
    public var error: Error? {
        switch self {
        case .success: return nil
        case .failure(let error): return error
        }
    }
}


extension Response where T:CodableResource {

    public init(request: URLRequest?, data: Data?, response: HTTPURLResponse?, result: Result<T>) {
        self.request = request
        self.data = data
        self.response = response
        self.result = result
    }

    
    
}

//extension Response where T == Resources<CodableResource> {
//
//}


// MARK: - CustomStringConvertible

extension Result: CustomStringConvertible {
    public var description: String {
        switch self {
        case .success: return "✅ SUCCESS"
        case .failure: return "❌ FAILURE"
        }
    }
}

// MARK: - CustomDebugStringConvertible

extension Result: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .success(let value): return "✅ SUCCESS: \(value)"
        case .failure(let error): return "❌ FAILURE: \(error)"
        }
    }
}
