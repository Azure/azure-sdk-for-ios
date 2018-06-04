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
    
    static var host: String!
    
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

    static func store(selfLink: String?, forAltLink altLink: String?) {
        guard let selfLink = selfLink, let altLink = altLink else { return }

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

        commit()
    }

    fileprivate static func _storeLinks(forResource resource: CodableResource) {
        store(selfLink: resource.selfLink, forAltLink: resource.altLink)
    }
    
    public static func storeLinks(forResource resource: CodableResource) {
        
        _storeLinks(forResource: resource)
        
        commit()
    }
    
    public static func storeLinks<T: CodableResources>(forResources resources: T) {
        
        for resource in resources.items {
            _storeLinks(forResource: resource)
        }
        
        commit()
    }


    // MARK: - removeLinks

    fileprivate static func _removeLinks(forAltLink altLink: String?, andSelfLink selfLink: String?) {
        
        if let altLink = altLink, !altLink.isEmpty {
            selfLinkLookup = selfLinkLookup.filter { !$0.key.contains(altLink) }
        }
        
        if let selfLink = selfLink, !selfLink.isEmpty {
            altLinkLookup = altLinkLookup.filter { !$0.key.contains(selfLink) }
        }
    }

    fileprivate static func _removeLinks(forResource resource: CodableResource) {
        _removeLinks(forAltLink: getAltLink(forResource: resource), andSelfLink: getSelfLink(forResource: resource))
    }

    fileprivate static func _removeLinks(forResourceWithAltLink altLink: String) {
        _removeLinks(forAltLink: altLink, andSelfLink: selfLinkLookup[altLink])
    }

    static func removeLinks(forResourceWithSelfLink selfLink: String) {
        _removeLinks(forAltLink: altLinkLookup[selfLink], andSelfLink: selfLink)
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

    public static func getFilePath(forResourceAt location: ResourceLocation) -> String? {
        
        guard
            let selfLink = getSelfLink(forResourceAt: location),
            let resourceId = getResourceId(forResourceAt: location, withSelfLink: selfLink)
        else { return nil }
        
        return "\(selfLink)/\(resourceId).json"
    }

    public static func getDirectoryPath(forResourceAt location: ResourceLocation) -> (path:String, resourceId: String)? {

        guard let selfLink = getSelfLink(forResourceAt: location) else { return (location.type, "") }

        let resourceId = getResourceId(forResourceAt: location, withSelfLink: selfLink)

        if location.isFeed {
            return (selfLink + "/" + location.type, resourceId.valueOrEmpty)
        }

        return (selfLink, resourceId.valueOrEmpty)
    }

    public static func printDump() {
        Log.debug("************************************************************")
        Log.debug("************************************************************")
        Log.debug("altLinkLookup  : \(altLinkLookup.count)")
        Log.debug("selfLinkLookup : \(selfLinkLookup.count)")
        Log.debug("")
        Log.debug("altLinkLookup:")
        for al in altLinkLookup {
            Log.debug("key   : \(al.key)")
            Log.debug("value : \(al.value)")
        }
        Log.debug("")
        Log.debug("selfLinkLookup:")
        for sl in selfLinkLookup {
            Log.debug("key   : \(sl.key)")
            Log.debug("value : \(sl.value)")
        }
        Log.debug("")
        Log.debug("\n")
    }
}
