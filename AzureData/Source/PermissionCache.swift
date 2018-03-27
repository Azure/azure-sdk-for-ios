//
//  PermissionCache.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

public class PermissionCache {
    
    fileprivate static let permissionCacheStorageKey  = "com.azure.data.lookup.altlink"

    fileprivate static let slashCharacterSet: CharacterSet = ["/"]

    
    // Key is based on altLink
    fileprivate static var cache: [String:Permission] = [:]
    
    
    public static func commit() {
        // TODO: save cache to keychain
    }
    
    public static func restore() {
        // TODO: restore cache from keychain
    }
    
    public static func purge() {
        cache = [:]
        commit()
    }
    

    // MARK: - Get Permission
    
    public static func getPermission(forResourceAtAltLink altLink: String) -> Permission? {
        
        let altLink = altLink.trimmingCharacters(in: slashCharacterSet)
        
        if !altLink.isEmpty {
            return cache[altLink]
        }
        
        return nil
    }
    
    public static func getPermission(forResource resource: CodableResource) -> Permission? {
        
        if let altLink = ResourceOracle.getAltLink(forResource: resource) {
            return cache[altLink]
        }
        
        return nil
    }

    public static func getPermission(forResourceAtSelfLink selfLink: String) -> Permission? {
        
        if let altLink = ResourceOracle.getAltLink(forSelfLink: selfLink) {
            return cache[altLink]
        }
        
        return nil
    }

    
    // MARK: - Set Permission
    
    public static func setPermission(_ permission: Permission, forResourceAtAltLink altLink: String) -> Bool {
        
        let altLink = altLink.trimmingCharacters(in: slashCharacterSet)
        
        if !altLink.isEmpty {
            cache[altLink] = permission
            return true
        }
        
        return false
    }

    public static func setPermission(_ permission: Permission, forResource resource: CodableResource) -> Bool {
        
        if let altLink = ResourceOracle.getAltLink(forResource: resource) {
            cache[altLink] = permission
            return true
        }
        
        return false
    }

    public static func setPermission(_ permission: Permission, forResourceAtSelfLink selfLink: String) -> Bool {
        
        if let altLink = ResourceOracle.getAltLink(forSelfLink: selfLink) {
            cache[altLink] = permission
            return true
        }
        
        return false
    }
}
