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

public typealias ResultHandler<TSuccess, TError: Error> = (Result<TSuccess, TError>, HTTPResponse?) -> Void
public typealias HTTPResultHandler<T> = ResultHandler<T, AzureError>
public typealias PipelineStageResultHandler = ResultHandler<PipelineResponse, AzureError>
public typealias OnRequestCompletionHandler = (PipelineRequest, AzureError?) -> Void
public typealias OnResponseCompletionHandler = (PipelineResponse, AzureError?) -> Void
public typealias OnErrorCompletionHandler = (AzureError, Bool) -> Void

/// Protocol for implementing pipeline stages.
public protocol PipelineStage {
    // MARK: Required Properties

    var next: PipelineStage? { get set }

    // MARK: Required Methods

    /// Request modification hook.
    /// - Parameters:
    ///   - request: The `PipelineRequest` input.
    ///   - completionHandler: A completion handler which forwards the modified request.
    func on(request: PipelineRequest, completionHandler: @escaping OnRequestCompletionHandler)

    /// Response modification hook.
    /// - Parameters:
    ///   - response: The `PipelineResponse` input.
    ///   - completionHandler: A completion handler which forwards the modified response.
    func on(response: PipelineResponse, completionHandler: @escaping OnResponseCompletionHandler)

    /// Response error hook.
    /// - Parameters:
    ///   - error: The `PipelineError` input.
    ///   - pipelineResponse: The `PipelineResponse` object.
    ///   - completionHandler: A completion handler which forwards the error along with a boolean
    ///   that indicates whether the exception was handled or not.
    func on(
        error: AzureError,
        pipelineResponse: PipelineResponse,
        completionHandler: @escaping OnErrorCompletionHandler
    )

    /// Executes the policy method.
    /// - Parameters:
    ///   - pipelineRequest: The `PipelineRequest` input.
    ///   - completionHandler: A `PipelineStageResultHandler` completion handler.
    func process(request pipelineRequest: PipelineRequest, completionHandler: @escaping PipelineStageResultHandler)
}

/// Default implementations for `PipelineStage`.
public extension PipelineStage {
    func on(request: PipelineRequest, completionHandler: @escaping OnRequestCompletionHandler) {
        completionHandler(request, nil)
    }

    func on(response: PipelineResponse, completionHandler: @escaping OnResponseCompletionHandler) {
        completionHandler(response, nil)
    }

    func on(
        error: AzureError,
        pipelineResponse _: PipelineResponse,
        completionHandler: @escaping OnErrorCompletionHandler
    ) {
        completionHandler(error, false)
    }

    func process(
        request pipelineRequest: PipelineRequest,
        completionHandler: @escaping PipelineStageResultHandler
    ) {
        on(request: pipelineRequest) { request, error in
            // if error occurs during the onRequest phase, back out and
            // propagate immediately
            if let error = error {
                let pipelineResponse = PipelineResponse(
                    request: request.httpRequest,
                    response: nil,
                    logger: request.logger,
                    context: request.context
                )
                self.on(error: error, pipelineResponse: pipelineResponse) { errorOut, handled in
                    if !handled {
                        completionHandler(.failure(errorOut), nil)
                        return
                    }
                }
            }
            self.next!.process(request: request) { result, httpResponse in
                switch result {
                case let .success(pipelineResponse):
                    self.on(response: pipelineResponse) { response, error in
                        if let error = error {
                            self.on(error: error, pipelineResponse: pipelineResponse) { errorOut, handled in
                                if !handled {
                                    completionHandler(.failure(errorOut), httpResponse)
                                    return
                                }
                            }
                        }
                        completionHandler(.success(response), httpResponse)
                    }
                case let .failure(error):
                    let pipelineResponse = PipelineResponse(
                        request: request.httpRequest,
                        response: httpResponse,
                        logger: request.logger,
                        context: request.context
                    )
                    self.on(error: error, pipelineResponse: pipelineResponse) { errorOut, handled in
                        if !handled {
                            completionHandler(.failure(errorOut), httpResponse)
                            return
                        }
                    }
                }
            }
        }
    }
}
