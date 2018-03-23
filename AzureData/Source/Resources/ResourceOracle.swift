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
    
    
    public static func getAltLink(forResource resource: CodableResource) -> String? {
        
        var altLink = resource.altLink
        
        if altLink.isNilOrEmpty, let selfLink = resource.selfLink, !selfLink.isEmpty {
            altLink = altLinkLookup[selfLink]
        }
        
        if let altLink = altLink?.trimmingCharacters(in: slashCharacterSet), !altLink.isEmpty {
            return altLink
        }
        
        return nil
    }

    
    public static func getSelfLink(forResource resource: CodableResource) -> String? {
        
        var selfLink = resource.selfLink
        
        if selfLink.isNilOrEmpty, let altLink = resource.altLink, !altLink.isEmpty {
            selfLink = selfLinkLookup[altLink]
        }

        if let selfLink = selfLink?.trimmingCharacters(in: slashCharacterSet), !selfLink.isEmpty {
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
        
        if let selfLink = getSelfLink(forResource: resource), let resourceId = getResourceId(forResource: resource, withSelfLink: selfLink) {
            return "\(selfLink)/\(resourceId).json"
        }

        return nil
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
