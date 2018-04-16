//
//  Response.swift
//  AzureData iOS
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCore

public struct Response<T> {
    
    public let request: URLRequest?
    
    public let response: HTTPURLResponse?
    
    public let data: Data?
    
    public let result: Result<T>
    
    public var error: Error? { return result.error }
    
    public var resource: T?  { return result.resource }
    
    public var fromCache: Bool = false

    public lazy var metadata: ResponseMetadata? = response.flatMap { ResponseMetadata(for: $0) }

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

// MARK: - Pagination support

extension Response where T: CodableResources {
    public var hasMoreResults: Bool {
        guard let continuation = response?.msContinuationHeader else { return false }
        return !continuation.isEmpty
    }

    public func next(callback: @escaping (Response<T>) -> ()) {
        assert(request != nil && response != nil, "`next` must be called after an initial set of items have been fetched.")

        guard let continuation = response?.msContinuationHeader else {
            Log.debug("No more items to fetch.")
            callback(Response(DocumentClientError(withKind: .noMoreResultsError)))
            return
        }

        var continuationRequest = request!
        continuationRequest.addValue(continuation, forHTTPHeaderField: .msContinuation)

        return DocumentClient.shared.sendRequest(continuationRequest, callback: callback)
    }
}
