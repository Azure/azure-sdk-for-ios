//
//  PermissionProvider.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

public protocol PermissionProvider {
    
    //var configuration: PermissionProviderConfiguration { get }
    
    //init()
    
    //init(with configuration: PermissionProviderConfiguration)
    
    
    func getPermission(forResourceAtAltLink altLink: String, withPermissionMode mode: PermissionMode, callback: @escaping (PermissionProviderResponse) -> ())
    
    func getPermission(forResourceAtSelfLink selfLink: String, withPermissionMode mode: PermissionMode, callback: @escaping (PermissionProviderResponse) -> ())
    
    func getPermission<T:CodableResource>(forResource resource: T, withPermissionMode mode: PermissionMode, callback: @escaping (PermissionProviderResponse) -> ())
}


public struct ExamplePermissionProvider : PermissionProvider {
    
    public var configuration: PermissionProviderConfiguration
    
    public init() {
        self.configuration = PermissionProviderConfiguration.default
    }
    
    public init(with configuration: PermissionProviderConfiguration) {
        self.configuration = configuration
    }

    public func getPermission(forResourceAtAltLink altLink: String, withPermissionMode mode: PermissionMode, callback: @escaping (PermissionProviderResponse) -> ()) {
        
        if let permission = PermissionCache.getPermission(forResourceAtAltLink: altLink), mode == .read || permission.permissionMode == .all {
            callback(PermissionProviderResponse(permission))
        }

        let permission = Permission(withId: "foo", mode: mode, forResource: altLink) // call your webservice and get a Permission
        
        if !PermissionCache.setPermission(permission, forResourceAtAltLink: altLink) {
            callback(PermissionProviderResponse(PermissionProviderError.unsuccessfulCache))
        }
        
        callback(PermissionProviderResponse(permission))
    }
    
    public func getPermission(forResourceAtSelfLink selfLink: String, withPermissionMode mode: PermissionMode, callback: @escaping (PermissionProviderResponse) -> ()) {

        if let permission = PermissionCache.getPermission(forResourceAtSelfLink: selfLink), mode == .read || permission.permissionMode == .all {
            callback(PermissionProviderResponse(permission))
        }
        
        let permission = Permission(withId: "foo", mode: mode, forResource: selfLink) // call your webservice and get a Permission
        
        if !PermissionCache.setPermission(permission, forResourceAtSelfLink: selfLink) {
            callback(PermissionProviderResponse(PermissionProviderError.unsuccessfulCache))
        }
        
        callback(PermissionProviderResponse(permission))
    }
    
    public func getPermission<T>(forResource resource: T, withPermissionMode mode: PermissionMode, callback: @escaping (PermissionProviderResponse) -> ()) where T : CodableResource {

        if let permission = PermissionCache.getPermission(forResource: resource), mode == .read || permission.permissionMode == .all {
            callback(PermissionProviderResponse(permission))
        }
        
        let permission = Permission(withId: "foo", mode: mode, forResource: resource.selfLink!) // call your webservice and get a Permission
        
        if !PermissionCache.setPermission(permission, forResource: resource) {
            callback(PermissionProviderResponse(PermissionProviderError.unsuccessfulCache))
        }
        
        callback(PermissionProviderResponse(permission))
    }
}
