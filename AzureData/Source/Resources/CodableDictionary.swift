//
//  CodableDictionary.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation


/// Warning: boolean values must be written as true and false, not 1 and 0.
///     CodableDictionary does not recognize the abbreviated integer form.
public struct CodableDictionary {
    
    public typealias Key = String
    public typealias Value = CodableDictionaryValueType
    public typealias DictionaryType = [Key: Value]
    
    public var dictionary: [Key: Any?] {
        return Dictionary(uniqueKeysWithValues: internalDictionary.map {
            if let d = ($0.1).value as? CodableDictionary {
                return ($0.0, d.dictionary)
            } else {
                return ($0.0, ($0.1).value)
            }
        })
    }

    private var internalDictionary: DictionaryType
    
    public init(_ dictionary: [String: Any?] = [:]) {
        guard !dictionary.isEmpty else {
            self.internalDictionary = [:]
            return
        }
        self.internalDictionary = Dictionary(uniqueKeysWithValues: dictionary.map {
            if let d = $0.1 as? [String: Any?] {
                return ($0.0, CodableDictionaryValueType(CodableDictionary(d)))
            } else {
                return ($0.0, CodableDictionaryValueType($0.1))
            }
        })
    }
}

extension CodableDictionary: Collection {

    public typealias Indices = DictionaryType.Indices
    public typealias Iterator = DictionaryType.Iterator
    public typealias SubSequence = DictionaryType.SubSequence
    
    public var startIndex: Index { return internalDictionary.startIndex }
    public var endIndex: DictionaryType.Index { return internalDictionary.endIndex }
    public subscript(position: Index) -> Iterator.Element { return internalDictionary[position] }
    public subscript(bounds: Range<Index>) -> SubSequence { return internalDictionary[bounds] }
    public var indices: Indices { return internalDictionary.indices }
    
    public subscript(key: Key) -> Any? {
        get { return internalDictionary[key]?.value ?? nil }
        set(newValue) { internalDictionary[key] = CodableDictionaryValueType(newValue) }
    }
    
    public func index(after index: Index) -> Index {
        return internalDictionary.index(after: index)
    }
    
    public func makeIterator() -> DictionaryIterator<Key, Value> {
        return internalDictionary.makeIterator()
    }
    
    public typealias Index = DictionaryType.Index
}

extension CodableDictionary:  ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (Key, Value)...) {
        internalDictionary = DictionaryType(uniqueKeysWithValues: elements)
    }
}

extension CodableDictionary: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        internalDictionary = try container.decode(DictionaryType.self)
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(internalDictionary)
    }
}

extension CodableDictionary: CustomDebugStringConvertible {
    public var debugDescription: String { return dictionary.debugDescription }
}

extension CodableDictionary: CustomStringConvertible {
    public var description: String { return dictionary.description }
}


/// A wrapper for the permitted Codable value types.
/// Permits generic dictionary encoding/decoding when used with CodableDictionary.
public enum CodableDictionaryValueType: Codable {
    case uuid(UUID)
    case bool(Bool)
    case int(Int)
    case double(Double)
    case float(Float)
    case date(Date)
    case string(String)
    indirect case dictionary(CodableDictionary)
    indirect case array([CodableDictionaryValueType])
    case empty
    
    //    public init(_ value: Date) { self = .date(value) }
    //    public init(_ value: UUID) { self = .uuid(value) }
    //    public init(_ value: Int) { self = .int(value) }
    //    public init(_ value: Float) { self = .float(value) }
    //    public init(_ value: Bool) { self = .bool(value) }
    //    public init(_ value: String) { self = .string(value) }
    //    public init(_ value: CodableDictionary) { self = .dictionary(value) }
    //    // nil?
    
    public init(_ value: Any?) {
        self = {
            if let value = value as? UUID {
                return .uuid(value)
            } else if let value = value as? Bool {
                return .bool(value)
            } else if let value = value as? Int {
                return .int(value)
            } else if let value = value as? Double {
                // FYI, Int values are currently encoded to double in CK :(
                return .double(value)
            } else if let value = value as? Float {
                return .float(value)
            } else if let value = value as? Date {
                return .date(value)
            } else if let value = value as? String {
                return .string(value)
            } else if let value = value as? CodableDictionary {
                return .dictionary(value)
            } else if let value = value as? [Any?] {
                return .array(value.map {
                    guard let row = $0 else { return .empty }
                    if let d = row as? [String: Any?] {
                        return CodableDictionaryValueType(CodableDictionary(d))
                    } else {
                        return CodableDictionaryValueType(row)
                    }
                })
            } else {
                return .empty
            }
        }()
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self = {
            if let value = try? container.decode(CodableDictionary.self) {
                return .dictionary(value)
            } else if let value = try? container.decode([CodableDictionaryValueType].self) {
                return .array(value)
            } else if let value = try? container.decode(UUID.self) {
                return .uuid(value)
            } else if let value = try? container.decode(Bool.self) {
                return .bool(value)
            } else if let value = try? container.decode(Int.self) {
                return .int(value)
            } else if let value = try? container.decode(Double.self) {
                return .double(value)
            } else if let value = try? container.decode(Float.self) {
                return .float(value)
            } else if let value = try? container.decode(Date.self) {
                return .date(value)
            } else if let value = try? container.decode(String.self) {
                return .string(value)
            } else {
                return .empty
            }
        }()
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .uuid(let value): try container.encode(value)
        case .bool(let value): try container.encode(value)
        case .int(let value): try container.encode(value)
        case .double(let value): try container.encode(value)
        case .float(let value): try container.encode(value)
        case .date(let value): try container.encode(value)
        case .string(let value): try container.encode(value)
        case .dictionary(let value): try container.encode(value)
        case .array(let value): try container.encode(value)
        default: try container.encodeNil()
        }
    }
    
    public var value: Any? {
        switch self {
        case .uuid(let value): return value
        case .bool(let value): return value
        case .int(let value): return value
        case .double(let value): return value
        case .float(let value): return value
        case .date(let value): return value
        case .string(let value): return value
        case .dictionary(let value): return value
        case .array(let value): return value.map { $0.value }
        default: return nil
        }
    }
}

extension CodableDictionaryValueType: CustomDebugStringConvertible {
    public var debugDescription: String { return String(describing: value) }
}

extension CodableDictionaryValueType: CustomStringConvertible {
    public var description: String { return String(describing: value) }
}
