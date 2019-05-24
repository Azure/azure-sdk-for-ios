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
    
    public let result: Result<T, Error>
    
    public var error: Error? {
        switch result {
        case .failure(let error): return error
        default: return nil
        }
    }
    
    public var resource: T?  {
        switch result {
        case .success(let resource): return resource
        default: return nil
        }
    }
    
    public var fromCache: Bool = false
    
    public var metadata: Any?
    
    public init(request: URLRequest?, data: Data?, response: HTTPURLResponse?, result: Result<T, Error>, fromCache: Bool = false) {
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

extension Response {
    public func map<U>(_ transform: @escaping (T) throws -> U) -> Response<U> {
        return Response<U>(
            request: request,
            data: data,
            response: response,
            result: {
                switch result {
                case .success(let resource):
                    return Result { try transform(resource) }
                case .failure(let error):
                    return Result<U, Error>.failure(error)
                }
            }(),
            fromCache: fromCache
        )
    }
}
