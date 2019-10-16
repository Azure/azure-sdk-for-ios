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

public protocol PipelineStageProtocol {
    var next: PipelineStageProtocol? { get set }

    func onRequest(_ request: inout PipelineRequest)
    func onResponse(_ response: inout PipelineResponse)
    func onError(_ error: PipelineError) -> Bool

    func process(request: inout PipelineRequest, completion: @escaping PipelineStageResultHandler)
}

extension PipelineStageProtocol {
    public func onRequest(_: inout PipelineRequest) {}
    public func onResponse(_: inout PipelineResponse) {}
    public func onError(_: PipelineError) -> Bool { return false }

    public func process(request: inout PipelineRequest, completion: @escaping PipelineStageResultHandler) {
        onRequest(&request)
        next!.process(request: &request, completion: { result, httpResponse in
            switch result {
            case var .success(pipelineResponse):
                self.onResponse(&pipelineResponse)
                completion(.success(pipelineResponse), httpResponse)
            case let .failure(error):
                let handled = self.onError(error)
                if !handled {
                    completion(.failure(error), httpResponse)
                }
            }
        })
    }
}
