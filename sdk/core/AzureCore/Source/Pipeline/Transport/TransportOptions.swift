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

/// Options to control the HTTP pipeline transport.
public struct TransportOptions {
    /// Default timeout on any network call
    public let timeout: TimeInterval?
    /// An array of `PipelineStage` policies to use in lieu of the default ones.
    public let pipeline: [PipelineStage]?
    /// An `HTTPTransportStage` policy to use in lieu of the default.
    public let transport: HTTPTransportStage?

    /// Initialize a `TransportOptions` structure.
    /// - Parameters:
    ///   - timeout: Default timeout on any network call.
    ///   - pipeline: An array of `PipelineStage` policies to use in lieu of the default ones.
    ///   - transport: An `HTTPTransportStage` policy to use in lieu of the default.
    public init(timeout: TimeInterval? = nil, pipeline: [PipelineStage]? = nil, transport: HTTPTransportStage? = nil) {
        self.timeout = timeout
        self.pipeline = pipeline
        self.transport = transport
    }
}
