//
//  AzureAuth.swift
//  AzureAuth
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCore

public class AzureAuth {
    
    public static var user: AuthUser? {
        return AuthClient.shared.user
    }
    
    public static func authHeader() throws -> (key:String, value:String) {
        return try AuthClient.shared.authHeader()
    }
    
    public static func login(to service: URL, with provider: IdentityProvider, completion: @escaping (Response<AuthUser>) -> Void) {
        return AuthClient.shared.login(to: service, with: provider, completion: completion)
    }
    
    public static func refresh(for service: URL, completion: @escaping (Response<AuthUser>) -> Void) {
        return AuthClient.shared.refresh(for: service, completion: completion)
    }
}


extension URLRequest {
    public mutating func addAuthHeader() throws {
        let header = try AuthClient.shared.authHeader()
        addValue(header.value, forHTTPHeaderField: header.key)
    }
}
