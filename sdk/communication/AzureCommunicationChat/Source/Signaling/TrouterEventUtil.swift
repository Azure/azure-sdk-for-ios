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
import TrouterClientIos

/// Utility class for working with Trouter event payloads.
public enum TrouterEventUtil {
    /// Parses out the id/phone number portion of an MRI.
    /// - Parameters:
    ///   - mri: The original MRI.
    ///   - prefix: The MRI prefix.
    /// - Returns: The part of the MRI after the prefix that corresponds to the id or phone number of a user.
    private static func parse(mri: String, prefix: String) -> String {
        let index = mri.index(mri.startIndex, offsetBy: prefix.count)
        return String(mri.suffix(from: index))
    }

    /// Constructs a CommunicationIdentifier from an MRI.
    /// - Parameter mri: The MRI.
    /// - Returns: The CommunicationIdentifier.
    public static func getIdentifier(from mri: String) -> CommunicationIdentifier {
        let publicTeamsUserPrefix = "8:orgid:"
        let dodTeamsUserPrefix = "8:dod:"
        let gcchTeamsUserPrefix = "8:gcch:"
        let teamsVisitorUserPrefix = "8:teamsvisitor:"
        let phoneNumberPrefix = "4:"
        let acsUserPrefix = "8:acs:"
        let spoolUserPrefix = "8:spool:"

        if mri.starts(with: publicTeamsUserPrefix) {
            return MicrosoftTeamsUserIdentifier(
                userId: parse(mri: mri, prefix: publicTeamsUserPrefix),
                isAnonymous: false,
                rawId: mri,
                cloudEnvironment: CommunicationCloudEnvironment.Public
            )
        } else if mri.starts(with: dodTeamsUserPrefix) {
            return MicrosoftTeamsUserIdentifier(
                userId: parse(mri: mri, prefix: dodTeamsUserPrefix),
                isAnonymous: false,
                rawId: mri,
                cloudEnvironment: CommunicationCloudEnvironment.Dod
            )
        } else if mri.starts(with: gcchTeamsUserPrefix) {
            return MicrosoftTeamsUserIdentifier(
                userId: parse(mri: mri, prefix: gcchTeamsUserPrefix),
                isAnonymous: false,
                rawId: mri,
                cloudEnvironment: CommunicationCloudEnvironment.Gcch
            )
        } else if mri.starts(with: teamsVisitorUserPrefix) {
            return MicrosoftTeamsUserIdentifier(
                userId: parse(mri: mri, prefix: teamsVisitorUserPrefix),
                isAnonymous: true
            )
        } else if mri.starts(with: phoneNumberPrefix) {
            return PhoneNumberIdentifier(
                phoneNumber: parse(mri: mri, prefix: phoneNumberPrefix),
                rawId: mri
            )
        } else if mri.starts(with: acsUserPrefix) || mri.starts(with: spoolUserPrefix) {
            return CommunicationUserIdentifier(mri)
        } else {
            return UnknownIdentifier(mri)
        }
    }

    internal static func toIso8601Date(unixTime: Int? = 0) -> String {
        let unixTimeInMilliSeconds = Double(unixTime ?? 0) / 1000
        let date = Date(timeIntervalSince1970: TimeInterval(unixTimeInMilliSeconds))
        let iso8601DateFormatter = ISO8601DateFormatter()
        iso8601DateFormatter.formatOptions = [.withInternetDateTime]
        return iso8601DateFormatter.string(from: date)
    }

    /// Construct a BaseChatEvent or BaseChatThreadEvent model from a TrouterRequest payload.
    /// - Parameters:
    ///   - chatEventId: The ChatEventId, determines the type of ChatEvent that should be created.
    ///   - request: The request payload.
    /// - Returns: A chat event model.
    public static func create(chatEvent chatEventId: ChatEventId, from request: TrouterRequest) throws -> TrouterEvent {
        return try TrouterEvent(chatEventId: chatEventId, from: request)
    }
}
