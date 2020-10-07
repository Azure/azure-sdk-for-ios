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
        headers[contentHashHeader] = sha256Policy(using: contents)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, dd MMM YYYY HH:mm:ss 'GMT'" // Is this the right date format?
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
         0:HashMap$Node@115 "date":"Wed, 07 Oct 2020 17:00:39 GMT"
         1:HashMap$Node@136 "Authorization":"HMAC-SHA256 SignedHeaders=date;host;x-ms-content-sha256&Signature=BRv4OuRokaPmjN+HSUOdRS0mWKxEPxw15oHE5MVgm20="
         2:HashMap$Node@116 "x-ms-content-sha256":"YjVxGFu++f6tLM9YEVQVRmchZiYyxQ+8Bi3PXTJz2C4="
         3:HashMap$Node@117 "host":"localhost"
         */
        return headers
    }
    
    private func addSignatureHeader(
        url: URL,
        httpMethod: String) -> HTTPHeaders {
        // Order of the headers are important here for generating correct signature
        let signedHeaderNames = "\(dateHeader);\(hostHeader);\(contentHashHeader)"
        let signedHeaderValues = "" // What is this suppose to be?
        
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
        let signature = stringToSign.generateSHA256(using: accessKey) // Is this right?
        let hmacSHA256Format = "HMAC-SHA256 SignedHeaders=\(signedHeaderNames)&Signature=\(signature)"
        // Example of header: "Authorization":"HMAC-SHA256 SignedHeaders=date;host;x-ms-content-sha256&Signature=PrmeTIq2Ebqwc33tmViNtHuzzN+V+86mXzg5jzg1HTY="
        return ["Authorization": hmacSHA256Format]
    }
}

extension HMACAuthenticationPolicy {
    func sha256(using string: String) -> String {
        if let stringData = string.data(using: .utf8) {
            return hexString(from: digest(input: stringData))
        }

        return ""
    }
    
    func sha256Policy(using data: Data) -> String {
        return hexString(from: digest(input: data))
    }
    
    private func digest(input: Data) -> Data {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        CC_SHA256(input.bytes, UInt32(input.count), &hash)
        return Data(bytes: hash, count: Int(CC_SHA256_DIGEST_LENGTH))
    }
    
    private func hexString(from data: Data) -> String {
        let bytes = data.bytes
        
        var hexString = ""
        for byte in bytes {
            hexString += String(format: "%02hhx", UInt8(byte))
        }
        
        return hexString
    }
}

extension Data {
    var bytes: [UInt8] {
        return [UInt8](self)
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
