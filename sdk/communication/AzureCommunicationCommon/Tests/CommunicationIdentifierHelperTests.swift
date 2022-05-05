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
        var unknownIdentifier = CommunicationIdentifierHelper.createCommunicationIdentifier(from: "some id")
        XCTAssertTrue(unknownIdentifier.isKind(of: UnknownIdentifier.self))

        unknownIdentifier = CommunicationIdentifierHelper.createCommunicationIdentifier(from: "8:not_real_scope")
        XCTAssertTrue(unknownIdentifier.isKind(of: UnknownIdentifier.self))

        unknownIdentifier = CommunicationIdentifierHelper
            .createCommunicationIdentifier(from: "8:not_real_scope:not_real_raw_id")
        XCTAssertTrue(unknownIdentifier.isKind(of: UnknownIdentifier.self))
    }

    func test_createPhoneNumberIdentifier() {
        var phoneNumberIdentifier = CommunicationIdentifierHelper.createCommunicationIdentifier(from: "4:11231234")
        XCTAssertTrue(phoneNumberIdentifier.isKind(of: PhoneNumberIdentifier.self))
        phoneNumberIdentifier = CommunicationIdentifierHelper.createCommunicationIdentifier(from: "4:11231234:asdf")

        XCTAssertTrue(phoneNumberIdentifier.isKind(of: PhoneNumberIdentifier.self))
    }

    func test_createCommunicationUserIdentifier() {
        let acsScope = "8:acs:some_raw_id"
        var communciationUserIdentifier = CommunicationIdentifierHelper.createCommunicationIdentifier(from: acsScope)
        XCTAssertTrue(communciationUserIdentifier.isKind(of: CommunicationUserIdentifier.self))

        let spoolScope = "8:spool:some_raw_id"
        communciationUserIdentifier = CommunicationIdentifierHelper.createCommunicationIdentifier(from: spoolScope)
        XCTAssertTrue(communciationUserIdentifier.isKind(of: CommunicationUserIdentifier.self))

        let dodAcsScope = "8:dod-acs:some_raw_id"
        communciationUserIdentifier = CommunicationIdentifierHelper.createCommunicationIdentifier(from: dodAcsScope)
        XCTAssertTrue(communciationUserIdentifier.isKind(of: CommunicationUserIdentifier.self))

        let gcchAcsScope = "8:gcch-acs:some_raw_id"
        communciationUserIdentifier = CommunicationIdentifierHelper.createCommunicationIdentifier(from: gcchAcsScope)
        XCTAssertTrue(communciationUserIdentifier.isKind(of: CommunicationUserIdentifier.self))
    }

    func test_createMicrosoftTeamsUserIdentifier() {
        let teamUserAnonymousScope = "8:teamsvisitor:some_raw_id"
        var teamUserIdentifier = CommunicationIdentifierHelper
            .createCommunicationIdentifier(from: teamUserAnonymousScope)
        XCTAssertTrue(teamUserIdentifier.isKind(of: MicrosoftTeamsUserIdentifier.self))

        let teamUserPublicCloudScope = "8:orgid:some_raw_id"
        teamUserIdentifier = CommunicationIdentifierHelper.createCommunicationIdentifier(from: teamUserPublicCloudScope)
        XCTAssertTrue(teamUserIdentifier.isKind(of: MicrosoftTeamsUserIdentifier.self))

        let teamUserDODCloudScope = "8:dod:some_raw_id"
        teamUserIdentifier = CommunicationIdentifierHelper.createCommunicationIdentifier(from: teamUserDODCloudScope)
        XCTAssertTrue(teamUserIdentifier.isKind(of: MicrosoftTeamsUserIdentifier.self))

        let teamUserGCCHCloudScope = "8:gcch:some_raw_id"
        teamUserIdentifier = CommunicationIdentifierHelper.createCommunicationIdentifier(from: teamUserGCCHCloudScope)
        XCTAssertTrue(teamUserIdentifier.isKind(of: MicrosoftTeamsUserIdentifier.self))
    }
}
