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
