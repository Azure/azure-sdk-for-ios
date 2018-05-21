//
//  Extensions.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureData

extension Optional where Wrapped == DocumentClientError {
    var isInvalidIdError: Bool {
        guard let errorKind = self?.kind,  case .invalidId = errorKind else {
            return false
        }

        return true
    }

    var isNotFoundError: Bool {
        guard let errorKind = self?.kind, case .notFound = errorKind else {
            return false
        }

        return true
    }

    var isConflictError: Bool {
        guard let errorKind = self?.kind, case .conflict = errorKind else {
            return false
        }

        return true
    }

    func isInvalidHeaderError(forHeader header: MSHttpHeader, withMessage message: String) -> Bool {
        guard let errorKind = self?.kind else { return false }

        switch errorKind {
        case .resourceRequestError(let error):
            switch error {
            case .invalidValue(let h, let m):
                return header.rawValue == h && message == m
            default:
                return false
            }
        default:
            return false
        }
    }
}
