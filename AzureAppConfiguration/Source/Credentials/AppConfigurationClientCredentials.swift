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

public class AppConfigurationCredential {
    internal let endpoint: String // endpoint
    internal let id: String // access key id
    internal let secret: String // access key value

    public init(connectionString: String) throws {
        let csComps = connectionString.components(separatedBy: ";")
        guard csComps.count == 3 else {
            let message = "Expected exactly 3 components. Found \(csComps.count)."
            throw HttpResponseError.clientAuthentication(message)
        }
        var endpoint: String?
        var id: String?
        var secret: String?

        for component in connectionString.components(separatedBy: ";") {
            let compSplits = component.split(separator: "=", maxSplits: 1)
            let key = String(compSplits[0]).lowercased()
            let value = String(compSplits[1])
            switch key {
            case "endpoint":
                endpoint = value
            case "id":
                id = value
            case "secret":
                secret = value
            default:
                let message = "Unrecognized connection string component: \(key)"
                throw HttpResponseError.clientAuthentication(message)
            }
        }
        guard endpoint != nil, id != nil, secret != nil else {
            let message = "Invalid connection string: \(connectionString)"
            throw HttpResponseError.clientAuthentication(message)
        }
        self.endpoint = endpoint!
        self.id = id!
        self.secret = secret!
    }
}

public class AppConfigurationAuthenticationPolicy: AuthenticationProtocol {
    public var next: PipelineStageProtocol?
    public let scopes: [String]
    public let credential: AppConfigurationCredential

    public init(credential: AppConfigurationCredential, scopes: [String]) {
        self.scopes = scopes
        self.credential = credential
    }

    public func authenticate(request: PipelineRequest, then completion: @escaping OnRequestCompletionHandler) {
        let httpRequest = request.httpRequest
        let contentHash = try? (httpRequest.data ?? Data()).hash(algorithm: .sha256).base64String
        if let url = URL(string: httpRequest.url) {
            request.httpRequest.headers[HttpHeader.host] = url.host ?? ""
        }
        request.httpRequest.headers[.contentHash] = contentHash
        let dateValue = request.httpRequest.headers[HttpHeader.date] ?? request.httpRequest.headers[.xmsDate]
        if dateValue == nil {
            request.httpRequest.headers[.xmsDate] = Date().rfc1123Format
        }
        sign(request: request)
        completion(request)
    }

    private func sign(request: PipelineRequest) {
        let headers = request.httpRequest.headers
        let signedHeaderKeys = [HttpHeader.xmsDate.rawValue, HttpHeader.host.rawValue, AppConfigurationHeader.contentHash.rawValue]
        var signedHeaderValues = [String]()
        for key in signedHeaderKeys {
            if let value = headers[key] {
                signedHeaderValues.append(value)
            }
        }
        if let urlComps = URLComponents(string: request.httpRequest.url) {
            let stringToRemove = "\(urlComps.scheme!)://\(urlComps.host!)"
            let signingUrl = String(request.httpRequest.url.dropFirst(stringToRemove.count))
            if let decodedSecret = self.credential.secret.decodeBase64 {
                let stringToSign = "\(request.httpRequest.httpMethod.rawValue.uppercased(with: Locale(identifier: "en_US")))\n\(signingUrl)\n\(signedHeaderValues.joined(separator: ";"))"
                let signature = try? stringToSign.hmac(algorithm: .sha256, key: decodedSecret).base64String
                request.httpRequest.headers[.authorization] = "HMAC-SHA256 Credential=\(credential.id), SignedHeaders=\(signedHeaderKeys.joined(separator: ";")), Signature=\(signature ?? "ERROR")"
            }
        }
    }
}
