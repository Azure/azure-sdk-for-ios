//
//  PermissionProvider.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCore

public protocol PermissionProvider : AnyObject {
    
    var configuration: PermissionProviderConfiguration! { get set }
    
    func getPermission(forCollectionWithId collectionId: String, inDatabase databaseId: String, withPermissionMode mode: PermissionMode, completion: @escaping (Response<Permission>) -> Void)
    
    func getPermission(forDocumentWithId documentId: String, inCollection collectionId: String, inDatabase databaseId: String, withPermissionMode mode: PermissionMode, completion: @escaping (Response<Permission>) -> Void)
    
    func getPermission(forAttachmentsWithId attachmentId: String, onDocument documentId: String, inCollection collectionId: String, inDatabase databaseId: String, withPermissionMode mode: PermissionMode, completion: @escaping (Response<Permission>) -> Void)
    
    func getPermission(forStoredProcedureWithId storedProcedureId: String, inCollection collectionId: String, inDatabase databaseId: String, withPermissionMode mode: PermissionMode, completion: @escaping (Response<Permission>) -> Void)
    
    func getPermission(forUserDefinedFunctionWithId functionId: String, inCollection collectionId: String, inDatabase databaseId: String, withPermissionMode mode: PermissionMode, completion: @escaping (Response<Permission>) -> Void)
    
    func getPermission(forTriggerWithId triggerId: String, inCollection collectionId: String, inDatabase databaseId: String, withPermissionMode mode: PermissionMode, completion: @escaping (Response<Permission>) -> Void)
}


extension PermissionProvider {
    
    public func getPermissionEncoder() -> JSONEncoder {
        
        let encoder = JSONEncoder()
        
        encoder.dateEncodingStrategy = .custom(DocumentClient.roundTripIso8601Encoder)
        
        return encoder
    }
    
    public func getPermissionDecoder() -> JSONDecoder {
        
        let decoder = JSONDecoder()
        
        decoder.dateDecodingStrategy = .custom(DocumentClient.roundTripIso8601Decoder)
        
        return decoder
    }
    
    func getPermission(forResourceAt resourceLocation: ResourceLocation, withPermissionMode mode: PermissionMode, completion: @escaping (Response<Permission>) -> Void) {
        
        if !PermissionCache.isRestored {
            PermissionCache.restore()
        }
        
        if configuration == nil {
            configuration = PermissionProviderConfiguration.default
        }
        
        var location = resourceLocation
        
        let permissionMode = configuration.defaultPermissionMode == .all ? .all : mode
        
        let resourceType = resourceLocation.resourceType
        
        guard
            resourceType.supportsPermissionToken
        else {
            completion(Response(PermissionProviderError.invalidResourceType)); return
        }
        
        if let defaultResourceType = configuration.defaultResourceType {
            
            if resourceType != defaultResourceType && resourceType.isDecendent(of: defaultResourceType) {
                
                let ancestorIds = resourceLocation.ancestorIds()
                
                switch defaultResourceType {
                
                case .collection:
                    
                    location = .collection(databaseId: ancestorIds[.database]!, id: ancestorIds[.collection]!)
                    
                case .document:
                    
                    location = .document(databaseId: ancestorIds[.database]!, collectionId: ancestorIds[.collection]!, id: ancestorIds[.document]!)
                    
                default: completion(Response(PermissionProviderError.invalidDefaultResourceType))
                }
            }
        }
        
        if let permission = PermissionCache.getPermission(forResourceWithAltLink: location.link),
               permission.permissionMode == .all
            || permission.permissionMode == permissionMode,
           let timestamp = permission.timestamp,
               (configuration.defaultTokenDuration - Date().timeIntervalSince(timestamp)) > configuration.tokenRefreshThreshold {
            
            //Log.debugMessage("found cached Permission with PermissionMode.\(permission.permissionMode.rawValue) and a remaining duration of \(self.configuration.defaultTokenDuration - Date().timeIntervalSince(timestamp)) seconds  (greater than the \(self.configuration.tokenRefreshThreshold) second threshold)")
            
            completion(Response(permission))
            
        } else {
            
            _getPermission(forResourceAt: location, withPermissionMode: permissionMode) { result in
                
                if let permission = result.resource, !PermissionCache.setPermission(permission, forResourceWithAltLink: location.link) {
                    completion(Response(PermissionProviderError.permissionCachefailed))
                } else {
                    completion(result)
                }
            }
        }
    }
    
    
    fileprivate func _getPermission(forResourceAt location: ResourceLocation, withPermissionMode mode: PermissionMode, completion: @escaping (Response<Permission>) -> Void) {
        
        switch location {
            
        case .database, .user, .permission, .offer, .collection(_, nil), .partitionKeyRange:
            
            completion(Response(PermissionProviderError.invalidResourceType))
            
        case let .storedProcedure(databaseId, collectionId, nil),
             let .trigger(databaseId, collectionId, nil),
             let .udf(databaseId, collectionId, nil),
             let .document(databaseId, collectionId, nil):
            
            return getPermission(forCollectionWithId: collectionId, inDatabase: databaseId, withPermissionMode: mode, completion: completion)
            
        case let .collection(databaseId, id):
            
            return getPermission(forCollectionWithId: id!, inDatabase: databaseId, withPermissionMode: mode, completion: completion)
            
        case let .storedProcedure(databaseId, collectionId, id):
            
            return getPermission(forStoredProcedureWithId: id!, inCollection: collectionId, inDatabase: databaseId, withPermissionMode: mode, completion: completion)
            
        case let .trigger(databaseId, collectionId, id):
            
            return getPermission(forTriggerWithId: id!, inCollection: collectionId, inDatabase: databaseId, withPermissionMode: mode, completion: completion)
            
        case let .udf(databaseId, collectionId, id):
            
            return getPermission(forUserDefinedFunctionWithId: id!, inCollection: collectionId, inDatabase: databaseId, withPermissionMode: mode, completion: completion)
            
        case let .document(databaseId, collectionId, id):
            
            return getPermission(forDocumentWithId: id!, inCollection: collectionId, inDatabase: databaseId, withPermissionMode: mode, completion: completion)
            
        case let .attachment(databaseId, collectionId, documentId, id):
            
            if let attachmentId = id {
                return getPermission(forAttachmentsWithId: attachmentId, onDocument: documentId, inCollection: collectionId, inDatabase: databaseId, withPermissionMode: mode, completion: completion)
            } else {
                return getPermission(forDocumentWithId: documentId, inCollection: collectionId, inDatabase: databaseId, withPermissionMode: mode, completion: completion)
            }
            
        case let .resource(resource):
            
            switch location.resourceType {
                
            case .database, .user, .permission, .offer, .partitionKeyRange:
                
                completion(Response(PermissionProviderError.invalidResourceType))
                
            case .collection:
                
                if let databaseId = resource.ancestorIds()[.database] {
                    return getPermission(forCollectionWithId: resource.id, inDatabase: databaseId, withPermissionMode: mode, completion: completion)
                }
                
            case .storedProcedure:
                
                let ancestorIds = resource.ancestorIds()
                
                if let collectionId = ancestorIds[.collection], let databaseId = ancestorIds[.database] {
                    return getPermission(forStoredProcedureWithId: resource.id, inCollection: collectionId, inDatabase: databaseId, withPermissionMode: mode, completion: completion)
                }
                
            case .trigger:
                
                let ancestorIds = resource.ancestorIds()
                
                if let collectionId = ancestorIds[.collection], let databaseId = ancestorIds[.database] {
                    return getPermission(forTriggerWithId: resource.id, inCollection: collectionId, inDatabase: databaseId, withPermissionMode: mode, completion: completion)
                }
                
            case .udf:
                
                let ancestorIds = resource.ancestorIds()
                
                if let collectionId = ancestorIds[.collection], let databaseId = ancestorIds[.database] {
                    return getPermission(forUserDefinedFunctionWithId: resource.id, inCollection: collectionId, inDatabase: databaseId, withPermissionMode: mode, completion: completion)
                }
                
            case .document:
                
                let ancestorIds = resource.ancestorIds()
                
                if let collectionId = ancestorIds[.collection], let databaseId = ancestorIds[.database] {
                    return getPermission(forDocumentWithId: resource.id, inCollection: collectionId, inDatabase: databaseId, withPermissionMode: mode, completion: completion)
                }
                
            case .attachment:
                
                let ancestorIds = resource.ancestorIds()
                
                if let documentId = ancestorIds[.document], let collectionId = ancestorIds[.collection], let databaseId = ancestorIds[.database] {
                    return getPermission(forAttachmentsWithId: resource.id, onDocument: documentId, inCollection: collectionId, inDatabase: databaseId, withPermissionMode: mode, completion: completion)
                }
            }
            
        case let .child(_, resource, nil):
            
            switch location.resourceType {
                
            case .database, .user, .permission, .offer, .collection, .partitionKeyRange:
                
                completion(Response(PermissionProviderError.invalidResourceType))
                
            case .storedProcedure, .trigger, .udf, .document:
                
                if let databaseId = resource.ancestorIds()[.database] {
                    return getPermission(forCollectionWithId: resource.id, inDatabase: databaseId, withPermissionMode: mode, completion: completion)
                }
                
            case .attachment:
                
                let ancestorIds = resource.ancestorIds()
                
                if let collectionId = ancestorIds[.collection], let databaseId = ancestorIds[.database] {
                    return getPermission(forDocumentWithId: resource.id, inCollection: collectionId, inDatabase: databaseId, withPermissionMode: mode, completion: completion)
                }
            }
            
        case let .child(_, resource, id):
            
            switch location.resourceType {
                
            case .database, .user, .permission, .offer, .partitionKeyRange:
                
                completion(Response(PermissionProviderError.invalidResourceType))
                
            case .collection:
                
                return getPermission(forCollectionWithId: id!, inDatabase: resource.id, withPermissionMode: mode, completion: completion)
                
            case .storedProcedure:
                
                if let databaseId = resource.ancestorIds()[.database] {
                    return getPermission(forStoredProcedureWithId: id!, inCollection: resource.id, inDatabase: databaseId, withPermissionMode: mode, completion: completion)
                }
                
            case .trigger:
                
                if let databaseId = resource.ancestorIds()[.database] {
                    return getPermission(forTriggerWithId: id!, inCollection: resource.id, inDatabase: databaseId, withPermissionMode: mode, completion: completion)
                }
                
            case .udf:
                
                if let databaseId = resource.ancestorIds()[.database] {
                    return getPermission(forUserDefinedFunctionWithId: id!, inCollection: resource.id, inDatabase: databaseId, withPermissionMode: mode, completion: completion)
                }
                
            case .document:
                
                if let databaseId = resource.ancestorIds()[.database] {
                    return getPermission(forDocumentWithId: id!, inCollection: resource.id, inDatabase: databaseId, withPermissionMode: mode, completion: completion)
                }
                
            case .attachment:
                
                let ancestorIds = resource.ancestorIds()
                
                if let collectionId = ancestorIds[.collection], let databaseId = ancestorIds[.database] {
                    
                    if let attachmentId = id {
                        return getPermission(forAttachmentsWithId: attachmentId, onDocument: resource.id, inCollection: collectionId, inDatabase: databaseId, withPermissionMode: mode, completion: completion)
                    } else {
                        return getPermission(forDocumentWithId: resource.id, inCollection: collectionId, inDatabase: databaseId, withPermissionMode: mode, completion: completion)
                    }
                }
            }
        }
    }
}
