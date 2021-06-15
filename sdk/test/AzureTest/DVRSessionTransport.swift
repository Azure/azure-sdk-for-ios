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

import AzureCore
import DVR
import Foundation
import os

public class DVRSessionTransport: TransportStage {
    // MARK: Properties
    public var session: Session?

    // DVR cassette name to search
    private var cassetteName: String

    private var _next: PipelineStage?
    public var next: PipelineStage? {
        get {
            return _next
        }

        // swiftlint:disable:next unused_setter_value
        set {
            _next = nil
        }
    }

    // MARK: Initializers

    public init(cassetteName: String) {
        self.cassetteName = cassetteName
    }

    // MARK: HTTPTransportStage Methods

    public func open() {
        guard session == nil else { return }
        session = Session(cassetteName: cassetteName)
        if environmentVariable(forKey: "TEST_MODE", default: "playback") == "record" {
            session?.recordMode = .once
            session?.recordingEnabled = true
            session?.beginRecording()
            
        }
        else if environmentVariable(forKey: "TEST_MODE", default: "playback") == "live" {
            session?.recordMode = .all
            session?.recordingEnabled = false
        }
        else {
            session?.recordMode = .none
            session?.recordingEnabled = false
        }
    }

    public func close() {
        session?.endRecording {
            self.session = nil
        }
    }

    // MARK: PipelineStage Methods

    public func process(
        request pipelineRequest: PipelineRequest,
        completionHandler: @escaping PipelineStageResultHandler
    ) {
        open()
        guard let session = self.session else {
            pipelineRequest.logger.error("Invalid session.")
            return
        }
        var urlRequest = URLRequest(url: pipelineRequest.httpRequest.url)
        urlRequest.httpMethod = pipelineRequest.httpRequest.httpMethod.rawValue
        urlRequest.allHTTPHeaderFields = pipelineRequest.httpRequest.headers
        urlRequest.httpBody = pipelineRequest.httpRequest.data

        // need immutable copies to pass into the closure. At this point, these can't change
        // anyways.
        let httpRequest = pipelineRequest.httpRequest
        let responseContext = pipelineRequest.context
        let logger = pipelineRequest.logger

        if let cancellationToken = pipelineRequest.context?.value(forKey: .cancellationToken) as? CancellationToken {
            cancellationToken.start()
            if cancellationToken.isCanceled {
                completionHandler(.failure(AzureError.client("Request canceled.")), nil)
                return
            }
        }

        session.dataTask(with: urlRequest) { data, response, error in
            if let cancellationToken = pipelineRequest.context?
                .value(forKey: .cancellationToken) as? CancellationToken {
                if cancellationToken.isCanceled {
                    completionHandler(.failure(AzureError.client("Request canceled.")), nil)
                    return
                }
            }
            let rawResponse = response as? HTTPURLResponse
            let httpResponse = URLHTTPResponse(request: httpRequest, response: rawResponse)
            httpResponse.data = data

            // check for invalid status codes
            let statusCode = httpResponse.statusCode ?? -1
            let allowedStatusCodes = responseContext?.value(forKey: .allowedStatusCodes) as? [Int] ?? [200]
            if !allowedStatusCodes.contains(statusCode) {
                // do not add the inner error, as it may require decoding from XML.
                let error = AzureError.service("Service returned invalid status code [\(statusCode)].", nil)
                completionHandler(.failure(error), httpResponse)
            }

            let pipelineResponse = PipelineResponse(
                request: httpRequest,
                response: httpResponse,
                logger: logger,
                context: responseContext
            )
            if let error = error {
                completionHandler(.failure(AzureError.service("Service error.", error)), httpResponse)
            } else {
                completionHandler(.success(pipelineResponse), httpResponse)
            }
        }.resume()
    }
}
