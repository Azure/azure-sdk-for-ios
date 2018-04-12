//
//  UtilityExtensions.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

extension Optional where Wrapped == String {
    
    var valueOrEmpty: String {
        return self ?? ""
    }
    
    var valueOrNilString: String {
        return self ?? "nil"
    }
    
    var isNilOrEmpty: Bool {
        return self == nil || self!.isEmpty
    }
}


extension Optional where Wrapped == Date {
    
    var valueOrEmpty: String {
        return self != nil ? "\(self!.timeIntervalSince1970)" : ""
    }
    
    var valueOrNilString: String {
        return self != nil ? "\(self!.timeIntervalSince1970)" : "nil"
    }
}

extension Decodable {
    static func decode(data: Data) throws -> Self {
        let decoder = JSONDecoder()
        return try decoder.decode(Self.self, from: data)
    }
}


extension Encodable {
    func encode() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return try encoder.encode(self)
    }
}


extension DecodingError {
    
    var logMessage: String {
        switch self {
        case .typeMismatch(let type, let context):
            return "decodeError: typeMismatch\n\ttype: \(type)\n\tcontext: \(context)\n"
        case .dataCorrupted(let context):
            return "decodeError: dataCorrupted\n\tcontext: \(context)\n"
        case .keyNotFound(let key, let context):
            return "decodeError: keyNotFound\n\tkey: \(key)\n\tcontext: \(context)\n"
        case .valueNotFound(let type, let context):
            return "decodeError: valueNotFound\n\ttype: \(type)\n\tcontext: \(context)\n"
        }
    }
}
