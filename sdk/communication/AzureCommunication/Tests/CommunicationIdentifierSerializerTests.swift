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

        XCTAssertEqual(model?.kind, .communicationUser)
        XCTAssertEqual(model?.id, "some id")
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

        XCTAssertEqual(model?.kind, .unknown)
        XCTAssertEqual(model?.id, "some id")
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

        XCTAssertEqual(model?.kind, .callingApplication)
        XCTAssertEqual(model?.id, "some id")
    }

    func test_DeserializePhoneNumber() throws {
        let identifier = try CommunicationIdentifierSerializer
            .deserialize(identifier: CommunicationIdentifierModel(kind: .phoneNumber, id: "+12223334444"))

        let expectedIdentifier = PhoneNumberIdentifier(phoneNumber: "+12223334444")

        XCTAssertTrue(identifier is PhoneNumberIdentifier)
        XCTAssertEqual(expectedIdentifier.phoneNumber, (identifier as? PhoneNumberIdentifier)?.phoneNumber)
    }

    func test_SerializePhoneNumber() throws {
        let model = try CommunicationIdentifierSerializer
            .serialize(identifier: PhoneNumberIdentifier(phoneNumber: "+12223334444"))

        XCTAssertEqual(model?.kind, .phoneNumber)
        XCTAssertEqual(model?.phoneNumber, "+12223334444")
    }

    func test_DeserializeMicrosoftTeamsUser() throws {
        let identifier = try CommunicationIdentifierSerializer
            .deserialize(identifier: CommunicationIdentifierModel(kind: .microsoftTeamsUser, id: "some id"))

        let expectedIdentifier = MicrosoftTeamsUserIdentifier(userId: "some id")

        XCTAssertTrue(identifier is MicrosoftTeamsUserIdentifier)
        XCTAssertEqual(expectedIdentifier.userId, (identifier as? MicrosoftTeamsUserIdentifier)?.userId)
    }

    func test_SerializeMicrosoftTeamsUser() throws {
        let model = try CommunicationIdentifierSerializer
            .serialize(identifier: MicrosoftTeamsUserIdentifier(userId: "some id"))

        XCTAssertEqual(model?.kind, .microsoftTeamsUser)
        XCTAssertEqual(model?.id, "some id")
    }

    func test_DeserializeMissingProperty() throws {
        let expectation =
            XCTestExpectation(description: "Exception is throw due to missing id")

        let modelsWithMissingMandatoryProperty: [CommunicationIdentifierModel] = [
            CommunicationIdentifierModel(kind: .unknown),
            CommunicationIdentifierModel(kind: .communicationUser),
            CommunicationIdentifierModel(kind: .callingApplication),
            CommunicationIdentifierModel(kind: .phoneNumber),
            CommunicationIdentifierModel(kind: .microsoftTeamsUser)
        ]

        expectation.expectedFulfillmentCount = modelsWithMissingMandatoryProperty.count
        expectation.assertForOverFulfill = true

        for item in modelsWithMissingMandatoryProperty {
            do {
                try CommunicationIdentifierSerializer.deserialize(identifier: item)
            } catch {
                expectation.fulfill()
            }
        }
    }
}
