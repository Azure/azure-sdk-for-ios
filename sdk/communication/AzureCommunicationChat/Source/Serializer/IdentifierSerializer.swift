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

internal enum IdentifierSerializer {
    static func deserialize(identifier: CommunicationIdentifierModelInternal) throws -> CommunicationIdentifier {
        guard let rawId = identifier.rawId else {
            throw AzureError.client("Can't serialize CommunicationIdentifierModel: rawId is undefined.")
        }

        try assertOneNestedModel(identifier)

        if let communicationUser = identifier.communicationUser {
            return CommunicationUserIdentifier(communicationUser.id)
        } else if let phoneNumber = identifier.phoneNumber {
            return PhoneNumberIdentifier(phoneNumber: phoneNumber.value, rawId: rawId)
        } else if let microsoftTeamsUser = identifier.microsoftTeamsUser {
            guard let isAnonymous = microsoftTeamsUser.isAnonymous else {
                throw AzureError.client("Can't serialize CommunicationIdentifierModel: isAnonymous is undefined.")
            }

            guard let cloud = microsoftTeamsUser.cloud else {
                throw AzureError.client("Can't serialize CommunicationIdentifierModel: cloud is undefined.")
            }

            return MicrosoftTeamsUserIdentifier(
                userId: microsoftTeamsUser.userId,
                isAnonymous: isAnonymous,
                rawId: rawId,
                cloudEnvironment: try deserialize(model: cloud)
            )
        }

        return UnknownIdentifier(rawId)
    }

    private static func deserialize(model: CommunicationCloudEnvironmentModel) throws -> CommunicationCloudEnvironment {
        if model == CommunicationCloudEnvironmentModel.public {
            return CommunicationCloudEnvironment.Public
        }
        if model == CommunicationCloudEnvironmentModel.gcch {
            return CommunicationCloudEnvironment.Gcch
        }
        if model == CommunicationCloudEnvironmentModel.dod {
            return CommunicationCloudEnvironment.Dod
        }

        return CommunicationCloudEnvironment(environmentValue: model.requestString)
    }

    static func assertOneNestedModel(_ identifier: CommunicationIdentifierModelInternal) throws {
        var presentProperties = 0

        if identifier.communicationUser != nil {
            presentProperties += 1
        }
        if identifier.phoneNumber != nil {
            presentProperties += 1
        }
        if identifier.microsoftTeamsUser != nil {
            presentProperties += 1
        }

        if presentProperties > 1 {
            throw AzureError.client("Only one property should be present")
        }
    }

    static func serialize(identifier: CommunicationIdentifier) throws -> CommunicationIdentifierModelInternal {
        switch identifier {
        case let user as CommunicationUserIdentifier:
            return CommunicationIdentifierModelInternal(
                rawId: nil,
                communicationUser: CommunicationUserIdentifierModel(
                    id: user
                        .identifier
                ),
                phoneNumber: nil,
                microsoftTeamsUser: nil
            )
        case let phoneNumber as PhoneNumberIdentifier:
            return CommunicationIdentifierModelInternal(
                rawId: phoneNumber.rawId,
                communicationUser: nil,
                phoneNumber: PhoneNumberIdentifierModel(value: phoneNumber.phoneNumber),
                microsoftTeamsUser: nil
            )
        case let teamsUser as MicrosoftTeamsUserIdentifier:
            return try CommunicationIdentifierModelInternal(
                rawId: teamsUser.rawId,
                communicationUser: nil,
                phoneNumber: nil,
                microsoftTeamsUser:
                MicrosoftTeamsUserIdentifierModel(
                    userId: teamsUser.userId,
                    isAnonymous: teamsUser
                        .isAnonymous,
                    cloud: serialize(
                        cloud: teamsUser
                            .cloudEnvironment
                    )
                )
            )
        case let unknown as UnknownIdentifier:
            return CommunicationIdentifierModelInternal(
                rawId: unknown.identifier,
                communicationUser: nil,
                phoneNumber: nil,
                microsoftTeamsUser: nil
            )
        default:
            throw AzureError.client("CommunicationIdentifier is not supported and cannot be serialized")
        }
    }

    private static func serialize(cloud: CommunicationCloudEnvironment) throws -> CommunicationCloudEnvironmentModel {
        if cloud == CommunicationCloudEnvironment.Public {
            return CommunicationCloudEnvironmentModel.public
        }
        if cloud == CommunicationCloudEnvironment.Gcch {
            return CommunicationCloudEnvironmentModel.gcch
        }
        if cloud == CommunicationCloudEnvironment.Dod {
            return CommunicationCloudEnvironmentModel.dod
        }

        return CommunicationCloudEnvironmentModel(cloud.getEnvironmentValue())
    }
}
