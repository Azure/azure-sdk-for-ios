//
//  ContentDecodePolicy.swift
//  AzureCore
//
//  Created by Travis Prescott on 9/27/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation
import os.log

public class ContentDecodePolicy: NSObject, PipelineStageProtocol, XMLParserDelegate {

    public var next: PipelineStageProtocol?
    public let jsonRegex = NSRegularExpression("^(application|text)/([0-9a-z+.]+)?json$")

    private func removeAMPSemicolor(_ string: String) -> String {
        return string.replacingOccurrences(of: "amp;", with: "")
    }

    private func replaceAnd(_ string: String) -> String {
        return string.replacingOccurrences(of: "&", with: "And")
    }

    private func replaceNewLines(_ string: String) -> String {
        return string.replacingOccurrences(of: "\n", with: "; ")
    }

    private func replaceAposWithApos(_ string: String) -> String {
        return string.replacingOccurrences(of: "Andapos;", with: "'")
    }

    private func parse(xml data: Data) throws -> AnyObject {
        let parser = XMLParser(data: data)
        parser.delegate = self
        _ = parser.parse()
        var jsonData: Data?
        if let dictObj = root?.dictionary {
            jsonData = try? JSONSerialization.data(withJSONObject: dictObj, options: [])
        } else if let arrayObj = root?.array {
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

    public func onResponse(_ response: inout PipelineResponse) {
        let stream = response.getValue(forKey: "stream") as? Bool ?? false
        guard stream == false else { return }
        guard let httpResponse = response.httpResponse else { return }

        var contentType = (httpResponse.headers["Content-Type"]?.components(separatedBy: ";").first) ??
                          "application/json"
        contentType = contentType.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        do {
            if let deserializedJson = try deserialize(from: httpResponse, contentType: contentType) {
                let deserializedData = try JSONSerialization.data(withJSONObject: deserializedJson, options: [])
                response.add(value: deserializedData as AnyObject, forKey: .deserializedData)
            }
        } catch {
            os_log("Deserialization error: %@", error.localizedDescription)
        }
    }

    // MARK: - XML Parser Delegate

    var root: XMLTreeNode?
    var currNode: XMLTreeNode?

    public func parserDidStartDocument(_ parser: XMLParser) {
        root = XMLTreeNode(name: "_ROOT_", parent: nil)
    }

    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?,
                       qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        let newNode = XMLTreeNode(name: elementName, parent: currNode ?? root)
        // any XML attributes are promoted to private properties
        for (key, value) in attributeDict {
            let attr = XMLTreeNode(name: key, parent: newNode, type: .property, value: value)
            newNode.properties[key] = attr
        }
        currNode = newNode
    }

    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        currNode?.value = string
        currNode?.type = .property
    }

    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?,
                       qualifiedName qName: String?) {
        guard let current = currNode else { return }
        guard let parent = currNode?.parent else {
            return
        }
        switch current.type {
        case .property:
            parent.properties[current.name] = current
        case .array, .object:
            if parent.type == .array {
                parent.collection[current.name]?.append(current)
            } else if parent.properties.keys.contains(elementName) {
                // TODO: This will fail to find collections if there is only
                // one element in the XML array.

                // existing item and current item should be
                // added to the parent's items array
                parent.type = .array
                let existingItem = parent.properties[elementName]!
                parent.properties.removeValue(forKey: elementName)
                parent.collection[elementName] = [existingItem, current]
            } else {
                // simply add the object as a property to the parent
                parent.properties[elementName] = current
            }
        }
        currNode = parent
    }

    public func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        os_log("XML Parse Error: %@", parseError.localizedDescription)
    }
}

internal class XMLTreeNode {

    var dictionary: [String: Any]? {
        guard self.type == .object else { return nil }
        var propDict = [String: Any]()
        for (key, value) in self.properties {
            switch value.type {
            case .property:
                propDict[key] = value.value
            case .object:
                if let dictValue = value.dictionary {
                    propDict[key] = dictValue
                } else {
                    fatalError("Failed to get dictionary version of object.")
                }
            case .array:
                if let arrayValue = value.array {
                    propDict[key] = arrayValue
                } else {
                    fatalError("Failed to get array version of object.")
                }
            }
        }
        return propDict
    }

    var array: [Any]? {
        guard self.type == .array else { return nil }
        guard self.collection.keys.count == 1 else { fatalError("Unexpectedly found nonhomogenous collection.") }
        var array = [Any]()
        for (_, items) in self.collection {
            for item in items {
                switch item.type {
                case .object:
                    if let itemDict = item.dictionary {
                        array.append(itemDict)
                    }
                case .array:
                    fatalError("Unexpectedly found array element in array.")
                case .property:
                    fatalError("Unexpectedly found property in array.")
                }
            }
        }
        return array
    }

    internal enum ElementType {
        case property, object, array
    }

    var type: ElementType
    var name: String
    var value: String
    var properties = [String: XMLTreeNode]()
    var collection = [String: [XMLTreeNode]]()
    var parent: XMLTreeNode?

    init(name: String, parent: XMLTreeNode?, type: ElementType = .object, value: String = "") {
        self.name = name
        self.parent = parent
        self.type = type
        self.value = value
    }
}
