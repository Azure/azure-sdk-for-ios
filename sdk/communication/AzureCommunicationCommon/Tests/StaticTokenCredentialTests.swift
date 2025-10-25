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

class StaticTokenCredentialTests: CommunicationTokenCredentialTests {
    func test_StaticTokenCredential_ShouldStoreAnyToken() throws {
        let userCredential = try CommunicationTokenCredential(token: sampleExpiredToken)
        userCredential.token { (accessToken: CommunicationAccessToken?, error: Error?) in
            XCTAssertNil(error)
            XCTAssertEqual(accessToken?.token, self.sampleExpiredToken)
            XCTAssertEqual(accessToken?.expiresOn.timeIntervalSince1970, self.sampleExpiredTokenExpiry)
        }
    }

    func test_DecodesToken() throws {
        let userCredential = try CommunicationTokenCredential(token: sampleToken)
        userCredential.token { (accessToken: CommunicationAccessToken?, error: Error?) in
            XCTAssertNil(error)
            XCTAssertEqual(accessToken?.token, self.sampleToken)
            XCTAssertEqual(accessToken?.expiresOn.timeIntervalSince1970, self.sampleTokenExpiry)
        }
    }

    func test_ThrowsIfInvalidToken() throws {
        let invalidTokens = ["foo", "foo.bar", "foo.bar.foobar"]

        try invalidTokens.forEach { invalidToken in
            XCTAssertThrowsError(
                try CommunicationTokenCredential(token: invalidToken), ""
            ) { error in
                let error = error as NSError
                guard let message = error.userInfo["message"] as? String else {
                    XCTFail("Message is missing in user info")
                    return
                }

                XCTAssertTrue(
                    error.localizedDescription.contains("AzureCommunicationCommon.JwtTokenParser")
                )
                XCTAssertNotNil(message)
            }
        }
    }

    func test_ThrowIfTokenRequestedAfterCancelled() throws {
        let userCredential = try CommunicationTokenCredential(token: sampleToken)
        userCredential.cancel()
        userCredential.token { (accessToken: CommunicationAccessToken?, error: Error?) in
            XCTAssertNil(accessToken)
            XCTAssertNotNil(error)
            XCTAssertTrue(
                error.debugDescription
                    .contains(self.credentialCancelledError)
            )
        }
    }
}
