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

class ContentDecodeXMLParser: NSObject, XMLParserDelegate {
    // MARK: Properties

    var xmlMap: XMLMap?
    var xmlTree: XMLTree?
    var currNode: XMLTreeNode?
    var elementPath = [String]()
    var elementKey: String {
        return elementPath.joined(separator: ".")
    }

    var mapPath = [String]()
    var mapKey: String {
        return mapPath.joined(separator: ".")
    }

    var inferStructure = false
    var logger: ClientLogger?

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

    let jsonRegex = NSRegularExpression("^(application|text)/([0-9a-z+.]+)?json$")
    lazy var xmlParser = ContentDecodeXMLParser()

    // MARK: Initializers

    public init() {}

    // MARK: Public Methods

    public func on(response: PipelineResponse, completionHandler: @escaping OnResponseCompletionHandler) {
        let stream = response.value(forKey: "stream") as? Bool ?? false
        guard stream == false else { return }
        var returnResponse = response.copy()
        var returnError: AzureError?
        defer { completionHandler(returnResponse, returnError) }
        guard let contentType = returnResponse.httpResponse?.contentTypes?.first else { return }

        do {
            if let deserializedData = try deserialize(
                from: returnResponse,
                contentType: contentType,
                withKey: .xmlMap
            ) {
                returnResponse.add(value: deserializedData, forKey: .deserializedData)
            }
        } catch {
            if let azureError = error as? AzureError {
                returnError = azureError
            } else {
                returnError = AzureError.client("Deserialization error.", error)
            }
            if let err = returnError {
                response.logger.error(err.message)
            }
        }
    }

    public func on(
        error: AzureError,
        pipelineResponse: PipelineResponse,
        completionHandler: @escaping OnErrorCompletionHandler
    ) {
        let stream = pipelineResponse.value(forKey: "stream") as? Bool ?? false
        var returnError = error
        defer {
            completionHandler(returnError, false)
        }
        guard stream == false else { return }
        guard let contentType = pipelineResponse.httpResponse?.contentTypes?.first else { return }
        guard let deserializedError = try? deserialize(
            from: pipelineResponse,
            contentType: contentType,
            withKey: .xmlErrorMap
        ) as? Data,
            let innerErrorString = String(data: deserializedError, encoding: .utf8)
        else {
            return
        }
        let innerError = AzureError.service(innerErrorString, nil)
        returnError = AzureError.service(error.message, innerError)
    }

    // MARK: Internal Methods

    func parse(xml data: Data) throws -> AnyObject {
        let parser = XMLParser(data: data)
        parser.delegate = xmlParser
        _ = parser.parse()
        var jsonData: Data?
        if let dictObj = xmlParser.xmlTree?.dictionary {
            jsonData = try JSONSerialization.data(withJSONObject: dictObj, options: [])
        } else if let arrayObj = xmlParser.xmlTree?.array {
            jsonData = try JSONSerialization.data(withJSONObject: arrayObj, options: [])
        }
        guard let finalJson = jsonData else {
            throw AzureError.client("Unable to convert XML to JSON", nil)
        }
        return try JSONSerialization.jsonObject(with: finalJson, options: []) as AnyObject
    }

    func deserialize(
        from response: PipelineResponse,
        contentType: String,
        withKey key: ContextKey
    ) throws -> AnyObject? {
        guard let data = response.httpResponse?.data else { return nil }
        if jsonRegex.hasMatch(in: contentType) {
            return data as AnyObject
        } else if contentType.contains("xml") {
            xmlParser.xmlMap = response.value(forKey: key) as? XMLMap
            xmlParser.logger = response.logger
            let jsonData = try parse(xml: data)
            return try JSONSerialization.data(withJSONObject: jsonData, options: []) as AnyObject
        }
        return nil
    }
}
