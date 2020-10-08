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
    var policy: HMACAuthenticationPolicy?
    
    override func setUp() {
        policy = HMACAuthenticationPolicy(accessKey: secret_key)
    }
        
    func testShaEncyptionOnString() {
        let string = "banana"
        let result = "tJPUg2Sv5E0RwBZc9HCkFk0eJgmRHvmYvoaNRq3j3k4="
        XCTAssertEqual(string.data(using: .utf8)?.sha256, result)
    }
    
    func testShaEncyptionOnEmoji() {
        let emoji = "😀"
        let result = "8EQ6NCxe9UeDoRG1G6Vsk45HTDIyTZDDpgycjjo34tk="
        XCTAssertEqual(emoji.data(using: .utf8)?.sha256, result)
    }
    
    func testHMACEncyptionOnString() {
        let string = "banana".generateHmac(using: "pw==")
        let result = "88EC05aAS9iXnaimtNO78JLjiPtfWryQB/5QYEzEsu8="
        XCTAssertEqual(string, result)
    }

    func testHMACEncyptionOnEmoji() {
        let string = "😀".generateHmac(using: "pw==")
        let result = "1rudJKjn2Zi+3hRrBG29wIF6pD6YyAeQR1ZcFtXoKAU="
        XCTAssertEqual(string, result)
    }
    
    func testAddAuthenticationHeaderForGet() {
        let mockUrl = URL(string: "https://localhost?id=b93a5ef4-f622-44d8-a80b-ff983122554e")
        let mockHttpMethod: HTTPMethod = .get
        
        guard let policy = policy else {
            XCTFail("HMACAuthenticationPolicy was not init properly")
            return
        }
        
        let contents = Data()
        let url = mockUrl
        let httpMethod = mockHttpMethod
        let date = Date()
        
        let properties = HMACAuthenticationPolicy.HMACAuthenticationProperties(
            url: url!,
            httpMethod: httpMethod,
            contents: contents,
            date: date)
        
        let headers = policy.addAuthenticationHeaders(with: properties)

        let hashedContent = headers[HMACAuthenticationPolicy.contentHashHeader]
        let expectedHash = "47DEQpj8HBSa+/TImW+5JCeuQeRkm5NMpJWZG3hSuFU="
        XCTAssertEqual(hashedContent, expectedHash)
    }
    
    func testAddAuthenticationHeadersForPostWithBody() {
        guard let policy = policy else {
            XCTFail("HMACAuthenticationPolicy was not init properly")
            return
        }
        let mockUrl = URL(string: "https://localhost?id=b93a5ef4-f622-44d8-a80b-ff983122554e")
        let mockHttpMethod: HTTPMethod = .post
        let mockBody = "{\"propName\":\"name\", \"propValue\": \"value\"}"

        let contents = mockBody.data(using: .utf8) ?? Data()
        let url = mockUrl
        let httpMethod = mockHttpMethod
        let date = Date()
        
        let properties = HMACAuthenticationPolicy.HMACAuthenticationProperties(
            url: url!,
            httpMethod: httpMethod,
            contents: contents,
            date: date)
        
        let headers = policy.addAuthenticationHeaders(with: properties)
        
        let hashedContent = headers[HMACAuthenticationPolicy.contentHashHeader]
        let expectedHashContent = "YjVxGFu++f6tLM9YEVQVRmchZiYyxQ+8Bi3PXTJz2C4="
        XCTAssertEqual(hashedContent, expectedHashContent)
    }
    
    func testAddAuthenticationHeadersForPostUsingStaticDate() {
        guard let policy = policy else {
            XCTFail("HMACAuthenticationPolicy was not init properly")
            return
        }
        let mockUrl = URL(string: "https://localhost?id=b93a5ef4-f622-44d8-a80b-ff983122554e")
        let mockHttpMethod: HTTPMethod = .post
        let mockBody = "{\"propName\":\"name\", \"propValue\": \"value\"}"

        let contents = mockBody.data(using: .utf8) ?? Data()
        let url = mockUrl
        let httpMethod = mockHttpMethod
        let dateString = "Wed, 07 Oct 2020 18:16:02 GMT"
        let date = Date(dateString, format: .rfc1123)
        
        let properties = HMACAuthenticationPolicy.HMACAuthenticationProperties(
            url: url!,
            httpMethod: httpMethod,
            contents: contents,
            date: date!)
        
        let headers = policy.addAuthenticationHeaders(with: properties)
        
        let authHeader = headers["Authorization"]
        let expectedSignature = "Signature=KZD9UN4LsktsEX2e9cRp+LS2opjAtEVKqt+OzFCHh9o="
        XCTAssertTrue(authHeader?.contains(expectedSignature) ?? false)
        
        /**
         After signature
         HashMap@56 size=4
         0:HashMap$Node@113 "date":"Wed, 07 Oct 2020 18:16:02 GMT"
         1:HashMap$Node@114 "Authorization":"HMAC-SHA256 SignedHeaders=date;host;x-ms-content-sha256&Signature=KZD9UN4LsktsEX2e9cRp+LS2opjAtEVKqt+OzFCHh9o="
         2:HashMap$Node@115 "x-ms-content-sha256":"YjVxGFu++f6tLM9YEVQVRmchZiYyxQ+8Bi3PXTJz2C4="
         3:HashMap$Node@116 "host":"localhost"
         */
    }

    
}
