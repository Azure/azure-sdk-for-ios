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

#if canImport(AzureCore)
    import AzureCore
#endif
import Foundation

public class CommunicationIdentifierSerializer {
    static func deserialize(identifier: CommunicationIdentifierModel) throws -> CommunicationIdentifier {
        let kind = identifier.kind

        guard let id = identifier.id else {
            throw AzureError.client("Can't serialize CommunicationIdentifierModel: id is undefined.")
        }

        switch kind {
        case .communicationUser:
            return CommunicationUserIdentifier(identifier: id)
        case .callingApplication:
            return CallingApplicationIdentifier(identifier: id)
        case .phoneNumber:
            guard let phoneNumber = identifier.phoneNumber else {
                throw AzureError.client("Can't serialize CommunicationIdentifierModel: phoneNumber is undefined.")
            }
            return PhoneNumberIdentifier(phoneNumber: phoneNumber, id: id)
        case .microsoftTeamsUser:
            guard let isAnonymous = identifier.isAnonymous else {
                throw AzureError.client("Can't serialize CommunicationIdentifierModel: isAnonymous is undefined.")
            }
            guard let microsoftTeamsUserId = identifier.microsoftTeamsUserId else {
                throw AzureError.client("Can't serialize CommunicationIdentifierModel: microsoftTeamsUserId is undefined.")
            }
            guard let cloud = identifier.cloud else {
                throw AzureError.client("Can't serialize CommunicationIdentifierModel: cloud is undefined.")
            }
            return MicrosoftTeamsUserIdentifier(userId: microsoftTeamsUserId, isAnonymous: isAnonymous, identifier:id, cloudEnvironment: try deserialize(model: cloud))
        default:
            return UnknownIdentifier(identifier: id)
        }
    }

    static func serialize(identifier: CommunicationIdentifier) throws -> CommunicationIdentifierModel {
        switch identifier {
        case let userIdentifier as CommunicationUserIdentifier:
            return CommunicationIdentifierModel(kind: .communicationUser, id: userIdentifier.identifier)
        case let callingApplicationIdentifier as CallingApplicationIdentifier:
            return CommunicationIdentifierModel(kind: .callingApplication, id: callingApplicationIdentifier.identifier)
        case let phoneNumberIdentifier as PhoneNumberIdentifier:
            return CommunicationIdentifierModel(kind: .phoneNumber, id: phoneNumberIdentifier.id, phoneNumber: phoneNumberIdentifier.phoneNumber)
        case let microsoftTeamUserIdentifier as MicrosoftTeamsUserIdentifier:
            return CommunicationIdentifierModel(
                kind: .microsoftTeamsUser,
                id: microsoftTeamUserIdentifier.identifier,
                microsoftTeamsUserId: microsoftTeamUserIdentifier.userId,
                isAnonymous: microsoftTeamUserIdentifier.isAnonymous,
                cloud: try serialize(cloud: microsoftTeamUserIdentifier.cloudEnviroment)
            )
        case let unknownIdentifier as UnknownIdentifier:
            return CommunicationIdentifierModel(kind: .unknown, id: unknownIdentifier.identifier)
        default:
            throw AzureError.client("Not support kind in CommunicationIdentifier.")
        }
    }

    private static func deserialize(model: CommunicationCloudEnvironmentModel) throws -> CommunicationCloudEnvironment {
        if (model == CommunicationCloudEnvironmentModel.Public) {
            return CommunicationCloudEnvironment.Public;
        }
        if (model == CommunicationCloudEnvironmentModel.Gcch) {
            return CommunicationCloudEnvironment.Gcch;
        }
        if (model == CommunicationCloudEnvironmentModel.Dod) {
            return CommunicationCloudEnvironment.Dod;
        }

        return CommunicationCloudEnvironment(environmentValue: model.requestString);
    }

    private static func serialize(cloud: CommunicationCloudEnvironment) throws -> CommunicationCloudEnvironmentModel
    {
        if (cloud == CommunicationCloudEnvironment.Public) {
            return CommunicationCloudEnvironmentModel.Public;
        }
        if (cloud == CommunicationCloudEnvironment.Gcch) {
            return CommunicationCloudEnvironmentModel.Gcch;
        }
        if (cloud == CommunicationCloudEnvironment.Dod) {
            return CommunicationCloudEnvironmentModel.Dod;
        }

        return CommunicationCloudEnvironmentModel(cloud.environmentValue);
    }

}
