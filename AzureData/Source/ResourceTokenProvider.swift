//
//  ResourceTokenProvider.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCore


struct ResourceToken {
    let date: String
    let token: String
}

class ResourceTokenProvider {
    
    fileprivate let key: String
    fileprivate let mode: PermissionMode
    
    fileprivate let tokenVersion = "1.0"
    fileprivate let dateFormatter: DateFormatter = DateFormat.getHttpDateFormatter()
    
    init(withMasterKey key: String, withPermissionMode mode: PermissionMode) {
        self.key = key
        self.mode = mode
    }
    
    // https://docs.microsoft.com/en-us/rest/api/documentdb/access-control-on-documentdb-resources#constructkeytoken
    fileprivate func _getToken(verb v: HttpMethod, typeString type: String, resourceLink link: String) -> ResourceToken? {
        
        guard v.read || mode == .all else {
            return nil
        }
        
        let date = dateFormatter.string(from: Date())
        
        let payload = "\(v.lowercased)\n\(type)\n\(link)\n\(date.lowercased())\n\n"
        print(payload)
        let signiture = CryptoProvider.hmacSHA256(payload, withKey: key)!
        
        let authString = "type=master&ver=\(tokenVersion)&sig=\(signiture)"
        
        let authStringEncoded = authString.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics)!
        
        return ResourceToken(date: date, token: authStringEncoded)
    }
    
    func getToken(verb v: HttpMethod, resourceType type: ResourceType, resourceLink link: String) -> ResourceToken? {
        return _getToken(verb: v, typeString: type.rawValue, resourceLink: link)
    }
    
    func getToken<T:CodableResource>(_ type: T.Type = T.self, verb v: HttpMethod, resourceLink link: String) -> ResourceToken? {
        return _getToken(verb: v, typeString: type.type, resourceLink: link)
    }
}
 
