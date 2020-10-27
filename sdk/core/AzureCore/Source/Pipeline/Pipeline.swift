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
    // MARK: Properties

    private var policies: [PipelineStage]

    private let transport: TransportStage

    private var retryPolicy: RetryPolicy? {
        if let index = retryIndex {
            return policies[index] as? RetryPolicy
        }
        return nil
    }

    private var retryIndex: Int? {
        return policies.firstIndex { $0 as? RetryPolicy != nil }
    }

    // MARK: Initializers

    public init(transport: TransportStage, policies: [PipelineStage], withOptions options: TransportOptions? = nil) {
        self.policies = policies
        self.transport = transport

        // Add in any user-supplied policies
        if let retryIndex = self.retryIndex {
            let perRequestPolicies = Array(self.policies[0 ... retryIndex])
            let perRetryPolicies = Array(self.policies[retryIndex...])
            let userPerRequestPolicies = options?.perRequestPolicies ?? []
            let userPerRetryPolicies = options?.perRetryPolicies ?? []
            let combinedPolicies = perRequestPolicies + userPerRequestPolicies + perRetryPolicies + userPerRetryPolicies
            self.policies = combinedPolicies
        } else {
            // Append user policies if no retry policy
            assert(options?.perRetryPolicies == nil, "User supplied per-retry policies, but no retry policy exists.")
            self.policies = policies + (options?.perRequestPolicies ?? [])
        }

        // Link the policies together
        var prevPolicy: PipelineStage?
        for policy in self.policies {
            if prevPolicy != nil {
                prevPolicy!.next = policy
            }
            prevPolicy = policy
        }
    }

    // MARK: Methods

    public func run(request: PipelineRequest, completionHandler: @escaping PipelineStageResultHandler) {
        // special case where there is only a transport stage
        guard let firstPolicy = policies.first else {
            transport.process(request: request) { result, httpResponse in
                switch result {
                case let .success(pipelineResponse):
                    completionHandler(.success(pipelineResponse), httpResponse)
                case let .failure(error):
                    completionHandler(.failure(error), httpResponse)
                }
            }
            return
        }
        // normal case where there are policies
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
