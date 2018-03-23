//
//  ResourceValidation.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

fileprivate struct ResourceValidation {
    static let maximumIdLength: Int = 255
    static let invalidIdCharacters: CharacterSet = CharacterSet.whitespacesAndNewlines.union([ "/", "?", "#" ])
}

extension CodableResource {
    
    var hasValidId: Bool {
        return self.id.isValidIdForResource
    }
}

extension String {
    
    var isValidIdForResource: Bool {
        
        let validLength = self.count < ResourceValidation.maximumIdLength
        let validCharacters = self.rangeOfCharacter(from: ResourceValidation.invalidIdCharacters) == nil
        
        return validLength && validCharacters
    }
}
