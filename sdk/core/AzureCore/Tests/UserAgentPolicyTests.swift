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
@testable import AzureCore

class UserAgentPolicyTests: XCTestCase {

    /// Test that the default user agent policy is properly applied.
    func testDefaultUserAgentPolicy() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let policy = UserAgentPolicy()
        let userAgent = policy.userAgent
        XCTAssertEqual(userAgent, "ios/5.0 (iPhone) AzureCore/0.1.0")
    }

    /// Test that supplying a baseUserAgent without overwrite still captures much of the standard data.
    func testCustomUserAgentPolicyNoOverwrite() {
        let policy = UserAgentPolicy(baseUserAgent: "MyAgent")
        let userAgent = policy.userAgent
        XCTAssertEqual(userAgent, "MyAgent ios/5.0 (iPhone) AzureCore/0.1.0")
    }

    /// Test that supplying baseUserAgent with overwrite completely overwrites the user agent string.
    func testCustomUserAgentPolicy() {
        let policy = UserAgentPolicy(baseUserAgent: "MyAgent", userAgentOverwrite: true)
        let userAgent = policy.userAgent
        XCTAssertEqual(userAgent, "MyAgent")

        policy.appendUserAgent(value: "test")
        XCTAssertEqual(policy.userAgent, "MyAgent test")
    }
}
