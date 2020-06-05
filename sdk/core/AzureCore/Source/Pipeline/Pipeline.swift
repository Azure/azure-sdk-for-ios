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

internal class Pipeline {
    private var policies: [PipelineStage]
    private let transport: HTTPTransportStage

    public init(transport: HTTPTransportStage, policies: [PipelineStage]) {
        self.transport = transport
        self.policies = policies
        var prevPolicy: PipelineStage?
        for policy in policies {
            if prevPolicy != nil {
                prevPolicy!.next = policy
            }
            prevPolicy = policy
        }
        if self.policies.count > 0 {
            var lastPolicy = self.policies.removeLast()
            lastPolicy.next = transport
            self.policies.append(lastPolicy)
        } else {
            self.policies.append(transport)
        }
    }

    public func run(request: PipelineRequest, completionHandler: @escaping PipelineStageResultHandler) {
        let firstPolicy = policies.first ?? transport
        firstPolicy.process(request: request) { result, httpResponse in
            switch result {
            case let .success(pipelineResponse):
                completionHandler(.success(pipelineResponse), httpResponse)
            case let .failure(error):
                completionHandler(.failure(error), httpResponse)
            }
        }
    }
}
