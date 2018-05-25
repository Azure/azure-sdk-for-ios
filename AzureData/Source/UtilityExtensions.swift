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

extension String {
    /// "dbs/TC1AAA==/colls/TC1AAMDvwgA=".path = ("dbs/TC1AAA==/colls", "TC1AAMDvwgA=")
    var path: (directory: String, file: String)? {
        let components = self.split(separator: "/")
        let count = components.count

        guard count > 0 else { return nil }
        guard count >= 2 else { return ("/", String(components[count - 1])) }

        return (components[0...(count - 2)].joined(separator: "/"), String(components[count - 1]))
    }

    /// "dbs/TC1AAA==/colls/TC1AAMDvwgA=".contentPath = "dbs/TC1AAA=="
    /// "dbs/TC1AAA==/colls/TC1AAMDvwgA=/docs/ZBcw7B==".contentPath = "dbs/TC1AAA==/colls/TC1AAMDvwgA="
    var ancestorPath: String? {
        let components = self.split(separator: "/")
        let count = components.count

        guard count > 2 else { return nil }

        return components[0...(count - 3)].joined(separator: "/")
    }

    /// "dbs/TC1AAA==/colls/TC1AAMDvwgA=".lastPathComponent = "TC1AAMDvwgA="
    var lastPathComponent: String {
        let components = self.split(separator: "/")
        return components.count > 1 ? String(components[components.count - 1]) : self
    }
}
