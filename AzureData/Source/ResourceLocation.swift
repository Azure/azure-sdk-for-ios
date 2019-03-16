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
///   `location.path // "dbs/MyDatabase/colls/MyCollection/docs" (the location of the documents feed)`
///   `location.link // "dbs/MyDatabase/colls/MyCollection" (the location of the collection itself)`
///
/// - Example: Get a single existing document from the collection:
///   `let location: ResourceLocation = .document(databaseId: "MyDatabase", collectionId: "MyCollection", id: "MyDocument")`
///   `location.path // "dbs/MyDatabase/colls/MyCollection/docs/MyDocument" (the location of the document)`
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
    case partitionKeyRange(databaseId: String, collectionId: String, id: String?)
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
        case let .partitionKeyRange(databaseId, collectionId, id):      return "dbs/"   + databaseId + "/colls/" + collectionId + "/pkranges" + id.path
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
        case let .partitionKeyRange(databaseId, collectionId, _):      return "dbs/"   + databaseId + "/colls/" + collectionId
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
        case .document:             return DocumentContainer<AnyDocument>.type
        case .attachment:           return Attachment.type
        case .offer:                return Offer.type
        case .partitionKeyRange:    return PartitionKeyRange.type
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
        case .partitionKeyRange:    return .partitionKeyRange
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
        case let .partitionKeyRange(_, _, id):  return id
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
        case let .partitionKeyRange(databaseId, collectionId, _):       return [ .database : databaseId, .collection : collectionId ]
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

// MARK: - ResourceLocation+selfLink

extension ResourceLocation {

    func altLink(forId id: String) -> String {
        return path.lastPathComponent == id ? path : "\(path)/\(id)"
    }

    func selfLink(forResourceId resourceId: String) -> String? {
        guard let directory = directory else { return nil }

        return "\(directory)/\(resourceId)"
    }

    var directory: String? {
        guard let parent = parentSelfLink else { return nil }

        switch self {
        case .database:               return "\(parent)"
        case .user:                   return "\(parent)/users"
        case .collection:             return "\(parent)/colls"
        case .storedProcedure:        return "\(parent)/sprocs"
        case .trigger:                return "\(parent)/triggers"
        case .udf:                    return "\(parent)/udfs"
        case .document:               return "\(parent)/docs"
        case .attachment:             return "\(parent)/attachments"
        case .permission:             return "\(parent)/permissions"
        case .offer:                  return "\(parent)"
        case .partitionKeyRange:      return "\(parent)/pkranges"
        case .child(let type, _, _):  return "\(parent)/\(type.rawValue)"
        case .resource(let resource): return ResourceOracle.getSelfLink(forResource: resource)?.lastPathComponentRemoved
        }
    }

    private var parentSelfLink: String? {
        switch self {
        case .database:
            return "dbs"
        case .user(let databaseId, _),
             .collection(let databaseId, _):
            return ResourceOracle.getSelfLink(forResourceAt: .database(id: databaseId))
        case .storedProcedure(let databaseId, let collectionId, _),
             .trigger(let databaseId, let collectionId, _),
             .udf(let databaseId, let collectionId, _),
             .document(let databaseId, let collectionId, _):
            return ResourceOracle.getSelfLink(forResourceAt: .collection(databaseId: databaseId, id: collectionId))
        case .attachment(let databaseId, let collectionId, let documentId, _):
            return ResourceOracle.getSelfLink(forResourceAt: .document(databaseId: databaseId, collectionId: collectionId, id: documentId))
        case .permission(let databaseId, let userId, _):
            return ResourceOracle.getSelfLink(forResourceAt: .user(databaseId: databaseId, id: userId))
        case .offer:
            return "offers"
        case .partitionKeyRange(let databaseId, let collectionId, _):
            return ResourceOracle.getSelfLink(forResourceAt: .collection(databaseId: databaseId, id: collectionId))
        case .child(_, let parent, _):
            return ResourceOracle.getSelfLink(forResource: parent)
        case .resource(let resource):
            return ResourceOracle.getSelfLink(forResource: resource)?.lastPathComponentRemoved.lastPathComponentRemoved
            
        }
    }
}

// MARK: - ResourceLocation+Codable

extension ResourceLocation: Codable {
    enum CodingKeys: String, CodingKey {
        case database
        case user
        case permission
        case collection
        case storedProcedure
        case trigger
        case udf
        case document
        case attachment
        case offer
        case partitionKeyRange
        case resource
        case child
    }

    public init(from decoder: Decoder) throws {
        let  container = try decoder.container(keyedBy: CodingKeys.self)

        if let database = try container.decodeIfPresent([String: String?].self, forKey: .database),
           let databaseId = database["id"] {
            self = .database(id: databaseId)
            return
        }

        if let user = try container.decodeIfPresent([String: String?].self, forKey: .user),
           let databaseId = user["databaseId"],
           let userId = user["id"] {
            self = .user(databaseId: databaseId!, id: userId)
            return
        }

        if let permission = try container.decodeIfPresent([String: String?].self, forKey: .permission),
           let databaseId = permission["databaseId"], let userId =  permission["userId"],
           let permissionId = permission["id"] {
            self = .permission(databaseId: databaseId!, userId: userId!, id: permissionId)
            return
        }

        if let collection = try container.decodeIfPresent([String: String?].self, forKey: .collection),
           let databaseId = collection["databaseId"],
           let collectionId = collection["id"] {
            self = .collection(databaseId: databaseId!, id: collectionId)
            return
        }

        if let storedProcedure = try container.decodeIfPresent([String: String?].self, forKey: .storedProcedure),
           let databaseId = storedProcedure["databaseId"], let collectionId = storedProcedure["collectionId"],
           let id = storedProcedure["id"] {
            self = .storedProcedure(databaseId: databaseId!, collectionId: collectionId!, id: id)
            return
        }

        if let trigger = try container.decodeIfPresent([String: String?].self, forKey: .trigger),
           let databaseId = trigger["databaseId"], let collectionId = trigger["collectionId"],
           let triggerId = trigger["id"] {
            self = .trigger(databaseId: databaseId!, collectionId: collectionId!, id: triggerId)
            return
        }

        if let udf = try container.decodeIfPresent([String: String?].self, forKey: .udf),
           let databaseId = udf["databaseId"], let collectionId = udf["collectionId"],
           let id = udf["id"] {
            self = .udf(databaseId: databaseId!, collectionId: collectionId!, id: id)
            return
        }

        if let document = try container.decodeIfPresent([String: String?].self, forKey: .document),
           let databaseId = document["databaseId"], let collectionId = document["collectionId"],
           let documentId = document["id"] {
            self = .document(databaseId: databaseId!, collectionId: collectionId!, id: documentId)
            return
        }

        if let offer = try container.decodeIfPresent([String: String?].self, forKey: .offer),
           let id = offer["id"] {
            self = .offer(id: id)
            return
        }

        if let partitionKeyRange = try container.decodeIfPresent([String: String?].self, forKey: .partitionKeyRange),
            let databaseId = partitionKeyRange["databaseId"], let collectionId = partitionKeyRange["collectionId"],
            let partitionKeyRangeId = partitionKeyRange["id"] {
            self = .partitionKeyRange(databaseId: databaseId!, collectionId: collectionId!, id: partitionKeyRangeId)
            return
        }

        if let resource = try container.decodeIfPresent([String: String?].self, forKey: .resource),
           let altLink = resource["altLink"],
           let codableResourceString = resource["resource"],
           var codableResource = ResourceSystemProperties(for: codableResourceString!.data(using: .utf8)!) {
            codableResource.setAltLink(to: altLink!)
            self = .resource(resource: codableResource)
            return
        }

        if let child = try container.decodeIfPresent([String: String?].self, forKey: .child),
           let parentString = child["parent"], let resourceTypeString = child["resourceType"],
           var parent = ResourceSystemProperties(for: parentString!.data(using: .utf8)!),
           let parentAltLink = child["parentAltLink"],
           let resourceType = ResourceType(rawValue: resourceTypeString!),
           let id = child["id"] {
            parent.setAltLink(to: parentAltLink!)
            self = .child(resourceType, in: parent, id: id)

            return
        }

        throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "No valid coding key present in the data."))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .database(let databaseId):
            try container.encode(["databaseId": databaseId], forKey: .database)
        case .user(let databaseId, let id):
            try container.encode(["databaseId": databaseId, "id": id], forKey: .user)
        case .permission(let databaseId, let userId, let id):
            try container.encode(["databaseId": databaseId, "userId": userId, "id": id], forKey: .permission)
        case .collection(let databaseId, let id):
            try container.encode(["databaseId": databaseId, "id": id], forKey: .collection)
        case .storedProcedure(let databaseId, let collectionId, let id):
            try container.encode(["databaseId": databaseId, "collectionId": collectionId, "id": id], forKey: .storedProcedure)
        case .trigger(let databaseId, let collectionId, let id):
            try container.encode(["databaseId": databaseId, "collectionId": collectionId, "id": id], forKey: .trigger)
        case .udf(let databaseId, let collectionId, let id):
            try container.encode(["databaseId": databaseId, "collectionId": collectionId, "id": id], forKey: .udf)
        case .document(let databaseId, let collectionId, let id):
            try container.encode(["databaseId": databaseId, "collectionId": collectionId, "id": id], forKey: .document)
        case .attachment(let databaseId, let collectionId, let documentId, let id):
            try container.encode(["databaseId": databaseId, "collectionId": collectionId, "documentId": documentId, "id": id], forKey: .attachment)
        case .offer(let id):
            try container.encode(["id": id], forKey: .offer)
        case .partitionKeyRange(let databaseId, let collectionId, let id):
            try container.encode(["databaseId": databaseId, "collectionId": collectionId, "id": id], forKey: .partitionKeyRange)
        case .resource(let resource):
            try container.encode(
                [
                    "altLink": resource.altLink,
                    "resource": String(data: JSONEncoder().encode(ResourceSystemProperties(for: resource)), encoding: .utf8)
                ],
                forKey: .resource
            )
        case .child(let resourceType, let parent, let id):
            try container.encode(
                [
                    "resourceType": resourceType.rawValue,
                    "parentAltLink": parent.altLink,
                    "parent": String(data: JSONEncoder().encode(ResourceSystemProperties(for: parent)), encoding: .utf8),
                    "id": id
                ],
                forKey: .child
            )
        }
    }
}

