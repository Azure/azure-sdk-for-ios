//
//  ConflictStrategy.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

public typealias ConflictResolver = (_ local:CodableResource, _ remote:CodableResource) -> CodableResource

public enum ConflictStrategy {
    
    case none
    case overwrite
    case custom(ConflictResolver)
}

// if .none or .custom add If-Match header with etag (don't add for .overwrite)
// replace(local) -> returns a conflict (412 Precondition Failure)
//   server will only return 412 Precondition Failure if the If-Match header was present
// if .none return the conflict as an error
// if .custom
//     remote = get -> returns remote
//     resolved = conflictResolvers[type](local, remote)
//     resolved.etag = remote.etag
//     replace(resolved) -> boom
