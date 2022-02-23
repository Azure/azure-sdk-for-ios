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

public class LargeBodyFilter: Filter {
    let maxBodySize: Int
    init(maxBodySize: Int = 1_048_576) {
        self.maxBodySize = maxBodySize
        super.init()
        beforeRecordRequest = truncateBody
        beforeRecordResponse = truncateBody
    }

    func truncateBody(request: URLRequest) -> URLRequest? {
        guard let data = request.httpBody else {
            return request
        }
        guard var stringBody = String(data: data, encoding: .utf8) else {
            return request
        }

        if stringBody.count > maxBodySize {
            var newRequest = request
            stringBody = stringBody.prefix(maxBodySize) + "..."
            newRequest.httpBody = stringBody.data(using: .utf8)
            return newRequest
        } else {
            return request
        }
    }

    func truncateBody(response: Foundation.URLResponse, data: Data?) -> (Foundation.URLResponse, Data?)? {
        guard let unwrappedData = data else {
            return (response, data)
        }

        guard var stringData = String(data: unwrappedData, encoding: .utf8) else {
            return (response, data)
        }

        if stringData.count > maxBodySize {
            stringData = String(stringData.prefix(maxBodySize)) + "..."
            return (response, stringData.data(using: .utf8))
        } else {
            return (response, data)
        }
    }
}
