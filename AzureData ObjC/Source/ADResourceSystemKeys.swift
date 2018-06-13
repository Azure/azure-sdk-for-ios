//
//  ADResourceSystemKeys.swift
//  AzureData ObjC
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

enum ADResourceSystemKeys: String, CodingKey {
    case id
    case resourceId         = "_rid"
    case selfLink           = "_self"
    case etag               = "_etag"
    case timestamp          = "_ts"
}
