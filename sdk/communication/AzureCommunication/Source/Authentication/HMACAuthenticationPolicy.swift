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

import AzureCore
import Foundation

@objcMembers public class HMACAuthenticationPolicy: PipelineStage {
    public var next: PipelineStage?
    
    private(set) var secret: [UInt8] = [];
    
    public init(accessKey: String) {
        secret = Array(accessKey.utf8)
    }
    
    public func process(request pipelineRequest: PipelineRequest, completionHandler: @escaping PipelineStageResultHandler) {
        
    }
     
    
    private func createContentHash(request pipelineRequest: PipelineRequest) -> String {
        return ""
    }
    
    private func getAuthorizationHeader(
        method pipelineRequest: PipelineRequest,
        url: URL,
        contentHash: String,
        date: String) -> String {
        let signedHeaders = "date;host;x-ms-constent-sha256"
        
        guard let host = url.host,
              let query = url.query else {
            return ""
        }
        
        let pathAndQuery = "\(url.path)\(query)"
        let stringToSign = "\n\(pathAndQuery)\n\(date);\(host);\(contentHash)"
        let signature = computeHMAC(for: stringToSign)
        
        return "HMAC-SHA256 SignedHeaders=\(signedHeaders)&Signature=\(signature)"
    }
    
    private func computeHMAC(for value: String) -> String {
        return ""
    }
}
