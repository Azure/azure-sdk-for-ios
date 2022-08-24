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

@testable import AzureCommunicationChat
import AzureCommunicationCommon
import AzureCore

class IdentifierSerializerTests: XCTestCase {
    let testUserId = "User Id"
    let testRawId = "Raw Id"
    let testPhoneNumber = "+12223334444"
    let testTeamsUserId = "Microsoft Teams User Id"

    private var testUserModel: CommunicationUserIdentifierModel?
    private var testPhoneNumberModel: PhoneNumberIdentifierModel?
    private var testTeamsUserModel: MicrosoftTeamsUserIdentifierModel?

    override func setUp() {
        super.setUp()

        testUserModel = CommunicationUserIdentifierModel(id: testUserId)
        testPhoneNumberModel = PhoneNumberIdentifierModel(value: testPhoneNumber)
        testTeamsUserModel = MicrosoftTeamsUserIdentifierModel(
            userId: testTeamsUserId,
            isAnonymous: true,
            cloud: .gcch
        )
    }

    func test_moreThanOneNestObject_Deserialize() throws {
        let communicationModels = [
            CommunicationIdentifierModelInternal(
                rawId: testRawId,
                communicationUser: testUserModel,
                phoneNumber: testPhoneNumberModel,
                microsoftTeamsUser: nil
            ),
            CommunicationIdentifierModelInternal(
                rawId: testRawId,
                communicationUser: testUserModel,
                phoneNumber: nil,
                microsoftTeamsUser: testTeamsUserModel
            ),
            CommunicationIdentifierModelInternal(
                rawId: testRawId,
                communicationUser: nil,
                phoneNumber: testPhoneNumberModel,
                microsoftTeamsUser: testTeamsUserModel
            )
        ]

        for item in communicationModels {
            XCTAssertThrowsError(try IdentifierSerializer.deserialize(identifier: item))
        }
    }

    func test_DeserializeCommunicationUser() throws {
        let identifierModel = CommunicationIdentifierModelInternal(
            rawId: testRawId,
            communicationUser: testUserModel,
            phoneNumber: nil,
            microsoftTeamsUser: nil
        )
        let identifier = try IdentifierSerializer.deserialize(identifier: identifierModel)
        let expectedIdentifier = CommunicationUserIdentifier(testUserId)

        XCTAssertTrue(identifier is CommunicationUserIdentifier)
        XCTAssertEqual(
            expectedIdentifier.identifier,
            (identifier as? CommunicationUserIdentifier)?.identifier
        )
    }

    func test_SerializeCommunicationUser() throws {
        let model = try IdentifierSerializer
            .serialize(identifier: CommunicationUserIdentifier("some id"))

        XCTAssertNotNil(model.communicationUser)
        XCTAssertEqual(model.communicationUser?.id, "some id")
    }

    func test_DeserializeUnknown() throws {
        let identifierModel = CommunicationIdentifierModelInternal(
            rawId: testRawId,
            communicationUser: nil,
            phoneNumber: nil,
            microsoftTeamsUser: nil
        )
        let identifier = try IdentifierSerializer.deserialize(identifier: identifierModel)
        let expectedIdentifier = UnknownIdentifier(testRawId)

        XCTAssertTrue(identifier is UnknownIdentifier)
        XCTAssertEqual(expectedIdentifier.identifier, (identifier as? UnknownIdentifier)?.identifier)
    }

    func test_SerializeUnknown() throws {
        let model = try IdentifierSerializer
            .serialize(identifier: UnknownIdentifier(testRawId))

        XCTAssertEqual(model.rawId, testRawId)
    }

    func test_DeserializePhoneNumber() throws {
        let identifierModel = CommunicationIdentifierModelInternal(
            rawId: testRawId,
            communicationUser: nil,
            phoneNumber: testPhoneNumberModel,
            microsoftTeamsUser: nil
        )
        let identifier = try IdentifierSerializer.deserialize(identifier: identifierModel)
        let expectedIdentifier = PhoneNumberIdentifier(phoneNumber: testPhoneNumber, rawId: testRawId)

        XCTAssertTrue(identifier is PhoneNumberIdentifier)
        XCTAssertEqual(expectedIdentifier.phoneNumber, (identifier as? PhoneNumberIdentifier)?.phoneNumber)
        XCTAssertEqual(expectedIdentifier.rawId, (identifier as? PhoneNumberIdentifier)?.rawId)
    }

    func test_SerializePhoneNumber_ExpectedIdString() throws {
        try serializePhoneNumber(expectedId: testRawId)
    }

    func serializePhoneNumber(expectedId: String?) throws {
        let model = try IdentifierSerializer
            .serialize(identifier: PhoneNumberIdentifier(phoneNumber: testPhoneNumber, rawId: expectedId))

        XCTAssertNotNil(model.phoneNumber)
        XCTAssertEqual(model.phoneNumber?.value, testPhoneNumber)
        XCTAssertEqual(model.rawId, expectedId)
    }

    func test_DeserializeMicrosoftTeamsUser() throws {
        let model = CommunicationIdentifierModelInternal(
            rawId: testRawId,
            communicationUser: nil,
            phoneNumber: nil,
            microsoftTeamsUser: testTeamsUserModel
        )
        let identifier = try IdentifierSerializer.deserialize(identifier: model)

        let expectedIdentifier = MicrosoftTeamsUserIdentifier(
            userId: testTeamsUserId,
            isAnonymous: true,
            rawId: testRawId,
            cloudEnvironment: .Gcch
        )

        XCTAssertTrue(identifier is MicrosoftTeamsUserIdentifier)
        XCTAssertEqual(expectedIdentifier.userId, (identifier as? MicrosoftTeamsUserIdentifier)?.userId)
    }

    func test_SerializeMicrosoftTeamsUser_NotAnonymous_ExpectedIdNil() throws {
        try serializeMicrosoftTeamsUser(isAnonymous: false, expectedId: nil)
    }

    func test_SerializeMicrosoftTeamsUser_Anonymous_ExpectedIdNil() throws {
        try serializeMicrosoftTeamsUser(isAnonymous: true, expectedId: nil)
    }

    func test_SerializeMicrosoftTeamsUser_NotAnonymous_ExpectedIdString() throws {
        try serializeMicrosoftTeamsUser(isAnonymous: false, expectedId: testRawId)
    }

    func test_SerializeMicrosoftTeamsUser_Anonymous_ExpectedIdString() throws {
        try serializeMicrosoftTeamsUser(isAnonymous: true, expectedId: testRawId)
    }

    func serializeMicrosoftTeamsUser(isAnonymous: Bool, expectedId: String?) throws {
        let identifier = MicrosoftTeamsUserIdentifier(
            userId: testTeamsUserId,
            isAnonymous: isAnonymous,
            rawId: expectedId
        )
        let model = try IdentifierSerializer.serialize(identifier: identifier)

        XCTAssertNotNil(model.microsoftTeamsUser)

        XCTAssertEqual(model.microsoftTeamsUser?.isAnonymous, isAnonymous)
        XCTAssertEqual(model.microsoftTeamsUser?.userId, testTeamsUserId)
        XCTAssertEqual(model.microsoftTeamsUser?.cloud, .public)
    }

    func test_DeserializeMissingProperty() throws {
        let modelsWithMissingMandatoryProperty: [CommunicationIdentifierModelInternal] = [
            CommunicationIdentifierModelInternal( // missing raw id
                rawId: nil,
                communicationUser: testUserModel,
                phoneNumber: nil,
                microsoftTeamsUser: nil
            ),
            CommunicationIdentifierModelInternal( // missing raw id
                rawId: nil,
                communicationUser: nil,
                phoneNumber: testPhoneNumberModel,
                microsoftTeamsUser: nil
            ),
            CommunicationIdentifierModelInternal( // MicrosoftTeamsUserIdentifierModel missing isAnonymous
                rawId: "some id",
                communicationUser: nil,
                phoneNumber: nil,
                microsoftTeamsUser: MicrosoftTeamsUserIdentifierModel(
                    userId: "some id",
                    cloud: .public
                )
            ),
            CommunicationIdentifierModelInternal( // MicrosoftTeamsUserIdentifierModel missing isAnonymous
                rawId: "some id",
                communicationUser: nil,
                phoneNumber: nil,
                microsoftTeamsUser: MicrosoftTeamsUserIdentifierModel(
                    userId: "some id",
                    isAnonymous: false
                )
            ),
            CommunicationIdentifierModelInternal( // missing raw id
                rawId: nil,
                communicationUser: nil,
                phoneNumber: nil,
                microsoftTeamsUser: testTeamsUserModel
            )
        ]

        var exceptionCount = 0

        for item in modelsWithMissingMandatoryProperty {
            do {
                _ = try IdentifierSerializer.deserialize(identifier: item)
            } catch {
                exceptionCount += 1
            }
        }

        XCTAssertEqual(exceptionCount, modelsWithMissingMandatoryProperty.count)
    }
}
