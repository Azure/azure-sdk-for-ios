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

public class HTTPRequest: DataStringConvertible {
    // MARK: Properties

    public let httpMethod: HTTPMethod
    public var url: URL
    public var headers: HTTPHeaders
    public var data: Data?

    // MARK: Initializers

    public convenience init(method: HTTPMethod, url: String, headers: HTTPHeaders, data: Data? = nil) throws {
        guard let encodedUrl = URL(string: url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)) else {
            throw AzureError.serviceRequest("Invalid URL.")
        }
        try self.init(method: method, url: encodedUrl, headers: headers, data: data)
    }

    public init(method: HTTPMethod, url: URL, headers: HTTPHeaders, data: Data? = nil) throws {
        self.httpMethod = method
        self.url = url
        self.headers = headers
        self.data = data
    }

    // MARK: Public Methods

    public func add(queryParams addedParams: [QueryParameter]) {
        guard !addedParams.isEmpty else { return }
        guard var urlComps = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return }

        let addedQueryItems = addedParams.map { name, value in URLQueryItem(name: name, value: value) }
        if var urlQueryItems = urlComps.queryItems, !urlQueryItems.isEmpty {
            urlQueryItems.append(contentsOf: addedQueryItems)
            urlComps.queryItems = urlQueryItems
        } else {
            urlComps.queryItems = addedQueryItems
        }
        if let finalUrl = urlComps.url {
            url = finalUrl
        }
    }
}
