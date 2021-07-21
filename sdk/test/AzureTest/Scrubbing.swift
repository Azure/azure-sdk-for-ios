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
    
    static let subscriptionIDRegex = "(/(subscriptions))/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"
    static let graphSubscriptionIDRegex = "(https://(graph.windows.net))/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"
    
    static var subcriptionIDReplacement = "99999999-9999-9999-9999-999999999999"
    
    static var standardHeaderScrubbing: [String : FilterBehavior] = [
        "location": .closure({ key, val in
            scrubSubscriptionId(from: val ?? "")
        }),
        "operation-location": .replace(""),
        "azure-asyncoperation": .replace(""),
        "www-authenticate": .replace(""),
        "access_token": .replace("")
        
    ]
    
    static func scrubSubscriptionId(from string: String?) -> String? {
        
        guard var editedString = string else {
            return nil
        }
        editedString.replaceAllMatches(usingRegex: Filter.subscriptionIDRegex, withReplacement: "$1/\(Filter.subcriptionIDReplacement)", options: .caseInsensitive)
        editedString.replaceAllMatches(usingRegex: Filter.graphSubscriptionIDRegex, withReplacement: "$1/\(Filter.subcriptionIDReplacement)", options: .caseInsensitive)
        
        return editedString
        
        
    }
    
    
    
    func scrubSubscriptionIDs(from request: URLRequest) -> URLRequest {
        
        var cleanRequest = request
        
        let dirtyHeaders = request.allHTTPHeaderFields ?? [:]
        let cleanHeaders = dirtyHeaders.mapValues { val in
            return Filter.scrubSubscriptionId(from: val) ?? val
        }
        
        cleanRequest.allHTTPHeaderFields = cleanHeaders.isEmpty ? nil : cleanHeaders
        cleanRequest.url = URL(string: Filter.scrubSubscriptionId(from: request.url?.absoluteString))
        cleanRequest.mainDocumentURL = URL(string: Filter.scrubSubscriptionId(from: request.mainDocumentURL?.absoluteString))
        cleanRequest.httpBody = Filter.scrubSubscriptionId(from: String(data: request.httpBody, encoding: .utf8))?.data(using: .utf8)

        return cleanRequest
    }
    
    func scrubSubscriptionIDs(from response: Foundation.URLResponse, data: Data?) -> (Foundation.URLResponse, Data?) {
        guard let dirtyData = data else {
            return (response, data)
        }
        let responseDataString = String(data: dirtyData, encoding: .utf8)
        let cleanedDataString = Filter.scrubSubscriptionId(from: responseDataString)
        let cleanedData = cleanedDataString?.data(using: .utf8)
        return (response, cleanedData)
        
    }
    
}

extension String {
    
    mutating func replaceAllMatches(usingRegex: String, withReplacement: String, options: NSRegularExpression.Options = [], matchingOptions: NSRegularExpression.MatchingOptions = []) {
        do {
            let regularExpression = try NSRegularExpression(pattern: usingRegex, options: options)
            let range = NSRange(location: 0, length: self.utf8.count)
            self = regularExpression.stringByReplacingMatches(in: self, options: matchingOptions, range: range, withTemplate: withReplacement)
        } catch {
            return
        }
    }
}







