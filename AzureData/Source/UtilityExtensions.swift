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
        @unknown default:
            return "decodeError: unknown\n"
        }
    }
}

extension HTTPURLResponse {
    var msAltContentPath: String? {
        return allHeaderFields[MSHttpHeader.msAltContentPath.rawValue] as? String
    }

    var msContinuation: String? {
        return allHeaderFields[MSHttpHeader.msContinuation.rawValue] as? String
    }

    var msContentPath: String? {
        return allHeaderFields[MSHttpHeader.msContentPath.rawValue] as? String
    }

    func withValue(_ value: String, forHeader header: String) -> HTTPURLResponse? {
        var headers = [String: String]()
        for (key, value) in allHeaderFields {
            headers[String(describing: key)] = String(describing: value)
        }

        headers[header] = value

        return HTTPURLResponse(url: self.url ?? URL(string: "nourl://")!, statusCode: statusCode, httpVersion: "HTTP/1.1", headerFields: headers)
    }
}

extension Optional where Wrapped == HTTPURLResponse {
    func withValue(_ value: String, forHeader header: String) -> HTTPURLResponse? {
        guard let response = self else {
            return HTTPURLResponse(url: URL(string: "nourl://")!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: [header: value])
        }

        return response.withValue(value, forHeader: header)
    }
}

extension String {
    func extractId(for resourceType: ResourceType) -> String? {
        return extractId(for: resourceType.rawValue)
    }

    func extractId(for resourceType: String) -> String? {
        let path = Substring(resourceType)
        let split = self.split(separator: "/")

        if let key = split.firstIndex(of: path), key < split.endIndex {
            return String(split[split.index(after: key)])
        }

        return nil
    }

    func extractParent() -> (type: ResourceType?, id: String)? {
        let components = split(separator: "/")
        let count = components.count
        guard count >= 4 else { return nil }
        return (ResourceType(rawValue: String(components[count - 4])), String(components[count - 3]))
    }

    var resourceType: ResourceType? {
        guard let (directory, _) = self.path else { return nil }
        return ResourceType(rawValue: directory.lastPathComponent)
    }

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

    /// "dbs/TC1AAA==/colls/TC1AAMDvwgA=".lastPathComponentRemoved = "dbs/TC1AAA==/colls"
    var lastPathComponentRemoved: String {
        let components = self.split(separator: "/")
        return components.dropLast().joined(separator: "/")
    }
}

extension CodableResource {
    var parentLocation: ResourceLocation? {
        guard let selfLink = selfLink else { return nil }
        guard let parent = selfLink.extractParent() else { return nil }
        guard let resourceType = parent.type else { return nil }

        switch resourceType {
        case .attachment:
            return ResourceLocation.attachment(databaseId: selfLink.extractId(for: .database)!, collectionId: selfLink.extractId(for: .collection)!, documentId: selfLink.extractId(for: .document)!, id: parent.id)
        case .collection:
            return ResourceLocation.collection(databaseId: selfLink.extractId(for: .database)!, id: parent.id)
        case .database:
            return ResourceLocation.database(id: parent.id)
        case .document:
            return ResourceLocation.document(databaseId: selfLink.extractId(for: .database)!, collectionId: selfLink.extractId(for: .collection)!, id: parent.id)
        case .offer:
            return ResourceLocation.offer(id: parent.id)
        case .permission:
            return ResourceLocation.permission(databaseId: selfLink.extractId(for: .database)!, userId: selfLink.extractId(for: .user)!, id: parent.id)
        case .storedProcedure:
            return ResourceLocation.storedProcedure(databaseId: selfLink.extractId(for: .database)!, collectionId: selfLink.extractId(for: .collection)!, id: parent.id)
        case .trigger:
            return ResourceLocation.trigger(databaseId: selfLink.extractId(for: .database)!, collectionId: selfLink.extractId(for: .collection)!, id: parent.id)
        case .user:
            return ResourceLocation.user(databaseId: selfLink.extractId(for: .user)!, id: parent.id)
        case .udf:
            return ResourceLocation.udf(databaseId: selfLink.extractId(for: .database)!, collectionId: selfLink.extractId(for: .collection)!, id: parent.id)
        case .partitionKeyRange:
            return ResourceLocation.partitionKeyRange(databaseId: selfLink.extractId(for: .database)!, collectionId: selfLink.extractId(for: .collection)!, id: parent.id)
        }
    }
}
