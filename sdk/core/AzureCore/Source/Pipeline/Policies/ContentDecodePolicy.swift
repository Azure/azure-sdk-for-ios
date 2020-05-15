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
import os.log

internal class ContentDecodeXMLParser: NSObject, XMLParserDelegate {
    // MARK: Properties

    internal var xmlMap: XMLMap?
    internal var xmlTree: XMLTree?
    internal var currNode: XMLTreeNode?
    internal var elementPath = [String]()
    internal var elementKey: String {
        return elementPath.joined(separator: ".")
    }

    internal var mapPath = [String]()
    internal var mapKey: String {
        return mapPath.joined(separator: ".")
    }

    internal var inferStructure = false
    internal var logger: ClientLogger?

    // MARK: Methods

    public func parserDidStartDocument(_: XMLParser) {
        inferStructure = xmlMap == nil
        if inferStructure {
            logger?.warning("No XML map found. Inferring structure of XML document.")
        }
        xmlTree = XMLTree()
    }

    public func parserDidEndDocument(_: XMLParser) {
        guard let current = currNode else { return }
        // ensure the XML tree root is updated
        xmlTree?.root = current
    }

    public func parser(
        _: XMLParser,
        didStartElement elementName: String,
        namespaceURI _: String?,
        qualifiedName _: String?,
        attributes attributeDict: [String: String] = [:]
    ) {
        elementPath.append(elementName)

        // resolve the map key
        let elementMetadata = xmlMap?[elementKey]
        switch elementMetadata?.jsonType {
        case .flatten:
            break
        default:
            mapPath.append(elementName)
        }

        // the rest of the method should use only the map key
        let mapMetadata = xmlMap?[mapKey]
        let jsonName = mapMetadata?.jsonName
        let newNode = XMLTreeNode(name: jsonName ?? elementName, type: .ignored, parent: currNode ?? xmlTree?.root)
        defer { currNode = newNode }

        let metadata = mapMetadata ?? elementMetadata

        if xmlMap != nil, metadata == nil {
            logger?.warning("No XML metadata found for \(elementName). Ignoring.")
            return
        }

        let attributeStrategy = metadata?.attributeStrategy ?? AttributeToJsonStrategy.underscoredProperties
        switch attributeStrategy {
        case .ignored:
            return
        case .underscoredProperties:
            for (key, value) in attributeDict {
                let defaultKey = "_\(key)"
                let jsonKey = xmlMap?[defaultKey]?.jsonName ?? defaultKey
                let attr = XMLTreeNode(name: jsonKey, type: .property, parent: nil, value: value)
                newNode.properties[jsonKey] = attr
            }
        }
    }

    public func parser(_: XMLParser, foundCharacters string: String) {
        guard string.trimmingCharacters(in: .whitespacesAndNewlines) != "" else { return }
        currNode?.type = .property
        currNode?.value = string
    }

    // swiftlint:disable:next cyclomatic_complexity
    public func parser(
        _: XMLParser,
        didEndElement elementName: String,
        namespaceURI _: String?,
        qualifiedName _: String?
    ) {
        defer {
            _ = elementPath.popLast()
            if mapPath.last == elementName {
                _ = mapPath.popLast()
            }
            let nextNode = currNode?.parent
            currNode?.parent = nil
            currNode = nextNode
        }
        guard let current = currNode else { return }
        guard let parent = currNode?.parent else { return }
        guard let xmlTree = xmlTree else { return }

        if let data = xmlMap?[mapKey] ?? xmlMap?[elementKey] {
            currNode?.type = data.jsonType
            switch data.jsonType {
            case .property:
                parent.properties[current.name] = current
            case .object, .array, .anyObject:
                parent.properties[current.name] = current
            case .arrayItem:
                parent.collection.append(current)
            case .ignored:
                break
            case .flatten:
                parent.properties = current.properties
            }
        } else if inferStructure {
            // When inferring structure, assume the element name is the key and the text
            // is the value. No complex properties or collections are permitted.
            current.type = parent === xmlTree.root ? .anyObject : .property
            parent.properties[current.name] = current
        } else {
            currNode?.type = .ignored
        }
    }

    public func parser(_: XMLParser, parseErrorOccurred parseError: Error) {
        var message = ""
        switch parseError {
        case let parseError as NSError:
            message = "\(parseError.userInfo)"
        default:
            message = parseError.localizedDescription
        }
        logger?.error(String(format: "XML Parse Error: %@", message))
    }
}

public class ContentDecodePolicy: PipelineStage {
    // MARK: Properties

    public var next: PipelineStage?

    internal let jsonRegex = NSRegularExpression("^(application|text)/([0-9a-z+.]+)?json$")
    internal lazy var xmlParser = ContentDecodeXMLParser()

    // MARK: Initializers

    public init() {}

    // MARK: Public Methods

    public func on(response: PipelineResponse, then completion: @escaping OnResponseCompletionHandler) {
        let stream = response.value(forKey: "stream") as? Bool ?? false
        guard stream == false else { return }
        var returnResponse = response.copy()
        defer { completion(returnResponse) }

        guard var contentType = returnResponse.httpResponse?.headers["Content-Type"]?.components(separatedBy: ";").first
        else { return }
        contentType = contentType.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        do {
            if let deserializedJson = try deserialize(from: returnResponse, contentType: contentType) {
                let deserializedData = try JSONSerialization.data(withJSONObject: deserializedJson, options: [])
                returnResponse.add(value: deserializedData as AnyObject, forKey: .deserializedData)
            }
        } catch {
            response.logger.error(String(format: "Deserialization error: %@", error.localizedDescription))
        }
    }

    // MARK: Internal Methods

    internal func parse(xml data: Data) throws -> AnyObject {
        let parser = XMLParser(data: data)
        parser.delegate = xmlParser
        _ = parser.parse()
        var jsonData: Data?
        if let dictObj = xmlParser.xmlTree?.dictionary {
            jsonData = try? JSONSerialization.data(withJSONObject: dictObj, options: [])
        } else if let arrayObj = xmlParser.xmlTree?.array {
            jsonData = try JSONSerialization.data(withJSONObject: arrayObj, options: [])
        }
        guard let finalJsonData = jsonData else {
            throw HTTPResponseError.decode("Failure decoding XML.")
        }
        return try JSONSerialization.jsonObject(with: finalJsonData, options: []) as AnyObject
    }

    internal func deserialize(from response: PipelineResponse, contentType: String) throws -> AnyObject? {
        guard let data = response.httpResponse?.data else { return nil }
        if jsonRegex.hasMatch(in: contentType) {
            return try JSONSerialization.jsonObject(with: data, options: []) as AnyObject
        } else if contentType.contains("xml") {
            xmlParser.xmlMap = response.value(forKey: .xmlMap) as? XMLMap
            xmlParser.logger = response.logger
            return try parse(xml: data)
        }
        return nil
    }
}
