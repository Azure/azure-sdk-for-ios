//
//  PermissionProvider.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

public protocol PermissionProvider {
    
    init(with configuration: PermissionProviderConfiguration)
    
    func getPermission(forResourceAt location: ResourceLocation, withPermissionMode mode: PermissionMode, completion: @escaping (PermissionResult) -> Void)
}
