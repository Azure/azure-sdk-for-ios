//
//  TokenProvider.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCore

public enum TokenType: String {
    case master = "master"
    case resource = "resource"
}

public enum TokenError : Error {
    case base64KeyError
}

public class TokenProvider {
    
    let key: String
    let keyType: String
    let tokenVersion: String
    
    let dateFormatter: DateFormatter = DateFormat.getHttpDateFormatter()
    
    
    public init(key k: String, keyType type: TokenType = .master, tokenVersion version: String = "1.0") {
        key = k
        keyType = type.rawValue
        tokenVersion = version
    }
    
    // https://docs.microsoft.com/en-us/rest/api/documentdb/access-control-on-documentdb-resources#constructkeytoken
    public func getToken(verb v: HttpMethod, resourceType type: ResourceType, resourceLink link: String) -> (String, String) {
        
        let verb = v.rawValue
        let resourceType = type.rawValue
        let resourceLink = link
        
        let dateString = dateFormatter.string(from: Date())
        
        let payload = "\(verb.lowercased())\n\(resourceType.lowercased())\n\(resourceLink)\n\(dateString.lowercased())\n\n"
        
        let signiture = CryptoProvider.hmacSHA256(payload, withKey: key)!
        
        let authString = "type=\(keyType)&ver=\(tokenVersion)&sig=\(signiture)"
        
        let authStringEncoded = authString.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics)!
        
        return (authStringEncoded, dateString)
    }
    
    
    public func getToken<T:CodableResource>(_ type: T.Type = T.self, verb v: HttpMethod, resourceLink link: String) -> (String, String) {
        
        let verb = v.rawValue
        let resourceType = type.type
        let resourceLink = link

        let dateString = dateFormatter.string(from: Date())

        let payload = "\(verb.lowercased())\n\(resourceType.lowercased())\n\(resourceLink)\n\(dateString.lowercased())\n\n"
        
        let signiture = CryptoProvider.hmacSHA256(payload, withKey: key)!
        
        let authString = "type=\(keyType)&ver=\(tokenVersion)&sig=\(signiture)"
        
        let authStringEncoded = authString.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics)!
        
        return (authStringEncoded, dateString)
    }
}
