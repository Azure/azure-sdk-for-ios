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
/**
 Helper class to easily create CommunicationIdentifiers
 */
@objcMembers
public class CommunicationIdentifierHelper: NSObject {
    /**
     Creates a CommunicationIdentifier from a given rawId. When storing rawIds use this function to restore the identifier that was encoded in the rawId.
     Parameters: rawId The rawId to be translated to its identifier representation.
     Returns: Type safe CommunicationIdentifier created. Use the `isKind(of:)` to verify  identifier type
     SeeAlso: ` CommunicationIdentifier`
     */
    public static func createCommunicationIdentifier(from rawId: String) -> CommunicationIdentifier {
        let phoneNumberPrefix = "4:"
        let teamUserAnonymousPrefix = "8:teamsvisitor:"
        let teamUserPublicCloudPrefix = "8:orgid:"
        let teamUserDODCloudPrefix = "8:dod:"
        let teamUserGCCHCloudPrefix = "8:gcch:"
        let acsUser = "8:acs:"
        let spoolUser = "8:spool:"
        let dodAcsUser = "8:dod-acs:"
        let gcchAcsUser = "8:gcch-acs:"

        if rawId.hasPrefix(phoneNumberPrefix) {
            let phoneNumber = "+" + rawId.dropFirst(phoneNumberPrefix.count)
            return PhoneNumberIdentifier(phoneNumber: phoneNumber, rawId: rawId)
        }

        let segments = rawId.split(separator: ":")
        if segments.count < 3 {
            return UnknownIdentifier(rawId)
        }

        let scope = segments[0] + ":" + segments[1] + ":"
        let suffix = String(rawId.dropFirst(scope.count))

        switch scope {
        case teamUserAnonymousPrefix:
            return MicrosoftTeamsUserIdentifier(userId: suffix, isAnonymous: true)
        case teamUserPublicCloudPrefix:
            return MicrosoftTeamsUserIdentifier(
                userId: suffix,
                isAnonymous: false,
                rawId: rawId,
                cloudEnvironment: .Public
            )
        case teamUserDODCloudPrefix:
            return MicrosoftTeamsUserIdentifier(
                userId: suffix,
                isAnonymous: false,
                rawId: rawId,
                cloudEnvironment: .Dod
            )
        case teamUserGCCHCloudPrefix:
            return MicrosoftTeamsUserIdentifier(
                userId: suffix,
                isAnonymous: false,
                rawId: rawId,
                cloudEnvironment: .Gcch
            )
        case acsUser, spoolUser, dodAcsUser, gcchAcsUser:
            return CommunicationUserIdentifier(rawId)
        default:
            return UnknownIdentifier(rawId)
        }
    }
}
