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
    let credentialCancelledError =
        "An instance of CommunicationTokenCredential cannot be reused once it has been canceled."
    let sampleToken =
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjMyNTAzNjgwMDAwfQ.9i7FNNHHJT8cOzo-yrAUJyBSfJ-tPPk2emcHavOEpWc"
    let sampleTokenExpiry: Double = 32_503_680_000

    let sampleExpiredToken =
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjEwMH0.1h_scYkNp-G98-O4cW6KvfJZwiz54uJMyeDACE4nypg"
    let sampleExpiredTokenExpiry: Double = 100

    var fetchTokenCallCount: Int = 0
    let timeout: TimeInterval = 10.0

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

    func generateTokenValidForSeconds(_ seconds: Int) -> String {
        let expiresOn = Date().addingTimeInterval(TimeInterval(seconds)).timeIntervalSince1970
        let tokenString = "{\"exp\": \(Int(expiresOn))}"

        let tokenStringData = tokenString.data(using: .ascii)!

        // swiftlint:disable line_length
        return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.\(tokenStringData.base64EncodedString()).adM-ddBZZlQ1WlN3pdPBOF5G4Wh9iZpxNP_fSvpF4cWs"
        // swiftlint:enable line_length
    }
}
