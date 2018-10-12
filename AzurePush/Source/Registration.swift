//
//  Registration.swift
//  AzurePush
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// A `Registration` associates a specific device with a set of tags and possibly a template.
/// The device will receive all push notifications targetting any or all of the tags associated and
/// if a template is provided, the push notifications contents will be in the format specified by
/// the template.
public struct Registration: Codable {

    /// A `Template` enables a client to specify the exact format of the notifications it wants to receive.
    /// https://docs.microsoft.com/en-us/previous-versions/azure/azure-services/dn530748(v%3dazure.100)
    public struct Template: Codable {

        /// The name of the template
        public let name: String

        /// The body of the template written in the Template Expression Language.
        /// https://docs.microsoft.com/en-us/previous-versions/azure/azure-services/dn530748(v%3dazure.100)#template-expression-language
        public let body: String

        /// A constant or a template expression that evaluates to a date in the W3D date format.
        public let expiry: String?

        public init(name: String, body: String, expiry: String? = nil) {
            self.name = name
            self.body = body
            self.expiry = expiry
        }
    }

    internal static let defaultName = "$Default"

    /// The ID of the registration.
    public let id: String

    /// The entity tag (ETag) of the registration.
    public let etag: String

    /// A globally unique token that identifies the device to APNS (Apple Push Notification Service).
    public let deviceToken: String

    /// The expiration date of the registration.
    public let expiresAt: Date

    /// The set of tags of the registration.
    public let tags: [String]

    /// The template of the registration, if any.
    public let template: Template?

    /// The name of the registration.
    public var name: String {
        guard let template = template else {
            return Registration.defaultName
        }

        return template.name
    }

    internal static func payload(forDeviceToken deviceToken: String, andTags tags: [String]) -> String {
        let tagsNode = tags.isEmpty ? "" : "<Tags>\(tags.joined(separator: ","))</Tags>"
        return "<entry xmlns=\"http://www.w3.org/2005/Atom\"><content type=\"text/xml\"><AppleRegistrationDescription xmlns:i=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns=\"http://schemas.microsoft.com/netservices/2010/10/servicebus/connect\">\(tagsNode)<DeviceToken>\(deviceToken)</DeviceToken></AppleRegistrationDescription></content></entry>"
    }

    internal static func payload(forDeviceToken deviceToken: String, template: Template, priority: String? = nil, andTags tags: [String]) -> String {
        let expiryNode = template.expiry.isNilOrEmpty ? "" : "<Expiry>\(template.expiry!)</Expiry>"
        let priorityNode = priority == nil ? "" : "<Priority>\(priority!)</Priority>"
        let tagsNode = tags.isEmpty ? "" : "<Tags>\(tags.joined(separator: ","))</Tags>"

        return "<entry xmlns=\"http://www.w3.org/2005/Atom\"><content type=\"text/xml\"><AppleTemplateRegistrationDescription xmlns:i=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns=\"http://schemas.microsoft.com/netservices/2010/10/servicebus/connect\">\(tagsNode)<DeviceToken>\(deviceToken)</DeviceToken><BodyTemplate><![CDATA[\(template.body)]]></BodyTemplate>\(expiryNode)\(priorityNode)<TemplateName>\(template.name)</TemplateName></AppleTemplateRegistrationDescription></content></entry>"
    }
}

extension Registration.Template {
    internal static func validate(name: String) -> Error? {
        guard name != Registration.defaultName else { return AzurePush.Error.reservedTemplateName }
        guard !name.contains(":") else { return AzurePush.Error.invalidTemplateName }
        return nil
    }
}

extension Optional where Wrapped == String {
    fileprivate var isNilOrEmpty: Bool {
        return self == nil || self!.isEmpty
    }
}
