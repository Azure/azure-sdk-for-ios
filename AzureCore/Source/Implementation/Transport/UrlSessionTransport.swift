//
//  UrlSessionTransport.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/30/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import os
import Foundation

public enum UrlSessionTransportError: Error {
    case invalidSession
}

public class UrlSessionTransport: HttpTransportable {

    private var session: URLSession?
    private var config: URLSessionConfiguration
    private let operationQueue: OperationQueue

    private var _next: PipelineStageProtocol?
    public var next: PipelineStageProtocol? {
        get {
            return _next
        }

        // swiftlint:disable:next unused_setter_value
        set {
            _next = nil
        }
    }

    public init() {
        self.config = URLSessionConfiguration.default
        self.operationQueue = OperationQueue()
        self.operationQueue.name = "com.domain.AzureCore.networkQueue"
    }

    public func open() {
        guard self.session == nil else { return }
        self.session = URLSession(configuration: self.config, delegate: nil, delegateQueue: self.operationQueue)
    }

    public func close() {
        self.session = nil
    }

    public func sleep(duration: Int) {
        Foundation.sleep(UInt32(duration))
    }

    public func onRequest(_ request: inout PipelineRequest) {}
    public func onResponse(_ response: inout PipelineResponse) {}
    public func onError(request: PipelineRequest) -> Bool { return false }

    public func process(request: inout PipelineRequest, completion: @escaping PipelineStageResultHandler) {
        self.open()
        guard let session = self.session else {
            os_log("Invalid session.")
            return
        }
        var urlRequest = URLRequest(url: URL(string: request.httpRequest.url)!)
        urlRequest.httpMethod = request.httpRequest.httpMethod.rawValue
        urlRequest.allHTTPHeaderFields = request.httpRequest.headers

        // need immutable copies to pass into the closure. At this point, these can't change
        // anyways.
        let httpRequest = request.httpRequest
        let responseContext = request.context
        let logger = request.logger

        session.dataTask(with: urlRequest) { (data, response, error) in
            let rawResponse = response as? HTTPURLResponse
            let httpResponse = UrlHttpResponse(request: httpRequest, response: rawResponse)
            httpResponse.data = data

            let pipelineResponse = PipelineResponse(request: httpRequest, response: httpResponse,
                                                    logger: logger, context: responseContext)
            if let error = error {
                completion(.failure(PipelineError(fromError: error, pipelineResponse: pipelineResponse)), httpResponse)
            } else {
                completion(.success(pipelineResponse), httpResponse)
            }
        }.resume()
    }
}
