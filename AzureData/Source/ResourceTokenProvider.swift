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
    func getToken(forResourceAt location: ResourceLocation, andMethod method: HttpMethod) -> ResourceToken? {
        
        guard method.read || mode == .all else { return nil }
        
        let date = dateFormatter.string(from: Date())
        
        let payload = "\(method.lowercased)\n\(location.type)\n\(location.link)\n\(date.lowercased())\n\n"

        let signature = CryptoProvider.hmacSHA256(payload, withKey: key)!
        
        let authString = "type=master&ver=\(tokenVersion)&sig=\(signature)"
        
        let authStringEncoded = authString.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics)!
        
        return ResourceToken(date: date, token: authStringEncoded)
    }
}
