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

/// User-configurable client options.
public struct AzureCommunicationChatClientOptions: ClientOptions {
    /// The API version of the client to invoke.
    public let apiVersion: String
    /// The `ClientLogger` to be used by this client.
    public let logger: ClientLogger
    /// Options for configuring telemetry sent by this client.
    public let telemetryOptions: TelemetryOptions
    /// Global transport options
    public let transportOptions: TransportOptions
    /// The default dispatch queue on which to call all completion handler. Defaults to `DispatchQueue.main`.
    public let dispatchQueue: DispatchQueue?
    /// The `CommunicationSignalingErrorHandler` called when signaling errors occur.
    public let signalingErrorHandler: CommunicationSignalingErrorHandler?

    /// API version of the  to invoke. Defaults to the latest.
    public enum ApiVersion: RequestStringConvertible {
        /// Custom value for unrecognized enum values
        case custom(String)
        /// API version "2021-03-07"
        case v20210307
        /// API version "2021-09-07"
        case v20210907

        /// The most recent API version of the
        public static var latest: ApiVersion {
            return .v20210907
        }

        public var requestString: String {
            switch self {
            case let .custom(val):
                return val
            case .v20210307:
                return "2021-03-07"
            case .v20210907:
                return "2021-09-07"
            }
        }

        public init(_ val: String) {
            switch val.lowercased() {
            case "2021-03-07":
                self = .v20210307
            case "2021-09-07":
                self = .v20210907
            default:
                self = .custom(val)
            }
        }
    }

    /// Initialize a `AzureCommunicationChatClientOptions` structure.
    /// - Parameters:
    ///   - apiVersion: The API version of the client to invoke.
    ///   - logger: The `ClientLogger` to be used by this client.
    ///   - telemetryOptions: Options for configuring telemetry sent by this client.
    ///   - cancellationToken: A token used to make a best-effort attempt at canceling a request.
    ///   - dispatchQueue: The default dispatch queue on which to call all completion handler. Defaults to
    /// `DispatchQueue.main`.
    ///   - signalingErrorHandler: This handler is called if a CommunicationSignalingError occurs.
    public init(
        apiVersion: AzureCommunicationChatClientOptions.ApiVersion = .latest,
        logger: ClientLogger = ClientLoggers.default(tag: "AzureCommunicationChat"),
        telemetryOptions: TelemetryOptions = TelemetryOptions(),
        transportOptions: TransportOptions? = nil,
        dispatchQueue: DispatchQueue? = nil,
        signalingErrorHandler: CommunicationSignalingErrorHandler? = nil
    ) {
        self.apiVersion = apiVersion.requestString
        self.logger = logger
        self.telemetryOptions = telemetryOptions
        self.transportOptions = transportOptions ?? TransportOptions()
        self.dispatchQueue = dispatchQueue
        self.signalingErrorHandler = signalingErrorHandler
    }
}
