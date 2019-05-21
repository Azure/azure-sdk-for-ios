//
//  PermissionCache.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCore

public class PermissionCache {
    
    fileprivate static let permissionCacheStorageKey  = "com.azure.data.permissioncache"

    fileprivate static let slashCharacterSet: CharacterSet = ["/"]

    
    // Key is altLink
    fileprivate static var cache: [String:Permission] = [:]
    
    
    public static var isRestored: Bool = false
    
    
    public static func commit() {
        if let data = try? JSONEncoder().encode(cache) {
            try? Keychain.saveDataToKeychain(data, withKey: permissionCacheStorageKey)
        }
    }
    
    public static func restore() {
        if let data = try? Keychain.getDataFromKeychain(forKey: permissionCacheStorageKey),
           let dict = try? JSONDecoder().decode([String:Permission].self, from: data) {
            cache = dict
        }
        isRestored = true
    }
    
    public static func purge() {
        cache = [:]
        commit()
    }
    

    
    
    // MARK: - Get Permission
    
    public static func getPermission(for resource: CodableResource) -> Permission? {
        
        if let altLink = ResourceOracle.getAltLink(forResource: resource) {
            return cache[altLink]
        }
        
        return nil
    }

    public static func getPermission(forResourceWithAltLink altLink: String) -> Permission? {
        
        let altLink = altLink.trimmingCharacters(in: slashCharacterSet)
        
        if !altLink.isEmpty {
            return cache[altLink]
        }
        
        return nil
    }

    
    // MARK: - Set Permission
    
    public static func setPermission(_ permission: Permission, for resource: CodableResource) -> Bool {
        
        if let altLink = ResourceOracle.getAltLink(forResource: resource) {
            return setPermission(permission, forResourceWithAltLink: altLink)
        }
        
        return false
    }

    public static func setPermission(_ permission: Permission, forResourceWithAltLink altLink: String) -> Bool {
        
        let altLink = altLink.trimmingCharacters(in: slashCharacterSet)
        
        if !altLink.isEmpty {
            cache[altLink] = permission
            commit()
            return true
        }
        
        return false
    }
    
    
    public static func printDump() {
        
        Log.debug("\n*****\n*****\n\ncount  : \(cache.count)\n\n*****\n*****\n")
        
        Log.debug("\n\ncache:\n")
        for c in cache {
            Log.debug("key   : \(c.key)\nvalue : \(c.value)\n")
        }
        Log.debug("\n")
    }
}
