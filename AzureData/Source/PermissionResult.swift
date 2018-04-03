//
//  PermissionResult.swift
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
