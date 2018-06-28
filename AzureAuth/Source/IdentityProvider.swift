//
//  IdentityProvider.swift
//  AzureAuth
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

public enum IdentityProvider {
    case aad(accessToken: String)
    case microsoft
    case facebook(tokenString: String)
    case google(idToken: String, serverAuthCode: String)
    case twitter(authToken: String, authTokenSecret: String)
    //case custom()
    
    public var name: String {
        switch self {
        case .aad:       return "aad"
        case .microsoft: return "microsoft"
        case .facebook:  return "facebook"
        case .google:    return "google"
        case .twitter:   return "twitter"
        }
    }
    
    public var displayName: String {
        switch self {
        case .aad:       return "AAD"
        case .microsoft: return "Microsoft"
        case .facebook:  return "Facebook"
        case .google:    return "Google"
        case .twitter:   return "Twitter"
        }
    }
    
    public var tokenPath: String {
        return ".auth/login/" + name
    }
    
    static var refreshPath: String {
        return ".auth/refresh"
    }
    
    public var payloadDict: [String:String] {
        switch self {
        case let .aad(accessToken):                     return [ "access_token" : accessToken ]
        case let .facebook(tokenString):                return [ "access_token" : tokenString ]
        case let .google(idToken, serverAuthCode):      return [ "id_token" : idToken, "authorization_code" : serverAuthCode ]
        case let .twitter(authToken, authTokenSecret):  return [ "access_token" : authToken, "access_token_secret" : authTokenSecret ]
        default: return [:]
        }
    }
    
    public func payload() throws -> Data {
        return try JSONEncoder().encode(payloadDict)
    }
    
    var keychainId: String {
        return "authprovider." + name
    }
}
