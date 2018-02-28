////
////  Token.swift
////  AzureData
////
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
////
//
//import Foundation
//
//public enum TokenPermissions {
//    case read
//    case readWrite
//}
//
//
//public enum TokenPermissionsLevel {
//    case account
//    case database
//    case collection
//    case resource
//}
//
//
//public struct Token {
//    
//    static let TokenRefreshSeconds = 600
//    
//    let token: String
//    
//    let tokenType: TokenType
//    
//    let permissions: TokenPermissions
//    
//    let permissionLevel: TokenPermissionsLevel
//    
//    let resourceLink: String? // dbs/ToDoList/colls/Lists
//    
//    let resourceSelfLink: String? // dbs/PD5DAA==/colls/PD5DALigDgw=/
//    
//    let duration: Double? // token liftime in seconds
//    
//    let expiration: Date? // private set based on duration
//    
//    var isValid: Bool {
//        return true
//        //return isMaster || expiration.subtract (Date()).seconds > TokenRefreshSeconds
//    }
//    
//    var isMaster: Bool {
//        return permissionLevel == .account
//    }
//    
//    
////    init()
//    // resourceLink, resourceSelfLink, duration, expiration can only be nil if permissionLevel == .account
//    
//    // equals
//    // return if resourceLink == string || resourceSelfLink == string
//    
//    // init ()
//}
//
//
//public protocol TokenProviderConfiguring {
//    
//}
//
//
//public struct TokenProviderConfiguration {
//    
//    static let `default`: TokenProviderConfiguration = TokenProviderConfiguration()
//    
//    // get readWrite token even for read operations to prevent scenario of
//    // getting a read token for a read operation then subsequently performing
//    // a write operation on the same resource requiring another round trip to
//    // server to get a token with write permissions.
//    //
//    // if this is set to true, should always request a readWrite token from server
//    //
//    // default: true
//    var alwaysGetWriteToken: Bool = true
//    
//    // this specifies the at what level of the resource hierarchy
//    // (Database/Collection/Document) to request a resource token
//    //
//    // for example, if this property is set to .collection and the user tries to
//    // write to a document, we'd request a readWrite resource token for the
//    // entire collection versus requesting a token only for the document
//    //
//    // default: .collection
//    var tokenResourceLevel: TokenPermissionsLevel = .collection
//}
//
//
//
//open class XTokenProvider {
//    
//    var tokens: [String:Token] = [:]
//    var tokenArr: [Token] = []
//    
//    
//    func GetToken(forResourceLink link: String, withPermissions permissions: TokenPermissions) -> Token {
//        
//        if let t = tokenArr.first(where: { ($0.resourceLink == link || $0.resourceSelfLink == link) && ($0.permissions == .readWrite || $0.permissions == permissions) }) {
//            
//        }
//        
//        // check for master key
//        
//        if let token = tokens[link], permissions == .read || token.permissions == permissions {
//            
//            // check expiration
//            return token
//        }
//    }
//    
//    init(config: TokenProviderConfiguration = TokenProviderConfiguration.default)
//    
//    init(tokens: [Token], config: TokenProviderConfiguration = TokenProviderConfiguration.default)
//}
//
//
//
//
//
//
//
//
//
//
