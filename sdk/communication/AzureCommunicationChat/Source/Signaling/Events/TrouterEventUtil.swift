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
    /// Parses out the id/phone number portion of a user id.
    /// - Parameters:
    ///   - id: The string id.
    ///   - prefix: The id prefix.
    /// - Returns: The part of the id after the prefix that corresponds to the user id or phone number of a user.
    private static func parse(id: String, prefix: String) -> String {
        let index = id.index(id.startIndex, offsetBy: prefix.count)
        return String(id.suffix(from: index))
    }

    /// Constructs a CommunicationIdentifier from a string id.
    /// - Parameter id: The string id.
    /// - Returns: The CommunicationIdentifier.
    internal static func getIdentifier(from id: String) -> CommunicationIdentifier {
        let publicTeamsUserPrefix = "8:orgid:"
        let dodTeamsUserPrefix = "8:dod:"
        let gcchTeamsUserPrefix = "8:gcch:"
        let teamsVisitorUserPrefix = "8:teamsvisitor:"
        let phoneNumberPrefix = "4:"
        let acsUserPrefix = "8:acs:"
        let spoolUserPrefix = "8:spool:"

        if id.starts(with: publicTeamsUserPrefix) {
            return MicrosoftTeamsUserIdentifier(
                userId: parse(id: id, prefix: publicTeamsUserPrefix),
                isAnonymous: false,
                rawId: id,
                cloudEnvironment: CommunicationCloudEnvironment.Public
            )
        } else if id.starts(with: dodTeamsUserPrefix) {
            return MicrosoftTeamsUserIdentifier(
                userId: parse(id: id, prefix: dodTeamsUserPrefix),
                isAnonymous: false,
                rawId: id,
                cloudEnvironment: CommunicationCloudEnvironment.Dod
            )
        } else if id.starts(with: gcchTeamsUserPrefix) {
            return MicrosoftTeamsUserIdentifier(
                userId: parse(id: id, prefix: gcchTeamsUserPrefix),
                isAnonymous: false,
                rawId: id,
                cloudEnvironment: CommunicationCloudEnvironment.Gcch
            )
        } else if id.starts(with: teamsVisitorUserPrefix) {
            return MicrosoftTeamsUserIdentifier(
                userId: parse(id: id, prefix: teamsVisitorUserPrefix),
                isAnonymous: true
            )
        } else if id.starts(with: phoneNumberPrefix) {
            return PhoneNumberIdentifier(
                phoneNumber: parse(id: id, prefix: phoneNumberPrefix),
                rawId: id
            )
        } else if id.starts(with: acsUserPrefix) || id.starts(with: spoolUserPrefix) {
            return CommunicationUserIdentifier(id)
        } else {
            return UnknownIdentifier(id)
        }
    }
    
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
    internal static func create(chatEvent chatEventId: ChatEventId, from request: TrouterRequest) throws -> TrouterEvent {
        return try TrouterEvent(chatEventId: chatEventId, from: request)
    }
}
