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

class CommunicationIdentifierTest: XCTestCase {
    func test_IfIdIsOptional_EqualityOnlyTestIfPresentOnBothSide() throws {
        XCTAssertTrue(
            MicrosoftTeamsUserIdentifier(userId: "user id", isAnonymous: true, rawId: "some id") ==
                MicrosoftTeamsUserIdentifier(userId: "user id", isAnonymous: true)
        )
        XCTAssertTrue(
            MicrosoftTeamsUserIdentifier(userId: "user id", isAnonymous: true, rawId: "some id") ==
                MicrosoftTeamsUserIdentifier(userId: "user id", isAnonymous: true)
        )
        XCTAssertTrue(
            MicrosoftTeamsUserIdentifier(userId: "user id", isAnonymous: true) ==
                MicrosoftTeamsUserIdentifier(userId: "user id", isAnonymous: true)
        )
        XCTAssertTrue(
            MicrosoftTeamsUserIdentifier(userId: "user id", isAnonymous: true) ==
                MicrosoftTeamsUserIdentifier(
                    userId: "user id",
                    isAnonymous: true,
                    rawId: "some id"
                )
        )
        XCTAssertFalse(
            MicrosoftTeamsUserIdentifier(userId: "user id", isAnonymous: true, rawId: "some id") ==
                MicrosoftTeamsUserIdentifier(userId: "user id", isAnonymous: true, rawId: "another id")
        )

        XCTAssertTrue(
            PhoneNumberIdentifier(phoneNumber: "+12223334444", rawId: "some id") ==
                PhoneNumberIdentifier(phoneNumber: "+12223334444")
        )
        XCTAssertTrue(
            PhoneNumberIdentifier(phoneNumber: "+12223334444") ==
                PhoneNumberIdentifier(phoneNumber: "+12223334444")
        )
        XCTAssertTrue(
            PhoneNumberIdentifier(phoneNumber: "+12223334444") ==
                PhoneNumberIdentifier(phoneNumber: "+12223334444", rawId: "some id")
        )
        XCTAssertFalse(
            PhoneNumberIdentifier(phoneNumber: "+12223334444", rawId: "some id") ==
                PhoneNumberIdentifier(phoneNumber: "+12223334444", rawId: "another id")
        )
    }

    func test_MicrosoftTeamsUserIdentifier_DefaultCloudIsPublic() throws {
        XCTAssertEqual(
            CommunicationCloudEnvironment.Public,
            MicrosoftTeamsUserIdentifier(userId: "user id", isAnonymous: true, rawId: "some id").cloudEnviroment
        )
    }
}
