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
    
    static let subscriptionIDRegex = try! NSRegularExpression(pattern: "(/(subscriptions))/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}", options: .caseInsensitive)
    static let graphSubscriptionIDRegex = try! NSRegularExpression(pattern: "(https://(graph.windows.net))/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}", options: .caseInsensitive)
    
    static var subcriptionIDReplacement = "00000000-0000-0000-0000-000000000000"
    
    static var standardHeaderScrubbing: [String : FilterBehavior] = [
        "location": .closure({ key, val in
            scrubSubscriptionId(from: val ?? "")
        }),
        "operation-location": .remove,
        "azure-asyncoperation": .remove,
        "www-authenticate": .remove,
        "access_token": .remove
        
    ]
    
    /// Returns the original string with subscription ID info (if any) replaced.
    static func scrubSubscriptionId(from string: String) -> String {
        var editedString = string
        editedString.replaceAllMatches(usingRegex: Filter.subscriptionIDRegex, withReplacement: "$1/\(Filter.subcriptionIDReplacement)")
        editedString.replaceAllMatches(usingRegex: Filter.graphSubscriptionIDRegex, withReplacement: "$1/\(Filter.subcriptionIDReplacement)")
        
        return editedString
        
        
    }
    
    /// Attempts to scrub subscription ID from optional String. Returns nil if the input is nil.
    static func tryScrubSubscriptionId(from string: String?) -> String? {
        
        if string != nil {
            return scrubSubscriptionId(from: string!)
        }
        return nil
    }
    
    /// Attempts to scrub subsctiption ID from optional Data that represents a string. Returns null if the input is nil or if the Data is not String-representable.
    static func tryScrubSubscriptionId(from data: Data?) -> Data? {
        
        guard let stringData = String(data: data, encoding: .utf8) else {
            return nil
        }
        return scrubSubscriptionId(from: stringData).data(using: .utf8)
    }
    
    func scrubSubscriptionIDs(from request: URLRequest) -> URLRequest {
        
        var cleanRequest = request
        
        let dirtyHeaders = request.allHTTPHeaderFields ?? [:]
        let cleanHeaders = dirtyHeaders.mapValues { val in
            return Filter.scrubSubscriptionId(from: val)
        }
        
        cleanRequest.allHTTPHeaderFields = cleanHeaders.isEmpty ? nil : cleanHeaders
        cleanRequest.url = URL(string: Filter.tryScrubSubscriptionId(from: request.url?.absoluteString))
        cleanRequest.mainDocumentURL = URL(string: Filter.tryScrubSubscriptionId(from: request.mainDocumentURL?.absoluteString))
        cleanRequest.httpBody = Filter.tryScrubSubscriptionId(from: String(data: request.httpBody, encoding: .utf8))?.data(using: .utf8)

        return cleanRequest
    }
    
    /// This function relies on Filter within DVR to scrub the URLResponse and is only responsible for scrubbing the optional Data. The URLResponse is passed as a parameter and within the return type so that this function can be used as Filter's beforeRecordResponse function
    func scrubSubscriptionIDs(from response: Foundation.URLResponse, data: Data?) -> (Foundation.URLResponse, Data?) {
        return (response, Filter.tryScrubSubscriptionId(from: data))
    }
    
}

extension String {
    
    mutating func replaceAllMatches(usingRegex: NSRegularExpression, withReplacement: String, matchingOptions: NSRegularExpression.MatchingOptions = []) {
        let range = NSRange(location: 0, length: self.utf8.count)
        self = usingRegex.stringByReplacingMatches(in: self, options: matchingOptions, range: range, withTemplate: withReplacement)

    }
    
    
}







