//
//  ResourceOracle.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCore

public class ResourceOracle {
    
    static var host: String?
    
    fileprivate static let altLinkLookupStorageKey  = "com.azure.data.lookup.altlink"
    fileprivate static let selfLinkLookupStorageKey = "com.azure.data.lookup.selflink"
    
    fileprivate static let slashString: String = "/"
    fileprivate static let slashCharacter: Character = "/"
    fileprivate static let slashCharacterSet: CharacterSet = ["/"]
    
    fileprivate static var altLinkLookup:  [String:String] = [:]
    fileprivate static var selfLinkLookup: [String:String] = [:]

    public static func commit() {
        UserDefaults.standard.set(altLinkLookup,  forKey: altLinkLookupStorageKey)
        UserDefaults.standard.set(selfLinkLookup, forKey: selfLinkLookupStorageKey)
    }
    
    public static func restore() {
        altLinkLookup  = UserDefaults.standard.dictionary(forKey: altLinkLookupStorageKey)  as? [String:String] ?? [:]
        selfLinkLookup = UserDefaults.standard.dictionary(forKey: selfLinkLookupStorageKey) as? [String:String] ?? [:]
    }

    public static func purge() {
        altLinkLookup  = [:]
        selfLinkLookup = [:]
        commit()
    }
    
    
    // MARK: - storeLinks
    
    fileprivate static func _storeLinks(forResource resource: CodableResource) {
        
        if let selfLink = resource.selfLink, let altLink = resource.altLink {
            
            let altLinkSubstrings  = altLink.split(separator: slashCharacter)
            let selfLinkSubstrings = selfLink.split(separator: slashCharacter)
            
            let count = selfLinkSubstrings.count
            
            if count == altLinkSubstrings.count {
                
                var i = 0
                
                while i < count {
                    
                    let altLinkComponent  = altLinkSubstrings.dropLast(i).joined(separator: slashString)
                    let selfLinkComponent = selfLinkSubstrings.dropLast(i).joined(separator: slashString)
                    
                    altLinkLookup[selfLinkComponent] = altLinkComponent
                    selfLinkLookup[altLinkComponent] = selfLinkComponent
                    
                    i += 2
                }
            }
        }
    }
    
    public static func storeLinks(forResource resource: CodableResource) {
        
        _storeLinks(forResource: resource)
        
        commit()
    }
    
    public static func storeLinks<T>(forResources resources: Resources<T>) {
        
        for resource in resources.items {
            _storeLinks(forResource: resource)
        }
        
        commit()
    }


    // MARK: - removeLinks
    
    fileprivate static func _removeLinks(forResource resource: CodableResource) {

        if let selfLink = getSelfLink(forResource: resource) {
            altLinkLookup[selfLink] = nil
        }

        if let altLink = getAltLink(forResource: resource) {
            selfLinkLookup[altLink] = nil
        }
    }

    fileprivate static func _removeLinks(forResourceWithAltLink altLink: String) {
        if let selfLink = selfLinkLookup.removeValue(forKey: altLink) {
            altLinkLookup[selfLink] = nil
        }
    }

    fileprivate static func _removeLinks(forResourceWithSelfLink selfLink: String) {
        if let altLink = altLinkLookup.removeValue(forKey: selfLink) {
            selfLinkLookup[altLink] = nil
        }
    }

    
    public static func removeLinks(forResource resource: CodableResource) {
        
        _removeLinks(forResource: resource)
        
        commit()
    }

    public static func removeLink(forResourceAt location: ResourceLocation)
    {
        if !location.isFeed {
            
            _removeLinks(forResourceWithAltLink: location.link)
            
            commit()
        }
    }
    
    
    // MARK: - Get Links for Resource
    
    public static func getAltLink(forResource resource: CodableResource) -> String? {
        
        var altLink = resource.altLink?.trimmingCharacters(in: slashCharacterSet)
        
        if altLink.isNilOrEmpty, let selfLink = resource.selfLink?.trimmingCharacters(in: slashCharacterSet), !selfLink.isEmpty {
            altLink = altLinkLookup[selfLink]
        }
        
        if let altLink = altLink, !altLink.isEmpty {
            return altLink
        }
        
        return nil
    }
    
    public static func getSelfLink(forResource resource: CodableResource) -> String? {
        
        var selfLink = resource.selfLink?.trimmingCharacters(in: slashCharacterSet)
        
        if selfLink.isNilOrEmpty, let altLink = resource.altLink?.trimmingCharacters(in: slashCharacterSet), !altLink.isEmpty {
            selfLink = selfLinkLookup[altLink]
        }

        if let selfLink = selfLink, !selfLink.isEmpty {
            return selfLink
        }
        
        return nil
    }

    static func getSelfLink(forResourceAt location: ResourceLocation) -> String? {
        
        let altLink = location.link

        if let selfLink = selfLinkLookup[altLink], !selfLink.isEmpty {
            return selfLink
        }
        
        return nil
    }

    
    
    // MARK: - Get Links for Links
    
    public static func getAltLink(forSelfLink selfLink: String) -> String? {
        
        let selfLink = selfLink.trimmingCharacters(in: slashCharacterSet)
        
        guard
            !selfLink.isEmpty,
            let altLink = altLinkLookup[selfLink],
            !altLink.isEmpty
        else { return nil }
        
        return altLink
    }
    
    public static func getSelfLink(forAltLink altLink: String) -> String? {
        
        let altLink = altLink.trimmingCharacters(in: slashCharacterSet)
        
        guard
            !altLink.isEmpty,
            let selfLink = selfLinkLookup[altLink],
            !selfLink.isEmpty
        else { return nil }
        
        return selfLink
    }
    
    
    
    // MARK: - Get resourceId

    public static func getResourceId(forResource resource: CodableResource, withSelfLink selfLink: String? = nil) -> String? {
        
        var resourceId = resource.resourceId
        
        if resourceId.isEmpty, let selfLink = selfLink ?? getSelfLink(forResource: resource), let rId = selfLink.extractId(for: resource.path) {
            resourceId = rId
        }
        
        if !resourceId.isEmpty {
            return resourceId
        }
        
        return nil
    }
    
    static func getResourceId(forResourceAt location: ResourceLocation, withSelfLink selfLink: String? = nil) -> String? {
        
        if let selfLink = selfLink ?? getSelfLink(forResourceAt: location), let resourceId = selfLink.extractId(for: location.type), !resourceId.isEmpty {
            return resourceId
        }
        
        return nil
    }
    
    
    // MARK: - Get File Path
    
    public static func getFilePath(forResource resource: CodableResource) -> (directory:String, file:String)? {
        
        guard
            let selfLink = getSelfLink(forResource: resource),
            let resourceId = getResourceId(forResource: resource, withSelfLink: selfLink)
        else { return nil }
        
        return (selfLink, "\(selfLink)/\(resourceId).json")
    }

    public static func getDirectoryPath(forResource resource: CodableResource) -> String? {
        
        guard
            let selfLink = getSelfLink(forResource: resource)
        else { return nil }
        
        return selfLink
    }

    public static func getFilePath(forResourceAt locaiton: ResourceLocation) -> String? {
        
        guard
            let selfLink = getSelfLink(forResourceAt: locaiton),
            let resourceId = getResourceId(forResourceAt: locaiton, withSelfLink: selfLink)
        else { return nil }
        
        return "\(selfLink)/\(resourceId).json"
    }

    public static func getDirectoryPath(forResourceAt locaiton: ResourceLocation) -> (path:String, resourceId: String)? {
        
        guard
            let selfLink = getSelfLink(forResourceAt: locaiton),
            let resourceId = getResourceId(forResourceAt: locaiton, withSelfLink: selfLink)
        else { return (locaiton.type, "") }
        
        if locaiton.isFeed {
            return (selfLink + "/" + locaiton.type, resourceId)
        }
        
        return (selfLink, resourceId)
    }

    
    public static func printDump() {
        
        log?.debugMessage("\n*****\n*****\n\naltLinkLookup  : \(altLinkLookup.count)\nselfLinkLookup : \(selfLinkLookup.count)\n\n*****\n*****\n")
        
        log?.debugMessage("\n\naltLinkLookup:\n")
        for al in altLinkLookup {
            log?.debugMessage("key   : \(al.key)\nvalue : \(al.value)\n")
        }
        log?.debugMessage("\n\nselfLinkLookup:\n")
        for sl in selfLinkLookup {
            log?.debugMessage("key   : \(sl.key)\nvalue : \(sl.value)\n")
        }
        log?.debugMessage("\n")
    }
}

fileprivate extension String {
    
    func extractId(for resourceType: String) -> String? {
        
        let path = Substring(resourceType)
        
        let split = self.split(separator: "/")
        
        if let key = split.index(of: path), key < split.endIndex {
            return String(split[split.index(after: key)])
        }
        
        return nil
    }
}
