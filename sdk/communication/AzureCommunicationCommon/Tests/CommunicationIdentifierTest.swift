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

class CommunicationIdentifierTest: XCTestCase {
    let testUserId = "User Id"
    let testRawId = "Raw Id"
    let testPhoneNumber = "+12223334444"
    let testTeamsUserId = "Microsoft Teams User Id"

    func test_CommunicationUserIdentifier_RawId_IsEqualTo_Identifier() {
        let userIdentifier = CommunicationUserIdentifier(testRawId)
        XCTAssertEqual(userIdentifier.rawId, userIdentifier.identifier)
    }

    func test_UnknownIdentifier_RawId_IsEqualTo_Identifier() {
        let unknownIdentifier = UnknownIdentifier(testRawId)
        XCTAssertEqual(unknownIdentifier.rawId, unknownIdentifier.identifier)
    }

    func test_PhoneNumberIdentifier_IfRawIdIsNull_RawIdIsGeneratedProperly() {
        let expectedPhoneNumberRawId = "4:12223334444"
        let phoneNumberIdentifier = PhoneNumberIdentifier(phoneNumber: testPhoneNumber)
        XCTAssertEqual(phoneNumberIdentifier.rawId, expectedPhoneNumberRawId)
    }

    func test_MicrosoftTeamsUserIdentifier_IfRawIdIsNull_RawIdIsGeneratedProperly_AnonymousUserIsFalse() {
        let expectedRawId = "8:orgid:User Id"
        var teamsUserIdentifier = MicrosoftTeamsUserIdentifier(userId: testUserId)
        XCTAssertEqual(teamsUserIdentifier.rawId, expectedRawId)

        let expectedRawIdAndCloudDod = "8:dod:User Id"
        teamsUserIdentifier = MicrosoftTeamsUserIdentifier(
            userId: testUserId,
            cloudEnvironment: .Dod
        )
        XCTAssertEqual(teamsUserIdentifier.rawId, expectedRawIdAndCloudDod)

        let expectedRawIdAndCloudGcch = "8:gcch:User Id"
        teamsUserIdentifier = MicrosoftTeamsUserIdentifier(
            userId: testUserId,
            cloudEnvironment: .Gcch
        )
        XCTAssertEqual(teamsUserIdentifier.rawId, expectedRawIdAndCloudGcch)

        let expectedRawIdAndCloudPublic = "8:orgid:User Id"
        teamsUserIdentifier = MicrosoftTeamsUserIdentifier(
            userId: testUserId,
            cloudEnvironment: .Public
        )
        XCTAssertEqual(teamsUserIdentifier.rawId, expectedRawIdAndCloudPublic)
    }

    func test_MicrosoftTeamsUserIdentifier_IfRawIdIsNull_RawIdIsGeneratedProperly_AnonymousUserIsTrue() {
        let expectedRawId = "8:teamsvisitor:User Id"
        let teamsUserIdentifier = MicrosoftTeamsUserIdentifier(userId: testUserId, isAnonymous: true)
        XCTAssertEqual(teamsUserIdentifier.rawId, expectedRawId)
    }

    // swiftlint:disable function_body_length
    func test_IfRawIdIsOptional_EqualityCheckingOnlyRawId() {
        XCTAssertFalse(
            MicrosoftTeamsUserIdentifier(
                userId: testUserId,
                isAnonymous: true,
                rawId: testRawId
            ) ==
                MicrosoftTeamsUserIdentifier(
                    userId: testUserId,
                    isAnonymous: true
                )
        )
        XCTAssertFalse(
            MicrosoftTeamsUserIdentifier(
                userId: testUserId,
                isAnonymous: true
            ) ==
                MicrosoftTeamsUserIdentifier(
                    userId: testUserId,
                    isAnonymous: true,
                    rawId: testRawId
                )
        )
        XCTAssertFalse(
            MicrosoftTeamsUserIdentifier(
                userId: testUserId,
                isAnonymous: true,
                rawId: "some id"
            ) ==
                MicrosoftTeamsUserIdentifier(
                    userId: testUserId,
                    isAnonymous: true,
                    rawId: testRawId
                )
        )
        XCTAssertFalse(
            PhoneNumberIdentifier(
                phoneNumber: testPhoneNumber,
                rawId: testRawId
            ) ==
                PhoneNumberIdentifier(phoneNumber: testPhoneNumber)
        )
        XCTAssertTrue(
            PhoneNumberIdentifier(phoneNumber: testPhoneNumber) ==
                PhoneNumberIdentifier(phoneNumber: testPhoneNumber)
        )
        XCTAssertFalse(
            PhoneNumberIdentifier(phoneNumber: testPhoneNumber) ==
                PhoneNumberIdentifier(
                    phoneNumber: testPhoneNumber,
                    rawId: testRawId
                )
        )
        XCTAssertFalse(
            PhoneNumberIdentifier(
                phoneNumber: testPhoneNumber,
                rawId: "some id"
            ) ==
                PhoneNumberIdentifier(
                    phoneNumber: testPhoneNumber,
                    rawId: testRawId
                )
        )
    }
    // swiftlint:enable function_body_length

    func test_createUnknownIdentifier() {
        var unknownIdentifier = createCommunicationIdentifier(from: "37691ec4-57fb-4c0f-ae31-32791610cb14")
        XCTAssertTrue(unknownIdentifier.isKind(of: UnknownIdentifier.self))
        XCTAssertEqual(unknownIdentifier.kind, .unknown)
        XCTAssertEqual(unknownIdentifier.rawId, "37691ec4-57fb-4c0f-ae31-32791610cb14")

        unknownIdentifier = createCommunicationIdentifier(from: "48:37691ec4-57fb-4c0f-ae31-32791610cb14")
        XCTAssertTrue(unknownIdentifier.isKind(of: UnknownIdentifier.self))
        XCTAssertEqual(unknownIdentifier.rawId, "48:37691ec4-57fb-4c0f-ae31-32791610cb14")
    }

    func test_createPhoneNumberIdentifier() {
        let phoneNumberRawId = "4:12345556789"
        let phoneNumberIdentifier = createCommunicationIdentifier(from: phoneNumberRawId)
        XCTAssertTrue(phoneNumberIdentifier.isKind(of: PhoneNumberIdentifier.self))
        XCTAssertEqual(phoneNumberIdentifier.kind, .phoneNumber)
        XCTAssertEqual((phoneNumberIdentifier as? PhoneNumberIdentifier)?.rawId, phoneNumberRawId)
        XCTAssertEqual((phoneNumberIdentifier as? PhoneNumberIdentifier)?.phoneNumber, "+12345556789")
    }

    func test_createCommunicationUserIdentifier() {
        let acsRawId = "8:acs:37691ec4-57fb-4c0f-ae31-32791610cb14_37691ec4-57fb-4c0f-ae31-32791610cb14"
        var communicationUserIdentifier = createCommunicationIdentifier(from: acsRawId)
        XCTAssertTrue(communicationUserIdentifier.isKind(of: CommunicationUserIdentifier.self))
        XCTAssertEqual(communicationUserIdentifier.kind, .communicationUser)
        XCTAssertEqual(communicationUserIdentifier.rawId, acsRawId)
        XCTAssertEqual(
            (communicationUserIdentifier as? CommunicationUserIdentifier)?.identifier, acsRawId
        )

        let spoolRawId = "8:spool:37691ec4-57fb-4c0f-ae31-32791610cb14_37691ec4-57fb-4c0f-ae31-32791610cb14"
        communicationUserIdentifier = createCommunicationIdentifier(from: spoolRawId)
        XCTAssertTrue(communicationUserIdentifier.isKind(of: CommunicationUserIdentifier.self))
        XCTAssertEqual(communicationUserIdentifier.kind, .communicationUser)
        XCTAssertEqual(communicationUserIdentifier.rawId, spoolRawId)
        XCTAssertEqual(
            (communicationUserIdentifier as? CommunicationUserIdentifier)?.identifier, spoolRawId
        )

        let dodAcsRawId = "8:dod-acs:37691ec4-57fb-4c0f-ae31-32791610cb14_37691ec4-57fb-4c0f-ae31-32791610cb14"
        communicationUserIdentifier = createCommunicationIdentifier(from: dodAcsRawId)
        XCTAssertTrue(communicationUserIdentifier.isKind(of: CommunicationUserIdentifier.self))
        XCTAssertEqual(communicationUserIdentifier.kind, .communicationUser)
        XCTAssertEqual(communicationUserIdentifier.rawId, dodAcsRawId)
        XCTAssertEqual(
            (communicationUserIdentifier as? CommunicationUserIdentifier)?.identifier, dodAcsRawId
        )

        let gcchAcsRawId = "8:gcch-acs:37691ec4-57fb-4c0f-ae31-32791610cb14_37691ec4-57fb-4c0f-ae31-32791610cb14"
        communicationUserIdentifier = createCommunicationIdentifier(from: gcchAcsRawId)
        XCTAssertTrue(communicationUserIdentifier.isKind(of: CommunicationUserIdentifier.self))
        XCTAssertEqual(communicationUserIdentifier.kind, .communicationUser)
        XCTAssertEqual(communicationUserIdentifier.rawId, gcchAcsRawId)
        XCTAssertEqual(
            (communicationUserIdentifier as? CommunicationUserIdentifier)?.identifier, gcchAcsRawId
        )
    }

    func test_createMicrosoftTeamsUserIdentifierAnonymousScope() {
        let teamUserAnonymousScope =
            "8:teamsvisitor:37691ec4-57fb-4c0f-ae31-32791610cb14_37691ec4-57fb-4c0f-ae31-32791610cb14"
        let teamUserIdentifier = createCommunicationIdentifier(from: teamUserAnonymousScope)
        XCTAssertTrue(teamUserIdentifier.isKind(of: MicrosoftTeamsUserIdentifier.self))
        XCTAssertEqual(teamUserIdentifier.kind, .microsoftTeamsUser)
        XCTAssertEqual(teamUserIdentifier.rawId, teamUserAnonymousScope)
        XCTAssertEqual(
            (teamUserIdentifier as? MicrosoftTeamsUserIdentifier)?.userId,
            "37691ec4-57fb-4c0f-ae31-32791610cb14_37691ec4-57fb-4c0f-ae31-32791610cb14"
        )
        XCTAssertEqual(
            (teamUserIdentifier as? MicrosoftTeamsUserIdentifier)?.isAnonymous, true
        )
        XCTAssertEqual(
            (teamUserIdentifier as? MicrosoftTeamsUserIdentifier)?.cloudEnviroment, .Public
        )
    }

    func test_createMicrosoftTeamsUserIdentifierPublicScope() {
        let teamUserPublicCloudScope =
            "8:orgid:37691ec4-57fb-4c0f-ae31-32791610cb14_37691ec4-57fb-4c0f-ae31-32791610cb14"
        let teamUserIdentifier = createCommunicationIdentifier(from: teamUserPublicCloudScope)
        XCTAssertTrue(teamUserIdentifier.isKind(of: MicrosoftTeamsUserIdentifier.self))
        XCTAssertEqual(teamUserIdentifier.kind, .microsoftTeamsUser)
        XCTAssertEqual(teamUserIdentifier.rawId, teamUserPublicCloudScope)
        XCTAssertEqual(
            (teamUserIdentifier as? MicrosoftTeamsUserIdentifier)?.userId,
            "37691ec4-57fb-4c0f-ae31-32791610cb14_37691ec4-57fb-4c0f-ae31-32791610cb14"
        )
        XCTAssertEqual(
            (teamUserIdentifier as? MicrosoftTeamsUserIdentifier)?.isAnonymous, false
        )
        XCTAssertEqual(
            (teamUserIdentifier as? MicrosoftTeamsUserIdentifier)?.cloudEnviroment, .Public
        )
    }

    func test_createMicrosoftTeamsUserIdentifierDODScope() {
        let teamUserDODCloudScope = "8:dod:37691ec4-57fb-4c0f-ae31-32791610cb14_37691ec4-57fb-4c0f-ae31-32791610cb14"
        let teamUserIdentifier = createCommunicationIdentifier(from: teamUserDODCloudScope)
        XCTAssertTrue(teamUserIdentifier.isKind(of: MicrosoftTeamsUserIdentifier.self))
        XCTAssertEqual(teamUserIdentifier.kind, .microsoftTeamsUser)
        XCTAssertEqual(teamUserIdentifier.rawId, teamUserDODCloudScope)
        XCTAssertEqual(
            (teamUserIdentifier as? MicrosoftTeamsUserIdentifier)?.userId,
            "37691ec4-57fb-4c0f-ae31-32791610cb14_37691ec4-57fb-4c0f-ae31-32791610cb14"
        )
        XCTAssertEqual(
            (teamUserIdentifier as? MicrosoftTeamsUserIdentifier)?.isAnonymous, false
        )
        XCTAssertEqual(
            (teamUserIdentifier as? MicrosoftTeamsUserIdentifier)?.cloudEnviroment, .Dod
        )
    }

    func test_createMicrosoftTeamsUserIdentifierGCCHScope() {
        let teamUserGCCHCloudScope = "8:gcch:37691ec4-57fb-4c0f-ae31-32791610cb14_37691ec4-57fb-4c0f-ae31-32791610cb14"
        let teamUserIdentifier = createCommunicationIdentifier(from: teamUserGCCHCloudScope)

        XCTAssertTrue(teamUserIdentifier.isKind(of: MicrosoftTeamsUserIdentifier.self))
        XCTAssertEqual(teamUserIdentifier.kind, .microsoftTeamsUser)
        XCTAssertEqual(teamUserIdentifier.rawId, teamUserGCCHCloudScope)

        XCTAssertEqual(
            (teamUserIdentifier as? MicrosoftTeamsUserIdentifier)?.userId,
            "37691ec4-57fb-4c0f-ae31-32791610cb14_37691ec4-57fb-4c0f-ae31-32791610cb14"
        )
        XCTAssertEqual(
            (teamUserIdentifier as? MicrosoftTeamsUserIdentifier)?.isAnonymous, false
        )
        XCTAssertEqual(
            (teamUserIdentifier as? MicrosoftTeamsUserIdentifier)?.cloudEnviroment, .Gcch
        )
    }

    func test_MicrosoftTeamsUserIdentifier_DefaultCloudIsPublic() throws {
        XCTAssertEqual(
            CommunicationCloudEnvironment.Public,
            MicrosoftTeamsUserIdentifier(
                userId: testUserId,
                isAnonymous: true,
                rawId: testRawId
            ).cloudEnviroment
        )
    }
}
