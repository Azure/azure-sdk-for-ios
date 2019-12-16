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

public typealias ResultHandler<TSuccess, TError: Error> = (Result<TSuccess, TError>, HttpResponse) -> Void
public typealias HttpResultHandler<T> = ResultHandler<T, Error>
public typealias PipelineStageResultHandler = ResultHandler<PipelineResponse, PipelineError>

/// Protocol for implementing pipeline stages.
public protocol PipelineStageProtocol {
    var next: PipelineStageProtocol? { get set }

    /// Request modification hook.
    /// - Parameters:
    ///   - request: The `PipelineRequest` input.
    ///   - completion: A completion handler which forwards the modified request.
    func onRequest(_ request: PipelineRequest, then completion: @escaping (PipelineRequest) -> Void)

    /// Response modification hook.
    /// - Parameters:
    ///   - response: The `PipelineResponse` input.
    ///   - completion: A completion handler which forwards the modified response.
    func onResponse(_ response: PipelineResponse, then completion: @escaping (PipelineResponse) -> Void)

    /// Response error hook.
    /// - Parameters:
    ///   - error: The `PipelineError` input.
    ///   - completion: A completion handler which forwards the error along with a boolean
    ///   that indicates whether the exception was handled or not.
    func onError(_ error: PipelineError, then completion: @escaping (PipelineError, Bool) -> Void)

    /// Executes the policy method.
    /// - Parameters:
    ///   - pipelineRequest: The `PipelineRequest` input.
    ///   - completion: A `PipelineStageResultHandler` completion handler.
    func process(request pipelineRequest: PipelineRequest, then completion: @escaping PipelineStageResultHandler)
}

/// Default implementations for `PipelineStageProtocol`.
extension PipelineStageProtocol {
    public func onRequest(_ request: PipelineRequest, then completion: @escaping (PipelineRequest) -> Void) {
        completion(request)
    }
    public func onResponse(_ response: PipelineResponse, then completion: @escaping (PipelineResponse) -> Void) {
        completion(response)
    }
    public func onError(_ error: PipelineError, then completion: @escaping (PipelineError, Bool) -> Void) {
        completion(error, false)
    }
    public func process(request pipelineRequest: PipelineRequest,
                        then completion: @escaping PipelineStageResultHandler) {
        onRequest(pipelineRequest) { request in
            self.next!.process(request: request) { result, httpResponse in
                switch result {
                case let .success(pipelineResponse):
                    self.onResponse(pipelineResponse) { response in
                        completion(.success(response), httpResponse)
                    }
                case let .failure(pipelineError):
                    self.onError(pipelineError) { error, handled in
                        if !handled {
                            completion(.failure(error), httpResponse)
                        }
                    }
                }
            }
        }
    }
}
