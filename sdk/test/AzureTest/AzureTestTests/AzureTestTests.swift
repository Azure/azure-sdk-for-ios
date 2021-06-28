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
import Foundation
import DVR
@testable import AzureTest

class AzureTestTests: XCTestCase {

    let fakeData = try! String(contentsOfFile: "/Users/jairmyree/Downloads/output-onlineyamltools.json")
    
    var fakeRequest : URLRequest?
    
    var fakeResponse : URLResponse?
    
    var fakeResponseData : Data?
    
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let dataDictionary = try! JSONSerialization.jsonObject(with: fakeData.data(using: .utf8)!, options: []) as! [String:Any]
        fakeRequest = URLRequest(url: URL(string: try! dataDictionary.arrayForKey("interactions").dictionaryForIndex(0).dicionaryForKey("request").stringForKey("uri"))!)
        fakeRequest?.httpBody = try! dataDictionary.arrayForKey("interactions").dictionaryForIndex(0).dicionaryForKey("request").stringForKey("body").data(using: .utf8)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCleanRequestURL() throws {
        print(fakeRequest?.url)
        let cleanedRequest = Scrubbing.scrubRequests(request: fakeRequest!)
        XCTAssert(cleanedRequest.url?.absoluteString == "https://management.azure.com/subscriptions/99999999-9999-9999-9999-999999999999/resourceGroups/rgname/providers/Microsoft.KeyVault/vaults/myValtZikfikxz?api-version=2019-09-01")
    }

        

}

