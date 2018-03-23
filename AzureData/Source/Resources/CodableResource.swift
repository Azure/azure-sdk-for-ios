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
}

extension CodableResource {
    
    public mutating func setAltLink(withContentPath path: String?) {
        let pathComponent = path.isNilOrEmpty ? Self.type : "\(path!)/\(Self.type)"
        self.setAltLink(to: "\(pathComponent)/\(id)")
    }
}


extension CodableResource {
    
    static func fragment (_ resourceId: String? = nil) -> String {
        return resourceId.isNilOrEmpty ? Self.type : "\(Self.type)/\(resourceId!)"
    }
    
    static func path (fromParent parentPath: String? = nil, resourceId: String? = nil) -> String {
        return parentPath.isNilOrEmpty ? fragment(resourceId) : "\(parentPath!)/\(fragment(resourceId))"
    }
    
    static func link (fromParentPath parentPath: String? = nil, resourceId: String? = nil) -> String {
        return resourceId.isNilOrEmpty ? parentPath ?? "" : path(fromParent: parentPath, resourceId: resourceId)
    }
    
    static func link (fromParentSelfLink parentSelf: String, resourceId: String? = nil) -> String {
        return resourceId.isNilOrEmpty ? String((parentSelf).split(separator: "/").last!).lowercased() : resourceId!.lowercased()
    }
    
    func resourceUri (forHost host: String) -> (URL, String)? {
        return self.selfLink.isNilOrEmpty ? nil : (URL(string: "\(host)/\(self.selfLink!)")!, self.resourceId.lowercased())
    }
//    public var link: String {
//        self.selfLink?.split(separator: "/")
//        // dbs/TC1AAA==/colls/TC1AAMDvwgA=/docs/TC1AAMDvwgBQAAAAAAAAAA==/
//    }
    
    static func url (atHost host: String, at path: String = Self.type) -> URL? {
        return URL(string: "https://\(host)/\(path)")
    }
}
