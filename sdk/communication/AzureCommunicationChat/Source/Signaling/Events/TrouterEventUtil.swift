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

import AzureCommunicationCommon
import AzureCore
import Foundation
import Trouter

/// Utility class for working with Trouter event payloads.
internal enum TrouterEventUtil {
    /// Convert an Int to an ISO 8601 Date.
    /// - Parameter unixTime: The date time.
    /// - Returns: The ISO 8601 formatted timestamp.
    internal static func toIso8601Date(unixTime: Int? = 0) -> String {
        let unixTimeInMilliSeconds = Double(unixTime ?? 0) / 1000
        let date = Date(timeIntervalSince1970: TimeInterval(unixTimeInMilliSeconds))
        let iso8601DateFormatter = ISO8601DateFormatter()
        iso8601DateFormatter.formatOptions = [.withInternetDateTime]
        return iso8601DateFormatter.string(from: date)
    }

    /// Construct a TrouterEvent from a TrouterRequest payload.
    /// - Parameters:
    ///   - chatEventId: The ChatEventId, determines the type of ChatEvent that should be created.
    ///   - request: The request payload.
    /// - Returns: A TrouterEvent.
    internal static func create(
        chatEvent chatEventId: ChatEventId,
        from request: TrouterRequest?
    ) throws -> TrouterEvent {
        return try TrouterEvent(chatEventId: chatEventId, from: request)
    }
}
