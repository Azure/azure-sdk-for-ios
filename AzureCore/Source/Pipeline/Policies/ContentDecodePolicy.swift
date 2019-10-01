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

    private func parse(xml data: Data) throws -> AnyObject? {
        guard var xmlString = String(data: data, encoding: .utf8) else { return nil }
        xmlString = replaceAnd(xmlString)
        xmlString = replaceAposWithApos(xmlString)
        guard let xmlData = xmlString.data(using: .utf8) else { return nil }
        let parser = XMLParser(data: xmlData)
        parser.delegate = self
        _ = parser.parse()
        for element in elements {
            if jsonString.contains("\(element)@},\"\(element)\":") {
                if !arrayElements.contains(element) {
                    arrayElements.append(element)
                }
            }
            jsonString = jsonString.replacingOccurrences(of: "\(element)@},\"\(element)\":", with: "},")
        }

        for element in arrayElements {
            jsonString = jsonString.replacingOccurrences(of: "\"\(element)\":", with: "\"\(element)\":[")
        }

        for element in elements {
            jsonString = jsonString.replacingOccurrences(of: "\(element)@", with: "")
        }

        jsonString = replaceNewLines(jsonString)
        jsonString = jsonString.replacingOccurrences(of: ":[//s]?\"[\\s]+?\"#", with: ":{",
                                                     options: .regularExpression, range: nil)
        jsonString = jsonString.replacingOccurrences(of: "\\", with: "").appending("}")
        guard let jsonStringData = jsonString.data(using: .utf8) else { return nil }
        return try JSONSerialization.jsonObject(with: jsonStringData, options: []) as AnyObject
    }

    private func deserialize(from httpResponse: HttpResponse, contentType: String) throws -> AnyObject? {
        guard let data = httpResponse.data else { return nil }
        if jsonRegex.matches(contentType) {
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
                response.add(value: deserializedData as AnyObject, forKey: "deserializedData")
            }
        } catch {
            os_log("Deserialization error: %@", error.localizedDescription)
        }
    }

    // MARK: - XML Parser Delegate

    private var elements = [String]()
    private var arrayElements = [String]()
    private var jsonString = "{"

    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?,
                       qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        if !elements.contains(elementName) {
            elements.append(elementName)
        }

        if ["\"", "}"].contains(jsonString.last) {
            jsonString += ","
        }

        jsonString += "\"\(elementName)\":{"

        var attributeCount = attributeDict.count
        for (key, value) in attributeDict {
            attributeCount -= 1
            let comma = attributeCount > 0 ? "," : ""
            jsonString += "\"_\(key)\":\"\(value)\"\(comma)" // Prepend XML attributes with underscore
        }
    }

    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        if jsonString.last == "{" {
            jsonString.removeLast()
            jsonString += "\"\(string)\"#"  // insert pattern # to detect found characters
        }
    }

    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?,
                       qualifiedName qName: String?) {
        if jsonString.last == "#" {
            jsonString.removeLast()
        } else {
            jsonString += "\(elementName)@}"
        }
    }

    public func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        os_log("XML Parse Error: %@", parseError.localizedDescription)
    }
}
