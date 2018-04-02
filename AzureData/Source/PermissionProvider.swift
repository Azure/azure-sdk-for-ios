//
//  PermissionProvider.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

public struct PermissionResult {
    
    public let error: Error?
    public let permission: Permission?
    
    public init(_ error: Error) {
        self.permission = nil
        self.error = error
    }
    
    public init(_ permission: Permission) {
        self.permission = permission
        self.error = nil
    }
}

public protocol PermissionProvider {
    
    //var configuration: PermissionProviderConfiguration { get }
    
    //init()
    
    init(with configuration: PermissionProviderConfiguration)
    
    
//    func getPermission(forResourceAtAltLink altLink: String, withPermissionMode mode: PermissionMode, completion: @escaping (PermissionProviderResponse) -> Void)
//
//    func getPermission(forResourceAtSelfLink selfLink: String, withPermissionMode mode: PermissionMode, completion: @escaping (PermissionProviderResponse) -> Void)

    func getPermission(forResourceAt location: ResourceLocation, withPermissionMode mode: PermissionMode, completion: @escaping (PermissionResult) -> Void)
    
    func getPermission<T:CodableResource>(forResource resource: T, withPermissionMode mode: PermissionMode, completion: @escaping (PermissionResult) -> Void)
}


//public class BasePermissionProvider : PermissionProvider {
//
//    let configuration: PermissionProviderConfiguration
//
//    public required init(with configuration: PermissionProviderConfiguration) {
//        self.configuration = configuration
//    }
//
//
//    public func getPermission(forResourceAt location: ResourceLocation, withPermissionMode mode: PermissionMode, completion: @escaping (PermissionResult) -> Void) {
//        <#code#>
//    }
//
//    public func getPermission<T>(forResource resource: T, withPermissionMode mode: PermissionMode, completion: @escaping (PermissionResult) -> Void) where T : CodableResource {
//        <#code#>
//    }
//}

