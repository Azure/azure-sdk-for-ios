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
import Foundation

// swiftlint:disable force_try
class TestClient: PipelineClient {
    // MARK: Properties

    public let options: TestClientOptions

    static let defaultPolicies: [PipelineStage] = [
        UserAgentPolicy(sdkName: "Test", sdkVersion: "1.0", telemetryOptions: TelemetryOptions()),
        RetryPolicy(),
        LoggingPolicy()
    ]

    static let endpoint = URL(string: "http://www.microsoft.com")!

    // MARK: Initializers

    private init(
        policies: [PipelineStage],
        withOptions options: TestClientOptions
    ) throws {
        self.options = options
        super.init(
            endpoint: TestClient.endpoint,
            transport: options.transportOptions.transport ?? URLSessionTransport(),
            policies: policies,
            logger: self.options.logger,
            options: options
        )
    }

    public convenience init(defaultPoliciesWithOptions options: TestClientOptions? = nil) {
        try! self.init(
            policies: TestClient.defaultPolicies,
            withOptions: options ?? TestClientOptions()
        )
    }

    public convenience init(
        customPolicies policies: [PipelineStage],
        withOptions options: TestClientOptions? = nil
    ) {
        try! self.init(
            policies: policies,
            withOptions: options ?? TestClientOptions()
        )
    }

    // MARK: Methods

    func testCall(
        value: String,
        withOptions options: TestCallOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<PipelineContext>
    ) {
        let url = self.url(template: "/", params: RequestParameters())!
        let request = try! HTTPRequest(method: .get, url: url)
        let context = PipelineContext.of(keyValues: [
            ContextKey.allowedStatusCodes.rawValue: [200] as AnyObject
        ])
        context.add(cancellationToken: options?.cancellationToken, applying: self.options as ClientOptions)
        context.add(value: value as AnyObject, forKey: "testValue")
        context.merge(with: options?.context)
        self.request(request, context: context) { result, httpResponse in
            let dispatchQueue = options?.dispatchQueue ?? self.commonOptions.dispatchQueue ?? DispatchQueue.main
            switch result {
            case .success:
                guard let statusCode = httpResponse?.statusCode else {
                    let noStatusCodeError = AzureError.client("Expected a status code in response but didn't find one.")
                    dispatchQueue.async {
                        completionHandler(.failure(noStatusCodeError), httpResponse)
                    }
                    return
                }
                if [200].contains(statusCode) {
                    dispatchQueue.async {
                        completionHandler(.success(context), httpResponse)
                    }
                }
            case let .failure(error):
                dispatchQueue.async {
                    completionHandler(.failure(error), httpResponse)
                }
            }
        }
    }
}
