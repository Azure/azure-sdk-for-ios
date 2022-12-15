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

enum FetchTokenError: Error {
    case badRequest(String)
}

class CommunicationTokenCredentialTests: XCTestCase {
    private let sampleToken =
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjMyNTAzNjgwMDAwfQ.9i7FNNHHJT8cOzo-yrAUJyBSfJ-tPPk2emcHavOEpWc"
    private let sampleTokenExpiry: Double = 32_503_680_000

    private let sampleExpiredToken =
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjEwMH0.1h_scYkNp-G98-O4cW6KvfJZwiz54uJMyeDACE4nypg"
    private let sampleExpiredTokenExpiry: Double = 100

    private var fetchTokenCallCount: Int = 0
    private let timeout: TimeInterval = 10.0

    override func setUp() {
        super.setUp()
        fetchTokenCallCount = 0
    }

    func creatTokenRefresher(refreshedToken: String? = nil) -> (TokenRefreshHandler) -> Void {
        func fetchTokenSync(completionHandler: TokenRefreshHandler) {
            fetchTokenCallCount += 1
            completionHandler(refreshedToken ?? sampleToken, nil)
        }
        return fetchTokenSync
    }

    func fetchTokenSyncWithError(completionHandler: TokenRefreshHandler) {
        fetchTokenCallCount += 1
        completionHandler(nil, FetchTokenError.badRequest("Error while fetching token"))
    }

    func fetchTokenAsync(completionHandler: @escaping TokenRefreshHandler) {
        fetchTokenCallCount += 1

        func getTokenFromServer(completionHandler: @escaping (String) -> Void) {
            // Delay to simulate getting token from server async
            DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 3) {
                completionHandler(self.sampleToken)
            }
        }

        getTokenFromServer { newToken in
            completionHandler(newToken, nil)
        }
    }

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

    func test_RefreshTokenProactively_ShouldNotBeCalledBeforeExpiringTime() throws {
        let expectation = XCTestExpectation()
        let tokenValidFor15Mins = generateTokenValidForSeconds(15 * 60)

        let tokenRefreshOptions = CommunicationTokenRefreshOptions(
            initialToken: tokenValidFor15Mins,
            refreshProactively: true,
            tokenRefresher: creatTokenRefresher()
        )

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

    func test_RefreshTokenProactively_ShouldBeCalledImmediatelyWithExpiredToken() throws {
        let expectation = XCTestExpectation()

        let tokenRefreshOptions = CommunicationTokenRefreshOptions(
            initialToken: sampleExpiredToken,
            refreshProactively: true,
            tokenRefresher: creatTokenRefresher()
        )

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

    func test_RefreshTokenProactively_ShouldBeCalledIfTokenExpiringSoon() throws {
        let testCases = [1, 9]

        let expectation = XCTestExpectation()
        let semaphore = DispatchSemaphore(value: 1)

        try testCases.forEach { minutes in
            semaphore.wait()
            setUp()

            let expiringToken = generateTokenValidForSeconds(minutes * 60)

            let tokenRefreshOptions = CommunicationTokenRefreshOptions(
                initialToken: expiringToken,
                refreshProactively: true,
                tokenRefresher: creatTokenRefresher()
            )

            let userCredential = try CommunicationTokenCredential(withOptions: tokenRefreshOptions)

            DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 1) {
                userCredential.token { (accessToken: CommunicationAccessToken?, _: Error?) in
                    XCTAssertNotNil(accessToken)
                    XCTAssertEqual(accessToken?.token, self.sampleToken)

                    userCredential.token { (accessToken: CommunicationAccessToken?, _: Error?) in
                        XCTAssertNotNil(accessToken)
                        XCTAssertEqual(accessToken?.token, self.sampleToken)
                        XCTAssertEqual(self.fetchTokenCallCount, 1)

                        if minutes == testCases.last {
                            expectation.fulfill()
                        }

                        semaphore.signal()
                    }
                }
            }
        }

        wait(for: [expectation], timeout: timeout)
    }

    func test_RefreshTokenProactively_FetchTokenReturnsError() throws {
        let expectation = XCTestExpectation()

        let tokenRefreshOptions = CommunicationTokenRefreshOptions(
            initialToken: sampleExpiredToken,
            refreshProactively: true,
            tokenRefresher: fetchTokenSyncWithError
        )

        let userCredential = try CommunicationTokenCredential(withOptions: tokenRefreshOptions)

        DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 1) {
            userCredential.token { (accessToken: CommunicationAccessToken?, error: Error?) in
                XCTAssertNotNil(error)
                XCTAssertEqual(error.debugDescription.contains("Error while fetching token"), true)
                XCTAssertNil(accessToken)
                XCTAssertEqual(self.fetchTokenCallCount, 2)

                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)
    }

    func test_RefreshTokenProactively_ShouldThrowExceptionOnExpiredTokenReturn() throws {
        let expectation = XCTestExpectation()

        let tokenRefreshOptions = CommunicationTokenRefreshOptions(
            initialToken: sampleExpiredToken,
            refreshProactively: true,
            tokenRefresher: creatTokenRefresher(refreshedToken: sampleExpiredToken)
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
                XCTAssertEqual(self.fetchTokenCallCount, 2)

                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)
    }

    func test_RefreshTokenProactively_fractionalBackoffAppliedWhenTokenExpiring() throws {
        let expectation = XCTestExpectation()
        let validForSeconds = 7
        let expectedTotalCallsTillLastSecond = floor(log2(Double(validForSeconds)))
        let dispatchAfter = DispatchTimeInterval.seconds(validForSeconds)
        let refreshedToken = generateTokenValidForSeconds(validForSeconds)
        let tokenRefreshOptions = CommunicationTokenRefreshOptions(
            initialToken: refreshedToken,
            refreshProactively: true,
            tokenRefresher: creatTokenRefresher(refreshedToken: refreshedToken)
        )
        let userCredential = try CommunicationTokenCredential(withOptions: tokenRefreshOptions)
        DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + dispatchAfter) {
            userCredential.token { (_: CommunicationAccessToken?, _: Error?) in
                XCTAssertEqual(self.fetchTokenCallCount, Int(expectedTotalCallsTillLastSecond))
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: timeout)
    }

    func test_RefreshTokenProactively_ShouldNotCallWhenTokenStillValid() throws {
        let expectation = XCTestExpectation()
        let refreshedToken = generateTokenValidForSeconds(15 * 60)
        let tokenRefreshOptions = CommunicationTokenRefreshOptions(
            initialToken: sampleToken,
            refreshProactively: true,
            tokenRefresher: creatTokenRefresher(refreshedToken: refreshedToken)
        )

        let userCredential = try CommunicationTokenCredential(withOptions: tokenRefreshOptions)
        let checkCount = 10
        for index in 0 ... checkCount {
            DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 1) {
                userCredential.token { (accessToken: CommunicationAccessToken?, _: Error?) in
                    XCTAssertNotNil(accessToken)
                    XCTAssertEqual(accessToken?.token, self.sampleToken)
                    XCTAssertEqual(self.fetchTokenCallCount, 0)
                    if index == checkCount {
                        expectation.fulfill()
                    }
                }
            }
        }
        wait(for: [expectation], timeout: timeout)
    }

    func test_RefreshTokenProactively_ShouldBeCalledAgainAfterFirstRefreshCall() throws {
        let expectation = XCTestExpectation()
        let expirySeconds = 10 * 60 + 1
        let initialToken = generateTokenValidForSeconds(expirySeconds)
        let refreshedToken = generateTokenValidForSeconds(expirySeconds + 1)
        let tokenRefreshOptions = CommunicationTokenRefreshOptions(
            initialToken: initialToken,
            refreshProactively: true,
            tokenRefresher: creatTokenRefresher(refreshedToken: refreshedToken)
        )
        let userCredential = try CommunicationTokenCredential(withOptions: tokenRefreshOptions)
        DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(self.fetchTokenCallCount, 1)
            userCredential.token { (accessToken: CommunicationAccessToken?, _: Error?) in
                XCTAssertNotNil(accessToken)
                XCTAssertEqual(accessToken?.token, refreshedToken)
            }
        }

        DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 2) {
            XCTAssertEqual(self.fetchTokenCallCount, 1)
            userCredential.token { (accessToken: CommunicationAccessToken?, _: Error?) in
                XCTAssertNotNil(accessToken)
                XCTAssertEqual(accessToken?.token, refreshedToken)
                XCTAssertEqual(self.fetchTokenCallCount, 2)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: timeout)
    }

    func test_RefreshToken_ShouldGetCalledImmediatelyWithoutInitialToken() throws {
        let expectation = XCTestExpectation()

        let expectedToken = sampleToken
        let expectedTokenExpiry = sampleTokenExpiry

        let tokenRefreshOptions = CommunicationTokenRefreshOptions(
            refreshProactively: true,
            tokenRefresher: creatTokenRefresher()
        )

        let userCredential = try CommunicationTokenCredential(withOptions: tokenRefreshOptions)
        DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(self.fetchTokenCallCount, 1)
            userCredential.token { (accessToken: CommunicationAccessToken?, error: Error?) in
                XCTAssertNotNil(accessToken)
                XCTAssertNil(error)
                XCTAssertEqual(accessToken?.token, expectedToken)
                XCTAssertEqual(accessToken?.expiresOn.timeIntervalSince1970, expectedTokenExpiry)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)
    }

    func test_RefreshTokenOnDemand_SyncRefresh() throws {
        let expectation = XCTestExpectation()

        let expectedToken = sampleToken
        let expectedTokenExpiry = sampleTokenExpiry

        let tokenRefreshOptions = CommunicationTokenRefreshOptions(
            initialToken: sampleExpiredToken,
            refreshProactively: false,
            tokenRefresher: creatTokenRefresher()
        )

        let userCredential = try CommunicationTokenCredential(withOptions: tokenRefreshOptions)
        DispatchQueue.global(qos: .utility).async {
            userCredential.token { (accessToken: CommunicationAccessToken?, error: Error?) in
                XCTAssertNotNil(accessToken)
                XCTAssertNil(error)
                XCTAssertEqual(accessToken?.token, expectedToken)
                XCTAssertEqual(accessToken?.expiresOn.timeIntervalSince1970, expectedTokenExpiry)

                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)
    }

    func test_RefreshTokenOnDemand_AsyncRefresh() throws {
        let expectation = XCTestExpectation()

        let expectedToken = sampleToken
        let expectedTokenExpiry = sampleTokenExpiry

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
                XCTAssertEqual(accessToken?.token, expectedToken)
                XCTAssertEqual(accessToken?.expiresOn.timeIntervalSince1970, expectedTokenExpiry)

                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)
    }

    private func generateTokenValidForSeconds(_ seconds: Int) -> String {
        let expiresOn = Date().addingTimeInterval(TimeInterval(seconds)).timeIntervalSince1970
        let tokenString = "{\"exp\": \(Int(expiresOn))}"

        let tokenStringData = tokenString.data(using: .ascii)!

        // swiftlint:disable line_length
        return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.\(tokenStringData.base64EncodedString()).adM-ddBZZlQ1WlN3pdPBOF5G4Wh9iZpxNP_fSvpF4cWs"
        // swiftlint:enable line_length
    }
}
