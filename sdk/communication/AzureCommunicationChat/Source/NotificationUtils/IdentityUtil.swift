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

func decode(jwtToken jwt: String) throws -> [String: Any] {
    enum DecodeErrors: Error {
        case badToken
        case other
    }

    func base64Decode(_ base64: String) throws -> Data {
        let base64 = base64
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let padded = base64.padding(toLength: ((base64.count + 3) / 4) * 4, withPad: "=", startingAt: 0)
        guard let decoded = Data(base64Encoded: padded) else {
            throw DecodeErrors.badToken
        }
        return decoded
    }

    func decodeJWTPart(_ value: String) throws -> [String: Any] {
        let bodyData = try base64Decode(value)
        let json = try JSONSerialization.jsonObject(with: bodyData, options: [])
        guard let payload = json as? [String: Any] else {
            throw DecodeErrors.other
        }
        return payload
    }

    let segments = jwt.components(separatedBy: ".")
    return try decodeJWTPart(segments[1])
}

func isDod(id: String) -> Bool {
    let gcchTeamsUserPrefix = "dod:"
    let gcchAcsUserPrefix = "dod-acs:"
    return (id.starts(with: gcchTeamsUserPrefix) || id.starts(with: gcchAcsUserPrefix))
}

func isGcch(id: String) -> Bool {
    let gcchTeamsUserPrefix = "gcch:"
    let gcchAcsUserPrefix = "gcch-acs:"
    return (id.starts(with: gcchTeamsUserPrefix) || id.starts(with: gcchAcsUserPrefix))
}

/// Parses out the id/phone number portion of a user id.
/// - Parameters:
///   - id: The string id.
///   - prefix: The id prefix.
/// - Returns: The part of the id after the prefix that corresponds to the user id or phone number of a user.
private func parse(id: String, prefix: String) -> String {
    let index = id.index(id.startIndex, offsetBy: prefix.count)
    return String(id.suffix(from: index))
}

/// Constructs a CommunicationIdentifier from a string id.
/// - Parameter id: The string id.
/// - Returns: The CommunicationIdentifier.
internal func getIdentifier(from id: String) -> CommunicationIdentifier {
    let publicTeamsUserPrefix = "8:orgid:"
    let dodTeamsUserPrefix = "8:dod:"
    let gcchTeamsUserPrefix = "8:gcch:"
    let teamsVisitorUserPrefix = "8:teamsvisitor:"
    let phoneNumberPrefix = "4:"
    let acsUserPrefix = "8:acs:"
    let spoolUserPrefix = "8:spool:"
    let dodAcsUserPrefix = "8:dod-acs:"
    let gcchAcsUserPrefix = "8:gcch-acs:"

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
    } else if id.starts(with: acsUserPrefix) || id.starts(with: spoolUserPrefix) || id
        .starts(with: dodAcsUserPrefix) || id.starts(with: gcchAcsUserPrefix)
    {
        return CommunicationUserIdentifier(id)
    } else {
        return UnknownIdentifier(id)
    }
}
