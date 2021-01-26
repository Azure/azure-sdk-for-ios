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

#if canImport(AzureCommunication)
    @testable import AzureCommunication
#endif
#if canImport(AzureCore)
    @testable import AzureCore
#endif

class CommunicationIdentifierSerializerTests: XCTestCase {
    func test_DeserializeCommunicationUser() throws {
        let identifier = try CommunicationIdentifierSerializer
            .deserialize(identifier: CommunicationIdentifierModel(kind: .communicationUser, id: "some id"))

        let expectedIdentifier = CommunicationUserIdentifier(identifier: "some id")

        XCTAssertTrue(identifier is CommunicationUserIdentifier)
        XCTAssertEqual(expectedIdentifier.identifier, (identifier as? CommunicationUserIdentifier)?.identifier)
    }

    func test_SerializeCommunicationUser() throws {
        let model = try CommunicationIdentifierSerializer
            .serialize(identifier: CommunicationUserIdentifier(identifier: "some id"))

        XCTAssertEqual(model.kind, .communicationUser)
        XCTAssertEqual(model.id, "some id")
    }

    func test_DeserializeUnknown() throws {
        let identifier = try CommunicationIdentifierSerializer
            .deserialize(identifier: CommunicationIdentifierModel(kind: .unknown, id: "some id"))

        let expectedIdentifier = UnknownIdentifier(identifier: "some id")

        XCTAssertTrue(identifier is UnknownIdentifier)
        XCTAssertEqual(expectedIdentifier.identifier, (identifier as? UnknownIdentifier)?.identifier)
    }

    func test_SerializeUnknown() throws {
        let model = try CommunicationIdentifierSerializer
            .serialize(identifier: UnknownIdentifier(identifier: "some id"))

        XCTAssertEqual(model.kind, .unknown)
        XCTAssertEqual(model.id, "some id")
    }

    func test_DeserializeCallingApplication() throws {
        let identifier = try CommunicationIdentifierSerializer
            .deserialize(identifier: CommunicationIdentifierModel(kind: .callingApplication, id: "some id"))

        let expectedIdentifier = CallingApplicationIdentifier(identifier: "some id")

        XCTAssertTrue(identifier is CallingApplicationIdentifier)
        XCTAssertEqual(expectedIdentifier.identifier, (identifier as? CallingApplicationIdentifier)?.identifier)
    }

    func test_SerializeCallingApplication() throws {
        let model = try CommunicationIdentifierSerializer
            .serialize(identifier: CallingApplicationIdentifier(identifier: "some id"))

        XCTAssertEqual(model.kind, .callingApplication)
        XCTAssertEqual(model.id, "some id")
    }

    func test_DeserializePhoneNumber() throws {
        let identifier = try CommunicationIdentifierSerializer
            .deserialize(identifier: CommunicationIdentifierModel(kind: .phoneNumber, id: "some id", phoneNumber: "+12223334444"))

        let expectedIdentifier = PhoneNumberIdentifier(phoneNumber: "+12223334444", id: "some id")

        XCTAssertTrue(identifier is PhoneNumberIdentifier)
        XCTAssertEqual(expectedIdentifier.phoneNumber, (identifier as? PhoneNumberIdentifier)?.phoneNumber)
        XCTAssertEqual(expectedIdentifier.id, (identifier as? PhoneNumberIdentifier)?.id)
    }

    func test_SerializePhoneNumber() throws {
        try serializePhoneNumber(expectedId: "some id")
        try serializePhoneNumber(expectedId: nil)
    }

    func serializePhoneNumber(expectedId: String?) throws {
        let model = try CommunicationIdentifierSerializer
            .serialize(identifier: PhoneNumberIdentifier(phoneNumber: "+12223334444", id: expectedId))

        XCTAssertEqual(model.kind, .phoneNumber)
        XCTAssertEqual(model.phoneNumber, "+12223334444")
        XCTAssertEqual(model.id, expectedId)
    }

    func test_DeserializeMicrosoftTeamsUser() throws {
        let identifier = try CommunicationIdentifierSerializer
            .deserialize(identifier: CommunicationIdentifierModel(kind: .microsoftTeamsUser, id: "some id", microsoftTeamsUserId: "user id", isAnonymous: false, cloud: CommunicationCloudEnvironmentModel.Gcch))

        let expectedIdentifier = MicrosoftTeamsUserIdentifier(userId: "user id", isAnonymous: false, id: "some id", cloudEnvironemt: CommunicationCloudEnvironment.Gcch)

        XCTAssertTrue(identifier is MicrosoftTeamsUserIdentifier)
        XCTAssertEqual(expectedIdentifier.userId, (identifier as? MicrosoftTeamsUserIdentifier)?.userId)
    }

    func test_SerializeMicrosoftTeamsUser() throws {
        try serializeMicrosoftTeamsUser(isAnonymous: false, expectedId: nil)
        try serializeMicrosoftTeamsUser(isAnonymous: true, expectedId: nil)
        try serializeMicrosoftTeamsUser(isAnonymous: false, expectedId: "some id")
        try serializeMicrosoftTeamsUser(isAnonymous: true, expectedId: "some id")
    }
    
    func serializeMicrosoftTeamsUser(isAnonymous: Bool, expectedId: String?) throws {
        let model = try CommunicationIdentifierSerializer
            .serialize(identifier: MicrosoftTeamsUserIdentifier(userId: "user id", isAnonymous: isAnonymous, id: expectedId))

        XCTAssertEqual(model.kind, .microsoftTeamsUser)
        XCTAssertEqual(model.microsoftTeamsUserId, "user id")
        XCTAssertEqual(model.isAnonymous, isAnonymous)
        XCTAssertEqual(model.id, expectedId)
    }

    func test_DeserializeMissingProperty() throws {
        let modelsWithMissingMandatoryProperty: [CommunicationIdentifierModel] = [
            CommunicationIdentifierModel(kind: .unknown), // Missing Id
            CommunicationIdentifierModel(kind: .communicationUser), // Missing Id
            CommunicationIdentifierModel(kind: .callingApplication), // Missing Id
            CommunicationIdentifierModel(kind: .phoneNumber, id: "some id"), // Missing PhoneNumber
            CommunicationIdentifierModel(kind: .phoneNumber, phoneNumber: "some id"), // Missing Id
            CommunicationIdentifierModel(kind: .microsoftTeamsUser, id: "some id", microsoftTeamsUserId: "some id", cloud: CommunicationCloudEnvironmentModel.Public), // Missing IsAnonymous
            CommunicationIdentifierModel(kind: .microsoftTeamsUser, id: "some id", isAnonymous: true, cloud: CommunicationCloudEnvironmentModel.Public), // Missing Missing MicrosoftTeamsUserId
            CommunicationIdentifierModel(kind: .microsoftTeamsUser, microsoftTeamsUserId: "some id", isAnonymous: true, cloud: CommunicationCloudEnvironmentModel.Public), // Missing id
            CommunicationIdentifierModel(kind: .microsoftTeamsUser, id: "some id", microsoftTeamsUserId: "some id", isAnonymous: true), // Missing cloud
        ]

        var exceptionCount = 0
        
        for item in modelsWithMissingMandatoryProperty {
            do {
                try CommunicationIdentifierSerializer.deserialize(identifier: item)
            } catch {
                exceptionCount += 1
            }
        }
        XCTAssertEqual(exceptionCount, modelsWithMissingMandatoryProperty.count)
    }
}
