//
//  AppConfigurationClientCredentials.swift
//  DemoAppObjC
//
//  Created by Travis Prescott on 8/8/19.
//  Copyright © 2019 Travis Prescott. All rights reserved.
//

import AzureCore
import Foundation

@objc
class AppConfigurationClientCredentials: NSObject {
    let credentials: CredentialInformation
    let headerProvider: AuthorizationHeaderProvider
    var baseUri: URL? {
        return self.credentials.baseUri
    }
    
    @objc init(withConnectionString connectionString: String) throws {
        self.credentials = try CredentialInformation.init(withConnectionString: connectionString)
        self.headerProvider = AuthorizationHeaderProvider.init(withCredentials: self.credentials)
    }
    
    func getAuthorizationheaders(url: URL, httpMethod: String, contents: Data?) -> [String: String] {
        let bytes = [UInt8](contents ?? Data())
        let digest = bytes.sha256
        return self.headerProvider.getAuthenticationHeaders(url: url, httpMethod: httpMethod, messageDigest: digest)
    }
    
    class CredentialInformation {
        var baseUri: URL?       // endpoint
        var id: String?         // access key id
        var secret: String?     // access key value
        
        init(withConnectionString connectionString: String) throws {
            let cs_comps = connectionString.components(separatedBy: ";")
            guard cs_comps.count == 3 else {
                throw AzureError.credentialError
            }
            
            for component in connectionString.components(separatedBy: ";") {
                let comp_splits = component.split(separator: "=", maxSplits: 1)
                let key = String(comp_splits[0])
                let value = String(comp_splits[1])
                
                switch key.lowercased() {
                case "endpoint":
                    self.baseUri = URL(string: value)
                case "id":
                    self.id = value
                case "secret":
                    self.secret = value
                default:
                    throw AzureError.credentialError
                }
            }
            guard baseUri != nil, id != nil, secret != nil else { throw AzureError.credentialError }
        }
    }
    
    class AuthorizationHeaderProvider {
        let credentials: CredentialInformation
        
        init(withCredentials credentials: CredentialInformation) {
            self.credentials = credentials
        }
        
        func getAuthenticationHeaders(url: URL, httpMethod: String, messageDigest: [UInt8]) -> [String: String] {
            var headers = [String: String]()
            let contentHash = messageDigest.base64String
            headers[HttpHeader.host.rawValue] = url.host ?? ""
            headers[HttpHeader.contentHash.rawValue] = contentHash
            if headers[HttpHeader.date.rawValue] == nil {
                headers[HttpHeader.date.rawValue] = Date().httpFormat
            }
            headers = self.addSignatureHeader(url: url, httpMethod: httpMethod, headers: headers)
            return headers
        }

        func addSignatureHeader(url: URL, httpMethod: String, headers: [String: String]) -> [String: String] {
            var newHeaders = headers
            let signedHeaderKeys = [HttpHeader.date.rawValue, HttpHeader.host.rawValue, HttpHeader.contentHash.rawValue]
            var signedHeaderValues = [String]()
            for key in signedHeaderKeys {
                guard newHeaders[key] != nil else {
                    continue
                }
                signedHeaderValues.append(newHeaders[key]!)
            }
            
            var pathAndQuery = url.path
            if let query = url.query {
                pathAndQuery += "?" + query
            }
            if let decodedSecret = self.credentials.secret?.decodeBase64 {
                let stringToSign = httpMethod.uppercased(with: Locale.init(identifier: "en_US")) + "\n" + pathAndQuery + "\n" + signedHeaderValues.joined(separator: ";")
                let signature = stringToSign.hmac(algorithm: .sha256, key: decodedSecret)
                newHeaders[HttpHeader.authorization.rawValue] = "HMAC-SHA256 Credential=\(self.credentials.id!), SignedHeaders=\(signedHeaderKeys.joined(separator: ";")), Signature=\(signature.base64String)"
            }
            return newHeaders
        }
    }
}
