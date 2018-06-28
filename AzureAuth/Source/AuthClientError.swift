//
//  AuthClientError.swift
//  AzureAuth
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

enum AuthClientError: Error {
    case unknown
    case expectedToken
    case invalidToken
    case expectedBodyWithResponse
    case invalidResponseSyntax
    case noCurrentUser
    
    var localizedDescription: String {
        switch self {
        case .unknown:                  return "Unknown"
        case .expectedToken:            return "No token was provided."
        case .invalidToken:             return "The token provided was not valid."
        case .expectedBodyWithResponse: return "The server did not return any data."
        case .invalidResponseSyntax:    return "The token in the login response was invalid. The token must be a JSON object with both a userId and an authenticationToken."
        case .noCurrentUser:            return "No current user set.  Must call login() before requesting using the authHeader property."
        }
    }
}
