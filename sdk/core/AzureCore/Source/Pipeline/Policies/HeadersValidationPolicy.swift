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
        let allowedHeaders = pipelineResponse.context?.value(forKey: .allowedHeaders) as? Set<String>

        for key in headers {
            guard let requestValue = request.headers[key] else {
                error = AzureError.general("Request header not found for '\(key)'")
                completionHandler(pipelineResponse, error)
                return
            }
            // automatically succeed when the response does not contain the header
            guard let responseValue = response.headers[key] else {
                completionHandler(pipelineResponse, nil)
                return
            }
            if requestValue != responseValue {
                var requestHeaders = request.headers
                var responseHeaders = response.headers
                if let allowHeaders = allowedHeaders {
                    requestHeaders = redact(headers: requestHeaders, withAllowedHeaders: Array(allowHeaders))
                    responseHeaders = redact(headers: responseHeaders, withAllowedHeaders: Array(allowHeaders))
                }
                let requestValue = requestHeaders[key] ?? "NIL"
                let responseValue = responseHeaders[key] ?? "NIL"
                error = AzureError
                    .general(
                        "Value for header '\(key)' did not match. Expected: \(requestValue) Actual: \(responseValue)"
                    )
            }
        }
        completionHandler(pipelineResponse, error)
    }

    // MARK: Methods

    private func redact(headers: HTTPHeaders, withAllowedHeaders allowedHeaders: [String]?) -> HTTPHeaders {
        guard let allowHeaders = allowedHeaders else { return headers }
        var copy = headers
        for header in copy.keys {
            if !allowHeaders.contains(header.lowercased()) {
                copy.updateValue("REDACTED", forKey: header)
            }
        }
        return copy
    }
}
