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
import CommonCrypto.CommonHMAC

@objcMembers public class HMACAuthenticationPolicy: Authenticating {
    public var next: PipelineStage?
    private let accessKey: String
    
    private let dateHeader = "date";
    private let hostHeader  = "host";
    private let contentHashHeader = "x-ms-content-sha256";
    
    public init(accessKey: String) {
        self.accessKey = accessKey
    }

    public func authenticate(
        request: PipelineRequest,
        completionHandler: @escaping OnRequestCompletionHandler) {
        let contents = request.httpRequest.data ?? Data()
        
        guard request.httpRequest.url.scheme?.contains("https") == true else {
            completionHandler(
                request,
                AzureError.sdk("HMACAuthenticationPolicy requires a URL using the HTTPS protocol scheme"))
            return
        }
        
        request.httpRequest.headers[.authorization] = appendAuthorizationHeaders(
            url: request.httpRequest.url,
            httpMethod: request.httpRequest.httpMethod.rawValue,
            contents: contents)
        
        completionHandler(request, nil)
    }
    
    private func appendAuthorizationHeaders(
        url: URL,
        httpMethod: String,
        contents: Data) -> String {
        
        
        
        
        return ""
    }
    
    private func addAuthenticationHeaders(
        url: URL,
        httpMethod: String,
        contents: Data) -> HTTPHeaders {
        var headers: HTTPHeaders = [:]
        let contentHashHeader = "x-ms-content-sha256"
        // How do we set the hash header here?
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, dd MMM YYYY HH:mm:ss 'GMT'" // Is this the right date format?
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let date = Date()
        let utcNow = dateFormatter.string(from: date)
        headers[dateHeader] = utcNow
        headers[hostHeader] = url.host
        headers.merge(addSignatureHeader(url: url, httpMethod: httpMethod)) { (_, new) in new }
        
        return headers
    }
    
    private func addSignatureHeader(
        url: URL,
        httpMethod: String) -> HTTPHeaders {
        // Order of the headers are important here for generating correct signature
        let signedHeaderNames = "\(hostHeader);\(dateHeader);\(contentHashHeader)"
        let signedHeaderValues = "" // What is this suppose to be?
        
        var pathAndQuery = url.path
        if let query = url.query {
            pathAndQuery += "?\(query)"
        }
        
        let stringToSign = "\(httpMethod.uppercased())\n\(pathAndQuery)\n\(signedHeaderValues)"
        let signature = stringToSign.generateSHA256(using: accessKey) // Is this right?
        let hmacSHA256Format = "HMAC-SHA256 SignedHeaders=\(signedHeaderNames)&Signature=\(signature)"
        return ["Authorization": hmacSHA256Format]
    }
}

extension String {
    func generateSHA256(using secret: String) -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), secret, secret.count, self, self.count, &digest)
        let data = Data(digest)
        return data.map { String(format: "%02hhx", $0) }.joined()
        
    }
}
