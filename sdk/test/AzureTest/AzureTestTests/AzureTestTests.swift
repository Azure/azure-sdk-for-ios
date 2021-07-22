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
import AzureTest

class AzureTestTests: XCTestCase {

    var fakeData: Data!
    
    var fakeRequest: URLRequest!
    
    var fakeResponse: URLResponse!
    
    var fakeResponseData: Data!
    
    private func chooseRecordedInteraction(number: Int) {
        fakeRequest = fakeData.request(number: number)
        fakeResponse = fakeData.response(number: number)
        fakeResponseData = fakeData.responseData(number: number)
    }
    
    override func setUpWithError() throws {
        let testBundle = Bundle(for: type(of: self))
        let path = testBundle.path(forResource: "TestData", ofType: "json")
        fakeData = try! Data(contentsOf: URL(fileURLWithPath: path!))
        chooseRecordedInteraction(number: 8)
        
    }

    func test_scrubbingRequest_removeSubscriptionIDs() throws {
        let cleanedRequest = Filter().scrubSubscriptionIDs(from: fakeRequest!)
        let shouldPass = cleanedRequest.url?.absoluteString.contains(regex: Filter.subcriptionIDReplacement) ?? false
        XCTAssert(shouldPass)
        
    }

    func test_scrubbingResponse_removeSubscriptionIDs() throws {
        let dirtyHeaders = ["location": "[\"https://management.azure.com/subscriptions/72f988bf-86f1-41af-91ab-2d7cd011db47/providers/Microsoft.KeyVault/locations/eastus/operationResults/VVR8MDYzNzU0NDA3MTY0MzE2NTczMnwwNjZENTEwRTA4N0U0MTY5ODc1MDhDRDY3QUJDMzdGOQ?api-version=2019-09-01\"]"]
        
        let dirtyBody = """
            "string": "{\"id\":\"/subscriptions/72f988bf-86f1-41af-91ab-2d7cd011db47/providers/Microsoft.KeyVault/locations/eastus/deletedVaults/myValtZikfikxz\",\"name\":\"myValtZikfikxz\",\"type\":\"Microsoft.KeyVault/deletedVaults\",\"properties\":{\"vaultId\":\"/subscriptions/72f988bf-86f1-41af-91ab-2d7cd011db47/resourceGroups/rgname/providers/Microsoft.KeyVault/vaults/myValtZikfikxz\",\"location\":\"eastus\",\"tags\":{},\"deletionDate\":\"2021-04-19T05:32:42Z\",\"scheduledPurgeDate\":\"2021-07-18T05:32:42Z\"}}"
        """
        
        var shouldPass = false
        
        let cleanLocation = Filter.scrubSubscriptionId(from: dirtyHeaders["location"])
        let cleanBody = Filter.scrubSubscriptionId(from: dirtyBody)
        
        let shouldPass = cleanLocation!.contains(regex: Filter.subcriptionIDReplacement) && cleanBody!.contains(regex: Filter.subcriptionIDReplacement)
        
        XCTAssert(shouldPass)
    }

    
}



fileprivate extension Array where Element == Any {
    func dictionary(forIndex: Int) -> Dictionary<String,Any>? {
        return self[forIndex] as? Dictionary<String, Any>
    }
    
    func array(forIndex: Int) -> Array<Any>? {
        return self[forIndex] as? Array<Any>
    }
    
    func string(forIndex: Int) -> String? {
        return self[forIndex] as? String
    }
    
}

fileprivate extension Data {
    
    private func topLevelDataDictionary() -> [String:Any] {
        try! JSONSerialization.jsonObject(with: self, options: []) as! [String:Any]
    }
    
    
    func responseDataHeaders() -> [String:String?] {
        let dictionary = topLevelDataDictionary()
        var stringDictionary = [String:String]()
        dictionary.forEach {
            stringDictionary[$0] = ($1 as? CustomStringConvertible)?.description
        }
        return stringDictionary
    }
    
    func request(number: Int = 0) -> URLRequest {
        let dataDictionary = topLevelDataDictionary()
        var fakeRequest = URLRequest(url: URL(string: dataDictionary.array(forKey: "interactions")?.dictionary(forIndex: number)?.dictionary(forKey: "request")?.string(forKey: "uri"))!)
        fakeRequest.httpBody = dataDictionary.array(forKey: "interactions")?.dictionary(forIndex: number)?.dictionary(forKey: "request")?.string(forKey: "body")?.data(using: .utf8)
        return fakeRequest
    }
    
    func response(number: Int = 0) -> URLResponse {
        let dataDictionary = topLevelDataDictionary()
        return HTTPURLResponse(url: URL(string: dataDictionary.array(forKey: "interactions")?.dictionary(forIndex: number)?.dictionary(forKey: "request")?.string(forKey: "uri"))!, statusCode: 200, httpVersion: nil, headerFields: dataDictionary.array(forKey: "interactions")?.dictionary(forIndex: number)?.dictionary(forKey: "response")?.dictionary(forKey: "headers")?.stringValues())! as URLResponse
    }
    
    func responseData(number: Int = 0) -> Data {
        let dataDictionary = topLevelDataDictionary()
        return (dataDictionary.array(forKey: "interactions")?.dictionary(forIndex: number)?.dictionary(forKey: "response")?.dictionary(forKey: "body")?.description.data(using: .utf8)!)!
    }
}

fileprivate extension Dictionary where Key == String, Value == Any {
    
     func stringValues() -> [String:String]  {
         var newDictionary = [String:String]()
         self.forEach { key, val in
            newDictionary[key] = (val as! CustomStringConvertible).description
         }
         return newDictionary
     }
  
    
    func dictionary(forKey: Key) -> Dictionary<String,Any>?  {
        return self[forKey] as? Dictionary<String,Any>
    }
    
    func array(forKey: Key) -> Array<Any>?  {
        return self[forKey] as? Array<Any>
    }
    
    func string(forKey: Key) -> String? {
        return self[forKey] as? String
    }
}

fileprivate extension String {
    func dictionaryFromString() -> [String : Any] {
        let data = self.data(using: .utf8)
        return try! JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
    }
    
    func contains(regex pattern: String, regexOptions: NSRegularExpression.Options = [], matchingOptions: NSRegularExpression.MatchingOptions = []) -> Bool {
            let regularExpression = try! NSRegularExpression(pattern: pattern, options: regexOptions)
            let range = NSRange(location: 0, length: self.utf8.count)
            return regularExpression.numberOfMatches(in: self, options: matchingOptions, range: range) > 0
    }
}
