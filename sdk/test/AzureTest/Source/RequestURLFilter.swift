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

/// A filter for replacing non-deterministic values in the request URL with deterministic ones to facilitate reliable playback.
public class RequestURLFilter: Filter {
    private var replacements = [String: String]()

    override public init() {
        super.init()
        beforeRecordRequest = process(request:)
    }

    func process(request: URLRequest) -> URLRequest? {
        var cleanRequest = request

        for (old, new) in replacements {
            if let url = request.url {
                cleanRequest.url = URL(string: url.absoluteString.replacingOccurrences(of: old, with: new))
            }

            if let httpBody = String(data: request.httpBody, encoding: .utf8) {
                cleanRequest.httpBody = httpBody.replacingOccurrences(of: old, with: new).data(using: .utf8)
            }
        }

        return cleanRequest
    }

    public func register(replacement newVal: String, for oldVal: String) {
        replacements[oldVal] = newVal
    }
}
