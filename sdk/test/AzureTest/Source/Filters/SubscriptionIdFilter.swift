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

import DVR
import Foundation

public class SubscriptionIDFilter: Filter {
    override public init() {
        super.init()
        let standardHeaderScrubbing: [String: FilterBehavior] = [
            "location": .closure(scrubSubscriptionIDClosure)
        ]
        filterHeaders = standardHeaderScrubbing
        beforeRecordRequest = scrubSubscriptionIDs
        beforeRecordResponse = scrubSubscriptionIDs
    }

    // swiftlint:disable:next force_try
    static let subscriptionIDRegex = try! NSRegularExpression(
        pattern: "(/(subscriptions))/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}",
        options: .caseInsensitive
    )
    // swiftlint:disable:next force_try
    static let graphSubscriptionIDRegex = try! NSRegularExpression(
        pattern: "(https://(graph.windows.net))/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}",
        options: .caseInsensitive
    )

    static var subcriptionIDReplacement = "00000000-0000-0000-0000-000000000000"

    /// Wraps `ScrubSubscriptionId` in a function to be passed as closure within initializer
    func scrubSubscriptionIDClosure(key _: String, val: String?) -> (String?) {
        guard let val = val else { return nil }
        return scrubSubscriptionId(from: val)
    }

    /// Returns the original string with subscription ID info (if any) replaced.
    func scrubSubscriptionId(from string: String) -> String {
        var editedString = string
        editedString.replaceAllMatches(
            usingRegex: SubscriptionIDFilter.subscriptionIDRegex,
            withReplacement: "$1/\(SubscriptionIDFilter.subcriptionIDReplacement)"
        )
        editedString.replaceAllMatches(
            usingRegex: SubscriptionIDFilter.graphSubscriptionIDRegex,
            withReplacement: "$1/\(SubscriptionIDFilter.subcriptionIDReplacement)"
        )

        return editedString
    }

    func scrubSubscriptionIDs(from request: URLRequest) -> URLRequest {
        var cleanRequest = request

        let dirtyHeaders = request.allHTTPHeaderFields ?? [:]
        let cleanHeaders = dirtyHeaders.mapValues { val in
            scrubSubscriptionId(from: val)
        }

        cleanRequest.allHTTPHeaderFields = cleanHeaders.isEmpty ? nil : cleanHeaders
        cleanRequest.url = nil
        if let url = request.url {
            cleanRequest.url = URL(string: scrubSubscriptionId(from: url.absoluteString))
        }

        cleanRequest.mainDocumentURL = nil
        if let docUrl = request.url {
            cleanRequest.url = URL(string: scrubSubscriptionId(from: docUrl.absoluteString))
        }

        cleanRequest.httpBody = nil
        if let httpBodyStringRep = String(data: request.httpBody, encoding: .utf8) {
            cleanRequest.httpBody = scrubSubscriptionId(from: httpBodyStringRep).data(using: .utf8)
        }

        return cleanRequest
    }

    /// This function relies on Filter within DVR to scrub the URLResponse and is only responsible for scrubbing the optional Data. The URLResponse is passed as a parameter and within the return type so that this function can be used as Filter's beforeRecordResponse function
    func scrubSubscriptionIDs(from response: Foundation.URLResponse, data: Data?) -> (Foundation.URLResponse, Data?) {
        guard let dataStringRep = String(data: data, encoding: .utf8) else { return (response, data) }
        return (response, scrubSubscriptionId(from: dataStringRep).data(using: .utf8))
    }
}

extension String {
    mutating func replaceAllMatches(
        usingRegex: NSRegularExpression,
        withReplacement: String,
        matchingOptions: NSRegularExpression.MatchingOptions = []
    ) {
        let range = NSRange(location: 0, length: utf8.count)
        self = usingRegex.stringByReplacingMatches(
            in: self,
            options: matchingOptions,
            range: range,
            withTemplate: withReplacement
        )
    }
}
