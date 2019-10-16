// --------------------------------------------------------------------------
//
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// The MIT License (MIT)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the ""Software""), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
//
// --------------------------------------------------------------------------

import Foundation

// MARK: XML Model Protocol

/// Protocol that ensures all XML models have  a method that returns metadata
/// necessary to convert an XML payload to a JSON payload.
public protocol XMLModelProtocol {
    static func xmlMap() -> XMLMap
}

// MARK: XML Metadata

public enum ElementToJsonStrategy {
    case property
    case anyObject
    case object(XMLModelProtocol.Type)
    case array(XMLModelProtocol.Type)
    case arrayItem(XMLModelProtocol.Type)
    case ignored
}

public enum AttributeToJsonStrategy {
    case ignored, underscoredProperties
}

/// Class containing metadata needed to translate an XML payload into the desired
/// JSON payload.
public struct XMLMetadata {
    public let jsonName: String
    public let jsonType: ElementToJsonStrategy
    public let attributeStrategy: AttributeToJsonStrategy

    public init(jsonName: String, jsonType: ElementToJsonStrategy = .property,
                attributes: AttributeToJsonStrategy = .ignored) {
        self.jsonName = jsonName
        self.jsonType = jsonType
        attributeStrategy = attributes
    }
}

// MARK: XML Map

/// A map of XML document path keys and metadata needed to convert an XML
/// payload into a JSON payload.
public class XMLMap: Sequence, IteratorProtocol {
    public typealias Element = (String, XMLMetadata)

    internal var map = [String: XMLMetadata]()
    internal var mapIterator: Dictionary<String, XMLMetadata>.Iterator?

    public func next() -> (String, XMLMetadata)? {
        if mapIterator == nil {
            mapIterator = map.makeIterator()
        }
        return mapIterator?.next()
    }

    /// Initialize directly with paths and values
    public init(_ existingValues: [String: XMLMetadata]) {
        map = existingValues
    }

    /// Generate XML map for single item types.
    public init(withType typeVal: XMLModelProtocol.Type, prefix: String? = nil) {
        for (key, metadata) in typeVal.xmlMap() {
            let keyPrefix = prefix != nil ? "\(prefix!).\(key)" : key
            switch metadata.jsonType {
            case let .object(type):
                let submodelMap = XMLMap(withType: type)
                for (subkey, subvalue) in submodelMap {
                    map["\(keyPrefix).\(subkey)"] = subvalue
                }
            case let .arrayItem(type):
                let submodelMap = XMLMap(withType: type)
                for (subkey, subvalue) in submodelMap {
                    map["\(keyPrefix).\(subkey)"] = subvalue
                }
            default:
                break
            }
            map[keyPrefix] = metadata
        }
    }

    /// Generate XML map for PagedCollection types.
    public init(withPagedCodingKeys codingKeys: PagedCodingKeys, innerType: XMLModelProtocol.Type) {
        guard let xmlItemName = codingKeys.xmlItemName else {
            fatalError("Coding Keys for XML must specify the element name for collection items.")
        }
        // ensure all parts of the items path exist and the collection metadata is specfied.
        let itemComponents = codingKeys.items.components(separatedBy: ".")
        var path = [String]()
        for component in itemComponents {
            path.append(component)
            let metadata = XMLMetadata(jsonName: component, jsonType: .anyObject,
                                       attributes: .underscoredProperties)
            map[path.joined(separator: ".")] = metadata
        }
        guard let itemsMetadata = map[codingKeys.items] else { return }
        map[codingKeys.items] = XMLMetadata(jsonName: itemsMetadata.jsonName, jsonType: .array(innerType),
                                            attributes: .underscoredProperties)

        // ensure all parts of the token path exist
        let tokenComponents = codingKeys.continuationToken.components(separatedBy: ".")
        path = [String]()
        for component in tokenComponents {
            path.append(component)
            let metadata = XMLMetadata(jsonName: component, jsonType: .anyObject,
                                       attributes: .underscoredProperties)
            map[path.joined(separator: ".")] = metadata
        }
        guard let tokenMetadata = map[codingKeys.continuationToken] else { return }
        map[codingKeys.continuationToken] = XMLMetadata(jsonName: tokenMetadata.jsonName, jsonType: .property)

        // ensure that the "item" element name is in the map even though it will disappear from the JSON
        let prefix = "\(codingKeys.items).\(xmlItemName)"
        map[prefix] = XMLMetadata(jsonName: xmlItemName, jsonType: .arrayItem(innerType),
                                  attributes: .underscoredProperties)

        // update the map with the map of the inner type
        let modelMap = XMLMap(withType: innerType, prefix: prefix)
        map = map.merging(modelMap) { _, new in new }
    }

    /// Accept a dot-separated path to get to XML properties. Returns nil if
    /// at any point a sub-key is not found.
    public subscript(index: String) -> XMLMetadata? {
        get {
            return map[index]
        }

        set {
            map[index] = newValue
        }
    }
}

// MARK: XML Tree

internal class XMLTree {
    internal var root: XMLTreeNode

    public init() {
        root = XMLTreeNode(name: "__ROOT__", type: .ignored, parent: nil)
    }

    var dictionary: [String: Any]? {
        return root.dictionary
    }

    var array: [Any]? {
        return root.array
    }
}

// MARK: XML Tree Node

internal class XMLTreeNode {
    var dictionary: [String: Any]? {
        var propDict = [String: Any]()
        for (key, metadata) in properties {
            switch metadata.type {
            case .property:
                propDict[key] = metadata.value
            case .object, .arrayItem, .anyObject:
                if let dictValue = metadata.dictionary {
                    propDict[key] = dictValue
                } else {
                    fatalError("Failed to get dictionary version of object.")
                }
            case .array:
                if let arrayValue = metadata.array {
                    propDict[key] = arrayValue
                } else {
                    fatalError("Failed to get array version of object.")
                }
            case .ignored:
                break
            }
        }
        return propDict
    }

    var array: [Any]? {
        var array = [Any]()
        for item in collection {
            if let itemDict = item.dictionary {
                array.append(itemDict)
            }
        }
        return array
    }

    var name: String
    var type: ElementToJsonStrategy
    var value: String
    var properties = [String: XMLTreeNode]()
    var collection = [XMLTreeNode]()
    var parent: XMLTreeNode?

    init(name: String, type: ElementToJsonStrategy, parent: XMLTreeNode?, value: String = "") {
        self.name = name
        self.parent = parent
        self.value = value
        self.type = type
    }
}
