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

@testable import AzureCore

// swiftlint:disable force_try
public extension PipelineRequest {
    convenience init(
        method: HTTPMethod = .get,
        url: String = "http://www.example.com",
        headers: HTTPHeaders = HTTPHeaders(),
        body: String? = nil,
        context: PipelineContext? = nil,
        logger: ClientLogger = ClientLoggers.none
    ) {
        let httpRequest = try! HTTPRequest(
            method: method,
            url: url,
            headers: headers,
            data: body?.data(using: .utf8)
        )
        self.init(request: httpRequest, logger: logger, context: context)
    }
}

public extension PipelineResponse {
    convenience init(
        request: PipelineRequest,
        responseCode: Int = 200,
        headers: HTTPHeaders = HTTPHeaders(),
        body: String? = nil,
        logger: ClientLogger = ClientLoggers.none
    ) {
        let httpResponse = HTTPResponse(request: request.httpRequest, statusCode: responseCode)
        httpResponse.headers = headers
        httpResponse.data = body?.data(using: .utf8)
        self.init(
            request: request.httpRequest,
            response: httpResponse,
            logger: logger,
            context: request.context
        )
    }
}
