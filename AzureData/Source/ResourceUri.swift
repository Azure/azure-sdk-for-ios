//
//  ResourceUri.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

// https://docs.microsoft.com/en-us/rest/api/documentdb/documentdb-resource-uri-syntax-for-rest
public struct ResourceUri {
    let empty = ""
    
    let baseUri: String
    
    init(forAccountNamed databaseaccount: String) {
        baseUri = "https://\(databaseaccount).documents.azure.com"
    }

    init(forAccountAt databaseurl: URL) {
        baseUri = databaseurl.absoluteString
    }
    
    func database(_ resourceId: String? = nil) -> (URL, String) {
        let baseLink = ""
        let itemLink = getItemLink(forType: .database, baseLink: baseLink, resourceId: resourceId)
        return getUrlLink(baseLink: baseLink, itemLink: itemLink, resourceId: resourceId)
    }
    
    func user(_ databaseId: String, userId resourceId: String? = nil) -> (URL, String) {
        let baseLink = "dbs/\(databaseId)"
        let itemLink = getItemLink(forType: .user, baseLink: baseLink, resourceId: resourceId)
        return getUrlLink(baseLink: baseLink, itemLink: itemLink, resourceId: resourceId)
    }
    
    func permission(_ databaseId: String, userId: String, permissionId resourceId: String? = nil) -> (URL, String) {
        let baseLink = "dbs/\(databaseId)/users/\(userId)"
        let itemLink = getItemLink(forType: .permission, baseLink: baseLink, resourceId: resourceId)
        return getUrlLink(baseLink: baseLink, itemLink: itemLink, resourceId: resourceId)
    }

    func permission(atLink baseLink: String, withResourceId resourceId: String? = nil) -> (URL, String) {
        let itemLink = getItemLink(forType: .permission, baseLink: baseLink, resourceId: resourceId)
        return getUrlLinkForSelf(baseLink: baseLink, itemLink: itemLink, resourceId: resourceId)
    }

    
    func collection(_ databaseId: String, collectionId resourceId: String? = nil) -> (URL, String) {
        let baseLink = "dbs/\(databaseId)"
        let itemLink = getItemLink(forType: .collection, baseLink: baseLink, resourceId: resourceId)
        return getUrlLink(baseLink: baseLink, itemLink: itemLink, resourceId: resourceId)
    }
    
    func storedProcedure(_ databaseId: String, collectionId: String, storedProcedureId resourceId: String? = nil) -> (URL, String) {
        let baseLink = "dbs/\(databaseId)/colls/\(collectionId)"
        let itemLink = getItemLink(forType: .storedProcedure, baseLink: baseLink, resourceId: resourceId)
        return getUrlLink(baseLink: baseLink, itemLink: itemLink, resourceId: resourceId)
    }

    func storedProcedure(atLink baseLink: String, withResourceId resourceId: String? = nil) -> (URL, String) {
        let itemLink = getItemLink(forType: .storedProcedure, baseLink: baseLink, resourceId: resourceId)
        return getUrlLinkForSelf(baseLink: baseLink, itemLink: itemLink, resourceId: resourceId)
    }

    func trigger(_ databaseId: String, collectionId: String, triggerId resourceId: String? = nil) -> (URL, String) {
        let baseLink = "dbs/\(databaseId)/colls/\(collectionId)"
        let itemLink = getItemLink(forType: .trigger, baseLink: baseLink, resourceId: resourceId)
        return getUrlLink(baseLink: baseLink, itemLink: itemLink, resourceId: resourceId)
    }

    func trigger(atLink baseLink: String, withResourceId resourceId: String? = nil) -> (URL, String) {
        let itemLink = getItemLink(forType: .trigger, baseLink: baseLink, resourceId: resourceId)
        return getUrlLinkForSelf(baseLink: baseLink, itemLink: itemLink, resourceId: resourceId)
    }

    func udf(_ databaseId: String, collectionId: String, udfId resourceId: String? = nil) -> (URL, String) {
        let baseLink = "dbs/\(databaseId)/colls/\(collectionId)"
        let itemLink = getItemLink(forType: .udf, baseLink: baseLink, resourceId: resourceId)
        return getUrlLink(baseLink: baseLink, itemLink: itemLink, resourceId: resourceId)
    }

    func udf(atLink baseLink: String, withResourceId resourceId: String? = nil) -> (URL, String) {
        let itemLink = getItemLink(forType: .udf, baseLink: baseLink, resourceId: resourceId)
        return getUrlLinkForSelf(baseLink: baseLink, itemLink: itemLink, resourceId: resourceId)
    }

    func document(inDatabase databaseId: String, inCollection collectionId: String, withId resourceId: String? = nil) -> (URL, String) {
        let baseLink = "dbs/\(databaseId)/colls/\(collectionId)"
        let itemLink = getItemLink(forType: .document, baseLink: baseLink, resourceId: resourceId)
        return getUrlLink(baseLink: baseLink, itemLink: itemLink, resourceId: resourceId)
    }

    func document(atLink baseLink: String, withResourceId resourceId: String? = nil) -> (URL, String) {
        let itemLink = getItemLink(forType: .document, baseLink: baseLink, resourceId: resourceId)
        return getUrlLinkForSelf(baseLink: baseLink, itemLink: itemLink, resourceId: resourceId)
    }
    
    func attachment(_ databaseId: String, collectionId: String, documentId: String, attachmentId resourceId: String? = nil) -> (URL, String) {
        let baseLink = "dbs/\(databaseId)/colls/\(collectionId)/docs/\(documentId)"
        let itemLink = getItemLink(forType: .attachment, baseLink: baseLink, resourceId: resourceId)
        return getUrlLink(baseLink: baseLink, itemLink: itemLink, resourceId: resourceId)
    }
    
    func attachment(atLink baseLink: String, withResourceId resourceId: String? = nil) -> (URL, String) {
        let itemLink = getItemLink(forType: .attachment, baseLink: baseLink, resourceId: resourceId)
        return getUrlLinkForSelf(baseLink: baseLink, itemLink: itemLink, resourceId: resourceId)
    }

    func offer() -> (URL, String) {
        let baseLink = ""
        let itemLink = getItemLink(forType: .offer, baseLink: baseLink, resourceId: nil)
        return getUrlLink(baseLink: baseLink, itemLink: itemLink, resourceId: nil)
    }

    func offer(_ resourceId: String) -> (URL, String) {
        let baseLink = ""
        let itemLink = getItemLink(forType: .offer, baseLink: baseLink, resourceId: resourceId)
        return getUrlLinkForSelf(baseLink: baseLink, itemLink: itemLink, resourceId: resourceId)
    }

    
    fileprivate func getItemLink(forType type: ResourceType, baseLink: String, resourceId: String?) -> String {
        
        let fragment = resourceId.isNilOrEmpty ? empty : "/\(resourceId!)"
        
        switch type {
        case .database:         return "dbs\(fragment)"
        case .user:             return "\(baseLink)/users\(fragment)"
        case .permission:       return "\(baseLink)/permissions\(fragment)"
        case .collection:       return "\(baseLink)/colls\(fragment)"
        case .storedProcedure:  return "\(baseLink)/sprocs\(fragment)"
        case .trigger:          return "\(baseLink)/triggers\(fragment)"
        case .udf:              return "\(baseLink)/udfs\(fragment)"
        case .document:         return "\(baseLink)/docs\(fragment)"
        case .attachment:       return "\(baseLink)/attachments\(fragment)"
        case .offer:            return "offers\(fragment)"
        }
    }
    
    fileprivate func getUrlLink(baseLink: String, itemLink:String, resourceId: String?) ->(URL, String) {
        return (URL(string:"\(baseUri)/\(itemLink)")!, resourceId.isNilOrEmpty ? baseLink : itemLink)
    }

    fileprivate func getUrlLinkForSelf(baseLink: String, itemLink:String, resourceId: String?) ->(URL, String) {
        return (URL(string:"\(baseUri)/\(itemLink)")!, resourceId.isNilOrEmpty ? String(baseLink.split(separator: "/").last!).lowercased() : resourceId!.lowercased())
    }
}
