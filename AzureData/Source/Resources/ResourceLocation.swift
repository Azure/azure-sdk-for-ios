//
//  ResourceLocation.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

protocol ResourceLocator {
    var path: String { get }
    var link: String { get }
}

enum ResourceLocation : ResourceLocator {
    case database(id: String?)
    case user(databaseId: String, id: String?)
    case permission(databaseId: String, userId: String, id: String?)
    case collection(databaseId: String, id: String?)
    case storedProcedure(databaseId: String, collectionId: String, id: String?)
    case trigger(databaseId: String, collectionId: String, id: String?)
    case udf(databaseId: String, collectionId: String, id: String?)
    case document(databaseId: String, collectionId: String, id: String?)
    case attachment(databaseId: String, collectionId: String, documentId: String, id: String?)
    case offer(id: String?)
    case resource(resource: CodableResource)
    case child(_ :ResourceType, in: CodableResource, resourceId: String?)
    
    
    var path: String {
        switch self {
        case let .database(id):                                          return "dbs"    + id.path
        case let .user(databaseId, id):                                  return "dbs/"   + databaseId + "/users"  + id.path
        case let .permission(databaseId, userId, id):                    return "dbs/"   + databaseId + "/users/" + userId + "/permissions" + id.path
        case let .collection(databaseId, id):                            return "dbs/"   + databaseId + "/colls"  + id.path
        case let .storedProcedure(databaseId, collectionId, id):         return "dbs/"   + databaseId + "/colls/" + collectionId + "/sprocs"   + id.path
        case let .trigger(databaseId, collectionId, id):                 return "dbs/"   + databaseId + "/colls/" + collectionId + "/triggers" + id.path
        case let .udf(databaseId, collectionId, id):                     return "dbs/"   + databaseId + "/colls/" + collectionId + "/udfs"     + id.path
        case let .document(databaseId, collectionId, id):                return "dbs/"   + databaseId + "/colls/" + collectionId + "/docs"     + id.path
        case let .attachment(databaseId, collectionId, documentId, id):  return "dbs/"   + databaseId + "/colls/" + collectionId + "/docs/" + documentId + "/attachments" + id.path
        case let .offer(id):                                             return "offers" + id.path
        case let .resource(resource):                                    return ResourceOracle.getSelfLink(forResource: resource)!
        case let .child(type, resource, resourceId):                     return ResourceOracle.getSelfLink(forResource: resource)! + "/" + type.path + resourceId.path
        }
    }
    
    
    var link: String {
        switch self {
        case let .database(id):                                          return id.path(in:"dbs")
        case let .user(databaseId, id):                                  return "dbs/"   + databaseId + id.path(in:"/users")
        case let .permission(databaseId, userId, id):                    return "dbs/"   + databaseId + "/users/" + userId + id.path(in:"/permissions")
        case let .collection(databaseId, id):                            return "dbs/"   + databaseId + id.path(in:"/colls")
        case let .storedProcedure(databaseId, collectionId, id):         return "dbs/"   + databaseId + "/colls/" + collectionId + id.path(in:"/sprocs")
        case let .trigger(databaseId, collectionId, id):                 return "dbs/"   + databaseId + "/colls/" + collectionId + id.path(in:"/triggers")
        case let .udf(databaseId, collectionId, id):                     return "dbs/"   + databaseId + "/colls/" + collectionId + id.path(in:"/udfs")
        case let .document(databaseId, collectionId, id):                return "dbs/"   + databaseId + "/colls/" + collectionId + id.path(in:"/docs")
        case let .attachment(databaseId, collectionId, documentId, id):  return "dbs/"   + databaseId + "/colls/" + collectionId + "/docs/" + documentId + id.path(in:"/attachments")
        case let .offer(id):                                             return id.path(in: "offers")
        case let .resource(resource):                                    return ResourceOracle.getResourceId(forResource: resource)!.lowercased()
        case let .child(_, resource, resourceId):                        return (resourceId ?? ResourceOracle.getResourceId(forResource: resource)!).lowercased()
        }
    }
}


fileprivate extension Optional where Wrapped == String {
    
    var path: String {
        
        if let id = self, !id.isEmpty {
            return "/" + id
        }
        
        return ""
    }
    
    func path(in parent: String) -> String {
        
        if let id = self, !id.isEmpty, !parent.isEmpty {
            return parent + "/" + id
        }
        
        return ""
    }
}
