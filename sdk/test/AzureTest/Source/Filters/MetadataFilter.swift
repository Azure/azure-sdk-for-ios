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

public class MetadataFilter: Filter {
    // swiftlint:disable force_try
    static let metadataRegex = try! NSRegularExpression(
        pattern: "/.well-known/openid-configuration|/common/discovery/instance",
        options: .caseInsensitive
    )

    override public init() {
        super.init()
        beforeRecordRequest = filterMetadata
    }

    func filterMetadata(from request: URLRequest) -> URLRequest? {
        guard let requestURL = request.url else {
            return request
        }
        if requestURL.absoluteString.contains(regex: MetadataFilter.metadataRegex) {
            return nil
        }
        return request
    }
}

extension String {
    func contains(regex: NSRegularExpression, matchingOptions: NSRegularExpression.MatchingOptions = []) -> Bool {
        let range = NSRange(location: 0, length: count)
        return regex.numberOfMatches(in: self, options: matchingOptions, range: range) > 0
    }
}
