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
    let testPhoneNumberRawId = "4:+12223334444"
    let testPhoneNumberWithoutPlus = "12223334444"
    let testPhoneNumberRawIdWithoutPlus = "4:12223334444"
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
        var phoneNumberIdentifier = PhoneNumberIdentifier(phoneNumber: testPhoneNumber)
        XCTAssertEqual(phoneNumberIdentifier.rawId, testPhoneNumberRawId)
        XCTAssertEqual(phoneNumberIdentifier.isAnonymous, false)
        XCTAssertEqual(phoneNumberIdentifier.assertedId, nil)
        phoneNumberIdentifier = PhoneNumberIdentifier(phoneNumber: testPhoneNumberWithoutPlus)
        XCTAssertEqual(phoneNumberIdentifier.rawId, testPhoneNumberRawIdWithoutPlus)
    }

    func test_PhoneNumberIdentifier_IsAnonymous() {
        var phoneNumberIdentifier = PhoneNumberIdentifier(phoneNumber: "anonymous")
        XCTAssertEqual(phoneNumberIdentifier.isAnonymous, true)
        phoneNumberIdentifier = PhoneNumberIdentifier(phoneNumber: "4:anonymous")
        XCTAssertEqual(phoneNumberIdentifier.isAnonymous, false)
        phoneNumberIdentifier = PhoneNumberIdentifier(phoneNumber: "anonymous123")
        XCTAssertEqual(phoneNumberIdentifier.isAnonymous, false)
    }

    func test_PhoneNumberIdentifier_AssertedId() {
        var phoneNumberIdentifier = PhoneNumberIdentifier(phoneNumber: "14255550121.123")
        XCTAssertEqual(phoneNumberIdentifier.assertedId, nil)
        phoneNumberIdentifier = PhoneNumberIdentifier(phoneNumber: "14255550121-123")
        XCTAssertEqual(phoneNumberIdentifier.assertedId, nil)
        phoneNumberIdentifier = PhoneNumberIdentifier(phoneNumber: "14255550121_123")
        XCTAssertEqual(phoneNumberIdentifier.assertedId, "123")
        phoneNumberIdentifier = PhoneNumberIdentifier(phoneNumber: "14255550121", rawId: "4:14255550121_123")
        XCTAssertEqual(phoneNumberIdentifier.assertedId, "123")
        phoneNumberIdentifier = PhoneNumberIdentifier(phoneNumber: "14255550121_123_456")
        XCTAssertEqual(phoneNumberIdentifier.assertedId, "456")
        phoneNumberIdentifier = PhoneNumberIdentifier(phoneNumber: "14255550121", rawId: "4:14255550121_123_456")
        XCTAssertEqual(phoneNumberIdentifier.assertedId, "456")
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

    // swiftlint:enable function_body_length
    func test_MicrosoftTeamsUserIdentifier_DefaultCloudIsPublic() throws {
        XCTAssertEqual(
            CommunicationCloudEnvironment.Public,
            MicrosoftTeamsUserIdentifier(
                userId: testUserId,
                isAnonymous: true,
                rawId: testRawId
            ).cloudEnvironment
        )
    }

    func test_MicrosoftTeamsAppIdentifier_IfRawIdIsNull_RawIdIsGeneratedProperly() {
        let expectedRawId = "28:orgid:User Id"
        var teamsAppIdentifier = MicrosoftTeamsAppIdentifier(appId: testUserId)
        XCTAssertEqual(teamsAppIdentifier.rawId, expectedRawId)

        let expectedRawIdAndCloudDod = "28:dod:User Id"
        teamsAppIdentifier = MicrosoftTeamsAppIdentifier(
            appId: testUserId,
            cloudEnvironment: .Dod
        )
        XCTAssertEqual(teamsAppIdentifier.rawId, expectedRawIdAndCloudDod)

        let expectedRawIdAndCloudGcch = "28:gcch:User Id"
        teamsAppIdentifier = MicrosoftTeamsAppIdentifier(
            appId: testUserId,
            cloudEnvironment: .Gcch
        )
        XCTAssertEqual(teamsAppIdentifier.rawId, expectedRawIdAndCloudGcch)
    }

    // swiftlint:enable function_body_length
    func test_MicrosoftTeamsAppIdentifier_DefaultCloudIsPublic() throws {
        XCTAssertEqual(
            CommunicationCloudEnvironment.Public,
            MicrosoftTeamsAppIdentifier(
                appId: testUserId
            ).cloudEnvironment
        )
    }

    func test_TeamsExtensionUserIdentifier_VariablesSetProperly() {
        let expectedUserId = UUID().uuidString
        let expectedTenantId = UUID().uuidString
        let expectedResourceId = UUID().uuidString
        let teamsExtensionUserIdentifier = TeamsExtensionUserIdentifier(
            userId: expectedUserId,
            tenantId: expectedTenantId,
            resourceId: expectedResourceId
        )
        XCTAssertEqual(teamsExtensionUserIdentifier.userId, expectedUserId)
        XCTAssertEqual(teamsExtensionUserIdentifier.tenantId, expectedTenantId)
        XCTAssertEqual(teamsExtensionUserIdentifier.resourceId, expectedResourceId)
        XCTAssertEqual(teamsExtensionUserIdentifier.cloudEnvironment, .Public)
        XCTAssertEqual(
            teamsExtensionUserIdentifier.rawId,
            "\(Prefix.AcsUser)\(expectedResourceId)_\(expectedTenantId)_\(expectedUserId)"
        )
    }

    func test_TeamsExtensionUserIdentifier_AssertRawIdGeneration() {
        let userId = UUID().uuidString
        let tenantId = UUID().uuidString
        let resourceId = UUID().uuidString
        var teamsExtensionUserIdentifier = TeamsExtensionUserIdentifier(
            userId: userId,
            tenantId: tenantId,
            resourceId: resourceId,
            cloudEnvironment: .Dod
        )
        XCTAssertEqual(
            teamsExtensionUserIdentifier.rawId,
            "\(Prefix.AcsUserDodCloud)\(resourceId)_\(tenantId)_\(userId)"
        )

        teamsExtensionUserIdentifier = TeamsExtensionUserIdentifier(
            userId: userId,
            tenantId: tenantId,
            resourceId: resourceId,
            cloudEnvironment: .Gcch
        )
        XCTAssertEqual(
            teamsExtensionUserIdentifier.rawId,
            "\(Prefix.AcsUserGcchCloud)\(resourceId)_\(tenantId)_\(userId)"
        )
    }

    func test_TeamsExtensionUserIdentifier_EqualityCheckingOnlyRawId() {
        let userId = UUID().uuidString
        let tenantId = UUID().uuidString
        let resourceId = UUID().uuidString
        XCTAssertTrue(
            TeamsExtensionUserIdentifier(
                userId: userId,
                tenantId: tenantId,
                resourceId: resourceId
            ) ==
                TeamsExtensionUserIdentifier(
                    userId: userId,
                    tenantId: tenantId,
                    resourceId: resourceId,
                )
        )

        XCTAssertTrue(
            TeamsExtensionUserIdentifier(
                userId: userId,
                tenantId: tenantId,
                resourceId: resourceId
            ) ==
                TeamsExtensionUserIdentifier(
                    userId: userId,
                    tenantId: tenantId,
                    resourceId: resourceId,
                    cloudEnvironment: .Public
                )
        )

        XCTAssertFalse(
            TeamsExtensionUserIdentifier(
                userId: userId,
                tenantId: tenantId,
                resourceId: resourceId
            ) ==
                TeamsExtensionUserIdentifier(
                    userId: userId,
                    tenantId: tenantId,
                    resourceId: resourceId,
                    cloudEnvironment: .Dod
                )
        )

        XCTAssertFalse(
            TeamsExtensionUserIdentifier(
                userId: userId,
                tenantId: tenantId,
                resourceId: resourceId
            ) ==
                TeamsExtensionUserIdentifier(
                    userId: userId,
                    tenantId: tenantId,
                    resourceId: resourceId,
                    cloudEnvironment: .Gcch
                )
        )
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
            PhoneNumberIdentifier(
                phoneNumber: testPhoneNumber,
                rawId: testPhoneNumberRawId
            ) ==
                PhoneNumberIdentifier(phoneNumber: testPhoneNumber)
        )
        XCTAssertTrue(
            PhoneNumberIdentifier(
                phoneNumber: testPhoneNumberWithoutPlus,
                rawId: testPhoneNumberRawIdWithoutPlus
            ) ==
                PhoneNumberIdentifier(phoneNumber: testPhoneNumberWithoutPlus)
        )
        XCTAssertTrue(
            PhoneNumberIdentifier(phoneNumber: testPhoneNumber) ==
                PhoneNumberIdentifier(phoneNumber: testPhoneNumber)
        )
        XCTAssertTrue(
            PhoneNumberIdentifier(phoneNumber: testPhoneNumberWithoutPlus) ==
                PhoneNumberIdentifier(phoneNumber: testPhoneNumberWithoutPlus)
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
        var teamsAppIdentifier = MicrosoftTeamsAppIdentifier(appId: testUserId)
        teamsAppIdentifier.rawId = testRawId
        var otherTeamsAppIdentifier = MicrosoftTeamsAppIdentifier(appId: testUserId)
        XCTAssertFalse(teamsAppIdentifier == otherTeamsAppIdentifier)
        XCTAssertFalse(otherTeamsAppIdentifier == teamsAppIdentifier)

        teamsAppIdentifier.rawId = "some id"
        otherTeamsAppIdentifier.rawId = testRawId
        XCTAssertFalse(teamsAppIdentifier == otherTeamsAppIdentifier)
        XCTAssertFalse(teamsAppIdentifier.isEqual(otherTeamsAppIdentifier))
    }
}
