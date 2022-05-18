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
import XCTest

class CommunicationIdentifierHelperTests: XCTestCase {
    func test_createUnknownIdentifier() {
        var unknownIdentifier = CommunicationIdentifierHelper
            .createCommunicationIdentifier(from: "37691ec4-57fb-4c0f-ae31-32791610cb14")
        XCTAssertTrue(unknownIdentifier.isKind(of: UnknownIdentifier.self))
        XCTAssertEqual(unknownIdentifier.rawId, "37691ec4-57fb-4c0f-ae31-32791610cb14")

        unknownIdentifier = CommunicationIdentifierHelper
            .createCommunicationIdentifier(from: "48:37691ec4-57fb-4c0f-ae31-32791610cb14")
        XCTAssertTrue(unknownIdentifier.isKind(of: UnknownIdentifier.self))
        XCTAssertEqual(unknownIdentifier.rawId, "48:37691ec4-57fb-4c0f-ae31-32791610cb14")
    }

    func test_createPhoneNumberIdentifier() {
        let phoneNumberRawId = "4:12345556789"
        let phoneNumberIdentifier = CommunicationIdentifierHelper.createCommunicationIdentifier(from: phoneNumberRawId)
        XCTAssertTrue(phoneNumberIdentifier.isKind(of: PhoneNumberIdentifier.self))
        XCTAssertEqual((phoneNumberIdentifier as? PhoneNumberIdentifier)?.rawId, phoneNumberRawId)
        XCTAssertEqual((phoneNumberIdentifier as? PhoneNumberIdentifier)?.phoneNumber, "+12345556789")
    }

    func test_createCommunicationUserIdentifier() {
        let acsRawId = "8:acs:37691ec4-57fb-4c0f-ae31-32791610cb14_37691ec4-57fb-4c0f-ae31-32791610cb14"
        var communicationUserIdentifier = CommunicationIdentifierHelper.createCommunicationIdentifier(from: acsRawId)
        XCTAssertTrue(communicationUserIdentifier.isKind(of: CommunicationUserIdentifier.self))
        XCTAssertEqual(communicationUserIdentifier.rawId, acsRawId)
        XCTAssertEqual(
            (communicationUserIdentifier as? CommunicationUserIdentifier)?.identifier, acsRawId
        )

        let spoolRawId = "8:spool:37691ec4-57fb-4c0f-ae31-32791610cb14_37691ec4-57fb-4c0f-ae31-32791610cb14"
        communicationUserIdentifier = CommunicationIdentifierHelper.createCommunicationIdentifier(from: spoolRawId)
        XCTAssertTrue(communicationUserIdentifier.isKind(of: CommunicationUserIdentifier.self))
        XCTAssertEqual(communicationUserIdentifier.rawId, spoolRawId)
        XCTAssertEqual(
            (communicationUserIdentifier as? CommunicationUserIdentifier)?.identifier, spoolRawId
        )

        let dodAcsRawId = "8:dod-acs:37691ec4-57fb-4c0f-ae31-32791610cb14_37691ec4-57fb-4c0f-ae31-32791610cb14"
        communicationUserIdentifier = CommunicationIdentifierHelper.createCommunicationIdentifier(from: dodAcsRawId)
        XCTAssertTrue(communicationUserIdentifier.isKind(of: CommunicationUserIdentifier.self))
        XCTAssertEqual(communicationUserIdentifier.rawId, dodAcsRawId)
        XCTAssertEqual(
            (communicationUserIdentifier as? CommunicationUserIdentifier)?.identifier, dodAcsRawId
        )

        let gcchAcsRawId = "8:gcch-acs:37691ec4-57fb-4c0f-ae31-32791610cb14_37691ec4-57fb-4c0f-ae31-32791610cb14"
        communicationUserIdentifier = CommunicationIdentifierHelper.createCommunicationIdentifier(from: gcchAcsRawId)
        XCTAssertTrue(communicationUserIdentifier.isKind(of: CommunicationUserIdentifier.self))
        XCTAssertEqual(communicationUserIdentifier.rawId, gcchAcsRawId)
        XCTAssertEqual(
            (communicationUserIdentifier as? CommunicationUserIdentifier)?.identifier, gcchAcsRawId
        )
    }

    func test_createMicrosoftTeamsUserIdentifierAnonymousScope() {
        let teamUserAnonymousScope =
            "8:teamsvisitor:37691ec4-57fb-4c0f-ae31-32791610cb14_37691ec4-57fb-4c0f-ae31-32791610cb14"
        let teamUserIdentifier = CommunicationIdentifierHelper
            .createCommunicationIdentifier(from: teamUserAnonymousScope)
        XCTAssertTrue(teamUserIdentifier.isKind(of: MicrosoftTeamsUserIdentifier.self))
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
        let teamUserIdentifier = CommunicationIdentifierHelper
            .createCommunicationIdentifier(from: teamUserPublicCloudScope)
        XCTAssertTrue(teamUserIdentifier.isKind(of: MicrosoftTeamsUserIdentifier.self))
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
        let teamUserIdentifier = CommunicationIdentifierHelper
            .createCommunicationIdentifier(from: teamUserDODCloudScope)
        XCTAssertTrue(teamUserIdentifier.isKind(of: MicrosoftTeamsUserIdentifier.self))
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
        let teamUserIdentifier = CommunicationIdentifierHelper
            .createCommunicationIdentifier(from: teamUserGCCHCloudScope)
        XCTAssertTrue(teamUserIdentifier.isKind(of: MicrosoftTeamsUserIdentifier.self))
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
}
