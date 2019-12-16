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

public class ContentDecodePolicy: NSObject, PipelineStageProtocol, XMLParserDelegate {
    public var next: PipelineStageProtocol?
    public let jsonRegex = NSRegularExpression("^(application|text)/([0-9a-z+.]+)?json$")
    public var logger: ClientLogger?

    private func parse(xml data: Data) throws -> AnyObject {
        let parser = XMLParser(data: data)
        parser.delegate = self
        _ = parser.parse()
        var jsonData: Data?
        if let dictObj = xmlTree?.dictionary {
            jsonData = try? JSONSerialization.data(withJSONObject: dictObj, options: [])
        } else if let arrayObj = xmlTree?.array {
            jsonData = try JSONSerialization.data(withJSONObject: arrayObj, options: [])
        }
        guard let finalJsonData = jsonData else {
            throw HttpResponseError.decode("Failure decoding XML.")
        }
        return try JSONSerialization.jsonObject(with: finalJsonData, options: []) as AnyObject
    }

    private func deserialize(from httpResponse: HttpResponse, contentType: String) throws -> AnyObject? {
        guard let data = httpResponse.data else { return nil }
        if jsonRegex.hasMatch(in: contentType) {
            return try JSONSerialization.jsonObject(with: data, options: []) as AnyObject
        } else if contentType.contains("xml") {
            return try parse(xml: data)
        }
        return nil
    }

    public func onResponse(_ response: PipelineResponse, then completion: (PipelineResponse) -> Void) {
        let stream = response.value(forKey: "stream") as? Bool ?? false
        guard stream == false else { return }
        guard let httpResponse = response.httpResponse else { return }
        var returnResponse = response.copy()

        xmlMap = response.value(forKey: .xmlMap) as? XMLMap

        // Store the logger so that the XML parser delegate functions can access it
        logger = response.logger

        var contentType = (httpResponse.headers["Content-Type"]?.components(separatedBy: ";").first) ??
            "application/json"
        contentType = contentType.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        do {
            if let deserializedJson = try deserialize(from: httpResponse, contentType: contentType) {
                let deserializedData = try JSONSerialization.data(withJSONObject: deserializedJson, options: [])
                returnResponse.add(value: deserializedData as AnyObject, forKey: .deserializedData)
            }
        } catch {
            response.logger.error(String(format: "Deserialization error: %@", error.localizedDescription))
        }
        completion(returnResponse)
    }

    // MARK: - XML Parser Delegate

    internal var xmlMap: XMLMap?
    internal var xmlTree: XMLTree?
    internal var currNode: XMLTreeNode?
    internal var elementPath = [String]()
    internal var inferStructure = false

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

    public func parser(_: XMLParser, didStartElement elementName: String, namespaceURI _: String?,
                       qualifiedName _: String?, attributes attributeDict: [String: String] = [:]) {
        elementPath.append(elementName)
        let elementKey = elementPath.joined(separator: ".")
        let jsonName = xmlMap?[elementKey]?.jsonName
        let newNode = XMLTreeNode(name: jsonName ?? elementName, type: .ignored, parent: currNode ?? xmlTree?.root)
        defer { currNode = newNode }

        let mapKey = elementPath.joined(separator: ".")
        guard !inferStructure else { return }
        guard let mapData = xmlMap?[mapKey] else {
            logger?.warning("No XML metadata found for \(elementName). Ignoring.")
            return
        }
        switch mapData.attributeStrategy {
        case .ignored:
            return
        case .underscoredProperties:
            for (key, value) in attributeDict {
                let attr = XMLTreeNode(name: key, type: .property, parent: newNode, value: value)
                newNode.properties["_\(key)"] = attr
            }
        }
    }

    public func parser(_: XMLParser, foundCharacters string: String) {
        currNode?.type = .property
        currNode?.value = string
    }

    public func parser(_: XMLParser, didEndElement elementName: String, namespaceURI _: String?,
                       qualifiedName _: String?) {
        defer {
            _ = elementPath.popLast()
            let nextNode = currNode?.parent
            currNode?.parent = nil
            currNode = nextNode
        }
        guard let current = currNode else { return }
        guard let parent = currNode?.parent else { return }
        guard let xmlTree = xmlTree else { return }

        let mapKey = elementPath.joined(separator: ".")
        if let mapData = xmlMap?[mapKey] {
            currNode?.type = mapData.jsonType
            switch mapData.jsonType {
            case .property:
                parent.properties[current.name] = current
            case .object, .array, .anyObject:
                parent.properties[current.name] = current
            case .arrayItem:
                parent.collection.append(current)
            case .ignored:
                break
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
        if let logger = logger {
            logger.error(String(format: "XML Parse Error: %@", parseError.localizedDescription))
        }
    }
}
