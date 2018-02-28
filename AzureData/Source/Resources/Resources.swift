//
//  Resources.swift
//  AzureData iOS
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

public struct Resources<T:CodableResource> : Decodable {
    
    public private(set) var resourceId: String
    public private(set) var count:      Int
    public private(set) var items:      [T]

    private enum CodingKeys : CodingKey {
        case resourceId
        case count
        case items
        
        var stringValue: String {
            switch self {
            case .resourceId: return "_rid"
            case .count: return "_count"
            case .items: return T.list
            }
        }
        
        init?(stringValue: String) {
            switch stringValue {
            case "_rid": self = .resourceId
            case "_count": self = .count
            case T.list: self = .items
            default: return nil
            }
        }
        
        var intValue: Int? { return nil }
        
        
        init?(intValue: Int) { return nil }
    }
}


extension Resources : CustomDebugStringConvertible {
    public var debugDescription: String {
        return "Resources :\n\tresourceId : \(self.resourceId)\n\tcount : \(self.count)\n\titems :\n\(self.items.map { "\($0)" }.joined(separator: "\n"))\n--"
    }
}
