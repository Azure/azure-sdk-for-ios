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

    var fakeData : Data!
    
    var fakeRequest : URLRequest?
    
    var fakeResponse : URLResponse?
    
    var fakeResponseData : Data?
    
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let testBundle = Bundle(for: type(of: self))
        let path = testBundle.path(forResource: "TestData", ofType: "json")
        fakeData = try! Data(contentsOf: URL(fileURLWithPath: path!))
        
        let dataDictionary = try! JSONSerialization.jsonObject(with: fakeData, options: []) as! [String:Any]
        fakeRequest = URLRequest(url: URL(string: try! dataDictionary.array(forKey: "interactions").dictionary(forIndex: 0).dictionary(forKey: "request").string(forKey: "uri"))!)
        fakeRequest?.httpBody = try! dataDictionary.array(forKey: "interactions").dictionary(forIndex: 0).dictionary(forKey: "request").string(forKey: "body").data(using: .utf8)
        
        fakeResponse = HTTPURLResponse(url: URL(string: try! dataDictionary.array(forKey: "interactions").dictionary(forIndex: 0).dictionary(forKey: "request").string(forKey: "uri"))!, statusCode: 200, httpVersion: nil, headerFields: try! dataDictionary.array(forKey: "interactions").dictionary(forIndex: 0).dictionary(forKey: "response").dictionary(forKey: "headers") as! [String:String])
        
        fakeResponseData = try! dataDictionary.array(forKey: "interactions").dictionary(forIndex: 0).dictionary(forKey: "response").dictionary(forKey: "body").description.data(using: .utf8)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_scrubbingRequest_removeSubscriptionIDs() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let cleanedRequest = Filter.scrubSubscriptionIDs(request: fakeRequest!)
        XCTAssert(cleanedRequest.url?.absoluteString == "https://management.azure.com/subscriptions/99999999-9999-9999-9999-999999999999/resourceGroups/rgname/providers/Microsoft.KeyVault/vaults/myValtZikfikxz?api-version=2019-09-01")
        
    }

    func test_scrubbingResponse_removeSubscriptionIDs() throws {
        
        let cleanedResponse = Filter.scrubSubscriptionIDs(response: fakeResponse!, data: fakeResponseData)
        print(String(data: cleanedResponse.1, encoding: .utf8))
    }

    
}

fileprivate extension Array where Element == Any {
    func dictionary(forIndex: Int) throws -> Dictionary<String,Any> {
        if let dictionary = self[forIndex] as? Dictionary<String, Any> {
            return dictionary
        }
        throw "Not a dictionary"
    }
    
    func array(forIndex: Int) throws -> Array<Any> {
        if let array = self[forIndex] as? Array<Any> {
            return array
        }
        throw "Not an array"
    }
    
    func string(forIndex: Int) throws -> String {
        if let string = self[forIndex] as? String {
            return string
        }
        throw "Not a string"
    }
    
}

 fileprivate extension Dictionary where Key == String, Value == Any {
    
     func stringValues() throws -> [String:String]  {
         var newDictionary = [String:String]()
         try self.forEach { key, val in
             if let val = val as? CustomStringConvertible {
                 newDictionary[key] = val.description
             }
             else {
                 throw "Not string representable"
             }
         }
         return newDictionary
     }
     
    func findValue(key: String, dictionary: Dictionary<String,Any>) -> Any? {
       if dictionary[key] != nil {
           return dictionary[key]
       }
        
       for testKey in dictionary.keys {
           if let innerDictionary = dictionary[testKey] as? Dictionary<String , Any> {
               let returnedValue = findValue(key: key, dictionary: innerDictionary)
               if returnedValue != nil {
                   return returnedValue
               }
           }
       }
       return nil
    }
    
    func dictionary(forKey: Key) throws -> Dictionary<String,Any>  {
        if let innerDictionary = self[forKey] as? Dictionary<String,Any> {
            return innerDictionary
        }
        throw "Not a dictionary"
    }
    
    func array(forKey: Key) throws -> Array<Any>  {
        if let innerArray = self[forKey] as? Array<Any> {
            return innerArray
        }
        throw "Not an array"
    }
    
    func string(forKey: Key) throws -> String {
        if let string = self[forKey] as? String {
            return string
        }
        throw "Not a string"
    }
}

fileprivate extension String {
    func dictionaryFromString() throws -> [String : Any] {
        let data = self.data(using: .utf8)
        guard let dictionary = try! JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] else {
            throw "Not a dictionary"
        }
        return dictionary
    }
}
