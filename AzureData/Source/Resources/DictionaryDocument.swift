//
//  DictionaryDocument.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Represents a document in the Azure Cosmos DB service.
///
/// - Remark:
///   A document is a structured JSON document. There is no set schema for the JSON documents,
///   and a document may contain any number of custom properties as well as an optional list of attachments.
///   Document is an application resource and can be authorized using the master key or resource keys.
public class DictionaryDocument : Document {
    
    let sysKeys = ["id", "_rid", "_self", "_etag", "_ts", "_attachments"]
    

    public private(set) var data: CodableDictionary?
    
    
    public override init () { super.init() }
    public override init (_ id: String) { super.init(id) }
    
    
    public subscript (key: String) -> Any? {
        get { return data?[key] }
        set {
            assert(Swift.type(of: self) == DictionaryDocument.self, "Error: Subscript cannot be used on children of DictionaryDocument\n")
            assert(!sysKeys.contains(key), "Error: Subscript cannot be used to set the following system generated properties: \(sysKeys.joined(separator: ", "))\n")
            
            if data == nil { data = CodableDictionary() }
            
            data![key] = newValue
        }
    }
    
    public required init(from decoder: Decoder) throws {
        
        try super.init(from: decoder)
        
        if Swift.type(of: self) == DictionaryDocument.self {
            
            let userContainer = try decoder.container(keyedBy: UserCodingKeys.self)
            
            data = CodableDictionary()
            
            let userKeys = userContainer.allKeys.filter { !sysKeys.contains($0.stringValue) }
            
            for key in userKeys {
                data![key.stringValue] = (try? userContainer.decode(CodableDictionaryValueType.self, forKey: key))?.value
            }
        }
    }
    
    
    public override func encode(to encoder: Encoder) throws {
        
        try super.encode(to: encoder)
        
        if Swift.type(of: self) == DictionaryDocument.self {
            
            var userContainer = encoder.container(keyedBy: UserCodingKeys.self)
            
            if let data = data {
                
                for (k, v) in data {
                    
                    let key = UserCodingKeys(stringValue: k)!
                    
                    switch v {
                    case .uuid(let value): try userContainer.encode(value, forKey: key)
                    case .bool(let value): try userContainer.encode(value, forKey: key)
                    case .int(let value): try userContainer.encode(value, forKey: key)
                    case .double(let value): try userContainer.encode(value, forKey: key)
                    case .float(let value): try userContainer.encode(value, forKey: key)
                    case .date(let value): try userContainer.encode(value, forKey: key)
                    case .string(let value): try userContainer.encode(value, forKey: key)
                    case .dictionary(let value): try userContainer.encode(value, forKey: key)
                    case .array(let value): try userContainer.encode(value, forKey: key)
                    default: break
                    }
                }
            }
        }
    }
    
    private struct UserCodingKeys : CodingKey {
        
        let key: String
        
        var stringValue: String {
            return key
        }
        
        init?(stringValue: String) {
            key = stringValue
        }
        
        var intValue: Int? { return nil }
        
        
        init?(intValue: Int) { return nil }
    }
    
    public override var debugDescription: String {
        return "DictionaryDocument :\n\tid : \(self.id)\n\tresourceId : \(self.resourceId)\n\tselfLink : \(self.selfLink.valueOrNilString)\n\tetag : \(self.etag.valueOrNilString)\n\ttimestamp : \(self.timestamp.valueOrNilString)\n\tattachmentsLink : \(self.attachmentsLink.valueOrNilString)\n\t\(self.data?.dictionary.map { "\($0) : \($1 ?? "nil")" }.joined(separator: "\n\t") ?? "nil")\n--"
    }
}
