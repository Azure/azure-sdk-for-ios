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

    public static func removeLinks(forResourceWithAltLink altLink: String) {

        _removeLinks(forResourceWithAltLink: altLink)

        commit()
    }
    
    
    // MARK: - Get Parent Links
    
    public static func getAltLink(forParentOfResource resource: CodableResource) -> String? {
        
        return getAltLink(forResource: resource)?.parentLink
    }
    
    public static func getAltLink(forParentOfResourceWithSelfLink selfLink: String) -> String? {

        guard let parentSelfLink = selfLink.parentLink else { return nil }
        
        return getAltLink(forSelfLink: parentSelfLink)
    }

    public static func getAltLink(forAncestorAt resourceType: ResourceType, ofResource resource: CodableResource) -> String? {
        
        return getAltLink(forResource: resource)?.extractLink(for: resourceType)
    }
    
    
    public static func getSelfLink(forParentOfResource resource: CodableResource) -> String? {
        
        return getSelfLink(forResource: resource)?.parentLink
    }
    
    public static func getSelfLink(forParentOfResourceWithAltLink altLink: String) -> String? {

        guard let parentAltLink = altLink.parentLink else { return nil }
        
        return getSelfLink(forAltLink: parentAltLink)
    }
    
    public static func getSelfLink(forAncestorAt resourceType: ResourceType, ofResource resource: CodableResource) -> String? {
        
        return getSelfLink(forResource: resource)?.extractLink(for: resourceType)
    }

    public static func getLink(forParentOfResourceWithLink link: String) -> String? {
        return link.parentLink
    }

    public static func getLink(forAncestorAt resourceType: ResourceType, ofResourceWithLink link: String) -> String? {
        return link.parentLink
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
    
    
    
    // MARK: - Get Ids

    public static func extractResourceId(for resourceType: ResourceType, fromSelfLink selfLink: String) -> String? {
        return selfLink.extractId(for: resourceType)
    }
    
    public static func extractId(for resourceType: ResourceType, fromAltLink altLink: String) -> String? {
        return altLink.extractId(for: resourceType)
    }
    
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
    
    
    // MARK: - Get File Path
    
    public static func getFilePath(forResource resource: CodableResource) -> String? {
        
        guard
            let selfLink = getSelfLink(forResource: resource),
            let resourceId = getResourceId(forResource: resource, withSelfLink: selfLink)
        else { return nil }
        
        return "\(selfLink)/\(resourceId).json"
    }
    
    
    public static func printDump() {
        
        print("\n*****\n*****\n\naltLinkLookup  : \(altLinkLookup.count)\nselfLinkLookup : \(selfLinkLookup.count)\n\n*****\n*****\n")
        
        print("\n\naltLinkLookup:\n")
        for al in altLinkLookup {
            print("key   : \(al.key)\nvalue : \(al.value)\n")
        }
        print("\n\nselfLinkLookup:\n")
        for sl in selfLinkLookup {
            print("key   : \(sl.key)\nvalue : \(sl.value)\n")
        }
        print("\n")
    }
}

fileprivate extension String {
    
    var lastPathComponent: String? {
        
        if let selfSubstring = self.split(separator: "/").last, !selfSubstring.isEmpty  {
            return String(selfSubstring)
        }
        
        return nil
    }
    
    var parentLink: String? {
        
        let selfSubstrings = self.split(separator: "/")
        
        guard selfSubstrings.count > 2 else { return nil }
        
        return selfSubstrings.dropLast(2).joined(separator: "/")
    }

    func extractLink(for resourceType: String) -> String? {
        
        let path = Substring(resourceType)
        
        let split = self.split(separator: "/")
        
        //  0            1             2               3             4          5
        // dbs/DocumentTestsDatabase/colls/DocumentTestsCollection/docs/DocumentTestsDocument
        
        if let key = split.index(of: path), key < split.endIndex {
            
            let drop = split.endIndex - split.index(after: key)
            
            return split.dropLast(drop).joined(separator: "/")
        }
        
        return nil
    }
    
    func extractId(for resourceType: String) -> String? {
        
        let path = Substring(resourceType)
        
        let split = self.split(separator: "/")
        
        if let key = split.index(of: path), key < split.endIndex {
            return String(split[split.index(after: key)])
        }
        
        return nil
    }

    func extractLink(for resourceType: ResourceType) -> String? {
        return self.extractLink(for: resourceType.path)
    }
    
    func extractId(for resourceType: ResourceType) -> String? {
        return self.extractId(for: resourceType.path)
    }
}

fileprivate extension CodableResource {
    
    func extractResourceIdFromSelfLink() -> String? {
        
        guard let link = self.selfLink, !link.isEmpty else { return nil }
        
        return link.extractId(for: Self.type)
    }
    
    func extractIdFromAltLink() -> String? {
        
        guard let link = self.altLink, !link.isEmpty else { return nil }
        
        return link.extractId(for: Self.type)
    }
}
