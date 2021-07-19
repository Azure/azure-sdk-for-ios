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
import DVR

public extension Filter {
    static let subscriptionIDRegex = try! NSRegularExpression(pattern: "(/(subscriptions))/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}", options: [.caseInsensitive])
    static let graphSubscriptionIDRegex = try! NSRegularExpression(pattern: "(https://(graph.windows.net))/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}", options: [.caseInsensitive])
    
    static let standard: Filter = {
        var standardFilter = Filter()
        let headers = ["Authorization" : FilterBehavior.remove]
        standardFilter.beforeRecordRequest = scrubSubscriptionIDs
        standardFilter.beforeRecordResponse = scrubSubscriptionIDs
        return standardFilter
    }()
    
    static func scrubSubscriptionId(from string: String?, embeddedStringKeys: [String] = ["tenantID","objectId"]) -> String? {
        
        
        
        let embeddedIDRegex = { (_ key : String) in
            try! NSRegularExpression(pattern: "\"\(key)\":\"/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\"", options: [.caseInsensitive])
        }
        
        guard var editedString = string else {
            return nil
        }
        var range = NSRange(location: 0, length: editedString.utf8.count)
        if Filter.subscriptionIDRegex.numberOfMatches(in: editedString, options: [], range: range) > 0 {
            editedString = Filter.subscriptionIDRegex.stringByReplacingMatches(in: editedString, options: [], range: range, withTemplate: "$1/99999999-9999-9999-9999-999999999999")
        }
        range = NSRange(location: 0, length: editedString.utf8.count)
        if Filter.graphSubscriptionIDRegex.numberOfMatches(in: editedString, options: [], range: range) > 0 {
            editedString = Filter.graphSubscriptionIDRegex.stringByReplacingMatches(in: editedString, options: [], range: range, withTemplate: "$1/99999999-9999-9999-9999-999999999999")
        }
        
        for key in embeddedStringKeys {
            let embeddedRegex = embeddedIDRegex(key)
            range = NSRange(location: 0, length: editedString.utf8.count)
            if embeddedRegex.numberOfMatches(in: editedString, options: [], range: range) > 0 {
                editedString = embeddedRegex.stringByReplacingMatches(in: editedString, options: [], range: range, withTemplate: "\"\(key)\":\"/99999999-9999-9999-9999-999999999999\"")
            }
        }
        return editedString
        
        
    }
    
    static func scrubSubscriptionIDs(request: URLRequest) -> URLRequest {
        
        var cleanRequest = request
        
        let dirtyHeaders = request.allHTTPHeaderFields ?? [:]
        let cleanHeaders = dirtyHeaders.mapValues { val -> String in
            guard let newValue = scrubSubscriptionId(from: val) else {
                return val
            }
            return newValue
        }
        cleanRequest.allHTTPHeaderFields = cleanHeaders.isEmpty ? nil : cleanHeaders
        
        cleanRequest.url = URL(string: scrubSubscriptionId(from: request.url?.absoluteString))
        cleanRequest.mainDocumentURL = URL(string: scrubSubscriptionId(from: request.mainDocumentURL?.absoluteString))
        cleanRequest.httpBody = scrubSubscriptionId(from: String(data: request.httpBody, encoding: .utf8))?.data(using: .utf8)

        return cleanRequest
    }
    
    static func scrubSubscriptionIDs(response: Foundation.URLResponse, data: Data?) -> (Foundation.URLResponse, Data?) {
        guard let dirtyData = data else {
            return (response, data)
        }
        
        do {
            guard let responseDataString = try JSONSerialization.jsonObject(with: dirtyData, options: .allowFragments) as? String else {
                return (response, data)
            }
            let cleanedDataString = scrubSubscriptionId(from: responseDataString)
            let cleanedData = cleanedDataString?.data(using: .utf8)
            return (response, cleanedData)
        } catch {
            return (response, data)
        }
    }
    
}









