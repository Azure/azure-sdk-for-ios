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
        let allowedHeaders = pipelineResponse.context?.value(forKey: .allowedHeaders) as? Set<String> ?? []

        for key in headers {
            var requestValue = request.headers[key]
            // automatically succeed when the response does not contain the header
            guard var responseValue = response.headers[key] else {
                completionHandler(pipelineResponse, nil)
                return
            }
            if requestValue != responseValue {
                if !allowedHeaders.contains(key.lowercased()) {
                    requestValue = "REDACTED"
                    responseValue = "REDACTED"
                }
                error = AzureError
                    .client(
                        "Value for header '\(key)' did not match. Expected: \(requestValue ?? "nil") Actual: \(responseValue)"
                    )
            }
        }
        completionHandler(pipelineResponse, error)
    }
}
