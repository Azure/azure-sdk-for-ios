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

// MARK: XML Metadata

public enum ElementToJsonStrategy {
    /// convert element to a JSON property
    case property

    /// convert element to `AnyObject`
    case anyObject

    /// convert element to another `XMLModel` type.
    case object(XMLModel.Type)

    /// convert element to an arry of `XMLModel`
    case array(XMLModel.Type)

    case arrayItem(XMLModel.Type)

    /// Ignore element entirely
    case ignored

    /// flatten element children up one level
    case flatten
}

public enum AttributeToJsonStrategy {
    case ignored, underscoredProperties
}

/// Class containing metadata needed to translate an XML payload into the desired
/// JSON payload.
public struct XMLMetadata {
    // MARK: Properties

    public let jsonName: String
    public let jsonType: ElementToJsonStrategy
    public let attributeStrategy: AttributeToJsonStrategy

    // MARK: Initializers

    public init(
        jsonName: String,
        jsonType: ElementToJsonStrategy = .property,
        attributes: AttributeToJsonStrategy = .ignored
    ) {
        self.jsonName = jsonName
        self.jsonType = jsonType
        self.attributeStrategy = attributes
    }
}

// MARK: XML Map

/// A map of XML document path keys and metadata needed to convert an XML
/// payload into a JSON payload.
public class XMLMap: Sequence, IteratorProtocol {
    // MARK: Properties

    public typealias Element = (String, XMLMetadata)

    var map = [String: XMLMetadata]()
    var mapIterator: Dictionary<String, XMLMetadata>.Iterator?

    // MARK: Initializers

    /// Initialize directly with paths and values
    public init(_ existingValues: [String: XMLMetadata]) {
        self.map = existingValues
    }

    /// Generate XML map for single item types.
    init(withType typeVal: XMLModel.Type, prefix: String? = nil) {
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
    public init(withPagedCodingKeys codingKeys: PagedCodingKeys, innerType: XMLModel.Type) {
        guard let xmlItemName = codingKeys.xmlItemName else {
            fatalError("Coding Keys for XML must specify the element name for collection items.")
        }
        // ensure all parts of the items path exist and the collection metadata is specfied.
        let itemComponents = codingKeys.items.components(separatedBy: ".")
        var path = [String]()
        for component in itemComponents {
            path.append(component)
            let metadata = XMLMetadata(
                jsonName: component,
                jsonType: .anyObject,
                attributes: .underscoredProperties
            )
            map[path.joined(separator: ".")] = metadata
        }
        guard let itemsMetadata = map[codingKeys.items] else { return }
        map[codingKeys.items] = XMLMetadata(
            jsonName: itemsMetadata.jsonName,
            jsonType: .array(innerType),
            attributes: .underscoredProperties
        )

        // ensure all parts of the token path exist
        let tokenComponents = codingKeys.continuationToken.components(separatedBy: ".")
        path = [String]()
        for component in tokenComponents {
            path.append(component)
            let metadata = XMLMetadata(
                jsonName: component,
                jsonType: .anyObject,
                attributes: .underscoredProperties
            )
            map[path.joined(separator: ".")] = metadata
        }
        guard let tokenMetadata = map[codingKeys.continuationToken] else { return }
        map[codingKeys.continuationToken] = XMLMetadata(jsonName: tokenMetadata.jsonName, jsonType: .property)

        // ensure that the "item" element name is in the map even though it will disappear from the JSON
        let prefix = "\(codingKeys.items).\(xmlItemName)"
        map[prefix] = XMLMetadata(
            jsonName: xmlItemName,
            jsonType: .arrayItem(innerType),
            attributes: .underscoredProperties
        )

        // update the map with the map of the inner type
        let modelMap = XMLMap(withType: innerType, prefix: prefix)
        self.map = map.merging(modelMap) { _, new in new }
    }

    // MARK: Public Methods

    public func next() -> (String, XMLMetadata)? {
        if mapIterator == nil {
            mapIterator = map.makeIterator()
        }
        return mapIterator?.next()
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
