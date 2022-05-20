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

/// Registrar transport.
internal struct RegistrarTransportSettings: Codable {
    /// TTL in seconds. We decide to put 45 min based on Registrar Service's security requirement.
    internal let ttl: Int
    /// APNS device token.
    internal let path: String
    /// Optional context.
    internal let context: String
    /// Creation time as RFC 1123 formatted date.
    internal let creationTime: String?
    /// Snooze time in seconds. Maximum value is 15552000.
    internal let snoozeSeconds: Int?

    internal init(
        path: String,
        creationTime: String? = nil,
        snoozeSeconds: Int? = nil
    ) {
        self.ttl = 2700
        self.path = path
        self.context = ""
        self.creationTime = creationTime
        self.snoozeSeconds = snoozeSeconds
    }
}
