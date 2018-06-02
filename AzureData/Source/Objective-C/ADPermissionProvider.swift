//
//  ADPermissionProvider.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCore

@objc(ADPermissionProvider)
public protocol ADPermissionProvider {
    var configuration: ADPermissionProviderConfiguration! { get set }

    func getPermission(forCollectionWithId collectionId: String, inDatabase databaseId: String, withPermissionMode mode: ADPermissionMode, completion: @escaping (ADResponse) -> Void)

    func getPermission(forDocumentWithId documentId: String, inCollection collectionId: String, inDatabase databaseId: String, withPermissionMode mode: ADPermissionMode, completion: @escaping (ADResponse) -> Void)

    func getPermission(forAttachmentsWithId attachmentId: String, onDocument documentId: String, inCollection collectionId: String, inDatabase databaseId: String, withPermissionMode mode: ADPermissionMode, completion: @escaping (ADResponse) -> Void)

    func getPermission(forStoredProcedureWithId storedProcedureId: String, inCollection collectionId: String, inDatabase databaseId: String, withPermissionMode mode: ADPermissionMode, completion: @escaping (ADResponse) -> Void)

    func getPermission(forUserDefinedFunctionWithId functionId: String, inCollection collectionId: String, inDatabase databaseId: String, withPermissionMode mode: ADPermissionMode, completion: @escaping (ADResponse) -> Void)

    func getPermission(forTriggerWithId triggerId: String, inCollection collectionId: String, inDatabase databaseId: String, withPermissionMode mode: ADPermissionMode, completion: @escaping (ADResponse) -> Void)
}
