//
//  AuthUser.swift
//  AzureAuth
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

public struct AuthUser: Codable {
    
    public var user: User
    
    public var userId: String? { return user.userId }
    
    public var authenticationToken: String
    
    public struct User: Codable {
        
        public var userId: String?
    }
}
