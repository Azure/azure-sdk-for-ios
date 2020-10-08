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

#if canImport(AzureCore)
import AzureCore
#endif

import Foundation
import CryptoKit

public class HMACAuthenticationPolicy: Authenticating {
    public var next: PipelineStage?
    private let accessKey: String
    
    static let dateHeader = "date"
    static let hostHeader  = "host"
    static let contentHashHeader = "x-ms-content-sha256"

    struct HMACAuthenticationProperties {
        let url: URL
        let httpMethod: HTTPMethod
        let contents: Data
        let date: Date
    }

    
    public init(accessKey: String) {
        self.accessKey = accessKey
    }

    public func authenticate(
        request: PipelineRequest,
        completionHandler: @escaping OnRequestCompletionHandler) {
        guard request.httpRequest.url.scheme?.contains("https") == true else {
            completionHandler(
                request,
                AzureError.sdk("HMACAuthenticationPolicy requires a URL using the HTTPS protocol scheme"))
            return
        }

        let contents = request.httpRequest.data ?? Data()
        let url = request.httpRequest.url
        let httpMethod = request.httpRequest.httpMethod
        let date = Date()
        
        let properties = HMACAuthenticationProperties(
            url: url,
            httpMethod: httpMethod,
            contents: contents,
            date: date)
        
        request.httpRequest.headers = addAuthenticationHeaders(with: properties)
        completionHandler(request, nil)
    }
    
    func addAuthenticationHeaders(with
                                    properties: HMACAuthenticationProperties) -> HTTPHeaders {
        var headers: HTTPHeaders = [:]
        headers[HMACAuthenticationPolicy.contentHashHeader] = properties.contents.sha256
                
        let utcNow = String(describing: properties.date, format: .rfc1123)
        headers[HMACAuthenticationPolicy.dateHeader] = utcNow
        headers[HMACAuthenticationPolicy.hostHeader] = properties.url.host
                
        headers.merge(addSignatureHeader(
                        url: properties.url,
                        httpMethod: properties.httpMethod.rawValue,
                        date: utcNow,
                        contentHashed: properties.contents.sha256)) { (_, new) in new }
        return headers
    }
        
    private func addSignatureHeader(
        url: URL,
        httpMethod: String,
        date: String,
        contentHashed: String) -> HTTPHeaders {
        // Order of the headers are important here for generating correct signature
        let signedHeaderNames = "\(HMACAuthenticationPolicy.dateHeader);\(HMACAuthenticationPolicy.hostHeader);\(HMACAuthenticationPolicy.contentHashHeader)"
        let signedHeaderValues =  "\(date);\(url.host ?? "");\(contentHashed)"
        
        // Add unit test for different ports
        // 1 with port 1 without port
        var pathAndQuery = url.path
        if let query = url.query {
            pathAndQuery += "?\(query)"
        }

        let stringToSign = "\(httpMethod.uppercased())\n\(pathAndQuery)\n\(signedHeaderValues)"
        let signature = stringToSign.generateHmac(using: accessKey)
        let hmacSHA256Format = "HMAC-SHA256 SignedHeaders=\(signedHeaderNames)&Signature=\(signature)"
        return ["Authorization": hmacSHA256Format]
    }
}

extension Data {
    public var sha256: String {
        if #available(iOS 13.0, *) {
            let hashed = SHA256.hash(data: self)
            return Data(hashed).base64EncodedString()
        } else {
            return self.hash(algorithm: .sha256).base64EncodedString()
        }
    }

}

extension String {
    func generateHmac(using secret: String) -> String {
        if #available(iOS 13.0, *) {
            let sKey = SymmetricKey(data: Data(base64Encoded: secret)!)
            let auth = HMAC<SHA256>.authenticationCode(for: self.data(using: .utf8)!, using: sKey)
            return Data(auth).base64EncodedString()
        } else {
            return self.hmac(algorithm: .sha256, key: Data(base64Encoded: secret)!).base64EncodedString()
        }
    }
}
