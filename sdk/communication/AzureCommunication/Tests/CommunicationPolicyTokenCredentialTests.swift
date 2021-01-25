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

class CommunicationPolicyTokenCredentialTests: XCTestCase {
    let sampleToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjMyNTAzNjgwMDAwfQ.9i7FNNHHJT8cOzo-yrAUJyBSfJ-tPPk2emcHavOEpWc"
    let aampleTokenExpiry = 32503680000
    let expiredToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjEwMH0.1h_scYkNp-G98-O4cW6KvfJZwiz54uJMyeDACE4nypg"
            
    func fetchTokenSync(completionHandler: TokenRefreshOnCompletion) {
        let newToken = sampleToken
        completionHandler(newToken, nil)
    }
    
    func testCreateStaticToken() throws {
        let expectation = self.expectation(description: "Create static token")
        
        let token = expiredToken
        let userCredential = try CommunicationTokenCredential(token: token)
        let communicationTokenPolicy = CommunicationPolicyTokenCredential(userCredential)
        communicationTokenPolicy.token(forScopes: [""]) { (accessToken, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(accessToken)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1000) { (error) in
            if let error = error {
                XCTFail("Create token timed out: \(error)")
            }
        }
    }
    
    func testCreateRefreshableWithoutInitialToken() throws {
        let expectation = self.expectation(description: "Create refreshable without initial token")
        let options = CommunicationTokenRefreshOptions(
            refreshProactively: true,
            tokenRefresher: fetchTokenSync
            )
        let userCredential = try CommunicationTokenCredential(with: options)
        let communicationTokenPolicy = CommunicationPolicyTokenCredential(userCredential)
        
        communicationTokenPolicy.token(forScopes: [""]) { (accessToken, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(accessToken)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1000) { (error) in
            if let error = error {
                XCTFail("Create token timed out: \(error)")
            }
        }
    }
    
    func testCreateRefreshableWithInitialToken() throws {
        let expectation = self.expectation(description: "Create refreshable with initial token")
        let token = expiredToken
        let options = CommunicationTokenRefreshOptions(
            initialToken: token,
            refreshProactively: true,
            tokenRefresher: fetchTokenSync
            )
        let userCredential = try CommunicationTokenCredential(with: options)
        let communicationTokenPolicy = CommunicationPolicyTokenCredential(userCredential)
        
        communicationTokenPolicy.token(forScopes: [""]) { (accessToken, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(accessToken)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1000) { (error) in
            if let error = error {
                XCTFail("Create token timed out: \(error)")
            }
        }
    }
    
    func testDecodesToken() throws {
        let expectation = self.expectation(description: "Decode access token")
        let initialToken = sampleToken
        let userCredential = try CommunicationTokenCredential(token: initialToken)
        let communicationTokenPolicy = CommunicationPolicyTokenCredential(userCredential)
        
        communicationTokenPolicy.token(forScopes: [""]) { (accessToken, error) in
            XCTAssertEqual(accessToken?.token, initialToken)
            XCTAssertEqual(accessToken?.expiresOn, accessToken?.expiresOn)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1000) { (error) in
            if let error = error {
                XCTFail("Create token timed out: \(error)")
            }
        }
    }
    
    func testStaticTokenReturnsExpiredToken() throws {
        let expectation = self.expectation(description: "Static token is expired")
        let initialToken = expiredToken
        let userCredential = try CommunicationTokenCredential(token: initialToken)
        let communicationTokenPolicy = CommunicationPolicyTokenCredential(userCredential)
        
        communicationTokenPolicy.token(forScopes: [""]) { [weak self] (accessToken, error) in
            guard let self = self else { return }
            XCTAssertEqual(self.expiredToken, accessToken?.token)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1000) { (error) in
            if let error = error {
                XCTFail("Create token timed out: \(error)")
            }
        }
    }
}
