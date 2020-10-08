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
import CommonCrypto
import CryptoKit

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
        let contents = request.httpRequest.data ?? Data() // Is this the body of the request?
        
        guard request.httpRequest.url.scheme?.contains("https") == true else {
            completionHandler(
                request,
                AzureError.sdk("HMACAuthenticationPolicy requires a URL using the HTTPS protocol scheme"))
            return
        }
        
        request.httpRequest.headers = addAuthenticationHeaders(
            url: request.httpRequest.url,
            httpMethod: request.httpRequest.httpMethod.rawValue,
            contents: contents)
        
        completionHandler(request, nil)
    }
    
    public func addAuthenticationHeaders(
        url: URL,
        httpMethod: String,
        contents: Data) -> HTTPHeaders {
        var headers: HTTPHeaders = [:]
        // How do we set the content hash header here?
        // example content hash: "YjVxGFu++f6tLM9YEVQVRmchZiYyxQ+8Bi3PXTJz2C4="
        headers[contentHashHeader] = contents.sha256
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, dd MMM YYYY HH:mm:ss 'GMT'" // Is this the right date format? Try ISO8601DateFormatter
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let date = Date()
        let utcNow = dateFormatter.string(from: date)
        headers[dateHeader] = utcNow
        headers[hostHeader] = url.host
        
        /**
        Example of headers
         HashMap@56 size=3
         0:HashMap$Node@115 "date":"Wed, 07 Oct 2020 17:00:39 GMT"
         1:HashMap$Node@116 "x-ms-content-sha256":"YjVxGFu++f6tLM9YEVQVRmchZiYyxQ+8Bi3PXTJz2C4="
         2:HashMap$Node@117 "host":"localhost"
         */
        
        headers.merge(addSignatureHeader(url: url, httpMethod: httpMethod)) { (_, new) in new }
        /**
         After signature
         HashMap@56 size=4
         0:HashMap$Node@113 "date":"Wed, 07 Oct 2020 18:16:02 GMT"
         1:HashMap$Node@114 "Authorization":"HMAC-SHA256 SignedHeaders=date;host;x-ms-content-sha256&Signature=KZD9UN4LsktsEX2e9cRp+LS2opjAtEVKqt+OzFCHh9o="
         2:HashMap$Node@115 "x-ms-content-sha256":"YjVxGFu++f6tLM9YEVQVRmchZiYyxQ+8Bi3PXTJz2C4="
         3:HashMap$Node@116 "host":"localhost"
         */
        return headers
    }
    
    private func addSignatureHeader(
        url: URL,
        httpMethod: String) -> HTTPHeaders {
        // Order of the headers are important here for generating correct signature
        let signedHeaderNames = "\(dateHeader);\(hostHeader);\(contentHashHeader)"
        let signedHeaderValues = "" // What is this suppose to be? // content hash
        
        // Add unit test for different ports
        // 1 with port 1 without port
        var pathAndQuery = url.path
        if let query = url.query {
            pathAndQuery += "?\(query)"
        }
        /**
         Example of what string to sign should be:
         "POST
         ?id=b93a5ef4-f622-44d8-a80b-ff983122554e
         Wed, 07 Oct 2020 16:46:04 GMT;localhost;YjVxGFu++f6tLM9YEVQVRmchZiYyxQ+8Bi3PXTJz2C4="
         */
        let stringToSign = "\(httpMethod.uppercased())\n\(pathAndQuery)\n\(signedHeaderValues)"
        // Example signature: "PrmeTIq2Ebqwc33tmViNtHuzzN+V+86mXzg5jzg1HTY="
        let signature = stringToSign.generateHmac(using: accessKey) // Is this right?
        let hmacSHA256Format = "HMAC-SHA256 SignedHeaders=\(signedHeaderNames)&Signature=\(signature)"
        // Example of header: "Authorization":"HMAC-SHA256 SignedHeaders=date;host;x-ms-content-sha256&Signature=PrmeTIq2Ebqwc33tmViNtHuzzN+V+86mXzg5jzg1HTY="
        return ["Authorization": hmacSHA256Format]
    }
}

extension Data {
    public var sha256: String {
        if #available(iOS 13.0, *) {
            let hashed = SHA256.hash(data: self)
            return Data(hashed).base64EncodedString()
        } else {
            var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
            self.withUnsafeBytes { bytes in
                _ = CC_SHA256(bytes.baseAddress, CC_LONG(self.count), &digest)
            }
        return Data(digest.makeIterator()).base64EncodedString()
        }
    }

}

extension String {
    func generateHmac(using secret: String) -> String {
//        if #available(iOS 13.0, *) {
//            let sKey = SymmetricKey(data: Data(base64Encoded: secret)!)
//            let auth = HMAC<SHA256>.authenticationCode(for: self.data(using: .utf8)!, using: sKey)
//            return Data(auth).base64EncodedString()
//        } else {
//            var digest = [UInt16](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
//        let rawData = Data(base64Encoded: secret)!
//        let str = String(decoding: rawData.uint16, as: UTF16.self)
//            CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), str, str.count, self, self.count, &digest)
//
//            return Data(digest).base64EncodedString()
//        }
        
        
            var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
//            let rawData = Data(base64Encoded: secret)!
//            let str = String(decoding: rawData, as: UTF8.self)
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), secret.base64EncodedString(), secret.base64EncodedString().count, self, self.count, &digest)
        
            return Data(digest).base64EncodedString()
//        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
//        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), secret, secret.count, self, self.count, &digest)
//        let data = Data(digest)
//        return data.base64EncodedString()
    }
}

