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

class AutoRefreshOnDemandTokenCredentialTests: CommunicationTokenCredentialTests {
    func test_SyncRefresh_ShouldBeCalledImmediatelyWithExpiredToken() throws {
        let expectation = XCTestExpectation()

        let tokenRefreshOptions = creatTokenRefreshOptions(initialToken: sampleExpiredToken)
        let userCredential = try CommunicationTokenCredential(withOptions: tokenRefreshOptions)
        DispatchQueue.global(qos: .utility).async {
            userCredential.token { (accessToken: CommunicationAccessToken?, error: Error?) in
                XCTAssertNotNil(accessToken)
                XCTAssertNil(error)
                XCTAssertEqual(accessToken?.token, self.sampleToken)
                XCTAssertEqual(accessToken?.expiresOn.timeIntervalSince1970, self.sampleTokenExpiry)

                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)
    }

    private func creatTokenRefreshOptions(
        initialToken: String? = nil,
        refreshedToken: String? = nil
    ) -> CommunicationTokenRefreshOptions {
        return CommunicationTokenRefreshOptions(
            initialToken: initialToken,
            refreshProactively: false,
            tokenRefresher: creatTokenRefresher(refreshedToken: refreshedToken)
        )
    }

    func test_ShouldNotBeCalledBeforeExpiringTime() throws {
        let expectation = XCTestExpectation()
        let tokenValidFor15Mins = generateTokenValidForSeconds(15 * 60)

        let tokenRefreshOptions = creatTokenRefreshOptions(initialToken: tokenValidFor15Mins)
        let userCredential = try CommunicationTokenCredential(withOptions: tokenRefreshOptions)

        DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 1) {
            userCredential.token { (accessToken: CommunicationAccessToken?, error: Error?) in
                XCTAssertNotNil(accessToken)
                XCTAssertNil(error)
                XCTAssertEqual(accessToken?.token, tokenValidFor15Mins)
                XCTAssertEqual(self.fetchTokenCallCount, 0)

                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)
    }

    func test_ShouldGetCalledImmediatelyWithoutInitialToken() throws {
        let expectation = XCTestExpectation()

        let tokenRefreshOptions = creatTokenRefreshOptions()
        let userCredential = try CommunicationTokenCredential(withOptions: tokenRefreshOptions)

        DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 1) {
            userCredential.token { (accessToken: CommunicationAccessToken?, error: Error?) in
                XCTAssertNotNil(accessToken)
                XCTAssertNil(error)
                XCTAssertEqual(accessToken?.token, self.sampleToken)
                XCTAssertEqual(self.fetchTokenCallCount, 1)

                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)
    }

    func test_ShouldThrowWhenTokenRefresherThrows() throws {
        let expectation = XCTestExpectation()

        let tokenRefreshOptions = CommunicationTokenRefreshOptions(
            initialToken: sampleExpiredToken,
            refreshProactively: false,
            tokenRefresher: fetchTokenSyncWithError
        )
        let userCredential = try CommunicationTokenCredential(withOptions: tokenRefreshOptions)

        DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 1) {
            userCredential.token { (accessToken: CommunicationAccessToken?, error: Error?) in
                XCTAssertNotNil(error)
                XCTAssertEqual(error.debugDescription.contains("Error while fetching token"), true)
                XCTAssertNil(accessToken)
                XCTAssertEqual(self.fetchTokenCallCount, 1)

                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)
    }

    func test_ShouldThrowExceptionOnExpiredTokenReturn() throws {
        let expectation = XCTestExpectation()

        let tokenRefreshOptions = creatTokenRefreshOptions(
            initialToken: sampleExpiredToken,
            refreshedToken: sampleExpiredToken
        )
        let userCredential = try CommunicationTokenCredential(withOptions: tokenRefreshOptions)

        DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 1) {
            userCredential.token { (accessToken: CommunicationAccessToken?, error: Error?) in
                XCTAssertNotNil(error)
                XCTAssertEqual(
                    error.debugDescription.contains("The token returned from the tokenRefresher is expired."),
                    true
                )
                XCTAssertNil(accessToken)
                XCTAssertEqual(self.fetchTokenCallCount, 1)

                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)
    }

    func test_AsyncRefresh() throws {
        let expectation = XCTestExpectation()

        let tokenRefreshOptions = CommunicationTokenRefreshOptions(
            initialToken: sampleExpiredToken,
            refreshProactively: false,
            tokenRefresher: fetchTokenAsync
        )
        let userCredential = try CommunicationTokenCredential(withOptions: tokenRefreshOptions)

        DispatchQueue.global(qos: .utility).async {
            userCredential.token { (accessToken: CommunicationAccessToken?, error: Error?) in
                XCTAssertNotNil(accessToken)
                XCTAssertNil(error)
                XCTAssertEqual(accessToken?.token, self.sampleToken)
                XCTAssertEqual(accessToken?.expiresOn.timeIntervalSince1970, self.sampleTokenExpiry)

                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)
    }

    func test_ThrowIfTokenRequestedAfterCancelled() throws {
        let expectation = XCTestExpectation()

        let tokenRefreshOptions = CommunicationTokenRefreshOptions(
            initialToken: sampleExpiredToken,
            refreshProactively: false,
            tokenRefresher: fetchTokenAsync
        )
        let userCredential = try CommunicationTokenCredential(withOptions: tokenRefreshOptions)
        userCredential.cancel()
        DispatchQueue.global(qos: .utility).async {
            userCredential.token { (accessToken: CommunicationAccessToken?, error: Error?) in
                XCTAssertNil(accessToken)
                XCTAssertNotNil(error)
                XCTAssertTrue(
                    error.debugDescription
                        .contains(self.credentialCancelledError)
                )
                XCTAssertEqual(self.fetchTokenCallCount, 0)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)
    }
}
