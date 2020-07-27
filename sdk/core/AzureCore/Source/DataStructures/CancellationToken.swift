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

public final class CancellationToken: Codable, Equatable {
    public private(set) var isCanceled: Bool
    public private(set) var isStarted: Bool
    public private(set) var timeoutInSeconds: Double?

    public func cancel() {
        isCanceled = true
    }

    public init(timeoutInSeconds: Double? = nil) {
        self.timeoutInSeconds = timeoutInSeconds
        self.isStarted = false
        self.isCanceled = false
    }

    // MARK: Equatable Protocol

    public static func == (lhs: CancellationToken, rhs: CancellationToken) -> Bool {
        return lhs.timeoutInSeconds == rhs.timeoutInSeconds
            && lhs.isStarted == rhs.isStarted
            && lhs.isCanceled == rhs.isCanceled
    }

    // MARK: Methods

    /// Start the cancellation token countdown. If the countdown is already running, this return immediately.
    public func start() {
        guard !isStarted, let timeout = timeoutInSeconds else { return }
        print("STARTING \(timeout) SECOND TIMEOUT!")
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + timeout) {
            self.isCanceled = true
        }
        isStarted = true
    }
}
