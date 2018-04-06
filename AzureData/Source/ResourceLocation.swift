//
//  ResourceLocation.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// The logical location of 1) a resource or feed and the and 2) the resource for which permissions are required
///
/// - Remark:
/// `path` refers to the logical location of the resource or feed of a coorisponding CRUD operation
/// `link` refers to the logical location of the the resource the operation is acting on (thus need permissions for)
///
/// - Example: Listing all documents in a collection:
///   `let location: ResourceLocation = .document(databaseId: "MyDatabase", collectionId: "MyCollection", id: nil)`
///   `location.path // "dbs/MyDatabase/colls/MyCollection/docs" (the locaiton of the documents feed)`
///   `location.link // "dbs/MyDatabase/colls/MyCollection" (the location of the collection itself)`
///
/// - Example: Get a single existing document from the collection:
///   `let location: ResourceLocation = .document(databaseId: "MyDatabase", collectionId: "MyCollection", id: "MyDocument")`
///   `location.path // "dbs/MyDatabase/colls/MyCollection/docs/MyDocument" (the locaiton of the document)`
///   `location.link // "dbs/MyDatabase/colls/MyCollection/docs/MyDocument" (the location of the document)`
public enum ResourceLocation {
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
    case child(_ :ResourceType, in: CodableResource, id: String?)
    
    
    public var path: String {
        switch self {
        case let .database(id):                                         return "dbs"    + id.path
        case let .user(databaseId, id):                                 return "dbs/"   + databaseId + "/users"  + id.path
        case let .permission(databaseId, userId, id):                   return "dbs/"   + databaseId + "/users/" + userId + "/permissions" + id.path
        case let .collection(databaseId, id):                           return "dbs/"   + databaseId + "/colls"  + id.path
        case let .storedProcedure(databaseId, collectionId, id):        return "dbs/"   + databaseId + "/colls/" + collectionId + "/sprocs"   + id.path
        case let .trigger(databaseId, collectionId, id):                return "dbs/"   + databaseId + "/colls/" + collectionId + "/triggers" + id.path
        case let .udf(databaseId, collectionId, id):                    return "dbs/"   + databaseId + "/colls/" + collectionId + "/udfs"     + id.path
        case let .document(databaseId, collectionId, id):               return "dbs/"   + databaseId + "/colls/" + collectionId + "/docs"     + id.path
        case let .attachment(databaseId, collectionId, documentId, id): return "dbs/"   + databaseId + "/colls/" + collectionId + "/docs/" + documentId + "/attachments" + id.path
        case let .offer(id):                                            return "offers" + id.path
        case let .resource(resource):                                   return ResourceOracle.getAltLink(forResource: resource)!
        case let .child(type, resource, id):                            return ResourceOracle.getAltLink(forResource: resource)! + "/" + type.rawValue + id.path
        }
    }
    
    
    public var link: String {
        switch self {
        case let .database(id):                                         return id.path(in:"dbs")
        case let .user(databaseId, id):                                 return "dbs/"   + databaseId + id.path(in:"/users")
        case let .permission(databaseId, userId, id):                   return "dbs/"   + databaseId + "/users/" + userId + id.path(in:"/permissions")
        case let .collection(databaseId, id):                           return "dbs/"   + databaseId + id.path(in:"/colls")
        case let .storedProcedure(databaseId, collectionId, id):        return "dbs/"   + databaseId + "/colls/" + collectionId + id.path(in:"/sprocs")
        case let .trigger(databaseId, collectionId, id):                return "dbs/"   + databaseId + "/colls/" + collectionId + id.path(in:"/triggers")
        case let .udf(databaseId, collectionId, id):                    return "dbs/"   + databaseId + "/colls/" + collectionId + id.path(in:"/udfs")
        case let .document(databaseId, collectionId, id):               return "dbs/"   + databaseId + "/colls/" + collectionId + id.path(in:"/docs")
        case let .attachment(databaseId, collectionId, documentId, id): return "dbs/"   + databaseId + "/colls/" + collectionId + "/docs/" + documentId + id.path(in:"/attachments")
        case let .offer(id):                                            return id?.lowercased() ?? ""
        case let .resource(resource):                                   return ResourceOracle.getAltLink(forResource: resource)!
        case let .child(type, resource, id):                            return ResourceOracle.getAltLink(forResource: resource)! + id.path(in:"/" + type.rawValue)
        }
    }
    
    
    public var type: String {
        switch self {
        case .database:             return Database.type
        case .user:                 return User.type
        case .permission:           return Permission.type
        case .collection:           return DocumentCollection.type
        case .storedProcedure:      return StoredProcedure.type
        case .trigger:              return Trigger.type
        case .udf:                  return UserDefinedFunction.type
        case .document:             return Document.type
        case .attachment:           return Attachment.type
        case .offer:                return Offer.type
        case let .resource(r):      return r.path
        case let .child(t, _, _):   return t.rawValue
        }
    }
    
    
    public var resourceType: ResourceType {
        switch self {
        case .database:             return .database
        case .user:                 return .user
        case .permission:           return .permission
        case .collection:           return .collection
        case .storedProcedure:      return .storedProcedure
        case .trigger:              return .trigger
        case .udf:                  return .udf
        case .document:             return .document
        case .attachment:           return .attachment
        case .offer:                return .offer
        case let .resource(r):      return ResourceType(rawValue: r.path)!
        case let .child(t, _, _):   return t
        }
    }
    
    
    public var id: String? {
        switch self {
        case let .database(id):                 return id
        case let .user(_, id):                  return id
        case let .permission(_, _, id):     	return id
        case let .collection(_, id):        	return id
        case let .storedProcedure(_, _, id):    return id
        case let .trigger(_, _, id):        	return id
        case let .udf(_, _, id):            	return id
        case let .document(_, _, id):       	return id
        case let .attachment(_, _, _, id):  	return id
        case let .offer(id):                	return id
        case let .resource(resource):       	return resource.id
        case let .child(_, _, id):          	return id
        }
    }

    
    public func ancestorIds() -> [ResourceType:String] {
        switch self {
        case .database:                                                 return [:]
        case let .user(databaseId, _):                                  return [ .database : databaseId ]
        case let .permission(databaseId, userId, _):                    return [ .database : databaseId, .user : userId]
        case let .collection(databaseId, _):                            return [ .database : databaseId ]
        case let .storedProcedure(databaseId, collectionId, _):         return [ .database : databaseId, .collection : collectionId ]
        case let .trigger(databaseId, collectionId, _):                 return [ .database : databaseId, .collection : collectionId ]
        case let .udf(databaseId, collectionId, _):                     return [ .database : databaseId, .collection : collectionId ]
        case let .document(databaseId, collectionId, _):                return [ .database : databaseId, .collection : collectionId ]
        case let .attachment(databaseId, collectionId, documentId, _):  return [ .database : databaseId, .collection : collectionId, .document : documentId ]
        case .offer:                                                    return [:]
        case let .resource(resource):                                   return resource.ancestorIds()
        case let .child(_, resource, _):                                return resource.ancestorIds(includingSelf: true)
        }
    }
    
    
    public var supportsPermissionToken: Bool {
        return self.resourceType.supportsPermissionToken
    }
    
    
    public var isFeed: Bool {
        return id.isNilOrEmpty
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
