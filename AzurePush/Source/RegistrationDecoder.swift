//
//  RegistrationDecoder.swift
//  AzurePush
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

#if os(iOS)

import Foundation

internal class RegistrationDecoder: NSObject {

    // MARK: -

    private enum CodingKeys: String {
        case registrationDescription = "AppleRegistrationDescription"
        case templateRegistrationDescription = "AppleTemplateRegistrationDescription"
        case registrationId = "RegistrationId"
        case etag = "ETag"
        case deviceToken = "DeviceToken"
        case tags = "Tags"
        case expirationTime = "ExpirationTime"
        case templateName = "TemplateName"
        case templateBody = "BodyTemplate"
        case templateExpiry = "Expiry"
    }

    // MARK: -

    private struct State {
        var text: String? = nil
        var properties: [CodingKeys: Any] = [:]
        var registrations: [Registration] = []

        mutating func reset() {
            properties = [:]
            registrations = []
        }

        mutating func createRegistration() {
            guard let id = properties[.registrationId] as? String else { return }
            guard let etag = properties[.etag] as? String else { return }
            guard let deviceToken = properties[.deviceToken] as? String else { return }
            guard let expiresAt = properties[.expirationTime] as? Date else { return }
            let tags = (properties[.tags] as? [String]) ?? []
            var template: Registration.Template? = nil

            if let name = properties[.templateName] as? String, let body = properties[.templateBody] as? String {
                template = .init(name: name, body: body, expiry: properties[.templateExpiry] as? String)
            }

            registrations.append(Registration(id: id, etag: etag, deviceToken: deviceToken, expiresAt: expiresAt, tags: tags, template: template))
            properties = [:]
        }
    }

    private var state = State()

    // MARK: - API

    internal func decode(from data: Data) -> [Registration] {
        state.reset()

        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()

        return state.registrations
    }
}

extension RegistrationDecoder: XMLParserDelegate {
    internal func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        guard let key = CodingKeys(rawValue: elementName) else {
            state.text = nil
            return
        }

        switch key {
        case .registrationDescription, .templateRegistrationDescription:
            state.createRegistration()
        case .registrationId:
            state.properties[.registrationId] = state.text
        case .expirationTime:
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'"
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            state.properties[.expirationTime] = state.text.flatMap { formatter.date(from: $0) }
        case .etag:
            state.properties[.etag] = state.text
        case .deviceToken:
            state.properties[.deviceToken] = state.text
        case .tags:
            state.properties[.tags] = state.text?.components(separatedBy: ",")
        case .templateExpiry:
            state.properties[.templateExpiry] = state.text
        case .templateBody:
            state.properties[.templateBody] = state.text
        case .templateName:
            state.properties[.templateName] = state.text
        }

        state.text = nil
    }

    internal func parser(_ parser: XMLParser, foundCharacters string: String) {
        if state.text == nil {
            state.text = string
        } else {
            state.text?.append(string)
        }
    }
}

#endif
