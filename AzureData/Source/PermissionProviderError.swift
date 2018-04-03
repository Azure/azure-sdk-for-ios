//
//  PermissionProviderError.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

public enum PermissionProviderError : Error {
    case notImplemented
    case unsuccessfulCache
    case failedToGetParentLink
    case failedToGetPermissionFromServer
    case resourceTokenUnsupportedForResourceType
    case invalidDefaultResourceLevel
}
