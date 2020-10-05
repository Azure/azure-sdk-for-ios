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

class HMACAuthenticationPolicyTests: XCTestCase {
    let secret_key = "68810419818922fb0263dd6ee4b9c56537dbad914aa7324a119fce26778a286e"
    
    
    func testHashingWithSecret() throws {
        let message = "TestMessage"
        let expectedHash = "567604ea3ac4de6ce263fffc795ede7724e045f28c888d075e8327b7219b44aa"
        
        let hashed = message.generateSHA256(using: secret_key)
        XCTAssertEqual(hashed, expectedHash)
    }
    
    func testhashingWithSecretUsingSha() {
        let message = "TestMessage"
        let expectedHash = "567604ea3ac4de6ce263fffc795ede7724e045f28c888d075e8327b7219b44aa"
        
        let sha = HMACAuthenticationPolicy(accessKey: secret_key).sha256(using: message)
        XCTAssertEqual(sha, expectedHash)
    }
}
