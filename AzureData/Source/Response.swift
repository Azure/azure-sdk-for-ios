//
//  Response.swift
//  AzureData iOS
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

public struct Response<T:CodableResource> {
    
    public let request: URLRequest?
    
    public let response: HTTPURLResponse?
    
    public let data: Data?
    
    public let result: Result<T>
    
    public var resource: T? { return result.resource }
    
    public var error: Error? { return result.error }
    
    public init(request: URLRequest?, data: Data?, response: HTTPURLResponse?, result: Result<T>) {
        self.request = request
        self.data = data
        self.response = response
        self.result = result
    }
    
    public init (_ error: Error) {
        self.init(request: nil, data: nil, response: nil, result: .failure(error))
    }
}


public struct ListResponse<T:CodableResource> {
    
    public let request: URLRequest?
    
    public let response: HTTPURLResponse?
    
    public let data: Data?
    
    public let result: ListResult<T>
    
    public var resource: Resources<T>? { return result.resource }
    
    public var error: Error? { return result.error }
    
    public init(request: URLRequest?, data: Data?, response: HTTPURLResponse?, result: ListResult<T>) {
        self.request = request
        self.data = data
        self.response = response
        self.result = result
    }
    
    public init (_ error: Error) {
        self.init(request: nil, data: nil, response: nil, result: .failure(error))
    }
}


public struct DataResponse {
    
    public let request: URLRequest?
    
    public let response: HTTPURLResponse?
    
    public var data: Data? { return result.resource }
    
    public let result: DataResult
    
    public var error: Error? { return result.error }
    
    public init(request: URLRequest?, data: Data?, response: HTTPURLResponse?, result: DataResult) {
        self.request = request
        self.response = response
        self.result = result
    }
    
    public init (_ error: Error) {
        self.init(request: nil, data: nil, response: nil, result: .failure(error))
    }
}


public enum Result<T:CodableResource> {
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


public enum ListResult<T:CodableResource> {
    case success(Resources<T>)
    case failure(Error)
    
    public var isSuccess: Bool {
        switch self {
        case .success: return true
        case .failure: return false
        }
    }
    
    public var isFailure: Bool { return !isSuccess }
    
    public var resource: Resources<T>? {
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


public enum DataResult {
    case success(Data)
    case failure(Error)
    
    public var isSuccess: Bool {
        switch self {
        case .success: return true
        case .failure: return false
        }
    }
    
    public var isFailure: Bool { return !isSuccess }

    public var resource: Data? {
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



// MARK: - CustomStringConvertible

extension Result: CustomStringConvertible {
    public var description: String {
        switch self {
        case .success: return "✅ SUCCESS"
        case .failure: return "❌ FAILURE"
        }
    }
}

extension ListResult: CustomStringConvertible {
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

extension ListResult: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .success(let value): return "✅ SUCCESS: \(value)"
        case .failure(let error): return "❌ FAILURE: \(error)"
        }
    }
}
