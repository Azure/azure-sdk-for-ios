//
//  CodableResource.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Represents a resource type in the Azure Cosmos DB service.
/// All Azure Cosmos DB resources, such as `Database`, `DocumentCollection`, and `Document` implement this protocal.
public protocol CodableResource : Codable {
    
    static var type:String  { get }
    static var list:String  { get }
    
    /// Gets or sets the Id of the resource in the Azure Cosmos DB service.
    var id: String  { get }
    
    /// Gets or sets the Resource Id associated with the resource in the Azure Cosmos DB service.
    var resourceId: String  { get }
    
    /// Gets the self-link associated with the resource from the Azure Cosmos DB service.
    var selfLink: String? { get }
    
    /// Gets the entity tag associated with the resource from the Azure Cosmos DB service.
    var etag: String? { get }
    
    /// Gets the last modified timestamp associated with the resource from the Azure Cosmos DB service.
    var timestamp: Date?   { get }
    
    /// Gets the alt-link associated with the resource from the Azure Cosmos DB service.
    var altLink: String? { get }
    
    mutating func setAltLink(to link: String)
    
    mutating func setEtag(to tag: String)
}

fileprivate struct ResourceValidation {
    static let maximumIdLength: Int = 255
    static let invalidIdCharacters: CharacterSet = CharacterSet.whitespacesAndNewlines.union([ "/", "?", "#" ])
}

extension CodableResource {
    
    public var path: String {
        return Self.type
    }
    
    public var resourceType: ResourceType? {
        return ResourceType(rawValue: Self.type)
    }
    
    public var hasValidId: Bool {
        return self.id.isValidIdForResource
    }
    
    public mutating func setAltLink(withContentPath path: String?) {
        let pathComponent = path.isNilOrEmpty ? Self.type : "\(path!)/\(Self.type)"
        self.setAltLink(to: "\(pathComponent)/\(id)")
    }
    
    public func ancestorIds(includingSelf: Bool = false) -> [ResourceType:String] {
        
        var ancestors: [ResourceType:String] = [:]
        
        if let split = self.altLink?.split(separator: "/") {
            
            for ancestor in ResourceType.ancestors {
                
                let ancestorPath = Substring(ancestor.path)
                
                if let key = split.firstIndex(of: ancestorPath), key < split.endIndex {
                     ancestors[ancestor] = String(split[split.index(after: key)])
                }
            }
        }
        
        if includingSelf {
            ancestors[ResourceType(rawValue: Self.type)!] = self.id
        }
        
        return ancestors
    }
}

extension String {

    var isValidIdForResource: Bool {
        
        let validLength = self.count < ResourceValidation.maximumIdLength
        let validCharacters = self.rangeOfCharacter(from: ResourceValidation.invalidIdCharacters) == nil
        
        return validLength && validCharacters
    }
}
