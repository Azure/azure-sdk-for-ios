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

public typealias QueryParameter = (String, String?)

public extension Array where Element == QueryParameter {
    mutating func append(_ name: String, _ value: String?) {
        append((name, value))
    }
}

extension URL {
    public func appendingQueryParameters(_ queryParams: [QueryParameter]?) -> URL? {
        guard let params = queryParams else { return self }
        guard !params.isEmpty else { return self }
        guard var urlComps = URLComponents(url: self, resolvingAgainstBaseURL: true) else { return nil }

        let queryItems = params.map { name, value in URLQueryItem(
            name: name,
            value: value?.addingPercentEncoding(withAllowedCharacters: .azureUrlQueryAllowed)
        ) }
        urlComps.percentEncodedQueryItems = queryItems
        return urlComps.url
    }

    public func deletingQueryParameters() -> URL? {
        guard var urlComps = URLComponents(url: self, resolvingAgainstBaseURL: true) else { return nil }
        urlComps.query = nil
        return urlComps.url
    }
}
