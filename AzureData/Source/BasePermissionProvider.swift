//
//  BasePermissionProvider.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCore

open class BasePermissionProvider : PermissionProvider {
    
    let configuration: PermissionProviderConfiguration
    
    public required init(with configuration: PermissionProviderConfiguration) {
        self.configuration = configuration
        PermissionCache.restore()
    }
    
    open func getPermission(forCollectionWithId collectionId: String, inDatabase databaseId: String, withPermissionMode mode: PermissionMode, completion: @escaping (PermissionResult) -> Void) {
        log?.debugMessage("\n @@@@\n\n collection\n\tcollectionId: \(collectionId)\n\tdatabaseId: \(databaseId)\n\n @@@\n\n")
        completion(PermissionResult(PermissionProviderError.notImplemented))
    }
    
    open func getPermission(forDocumentWithId documentId: String, inCollection collectionId: String, inDatabase databaseId: String, withPermissionMode mode: PermissionMode, completion: @escaping (PermissionResult) -> Void) {
        log?.debugMessage("\n @@@@\n\n document\n\tdocumentId: \(documentId)\n\tcollectionId: \(collectionId)\n\tdatabaseId: \(databaseId)\n\n @@@\n\n")
        completion(PermissionResult(PermissionProviderError.notImplemented))
    }
    
    open func getPermission(forAttachmentsWithId attachmentId: String, onDocument documentId: String, inCollection collectionId: String, inDatabase databaseId: String, withPermissionMode mode: PermissionMode, completion: @escaping (PermissionResult) -> Void) {
        log?.debugMessage("\n @@@@\n\n attachment\n\tattachmentId: \(attachmentId)\n\tdocumentId: \(documentId)\n\tcollectionId: \(collectionId)\n\tdatabaseId: \(databaseId)\n\n @@@\n\n")
        completion(PermissionResult(PermissionProviderError.notImplemented))
    }
    
    open func getPermission(forStoredProcedureWithId storedProcedureId: String, inCollection collectionId: String, inDatabase databaseId: String, withPermissionMode mode: PermissionMode, completion: @escaping (PermissionResult) -> Void) {
        log?.debugMessage("\n @@@@\n\n storedProcedure\n\tstoredProcedure: \(storedProcedureId)\n\tcollectionId: \(collectionId)\n\tdatabaseId: \(databaseId)\n\n @@@\n\n")
        completion(PermissionResult(PermissionProviderError.notImplemented))
    }
    
    open func getPermission(forUserDefinedFunctionWithId functionId: String, inCollection collectionId: String, inDatabase databaseId: String, withPermissionMode mode: PermissionMode, completion: @escaping (PermissionResult) -> Void) {
        log?.debugMessage("\n @@@@\n\n userDefinedFunction\n\tfunctionId: \(functionId)\n\tcollectionId: \(collectionId)\n\tdatabaseId: \(databaseId)\n\n @@@\n\n")
        completion(PermissionResult(PermissionProviderError.notImplemented))
    }
    
    open func getPermission(forTriggerWithId triggerId: String, inCollection collectionId: String, inDatabase databaseId: String, withPermissionMode mode: PermissionMode, completion: @escaping (PermissionResult) -> Void) {
        log?.debugMessage("\n @@@@\n\n trigger\n\ttriggerId: \(triggerId)\n\tcollectionId: \(collectionId)\n\tdatabaseId: \(databaseId)\n\n @@@\n\n")
        completion(PermissionResult(PermissionProviderError.notImplemented))
    }
    
    
    public func getPermission(forResourceAt resourceLocation: ResourceLocation, withPermissionMode mode: PermissionMode, completion: @escaping (PermissionResult) -> Void) {
        
        var location = resourceLocation
        
        let permissionMode = configuration.defaultPermissionMode == .all ? .all : mode
        
        let resourceType = resourceLocation.resourceType
        
        guard
            resourceType.supportsPermissionToken
        else {
            completion(PermissionResult(PermissionProviderError.invalidDefaultResourceLevel)); return
        }
        
        if let resourceLevel = configuration.defaultResourceLevel {
            
            guard
                resourceLevel.supportsPermissionToken
            else {
                completion(PermissionResult(PermissionProviderError.invalidDefaultResourceLevel)); return
            }
            
            if resourceType != resourceLevel && resourceType.isDecendent(of: resourceLevel) {
                
                let ancestorIds = resourceLocation.ancestorIds()
                
                switch resourceLevel {
                case .collection:
                    
                    location = .collection(databaseId: ancestorIds[.database]!, id: ancestorIds[.collection]!)
                    
                case .document:
                    
                    location = .document(databaseId: ancestorIds[.database]!, collectionId: ancestorIds[.collection]!, id: ancestorIds[.document]!)
                    
                default: completion(PermissionResult(PermissionProviderError.invalidDefaultResourceLevel))
                }
            }
        }
        
        if let permission = PermissionCache.getPermission(forResourceWithAltLink: location.link),
               permission.permissionMode == .all
            || permission.permissionMode == permissionMode,
           let timestamp = permission.timestamp,
               (configuration.defaultTokenDuration - Date().timeIntervalSince(timestamp)) > configuration.tokenRefreshThreshold {
            
            log?.debugMessage("found cached Permission with PermissionMode.\(permission.permissionMode.rawValue) and a remaining duration of \(self.configuration.defaultTokenDuration - Date().timeIntervalSince(timestamp)) seconds  (greater than the \(self.configuration.tokenRefreshThreshold) second threshold)")

            completion(PermissionResult(permission))
            
        } else {
            
            _getPermission(forResourceAt: location, withPermissionMode: permissionMode) { result in
                
                if let permission = result.permission, !PermissionCache.setPermission(permission, forResourceWithAltLink: location.link) {
                    completion(PermissionResult(PermissionProviderError.unsuccessfulCache))
                } else {
                    completion(result)
                }
            }
        }
    }
    
    
    fileprivate func _getPermission(forResourceAt location: ResourceLocation, withPermissionMode mode: PermissionMode, completion: @escaping (PermissionResult) -> Void) {
        
        switch location {
            
        case .database,
             .user,
             .permission,
             .offer: completion(PermissionResult(PermissionProviderError.resourceTokenUnsupportedForResourceType))
            
        case let .storedProcedure(databaseId, collectionId, nil),
             let .trigger(databaseId, collectionId, nil),
             let .udf(databaseId, collectionId, nil),
             let .document(databaseId, collectionId, nil):
            
            return getPermission(forCollectionWithId: collectionId, inDatabase: databaseId, withPermissionMode: mode, completion: completion)
            
        case let .collection(databaseId, id):
            
            if let collectionId = id {
                return getPermission(forCollectionWithId: collectionId, inDatabase: databaseId, withPermissionMode: mode, completion: completion)
            } else {
                completion(PermissionResult(PermissionProviderError.resourceTokenUnsupportedForResourceType))
            }
            
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
                
            case .database,
                 .user,
                 .permission,
                 .offer: completion(PermissionResult(PermissionProviderError.resourceTokenUnsupportedForResourceType))
                
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
            
            case .database,
                 .user,
                 .permission,
                 .offer,
                 .collection: completion(PermissionResult(PermissionProviderError.resourceTokenUnsupportedForResourceType))
                
            case .storedProcedure,
                 .trigger,
                 .udf,
                 .document:
                
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
                
            case .database,
                 .user,
                 .permission,
                 .offer: completion(PermissionResult(PermissionProviderError.resourceTokenUnsupportedForResourceType))

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
