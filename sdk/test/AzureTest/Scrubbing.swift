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

import Foundation

public class Scrubbing {
    
    //regex for subscription id scrubbing
    static let subscriptionIDRegex = try! NSRegularExpression(pattern: "(/(subscriptions))/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}", options: [.caseInsensitive])
    static let graphSubscriptionIDRegex = try! NSRegularExpression(pattern: "(https://(graph.windows.net))/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}", options: [.caseInsensitive])
    
    static func scrubSubscriptionIDs(request: URLRequest) -> URLRequest {
        
        var cleanRequest = request
        
    let dirtyHeaders = request.allHTTPHeaderFields ?? [:]
    let cleanHeaders = dirtyHeaders.map { key, val in
        (key, regexSubscriptionReplace(val))
    }
        cleanRequest.allHTTPHeaderFields = cleanHeaders.isEmpty ? nil : cleanHeaders
        
        cleanRequest.url = URL(string: regexSubscriptionReplace(request.url?.absoluteString))
        cleanRequest.mainDocumentURL = URL(string: regexSubscriptionReplace(request.mainDocumentURL?.absoluteString))
        cleanRequest.httpBody = regexSubscriptionReplace(String(data: request.httpBody, encoding: .utf8))?.data(using: .utf8)
    
        return cleanRequest
    }
    
    func scrubSubscriptionId(from string: String?) -> String? {
        guard var editedString = string else {
            return nil
        }
        var range = NSRange(location: 0, length: editedString.utf8.count)
        if subscriptionIDRegex.numberOfMatches(in: editedString, options: [], range: range) > 0 {
            editedString = subscriptionIDRegex.stringByReplacingMatches(in: editedString, options: [], range: range, withTemplate: "$1/99999999-9999-9999-9999-999999999999")
        }
        range = NSRange(location: 0, length: editedString.utf8.count)
        if graphSubscriptionIDRegex.numberOfMatches(in: editedString, options: [], range: range) > 0 {
            editedString = graphSubscriptionIDRegex.stringByReplacingMatches(in: editedString, options: [], range: range, withTemplate: "$1/99999999-9999-9999-9999-999999999999")
        }
        return editedString
    }
    
    static func scrubSubscriptionIDs(response: Foundation.URLResponse, data: Data?) -> URLRequest {
        fatalError("Unimplemented")
    }
    
    public static func scrubRequests(request: URLRequest) -> URLRequest {
        var cleanedRequest = request
        cleanedRequest = scrubSubscriptionIDs(request: cleanedRequest)
        
        return cleanedRequest
    }
    
    static func scrubResponse(response: Foundation.URLResponse,data: Data?) -> (Foundation.URLResponse, Data?) {
        fatalError("Unimplemented")
    }
}


extension Array where Element == Any {
    func dictionaryForIndex(_ index: Int) throws -> Dictionary<String,Any> {
        if let dictionary = self[index] as? Dictionary<String, Any> {
            return dictionary
        }
        throw "Not a dictionary"
    }
    
    func arrayForIndex(_ index: Int) throws -> Array<Any> {
        if let array = self[index] as? Array<Any> {
            return array
        }
        throw "Not an array"
    }
    
    func stringForIndex(_ index: Int) throws -> String {
        if let string = self[index] as? String {
            return string
        }
        throw "Not a string"
    }
    
}

 extension Dictionary where Key == String, Value == Any {
    
    static func findValue(key: String, dictionary: Dictionary<String,Any>) -> Any? {
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
    
    func dicionaryForKey(_ key: Key) throws -> Dictionary<String,Any>  {
        if let innerDictionary = self[key] as? Dictionary<String,Any> {
            return innerDictionary
        }
        throw "Not a dictionary"
    }
    
    func arrayForKey(_ key: Key) throws -> Array<Any>  {
        if let innerArray = self[key] as? Array<Any> {
            return innerArray
        }
        throw "Not an array"
    }
    
    func stringForKey(_ key: Key) throws -> String {
        if let string = self[key] as? String {
            return string
        }
        throw "Not a string"
    }
}

extension String {
    public func dictionaryFromString() throws -> Dictionary<String, Any> {
        do {
            let data = self.data(using: .utf8)
            let dictionary = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any]
            return dictionary!
        } catch {
            throw "Not a dictionary"
        }
    }
}
