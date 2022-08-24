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

import XCTest
#if canImport(AzureCommunicationCommon)
    @testable import AzureCommunicationCommon
#endif

class CreateCommunicationIdentifier: XCTestCase {
    func test_createUnknownIdentifier() {
        let identifier = createCommunicationIdentifier(fromRawId: "48:37691ec4-57fb-4c0f-ae31-32791610cb14")
        switch identifier.kind {
        case .communicationUser:
            XCTFail("test_createUnknownIdentifier created the wrong type")
        case .phoneNumber:
            XCTFail("test_createUnknownIdentifier created the wrong type")
        case .microsoftTeamsUser:
            XCTFail("test_createUnknownIdentifier created the wrong type")
        case .unknown:
            guard let identifier = identifier as? UnknownIdentifier else { return }
            XCTAssertEqual(identifier.rawId, "48:37691ec4-57fb-4c0f-ae31-32791610cb14")
        default:
            XCTFail("test_createUnknownIdentifier created the wrong type")
        }
    }

    func test_createUnkownUdentifier_withoutprefix() {
        let identifier = createCommunicationIdentifier(fromRawId: "37691ec4-57fb-4c0f-ae31-32791610cb14")
        switch identifier.kind {
        case .communicationUser:
            XCTFail("test_createUnknownIdentifier created the wrong type")
        case .phoneNumber:
            XCTFail("test_createUnknownIdentifier created the wrong type")
        case .microsoftTeamsUser:
            XCTFail("test_createUnknownIdentifier created the wrong type")
        case .unknown:
            guard let identifier = identifier as? UnknownIdentifier else { return }
            XCTAssertEqual(identifier.rawId, "37691ec4-57fb-4c0f-ae31-32791610cb14")
        default:
            XCTFail("test_createUnknownIdentifier created the wrong type")
        }
    }

    func test_createPhoneNumberIdentifier() {
        let phoneNumberRawId = "4:12345556789"
        let identifier = createCommunicationIdentifier(fromRawId: phoneNumberRawId)

        switch identifier.kind {
        case .communicationUser:
            XCTFail("test_createPhoneNumberIdentifier created the wrong type")
        case .phoneNumber:
            guard let identifier = identifier as? PhoneNumberIdentifier else { return }

            XCTAssertEqual(identifier.rawId, phoneNumberRawId)
            XCTAssertEqual(identifier.phoneNumber, "+12345556789")
        case .microsoftTeamsUser:
            XCTFail("test_createPhoneNumberIdentifier created the wrong type")
        case .unknown:
            XCTFail("test_createPhoneNumberIdentifier created the wrong type")
        default:
            XCTFail("test_createPhoneNumberIdentifier created the wrong type")
        }
    }

    func test_createCommunicationUserIdentifier_usingACS() {
        let acsRawId = "8:acs:37691ec4-57fb-4c0f-ae31-32791610cb14_37691ec4-57fb-4c0f-ae31-32791610cb14"
        let identifier = createCommunicationIdentifier(fromRawId: acsRawId)
        switch identifier.kind {
        case .communicationUser:
            guard let identifier = identifier as? CommunicationUserIdentifier else { return }

            XCTAssertEqual(identifier.rawId, acsRawId)
            XCTAssertEqual(identifier.identifier, acsRawId)
        case .phoneNumber:
            XCTFail("test_createCommunicationUserIdentifier_usingACS created the wrong type")
        case .microsoftTeamsUser:
            XCTFail("test_createCommunicationUserIdentifier_usingACS created the wrong type")
        case .unknown:
            XCTFail("test_createCommunicationUserIdentifier_usingACS created the wrong type")
        default:
            XCTFail("test_createCommunicationUserIdentifier_usingACS created the wrong type")
        }
    }

    func test_createCommunicationUserIdentifier_usingSpool() {
        let spoolRawId = "8:spool:37691ec4-57fb-4c0f-ae31-32791610cb14_37691ec4-57fb-4c0f-ae31-32791610cb14"
        let identifier = createCommunicationIdentifier(fromRawId: spoolRawId)
        switch identifier.kind {
        case .communicationUser:
            guard let identifier = identifier as? CommunicationUserIdentifier else { return }

            XCTAssertEqual(identifier.rawId, spoolRawId)
            XCTAssertEqual(identifier.identifier, spoolRawId)
        case .phoneNumber:
            XCTFail("test_createCommunicationUserIdentifier_usingSpool created the wrong type")
        case .microsoftTeamsUser:
            XCTFail("test_createCommunicationUserIdentifier_usingSpool created the wrong type")
        case .unknown:
            XCTFail("test_createCommunicationUserIdentifier_usingSpool created the wrong type")
        default:
            XCTFail("test_createCommunicationUserIdentifier_usingSpool created the wrong type")
        }
    }

    func test_createCommunicationUserIdentifier_usingDoDACS() {
        let dodAcsRawId = "8:dod-acs:37691ec4-57fb-4c0f-ae31-32791610cb14_37691ec4-57fb-4c0f-ae31-32791610cb14"
        let identifier = createCommunicationIdentifier(fromRawId: dodAcsRawId)
        switch identifier.kind {
        case .communicationUser:
            guard let identifier = identifier as? CommunicationUserIdentifier else { return }

            XCTAssertEqual(identifier.rawId, dodAcsRawId)
            XCTAssertEqual(identifier.identifier, dodAcsRawId)
        case .phoneNumber:
            XCTFail("test_createCommunicationUserIdentifier_usingDoDACS created the wrong type")
        case .microsoftTeamsUser:
            XCTFail("test_createCommunicationUserIdentifier_usingDoDACS created the wrong type")
        case .unknown:
            XCTFail("test_createCommunicationUserIdentifier_usingDoDACS created the wrong type")
        default:
            XCTFail("test_createCommunicationUserIdentifier_usingDoDACS created the wrong type")
        }
    }

    func test_createCommunicationUserIdentifier_usingGcchACS() {
        let gcchAcsRawId = "8:gcch-acs:37691ec4-57fb-4c0f-ae31-32791610cb14_37691ec4-57fb-4c0f-ae31-32791610cb14"
        let identifier = createCommunicationIdentifier(fromRawId: gcchAcsRawId)
        switch identifier.kind {
        case .communicationUser:
            guard let identifier = identifier as? CommunicationUserIdentifier else { return }

            XCTAssertEqual(identifier.rawId, gcchAcsRawId)
            XCTAssertEqual(identifier.identifier, gcchAcsRawId)
        case .phoneNumber:
            XCTFail("test_createCommunicationUserIdentifier_usingGcchACS created the wrong type")
        case .microsoftTeamsUser:
            XCTFail("test_createCommunicationUserIdentifier_usingGcchACS created the wrong type")
        case .unknown:
            XCTFail("test_createCommunicationUserIdentifier_usingGcchACS created the wrong type")
        default:
            XCTFail("test_createCommunicationUserIdentifier_usingGcchACS created the wrong type")
        }
    }

    func test_createMicrosoftTeamsUserIdentifierAnonymousScope() {
        let teamUserAnonymousScope =
            "8:teamsvisitor:37691ec4-57fb-4c0f-ae31-32791610cb14_37691ec4-57fb-4c0f-ae31-32791610cb14"
        let identifier = createCommunicationIdentifier(fromRawId: teamUserAnonymousScope)
        switch identifier.kind {
        case .communicationUser:
            XCTFail("test_createMicrosoftTeamsUserIdentifierAnonymousScope created the wrong type")
        case .phoneNumber:
            XCTFail("test_createMicrosoftTeamsUserIdentifierAnonymousScope created the wrong type")
        case .microsoftTeamsUser:
            guard let identifier = identifier as? MicrosoftTeamsUserIdentifier else { return }
            XCTAssertEqual(identifier.rawId, teamUserAnonymousScope)
            XCTAssertEqual(
                identifier.userId,
                "37691ec4-57fb-4c0f-ae31-32791610cb14_37691ec4-57fb-4c0f-ae31-32791610cb14"
            )
            XCTAssertEqual(identifier.isAnonymous, true)
            XCTAssertEqual(identifier.cloudEnviroment, .Public)
        case .unknown:
            XCTFail("test_createMicrosoftTeamsUserIdentifierAnonymousScope created the wrong type")
        default:
            XCTFail("test_createMicrosoftTeamsUserIdentifierAnonymousScope created the wrong type")
        }
    }

    func test_createMicrosoftTeamsUserIdentifierPublicScope() {
        let teamUserPublicCloudScope =
            "8:orgid:37691ec4-57fb-4c0f-ae31-32791610cb14_37691ec4-57fb-4c0f-ae31-32791610cb14"
        let identifier = createCommunicationIdentifier(fromRawId: teamUserPublicCloudScope)
        switch identifier.kind {
        case .communicationUser:
            XCTFail("test_createMicrosoftTeamsUserIdentifierPublicScope created the wrong type")
        case .phoneNumber:
            XCTFail("test_createMicrosoftTeamsUserIdentifierPublicScope created the wrong type")
        case .microsoftTeamsUser:
            guard let identifier = identifier as? MicrosoftTeamsUserIdentifier else { return }
            XCTAssertEqual(identifier.rawId, teamUserPublicCloudScope)
            XCTAssertEqual(
                identifier.userId,
                "37691ec4-57fb-4c0f-ae31-32791610cb14_37691ec4-57fb-4c0f-ae31-32791610cb14"
            )
            XCTAssertEqual(identifier.isAnonymous, false)
            XCTAssertEqual(identifier.cloudEnviroment, .Public)
        case .unknown:
            XCTFail("test_createMicrosoftTeamsUserIdentifierPublicScope created the wrong type")
        default:
            XCTFail("test_createMicrosoftTeamsUserIdentifierPublicScope created the wrong type")
        }
    }

    func test_createMicrosoftTeamsUserIdentifierDODScope() {
        let teamUserDODCloudScope = "8:dod:37691ec4-57fb-4c0f-ae31-32791610cb14_37691ec4-57fb-4c0f-ae31-32791610cb14"
        let identifier = createCommunicationIdentifier(fromRawId: teamUserDODCloudScope)
        switch identifier.kind {
        case .communicationUser:
            XCTFail("test_createMicrosoftTeamsUserIdentifierDODScope created the wrong type")
        case .phoneNumber:
            XCTFail("test_createMicrosoftTeamsUserIdentifierDODScope created the wrong type")
        case .microsoftTeamsUser:
            guard let identifier = identifier as? MicrosoftTeamsUserIdentifier else { return }
            XCTAssertEqual(identifier.rawId, teamUserDODCloudScope)
            XCTAssertEqual(
                identifier.userId,
                "37691ec4-57fb-4c0f-ae31-32791610cb14_37691ec4-57fb-4c0f-ae31-32791610cb14"
            )
            XCTAssertEqual(identifier.isAnonymous, false)
            XCTAssertEqual(identifier.cloudEnviroment, .Dod)
        case .unknown:
            XCTFail("test_createMicrosoftTeamsUserIdentifierDODScope created the wrong type")
        default:
            XCTFail("test_createMicrosoftTeamsUserIdentifierDODScope created the wrong type")
        }
    }

    func test_createMicrosoftTeamsUserIdentifierGCCHScope() {
        let teamUserGCCHCloudScope = "8:gcch:37691ec4-57fb-4c0f-ae31-32791610cb14_37691ec4-57fb-4c0f-ae31-32791610cb14"
        let identifier = createCommunicationIdentifier(fromRawId: teamUserGCCHCloudScope)
        switch identifier.kind {
        case .communicationUser:
            XCTFail("test_createMicrosoftTeamsUserIdentifierGCCHScope created the wrong type")
        case .phoneNumber:
            XCTFail("test_createMicrosoftTeamsUserIdentifierGCCHScope created the wrong type")
        case .microsoftTeamsUser:
            guard let identifier = identifier as? MicrosoftTeamsUserIdentifier else { return }
            XCTAssertEqual(identifier.rawId, teamUserGCCHCloudScope)
            XCTAssertEqual(
                identifier.userId,
                "37691ec4-57fb-4c0f-ae31-32791610cb14_37691ec4-57fb-4c0f-ae31-32791610cb14"
            )
            XCTAssertEqual(identifier.isAnonymous, false)
            XCTAssertEqual(identifier.cloudEnviroment, .Gcch)
        case .unknown:
            XCTFail("test_createMicrosoftTeamsUserIdentifierGCCHScope created the wrong type")
        default:
            XCTFail("test_createMicrosoftTeamsUserIdentifierGCCHScope created the wrong type")
        }
    }
}
