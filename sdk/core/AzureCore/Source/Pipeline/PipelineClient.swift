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

/// Protocol for baseline options for individual service clients.
public protocol AzureConfigurable {
    /// The API version of the service to invoke.
    var apiVersion: String { get }
    /// The `ClientLogger` to be used by the service client.
    var logger: ClientLogger { get }
}

/// Protocol for baseline options for individual client API calls.
public protocol AzureOptions {
    /// A client-generated, opaque value with 1KB character limit that is recorded in analytics logs.
    /// Highly recommended for correlating client-side activites with requests received by the server.
    var clientRequestId: String? { get }
}

/// Base class for all pipeline-based service clients.
open class PipelineClient {
    // MARK: Properties

    internal var pipeline: Pipeline
    public var baseUrl: String
    public var logger: ClientLogger

    // MARK: Initializers

    public init(
        baseUrl: String,
        transport: HTTPTransportStage,
        policies: [PipelineStage],
        logger: ClientLogger
    ) {
        self.baseUrl = baseUrl
        self.logger = logger
        if self.baseUrl.suffix(1) != "/" { self.baseUrl += "/" }
        self.pipeline = Pipeline(transport: transport, policies: policies)
    }

    // MARK: Public Methods

    public func url(forTemplate templateIn: String, withKwargs kwargs: [String: String]? = nil) -> URL? {
        var template = templateIn
        if template.hasPrefix("/") { template = String(template.dropFirst()) }
        var urlString: String
        if template.starts(with: baseUrl) {
            urlString = template
        } else {
            urlString = baseUrl + template
        }
        if let urlKwargs = kwargs {
            for (key, value) in urlKwargs {
                urlString = urlString.replacingOccurrences(of: "{\(key)}", with: value)
            }
        }
        return URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))
    }

    public func request(
        _ request: HTTPRequest,
        context: PipelineContext?,
        then completion: @escaping HTTPResultHandler<Data?>
    ) {
        let pipelineRequest = PipelineRequest(request: request, logger: logger, context: context)
        pipeline.run(request: pipelineRequest) { result, httpResponse in
            switch result {
            case let .success(pipelineResponse):
                let deserializedData = pipelineResponse.value(forKey: .deserializedData) as? Data

                // invalid status code is a failure
                let statusCode = httpResponse?.statusCode ?? -1
                let allowedStatusCodes = pipelineResponse.value(forKey: .allowedStatusCodes) as? [Int] ?? [200]
                if !allowedStatusCodes.contains(httpResponse?.statusCode ?? -1) {
                    self.logError(withData: deserializedData)
                    let error = HTTPResponseError.statusCode("Service returned invalid status code [\(statusCode)].")
                    completion(.failure(error), httpResponse)
                } else {
                    if let deserialized = deserializedData {
                        completion(.success(deserialized), httpResponse)
                    } else if let data = httpResponse?.data {
                        completion(.success(data), httpResponse)
                    }
                }
            case let .failure(error):
                completion(.failure(error), httpResponse)
            }
        }
    }

    // MARK: Internal Methods

    internal func logError(withData data: Data?) {
        guard let data = data else { return }
        guard let json = try? JSONSerialization.jsonObject(with: data) else { return }
        guard let errorDict = json as? [String: Any] else { return }
        logger.debug {
            var errorStrings = [String]()
            for (key, value) in errorDict {
                errorStrings.append("\(key): \(value)")
            }
            return errorStrings.joined(separator: "\n")
        }
    }
}
