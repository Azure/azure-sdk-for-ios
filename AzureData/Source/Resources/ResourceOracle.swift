//
//  ResourceOracle.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

public class ResourceOracle {
    
    fileprivate static let slashString: String = "/"
    fileprivate static let slashCharacter: Character = "/"
    fileprivate static let slashCharacterSet: CharacterSet = ["/"]
    

    fileprivate static var altLinkLookup:  [String:String] = [:]
    fileprivate static var selfLinkLookup: [String:String] = [:]

    
    public static func storeLinks(forResource resource: CodableResource) {
        
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
    
    
    public static func getParentAltLink(forResource resource: CodableResource) -> String? {

        guard
            let altLink = getAltLink(forResource: resource)
        else { return nil }

        let altLinkSubstrings = altLink.split(separator: slashCharacter)
        
        guard
            altLinkSubstrings.count > 2
        else { return nil }
        
        return altLinkSubstrings.dropLast(2).joined(separator: slashString)
    }
    
    
    public static func getParentSelfLink(forResource resource: CodableResource) -> String? {
        
        guard
            let selfLink = getSelfLink(forResource: resource)
        else { return nil }
        
        let selfLinkSubstrings = selfLink.split(separator: slashCharacter)
        
        guard
            selfLinkSubstrings.count > 2
        else { return nil }
        
        return selfLinkSubstrings.dropLast(2).joined(separator: slashString)
    }
    
    
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

    
    public static func getResourceId(forResource resource: CodableResource, withSelfLink selfLink: String? = nil) -> String? {
        
        var resourceId = resource.resourceId
        
        if resourceId.isEmpty, let selfLink = selfLink ?? getSelfLink(forResource: resource), let selfLinkSubstring = selfLink.split(separator: slashCharacter).last {
            resourceId = String(selfLinkSubstring)
        }

        if !resourceId.isEmpty {
            return resourceId
        }
        
        return nil
    }
    
    
    public static func getFilePath(forResource resource: CodableResource) -> String? {
        
        guard
            let selfLink = getSelfLink(forResource: resource),
            let resourceId = getResourceId(forResource: resource, withSelfLink: selfLink)
        else { return nil }
        
        return "\(selfLink)/\(resourceId).json"
    }
    
    
    public static func printDump() {
        print("")
        print("")
        print("altLinkLookup:")
        print("")
        for al in altLinkLookup {
            print("key   : \(al.key)")
            print("value : \(al.value)")
            print("")
        }
        print("")
        print("")
        print("selfLinkLookup:")
        print("")
        for sl in selfLinkLookup {
            print("key   : \(sl.key)")
            print("value : \(sl.value)")
            print("")

        }
        print("")
        print("")
    }
}
