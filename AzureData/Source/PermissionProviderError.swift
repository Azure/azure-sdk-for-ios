//
//  PermissionProviderError.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

public enum PermissionProviderError : Error {
    case permissionCachefailed
    case getPermissionFailed
    case invalidResourceType
    case invalidDefaultResourceType
}
