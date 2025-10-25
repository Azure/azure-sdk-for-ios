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

class Pipeline {
    // MARK: Properties

    var policies: [PipelineStage]

    let transport: TransportStage

    // MARK: Initializers

    public init(transport: TransportStage, policies: [PipelineStage], withOptions options: TransportOptions? = nil) {
        self.transport = transport
        self.policies = [PipelineStage]()

        // Add in any user-supplied policies
        // Policy order is:
        //   SDK-supplied perRequest policies
        //   User-supplied perRequest policies
        //   SDK-supplied Retry Policy
        //     SDK-supplied perRetry policies
        //     User-suppied perRetry policies
        var combinedPolicies: [PipelineStage]
        if let retryIndex = policies.retryIndex {
            let perRequestPolicies = Array(policies[0 ..< retryIndex])
            let perRetryPolicies = Array(policies[retryIndex...])
            let userPerRequestPolicies = options?.perRequestPolicies ?? []
            let userPerRetryPolicies = options?.perRetryPolicies ?? []
            combinedPolicies = perRequestPolicies + userPerRequestPolicies + perRetryPolicies + userPerRetryPolicies
        } else {
            // Append user policies if no retry policy
            assert(options?.perRetryPolicies == nil, "User supplied per-retry policies, but no retry policy exists.")
            combinedPolicies = policies + (options?.perRequestPolicies ?? [])
        }

        // Append the TransportStage for the edge case where there are no policies
        combinedPolicies.append(transport)

        // Link the policies together
        var prevPolicy: PipelineStage?
        for policy in combinedPolicies {
            if prevPolicy != nil {
                prevPolicy!.next = policy
            }
            prevPolicy = policy
            self.policies.append(policy)
        }
    }

    // MARK: Methods

    public func run(request: PipelineRequest, completionHandler: @escaping PipelineStageResultHandler) {
        policies.first?.process(request: request) { result, httpResponse in
            switch result {
            case let .success(pipelineResponse):
                completionHandler(.success(pipelineResponse), httpResponse)
            case let .failure(error):
                completionHandler(.failure(error), httpResponse)
            }
        }
    }
}

extension Array where Element == PipelineStage {
    var retryPolicy: RetryPolicy? {
        if let index = retryIndex {
            return self[index] as? RetryPolicy
        }
        return nil
    }

    var retryIndex: Int? {
        return firstIndex { $0 as? RetryPolicy != nil }
    }
}
