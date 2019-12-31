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

public class UserAgentPolicy: PipelineStageProtocol {
    public var next: PipelineStageProtocol?

    private var _userAgent: String

    public let userAgentOverwrite: Bool
    public var userAgent: String {
        return _userAgent
    }

    public init(baseUserAgent: String? = nil, userAgentOverwrite: Bool = false) {
        // TODO: User-Agent format according to SDK guidelines
        // [<application_id> ]azsdk-<sdk_language>-<package_name>/<package_version> <platform_info>
        // [Application/Version] azsdk-ios-AppConfiguration/0.1.0
        //   (Swift BLAH; ObjC BLAH; Macintosh; Intel Max OS X 10_10; rv:33.0)
        self.userAgentOverwrite = userAgentOverwrite
        if baseUserAgent == nil {
            // TODO: Distinguish between Swift and ObjC?
            let swiftVersion = 5.0
            let platform = "iPhone"
            let azureCoreVersion = "0.1.0"
            _userAgent = "ios/\(swiftVersion) (\(platform)) AzureCore/\(azureCoreVersion)"
        } else {
            _userAgent = baseUserAgent!
        }
    }

    public func appendUserAgent(value: String) {
        _userAgent = "\(_userAgent) \(value)"
    }

    public func onRequest(_ request: PipelineRequest, then completion: @escaping OnRequestCompletionHandler) {
        if let contextUserAgent = request.context?.value(forKey: "userAgent") as? String {
            if request.context?.value(forKey: "userAgentOverwrite") != nil {
                request.httpRequest.headers[.userAgent] = contextUserAgent
            } else {
                request.httpRequest.headers[.userAgent] = "\(userAgent) \(contextUserAgent)"
            }
        } else if userAgentOverwrite || request.httpRequest.headers[HttpHeader.userAgent] == nil {
            request.httpRequest.headers[.userAgent] = userAgent
        }
        completion(request)
    }
}
