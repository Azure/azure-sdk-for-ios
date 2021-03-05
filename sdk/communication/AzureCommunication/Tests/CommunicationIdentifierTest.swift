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
    let testUserId = "User Id"
    let testRawId = "Raw Id"
    let testPhoneNumber = "+12223334444"
    let testTeamsUserId = "Microsoft Teams User Id"

    func test_IfIdIsOptional_EqualityOnlyTestIfPresentOnBothSide() throws {
        XCTAssertTrue(
            MicrosoftTeamsUserIdentifier(
                userId: "user id",
                isAnonymous: true,
                rawId: testRawId
            ) ==
                MicrosoftTeamsUserIdentifier(
                    userId: "user id",
                    isAnonymous: true
                )
        )
        XCTAssertTrue(
            MicrosoftTeamsUserIdentifier(
                userId: "user id",
                isAnonymous: true
            ) ==
                MicrosoftTeamsUserIdentifier(
                    userId: "user id",
                    isAnonymous: true
                )
        )
        XCTAssertTrue(
            MicrosoftTeamsUserIdentifier(
                userId: "user id",
                isAnonymous: true
            ) ==
                MicrosoftTeamsUserIdentifier(
                    userId: "user id",
                    isAnonymous: true,
                    rawId: testRawId
                )
        )
        XCTAssertFalse(
            MicrosoftTeamsUserIdentifier(
                userId: "user id",
                isAnonymous: true,
                rawId: "some id"
            ) ==
                MicrosoftTeamsUserIdentifier(
                    userId: "user id",
                    isAnonymous: true,
                    rawId: testRawId
                )
        )

        XCTAssertTrue(
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
        XCTAssertTrue(
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

    func test_MicrosoftTeamsUserIdentifier_DefaultCloudIsPublic() throws {
        XCTAssertEqual(
            CommunicationCloudEnvironment.Public,
            MicrosoftTeamsUserIdentifier(
                userId: "user id",
                isAnonymous: true,
                rawId: testRawId
            ).cloudEnviroment
        )
    }
}
