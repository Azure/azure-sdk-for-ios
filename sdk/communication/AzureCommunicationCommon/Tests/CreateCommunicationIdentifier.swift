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
    private let rawIdSuffix = "37691ec4-57fb-4c0f-ae31-32791610cb14_37691ec4-57fb-4c0f-ae31-32791610cb14"

    func test_createUnknownIdentifier() {
        let testCases = [
            "48:37691ec4-57fb-4c0f-ae31-32791610cb14",
            "28:ag08-global:01234567-89ab-cdef-0123-456789abcdef",
            "28:ag09-global:01234567-89ab-cdef-0123-456789abcdef",
            "28:gal-global:01234567-89ab-cdef-0123-456789abcdef"
        ]

        testCases.forEach { rawId in
            let identifier = createCommunicationIdentifier(fromRawId: rawId)
            switch identifier.kind {
            case .unknown:
                guard let identifier = identifier as? UnknownIdentifier else { return }
                XCTAssertEqual(identifier.rawId, rawId)
            default:
                XCTFail("test_createUnknownIdentifier created the wrong type")
            }
        }
    }

    func test_createUnkownUdentifier_withoutprefix() {
        let identifier = createCommunicationIdentifier(fromRawId: "37691ec4-57fb-4c0f-ae31-32791610cb14")
        switch identifier.kind {
        case .unknown:
            guard let identifier = identifier as? UnknownIdentifier else { return }
            XCTAssertEqual(identifier.rawId, "37691ec4-57fb-4c0f-ae31-32791610cb14")
        default:
            XCTFail("test_createUnknownIdentifier created the wrong type")
        }
    }

    func test_createPhoneNumberIdentifier() {
        let phoneNumberRawId = "\(Prefix.PhoneNumber)12345556789"
        let identifier = createCommunicationIdentifier(fromRawId: phoneNumberRawId)

        switch identifier.kind {
        case .phoneNumber:
            guard let identifier = identifier as? PhoneNumberIdentifier else { return }
            XCTAssertEqual(identifier.rawId, phoneNumberRawId)
            XCTAssertEqual(identifier.phoneNumber, "12345556789")
        default:
            XCTFail("test_createPhoneNumberIdentifier created the wrong type")
        }
    }

    func test_createCommunicationUserIdentifier_usingACS() {
        let acsRawId = Prefix.AcsUser + rawIdSuffix
        let identifier = createCommunicationIdentifier(fromRawId: acsRawId)
        switch identifier.kind {
        case .communicationUser:
            guard let identifier = identifier as? CommunicationUserIdentifier else { return }
            XCTAssertEqual(identifier.rawId, acsRawId)
            XCTAssertEqual(identifier.identifier, acsRawId)
        default:
            XCTFail("test_createCommunicationUserIdentifier_usingACS created the wrong type")
        }
    }

    func test_createCommunicationUserIdentifier_usingSpool() {
        let spoolRawId = Prefix.SpoolUser + rawIdSuffix
        let identifier = createCommunicationIdentifier(fromRawId: spoolRawId)
        switch identifier.kind {
        case .communicationUser:
            guard let identifier = identifier as? CommunicationUserIdentifier else { return }
            XCTAssertEqual(identifier.rawId, spoolRawId)
            XCTAssertEqual(identifier.identifier, spoolRawId)
        default:
            XCTFail("test_createCommunicationUserIdentifier_usingSpool created the wrong type")
        }
    }

    func test_createCommunicationUserIdentifier_usingDoDACS() {
        let dodAcsRawId = Prefix.AcsUserDodCloud + rawIdSuffix
        let identifier = createCommunicationIdentifier(fromRawId: dodAcsRawId)
        switch identifier.kind {
        case .communicationUser:
            guard let identifier = identifier as? CommunicationUserIdentifier else { return }
            XCTAssertEqual(identifier.rawId, dodAcsRawId)
            XCTAssertEqual(identifier.identifier, dodAcsRawId)
        default:
            XCTFail("test_createCommunicationUserIdentifier_usingDoDACS created the wrong type")
        }
    }

    func test_createCommunicationUserIdentifier_usingGcchACS() {
        let gcchAcsRawId = Prefix.AcsUserGcchCloud + rawIdSuffix
        let identifier = createCommunicationIdentifier(fromRawId: gcchAcsRawId)
        switch identifier.kind {
        case .communicationUser:
            guard let identifier = identifier as? CommunicationUserIdentifier else { return }
            XCTAssertEqual(identifier.rawId, gcchAcsRawId)
            XCTAssertEqual(identifier.identifier, gcchAcsRawId)
        default:
            XCTFail("test_createCommunicationUserIdentifier_usingGcchACS created the wrong type")
        }
    }

    func test_createMicrosoftTeamsUserIdentifierAnonymousScope() {
        let teamUserAnonymousScope = Prefix.TeamUserAnonymous + rawIdSuffix
        let identifier = createCommunicationIdentifier(fromRawId: teamUserAnonymousScope)
        switch identifier.kind {
        case .microsoftTeamsUser:
            guard let identifier = identifier as? MicrosoftTeamsUserIdentifier else { return }
            XCTAssertEqual(identifier.rawId, teamUserAnonymousScope)
            XCTAssertEqual(identifier.userId, rawIdSuffix)
            XCTAssertEqual(identifier.isAnonymous, true)
            XCTAssertEqual(identifier.cloudEnviroment, .Public)
        default:
            XCTFail("test_createMicrosoftTeamsUserIdentifierAnonymousScope created the wrong type")
        }
    }

    func test_createMicrosoftTeamsUserIdentifierPublicScope() {
        let teamUserPublicCloudScope = Prefix.TeamUserPublicCloud + rawIdSuffix
        let identifier = createCommunicationIdentifier(fromRawId: teamUserPublicCloudScope)
        switch identifier.kind {
        case .microsoftTeamsUser:
            guard let identifier = identifier as? MicrosoftTeamsUserIdentifier else { return }
            XCTAssertEqual(identifier.rawId, teamUserPublicCloudScope)
            XCTAssertEqual(identifier.userId, rawIdSuffix)
            XCTAssertEqual(identifier.isAnonymous, false)
            XCTAssertEqual(identifier.cloudEnviroment, .Public)
        default:
            XCTFail("test_createMicrosoftTeamsUserIdentifierPublicScope created the wrong type")
        }
    }

    func test_createMicrosoftTeamsUserIdentifierDODScope() {
        let teamUserDODCloudScope = Prefix.TeamUserDodCloud + rawIdSuffix
        let identifier = createCommunicationIdentifier(fromRawId: teamUserDODCloudScope)
        switch identifier.kind {
        case .microsoftTeamsUser:
            guard let identifier = identifier as? MicrosoftTeamsUserIdentifier else { return }
            XCTAssertEqual(identifier.rawId, teamUserDODCloudScope)
            XCTAssertEqual(identifier.userId, rawIdSuffix)
            XCTAssertEqual(identifier.isAnonymous, false)
            XCTAssertEqual(identifier.cloudEnviroment, .Dod)
        default:
            XCTFail("test_createMicrosoftTeamsUserIdentifierDODScope created the wrong type")
        }
    }

    func test_createMicrosoftTeamsUserIdentifierGCCHScope() {
        let teamUserGCCHCloudScope = Prefix.TeamUserGcchCloud + rawIdSuffix
        let identifier = createCommunicationIdentifier(fromRawId: teamUserGCCHCloudScope)
        switch identifier.kind {
        case .microsoftTeamsUser:
            guard let identifier = identifier as? MicrosoftTeamsUserIdentifier else { return }
            XCTAssertEqual(identifier.rawId, teamUserGCCHCloudScope)
            XCTAssertEqual(identifier.userId, rawIdSuffix)
            XCTAssertEqual(identifier.isAnonymous, false)
            XCTAssertEqual(identifier.cloudEnviroment, .Gcch)
        default:
            XCTFail("test_createMicrosoftTeamsUserIdentifierGCCHScope created the wrong type")
        }
    }

    func test_createMicrosoftBotIdentifier() {
        let testCases = [
            (CommunicationCloudEnvironment.Public, Prefix.BotPublicCloud + rawIdSuffix),
            (CommunicationCloudEnvironment.Dod, Prefix.BotDodCloud + rawIdSuffix),
            (CommunicationCloudEnvironment.Gcch, Prefix.BotGcchCloud + rawIdSuffix)
        ]

        testCases.forEach { cloud, rawId in

            let identifier = createCommunicationIdentifier(fromRawId: rawId)
            switch identifier.kind {
            case .microsoftBot:
                guard let identifier = identifier as? MicrosoftBotIdentifier else { return }
                XCTAssertEqual(identifier.rawId, rawId)
                XCTAssertEqual(identifier.botId, rawIdSuffix)
                XCTAssertEqual(identifier.isGlobal, false)
                XCTAssertEqual(identifier.cloudEnviroment, cloud)
            default:
                XCTFail("test_createMicrosoftBotIdentifier created the wrong type")
            }
        }
    }

    func test_createMicrosoftBotIdentifierGlobal() {
        let testCases = [
            (CommunicationCloudEnvironment.Public, Prefix.Bot + rawIdSuffix),
            (CommunicationCloudEnvironment.Dod, Prefix.BotDodCloudGlobal + rawIdSuffix),
            (CommunicationCloudEnvironment.Gcch, Prefix.BotGcchCloudGlobal + rawIdSuffix)
        ]

        testCases.forEach { cloud, rawId in

            let identifier = createCommunicationIdentifier(fromRawId: rawId)
            switch identifier.kind {
            case .microsoftBot:
                guard let identifier = identifier as? MicrosoftBotIdentifier else { return }
                XCTAssertEqual(identifier.rawId, rawId)
                XCTAssertEqual(identifier.botId, rawIdSuffix)
                XCTAssertEqual(identifier.isGlobal, true)
                XCTAssertEqual(identifier.cloudEnviroment, cloud)
            default:
                XCTFail("test_createMicrosoftBotIdentifierGlobal created the wrong type")
            }
        }
    }

    func test_rawIdStaysTheSameAfterConversionToIdentifierAndBack() {
        assertRoundTrip(
            rawId: "\(Prefix.AcsUser)bbbcbc1e-9f06-482a-b5d8-20e3f26ef0cd_45ab2481-1c1c-4005-be24-0ffb879b1130"
        )
        assertRoundTrip(
            rawId: "\(Prefix.SpoolUser)bbbcbc1e-9f06-482a-b5d8-20e3f26ef0cd_45ab2481-1c1c-4005-be24-0ffb879b1130"
        )
        assertRoundTrip(
            rawId: "\(Prefix.AcsUserDodCloud)bbbcbc1e-9f06-482a-b5d8-20e3f26ef0cd_45ab2481-1c1c-4005-be24-0ffb879b1130"
        )
        assertRoundTrip(
            rawId: "\(Prefix.AcsUserGcchCloud)bbbcbc1e-9f06-482a-b5d8-20e3f26ef0cd_45ab2481-1c1c-4005-be24-0ffb879b1130"
        )
        assertRoundTrip(rawId: "\(Prefix.AcsUser)something")
        assertRoundTrip(rawId: "\(Prefix.TeamUserPublicCloud)45ab2481-1c1c-4005-be24-0ffb879b1130")
        assertRoundTrip(rawId: "\(Prefix.TeamUserDodCloud)45ab2481-1c1c-4005-be24-0ffb879b1130")
        assertRoundTrip(rawId: "\(Prefix.TeamUserGcchCloud)45ab2481-1c1c-4005-be24-0ffb879b1130")
        assertRoundTrip(rawId: "\(Prefix.TeamUserAnonymous)45ab2481-1c1c-4005-be24-0ffb879b1130")
        assertRoundTrip(rawId: "\(Prefix.TeamUserPublicCloud)legacyFormat")
        assertRoundTrip(rawId: "\(Prefix.PhoneNumber)112345556789")
        assertRoundTrip(rawId: "\(Prefix.PhoneNumber)+112345556789")
        assertRoundTrip(rawId: "\(Prefix.PhoneNumber)207ffef6-9444-41fb-92ab-20eacaae2768")
        assertRoundTrip(
            rawId: "\(Prefix.PhoneNumber)207ffef6-9444-41fb-92ab-20eacaae2768_207ffef6-9444-41fb-92ab-20eacaae2768"
        )
        assertRoundTrip(rawId: "\(Prefix.PhoneNumber)+112345556789_207ffef6-9444-41fb-92ab-20eacaae2768")
        assertRoundTrip(rawId: "\(Prefix.Bot)45ab2481-1c1c-4005-be24-0ffb879b1130")
        assertRoundTrip(rawId: "\(Prefix.BotPublicCloud)45ab2481-1c1c-4005-be24-0ffb879b1130")
        assertRoundTrip(rawId: "\(Prefix.BotDodCloud)45ab2481-1c1c-4005-be24-0ffb879b1130")
        assertRoundTrip(rawId: "\(Prefix.BotDodCloudGlobal)45ab2481-1c1c-4005-be24-0ffb879b1130")
        assertRoundTrip(rawId: "\(Prefix.BotGcchCloud)45ab2481-1c1c-4005-be24-0ffb879b1130")
        assertRoundTrip(rawId: "\(Prefix.BotGcchCloudGlobal)45ab2481-1c1c-4005-be24-0ffb879b1130")
    }

    private func assertRoundTrip(rawId: String) {
        XCTAssertEqual(createCommunicationIdentifier(fromRawId: rawId).rawId, rawId)
    }
}
