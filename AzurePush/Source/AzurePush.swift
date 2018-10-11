//
//  AzurePush.swift
//  AzurePush
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCore

public class AzurePush {

    // MARK: - Configuration

    /// Configures AzurePush to work with an Azure Notification Hub.
    ///
    /// - Parameters:
    ///     - hubName:          The name of the notification hub
    ///     - connectionString: The `DefaultListenSharedAccess` connection string of the notification hub.
    public static func configure(withHubName hubName: String, andConnectionString connectionString: String) throws {
        try NotificationClient.shared.configure(withHubName: hubName, andConnectionString: connectionString)
    }

    // MARK: - Registration

    /// Registers the current device to receive native push notifications from the Azure Notification Hub.
    /// This method should be called in the implementation of `application(_:didRegisterForRemoteNotificationsWithDeviceToken:)`
    /// in the app delegate.
    ///
    /// - Parameters:
    ///     - deviceToken: A globally unique token that identifies this device to APNS (Apple Push Notification Service).
    ///     - tags:        An optional list of tags (a tag is any string of up to 120 characters).
    ///                    Some notifications from the notification hub can target a specific set of tags. For such a push
    ///                    notification, if one of tags provided by this method during the registration is included
    ///                    in the set of tags the push notification targets, the current device will receive the push notification.
    ///                    See https://docs.microsoft.com/en-us/previous-versions/azure/azure-services/dn530749(v=azure.100)
    ///     - completion:  A closure called after the registration is completed. The `Response` parameter in the closure informs whether
    ///                    the registration was successful or not.
    public static func registerForRemoteNotifications(withDeviceToken deviceToken: Data, tags: [String] = [], completion: @escaping (Response<Registration>) -> Void) {
        NotificationClient.shared.registerForRemoteNotifications(withDeviceToken: deviceToken, tags: tags, completion: completion)
    }

    /// Registers the current device to receive push notifications from the Azure Notification Hub using a template.
    /// This method should be called in the implementation of `application(_:didRegisterForRemoteNotificationsWithDeviceToken:)`
    /// in the app delegate.
    ///
    /// - Parameters:
    ///     - deviceToken: A globally unique token that identifies this device to APNS (Apple Push Notification Service).
    ///     - tags:        An optional list of tags (a tag is any string of up to 120 characters).
    ///                    Some notifications from the notification hub can target a specific set of tags. For such a push
    ///                    notification, if one of tags provided by this method during the registration is included
    ///                    in the set of tags the push notification targets, the current device will receive the push notification.
    ///                    See https://docs.microsoft.com/en-us/previous-versions/azure/azure-services/dn530749(v=azure.100)
    ///     - template:    A template used to specify the exact format of the notifications this device can receive.
    ///     - completion:  A closure called after the registration is completed. The `Response` parameter in the closure informs whether
    ///                    the registration was successful or not.
    public static func registerForRemoteNotifications(withDeviceToken deviceToken: Data, usingTemplate template: Registration.Template, priority: String? = nil, tags: [String] = [], completion: @escaping (Response<Registration>) -> Void) {
        NotificationClient.shared.registerForRemoteNotifications(withDeviceToken: deviceToken, usingTemplate: template, priority: priority, tags: tags, completion: completion)
    }

    // MARK: - Unregistration

    /// Unregisters this device from the Azure Notification Hub. Any native push notification sent
    /// by the notification hub will no longer be received by this device.
    public static func unregisterForRemoteNotifications(completion: @escaping (Response<Data>) -> Void) {
        NotificationClient.shared.unregisterForRemoteNotifications(completion: completion)
    }

    /// Unregisters this device from the Azure Notification Hub. Any push notification sent by the notification hub
    /// matching the template corresponding to the template name provided will no longer be received by this device.
    public static func unregisterForRemoteNotifications(forRegistrationWithTemplateNamed templateName: String, completion: @escaping (Response<Data>) -> Void) {
        NotificationClient.shared.unregisterForRemoteNotifications(forRegistrationWithTemplateNamed: templateName, completion: completion)
    }

    /// Unregisters this device from the Azure Notification Hub. All native push notifications and push notifications
    /// matching any template provided by this device will no longer be received by this device.
    public static func unregisterForRemoteNotifications(forDeviceToken deviceToken: Data, completion: @escaping (Response<Data>) -> Void) {
        NotificationClient.shared.unregisterForRemoteNotifications(forDeviceToken: deviceToken, completion: completion)
    }
}

// MARK: -

extension AzurePush {
    public enum Error: Swift.Error {
        case notConfigured
        case invalidConnectionString(String)
        case reservedTemplateName
        case invalidTemplateName
        case failedToRetrieveAuthorizationToken
        case unknown

        public var localizedDescription: String {
            switch self {
            case .notConfigured: return "AzurePush is not yet configured. AzurePush.configure(withHubName:andConnectionString:) must be called before attempting any operation."
            case .invalidConnectionString(let message): return message
            case .reservedTemplateName: return "the template name is in conflict with a reserved name"
            case .invalidTemplateName: return "a template name can contain the colon character :"
            case .failedToRetrieveAuthorizationToken: return "the authorization token could not be retrieved"
            case .unknown: return "an unknown error occured, please check the response's payload for more information"
            }
        }
    }
}
