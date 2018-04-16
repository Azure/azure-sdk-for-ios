//
//  ResourceRequestError.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

public enum ResourceRequestError: Error {
    case invalidValue(forHeader: String, message: String)
    case multiple(_: [ResourceRequestError])

    var description: String {
        switch self {
        case .invalidValue(let header, let message):
            return "Invalid value for the header '\(header)': \(message)"
        case .multiple(let errors):
            return errors.map { "- \($0.description)"}.joined(separator: "\n")
        }
    }
}

extension ResourceRequestError: LocalizedError {
    public var errorDescription: String? {
        return self.description
    }
}
