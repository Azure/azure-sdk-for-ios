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

public class HeadersValidationPolicy: PipelineStage {
    // MARK: Properties

    public var next: PipelineStage?

    private var headers: [String]

    // MARK: Initializers

    public init(validatingHeaders headers: [String]) {
        self.headers = headers
    }

    // MARK: PipelineStage Methods

    public func on(
        response pipelineResponse: PipelineResponse,
        completionHandler: @escaping OnResponseCompletionHandler
    ) {
        let request = pipelineResponse.httpRequest
        let response = pipelineResponse.httpResponse!
        var error: AzureError?

        for key in headers {
            let requestValue = request.headers[key] ?? "NIL"
            let responseValue = response.headers[key] ?? "NIL"
            if requestValue != responseValue {
                error = AzureError
                    .general(
                        "Value for header '\(key)' did not match. Expected: \(requestValue) Actual: \(responseValue)"
                    )
            }
        }
        completionHandler(pipelineResponse, error)
    }
}
