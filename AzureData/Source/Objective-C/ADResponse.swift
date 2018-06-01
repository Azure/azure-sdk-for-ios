//
//  ADResponse.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCore

@objc(ADResponse)
public class ADResponse: NSObject {

    @objc
    public var request: URLRequest? { return _response.request }

    @objc
    public var response: HTTPURLResponse? { return _response.response }

    @objc
    public var data: Data? { return _response.data }

    @objc
    public var result: ObjCResult { return ObjCResult(_response.result) }

    @objc
    public var resource: AnyObject? { return result.resource }

    @objc
    public var error: Error? { return result.error }

    @objc
    public var fromCache: Bool { return _response.fromCache }

    @objc
    public var metadata: ADResponseMetadata? { return ADResponseMetadata(_response.metadata) }

    private var _response: Response<AnyObject>

    @objc
    public init(request: URLRequest?, data: Data?, response: HTTPURLResponse?, result: ObjCResult, fromCache: Bool = false) {
        self._response = Response(request: request, data: data, response: response, result: Result<AnyObject>(bridgedFromObjectiveC: result), fromCache: fromCache)
    }

    internal init(_ response: Response<AnyObject>) {
        self._response = response
    }

    internal init<T: AnyObject>(erasingTypeOf: Response<T>) {
        self._response = erasingTypeOf.map { $0 as AnyObject }
    }
}

@objc(ADResult)
public class ObjCResult: NSObject {
    @objc
    public var isSuccess: Bool { return result.isSuccess }

    @objc
    public var isFailure: Bool { return result.isFailure }

    @objc
    public var resource: AnyObject? { return result.resource }

    @objc
    public var error: Error? { return result.error }

    private var result: Result<AnyObject>

    @objc
    public init(resource: AnyObject) {
        self.result = .success(resource)
    }

    @objc
    public init(error: Error) {
        self.result = .failure(error)
    }

    internal init(_ result: Result<AnyObject>) {
        self.result = result
    }
}

// MARK: -

extension Response: ObjectiveCBridgeable where T: ObjectiveCBridgeable {
    typealias ObjectiveCType = ADResponse

    func bridgeToObjectiveC() -> ADResponse {
        return ADResponse(self.map { $0.bridgeToObjectiveC() })
    }

    init?(bridgedFromObjectiveC: ADResponse) {
        self.init(
            request: bridgedFromObjectiveC.request,
            data: bridgedFromObjectiveC.data,
            response: bridgedFromObjectiveC.response,
            result: Result<T>(unconditionallyBridgedFromObjectiveC: bridgedFromObjectiveC.result),
            fromCache: bridgedFromObjectiveC.fromCache
        )
    }
}

extension Response where T == DictionaryDocument {
    func bridgeToObjectiveC(withDocumentType documentType: ADDocument.Type) -> ADResponse {
        if let resource = resource, let document = documentType.init(from: resource.dataMergedWithSystemKeysAndValues) {
            return ADResponse(erasingTypeOf: self.map { _ in document })
        }

        return ADResponse(Response<AnyObject>(request: request, data: data, response: response, result: Result<AnyObject>.failure(DocumentClientError(withKind: .internalError)), fromCache: fromCache))
    }
}

extension Response where T == Resources<DictionaryDocument> {
    func bridgeToObjectiveC(withDocumentType documentType: ADDocument.Type) -> ADResponse {
        return ADResponse(erasingTypeOf: self.map { resources -> ADResources in
            let items = resources.items.compactMap { documentType.init(from: $0.dataMergedWithSystemKeysAndValues) }
            return ADResources(resourceId: resources.resourceId, count: items.count, items: items)
        })
    }
}

extension Result: ObjectiveCBridgeable where T: ObjectiveCBridgeable {
    typealias ObjectiveCType = ObjCResult

    func bridgeToObjectiveC() -> ObjCResult {
        return ObjCResult(self.map { $0.bridgeToObjectiveC() })
    }

    init?(bridgedFromObjectiveC: ObjCResult) {
        if bridgedFromObjectiveC.isSuccess {
            self = Result<T>.success(T.init(bridgedFromObjectiveC: bridgedFromObjectiveC.resource! as! T.ObjectiveCType)!)
            return
        }

        self = Result<T>.failure(bridgedFromObjectiveC.error!)
    }
}

extension Result where T == AnyObject {
    init(bridgedFromObjectiveC: ObjCResult) {
        if bridgedFromObjectiveC.isSuccess {
            self = Result<T>.success(bridgedFromObjectiveC.resource!)
            return
        }

        self = Result<T>.failure(bridgedFromObjectiveC.error!)
    }
}

extension Data: ObjectiveCBridgeable {
    typealias ObjectiveCType = NSData

    func bridgeToObjectiveC() -> NSData {
        return NSData(data: self)
    }
}
