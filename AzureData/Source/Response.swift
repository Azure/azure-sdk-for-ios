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
        guard let continuation = msContinuation else { return false }
        return !continuation.isEmpty
    }

    public func next(callback: @escaping (Response<T>) -> ()) {
        assert(request != nil && response != nil, "`next` must be called after an initial set of items have been fetched.")

        guard let continuation = msContinuation else {
            Log.debug("No more items to fetch.")
            callback(Response(DocumentClientError(withKind: .noMoreResultsError)))
            return
        }

        var continuationRequest = request!
        continuationRequest.addValue(continuation, forHTTPHeaderField: .msContinuation)

        return DocumentClient.shared.sendRequest(continuationRequest, callback: callback)
    }
}

// MARK: _

extension Response where T == Data {
    func resourceResponse<U: CodableResource>() -> Response<U> {
        return decodableResponse { data in
            var resource = try DocumentClient.shared.jsonDecoder.decode(U.self, from: data)
            resource.setAltLink(withContentPath: msAltContentPath)

            return resource
        }
    }

    func resourcesResponse<U: CodableResources>() -> Response<U> {
        return decodableResponse { data -> U in
            var resources = try DocumentClient.shared.jsonDecoder.decode(U.self, from: data)
            resources.setAltLinks(withContentPath: msAltContentPath)

            return resources
        }
    }

    private func decodableResponse<U: Decodable>(decode: (Data) throws -> U) -> Response<U> {
        do {
            switch result {
            case .success(let data):
                return try Response<U>(request: request, data: self.data, response: response, result: .success(decode(data)), fromCache: fromCache)

            case .failure(let error):
                return Response<U>(request: request, data: data, response: response, result: Result.failure(error), fromCache: fromCache)
            }
        } catch {
            return Response<U>(request: request, data: data, response: response, result: .failure(DocumentClientError(withError: error)), fromCache: fromCache)
        }
    }
}

// MARK: -

extension Response {
    var msAltContentPath: String? {
        return response?.allHeaderFields[MSHttpHeader.msAltContentPath.rawValue] as? String
    }

    var msContinuation: String? {
        return response?.allHeaderFields[MSHttpHeader.msContinuation.rawValue] as? String
    }

    var msContentPath: String? {
        return response?.allHeaderFields[MSHttpHeader.msContentPath.rawValue] as? String
    }
}
