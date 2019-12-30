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

public class HttpRequest: HttpMessage {
    public var httpMethod: HttpMethod
    public var url: String
    public var headers: HttpHeaders
    public var files: [String]?
    public var data: Data?

    public var query: [URLQueryItem]? {
        let comps = URLComponents(string: url)?.queryItems
        return comps
    }

    public init(httpMethod: HttpMethod, url: String, headers: HttpHeaders, files: [String]? = nil,
                data: Data? = nil) {
        self.httpMethod = httpMethod
        self.url = url
        self.headers = headers
        self.files = files
        self.data = data
    }

    public func format(queryParams: [String: String]?) {
        guard var urlComps = URLComponents(string: self.url) else { return }
        var queryItems = url.parseQueryString() ?? [String: String]()

        // add any query params from the queryParams dictionary
        if queryParams != nil {
            for (name, value) in queryParams! {
                queryItems[name] = value
            }
        }
        urlComps.queryItems = queryItems.convertToQueryItems()
        url = urlComps.url(relativeTo: nil)?.absoluteString ?? url
    }
}
