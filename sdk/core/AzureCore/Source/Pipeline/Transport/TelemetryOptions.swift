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

/// Options for configuring telemetry sent by the service client.
public struct TelemetryOptions {
    /// Whether platform information will be omitted from the user agent string sent by the service client.
    public let telemetryDisabled: Bool
    /// An optional user-specified application ID included in the user agent string sent by the service client.
    public let applicationId: String?

    /// Initialize a `TelemetryOptions` structure.
    /// - Parameters:
    ///   - telemetryDisabled: Whether platform information will be omitted from the user agent string sent by the
    ///   service client.
    ///   - applicationId: An optional user-specified application ID included in the user agent string sent by the
    ///   service client.
    public init(telemetryDisabled: Bool = false, applicationId: String? = nil) {
        self.telemetryDisabled = telemetryDisabled
        self.applicationId = applicationId
    }
}
