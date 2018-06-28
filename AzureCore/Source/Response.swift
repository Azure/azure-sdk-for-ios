//
//  Response.swift
//  AzureCore
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
    
    public var fromCache: Bool = false
    
    public var metadata: Any?
    
    public init(request: URLRequest?, data: Data?, response: HTTPURLResponse?, result: Result<T>, fromCache: Bool = false) {
        self.request = request
        self.data = data
        self.response = response
        self.result = result
        self.fromCache = fromCache
    }
    
    public init (_ resource: T, fromCache: Bool = false) {
        self.init(request: nil, data: nil, response: nil, result: .success(resource), fromCache: fromCache)
    }
    
    public init (_ error: Error, fromCache: Bool = false) {
        self.init(request: nil, data: nil, response: nil, result: .failure(error), fromCache: fromCache)
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


extension Response {
    public func map<U>(_ transform: (T) throws -> U) -> Response<U> {
        return Response<U>(
            request: request,
            data: data,
            response: response,
            result: result.map(transform),
            fromCache: fromCache
        )
    }
}

extension Result {
    public func map<U>(_ transform: (T) throws -> U) -> Result<U> {
        do {
            return try isSuccess ? Result<U>.success(transform(resource!)) : Result<U>.failure(error!)
        } catch {
            return Result<U>.failure(error)
        }
    }
}

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
