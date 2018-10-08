//
//  HttpStatusCode.swift
//  AzureCore
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

public enum HttpStatusCode : Int {
    case ok                     = 200
    case created                = 201
    case accepted               = 202
    case noContent              = 204
    case notModified            = 304
    case badRequest             = 400
    case unauthorized           = 401
    case forbidden              = 403
    case notFound               = 404
    case requestTimeout         = 408
    case conflict               = 409
    case gone                   = 410
    case preconditionFailure    = 412
    case entityTooLarge         = 413
    case tooManyRequests        = 429
    case retryWith              = 449
    case internalServerError    = 500
    case serviceUnavailable     = 503
}
