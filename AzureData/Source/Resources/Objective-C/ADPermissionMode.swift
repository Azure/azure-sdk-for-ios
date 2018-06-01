//
//  ADPermissionMode.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

@objc(ADPermissionMode)
public enum ADPermissionMode: Int {
    @objc(ADPermissionModeRead)
    case read

    @objc(ADPermissionModeAll)
    case all

    public var description: String {
        switch self {
        case .read:
            return "Read"
        case .all:
            return "All"
        }
    }

    internal init(_ permissionMode: PermissionMode) {
        switch permissionMode {
        case .read: self = .read
        case .all: self = .all
        }
    }

    internal var permissionMode: PermissionMode {
        return PermissionMode(rawValue: description)!
    }
}
