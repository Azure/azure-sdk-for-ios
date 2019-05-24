//
//  ResponseExtensions.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCore

extension Response {
    
    public mutating func responseMetadata() -> ResponseMetadata? {
        
        if let data = metadata as? ResponseMetadata {
            return data
        }
        
        let newMetadata = response.flatMap { ResponseMetadata(for: $0) }
        
        metadata = newMetadata
        
        return newMetadata
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

       guard let resources = resource,
             let location = resources.items.first?.parentLocation,
             let continuation = response?.msContinuation,
             !continuation.isEmpty else {
            Log.debug("No more items to fetch.")
            callback(Response(DocumentClientError(withKind: .noMoreResultsError)))
            return
        }

        var continuationRequest = request!
        continuationRequest.addValue(continuation, forHTTPHeaderField: .msContinuation)

        return DocumentClient.shared.resources(at: location, additionalHeaders: [MSHttpHeader.msContinuation.rawValue: continuation], callback: callback)
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

// MARK: -

extension Response where T: OptionalType {
    func unwrap(orErrorWith error: @autoclosure () -> Error) -> Response<T.Wrapped> {
        return Response<T.Wrapped>(
            request: request,
            data: data,
            response: response,
            result: {
                guard case let .success(resource) = result, resource.optional != nil
                    else { return .failure(error()) }
                return .success(resource.optional!)
            }(),
            fromCache: fromCache
        )
    }
}

protocol OptionalType {
    associatedtype Wrapped
    var optional: Wrapped? { get }
}

extension Optional: OptionalType {
    var optional: Wrapped? {
        return self
    }
}
