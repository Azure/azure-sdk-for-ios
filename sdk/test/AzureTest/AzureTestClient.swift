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
import AzureIdentity
import Foundation

public final class AzureTestClient: PipelineClient {

    /// Options provided to configure this `AzureTestClient`.
    public let options: AzureTestClientOptions

    private static let defaultScopes = [
        "https://storage.azure.com/.default"
    ]

    // MARK: Operations

    // MARK: Initializers

    /// Create an Azure resource client.
    /// - Parameters:
    ///   - baseUrl: Base URL for the client.
    ///   - authPolicy: An `Authenticating` policy to use for authenticating client requests.
    ///   - options: Options used to configure the client.
    private init(
        endpoint: URL,
        authPolicy: Authenticating,
        withOptions options: AzureTestClientOptions
    ) throws {
        self.options = options
        super.init(
            endpoint: endpoint,
            transport: options.transportOptions.transport ?? URLSessionTransport(),
            policies: [
                UserAgentPolicy(for: AzureTestClient.self, telemetryOptions: options.telemetryOptions),
                RequestIdPolicy(),
                AddDatePolicy(),
                authPolicy,
                ContentDecodePolicy(),
                HeadersValidationPolicy(validatingHeaders: []),
                LoggingPolicy(
                    allowHeaders: [],
                    allowQueryParams: []
                ),
                NormalizeETagPolicy()
            ],
            logger: self.options.logger,
            options: options
        )
    }

    /// Create an Azure resource client.
    /// - Parameters:
    ///   - credential: A `MSALCredential` object used to retrieve authentication tokens.
    ///   - endpoint: The URL for the client.
    ///   - options: Options used to configure the client.
    public convenience init(
        endpoint: URL,
        credential: MSALCredential,
        withOptions options: AzureTestClientOptions = AzureTestClientOptions()
    ) throws {
        try credential.validate()
        let authPolicy = BearerTokenCredentialPolicy(
            credential: credential,
            scopes: AzureTestClient.defaultScopes
        )
        try self.init(endpoint: endpoint, authPolicy: authPolicy, withOptions: options)
    }

    // MARK: Public Client Methods
    public func deploy(armTemplate: String) -> String {
        // TODO: Deploy the provided ARM template to Azure.
        return ""
    }

    public func delete(resource resourceId: String) {
        // TODO: Delete a resource
    }

    public func delete(resourceGroup group: String) {
        // TODO: Delete a resource group
    }
}
