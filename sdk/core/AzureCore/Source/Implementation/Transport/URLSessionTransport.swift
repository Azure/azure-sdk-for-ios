// --------------------------------------------------------------------------
//
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// The MIT License (MIT)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the ""Software""), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
//
// --------------------------------------------------------------------------

import Foundation
import os

public enum URLSessionTransportError: Error {
    case invalidSession
}

public class URLSessionTransport: HTTPTransportStage {

    // MARK: Properties

    private var session: URLSession?
    private var config: URLSessionConfiguration
    private let operationQueue: OperationQueue

    private var _next: PipelineStage?
    public var next: PipelineStage? {
        get {
            return _next
        }

        // swiftlint:disable:next unused_setter_value
        set {
            _next = nil
        }
    }

    // MARK: Initializers

    public init() {
        config = URLSessionConfiguration.default
        operationQueue = OperationQueue()
        operationQueue.name = "com.domain.AzureCore.networkQueue"
    }

    // MARK: HTTPTransportStage Methods

    public func open() {
        guard session == nil else { return }
        session = URLSession(configuration: config, delegate: nil, delegateQueue: operationQueue)
    }

    public func close() {
        session = nil
    }

    public func sleep(duration: Int) {
        Foundation.sleep(UInt32(duration))
    }

    // MARK: PipelineStage Methods

    public func process(request pipelineRequest: PipelineRequest,
                        then completion: @escaping PipelineStageResultHandler) {
        open()
        guard let session = self.session else {
            pipelineRequest.logger.error("Invalid session.")
            return
        }
        var urlRequest = URLRequest(url: URL(string: pipelineRequest.httpRequest.url)!)
        urlRequest.httpMethod = pipelineRequest.httpRequest.httpMethod.rawValue
        urlRequest.allHTTPHeaderFields = pipelineRequest.httpRequest.headers

        // need immutable copies to pass into the closure. At this point, these can't change
        // anyways.
        let httpRequest = pipelineRequest.httpRequest
        let responseContext = pipelineRequest.context
        let logger = pipelineRequest.logger

        session.dataTask(with: urlRequest) { data, response, error in
            let rawResponse = response as? HTTPURLResponse
            let httpResponse = URLHTTPResponse(request: httpRequest, response: rawResponse)
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
