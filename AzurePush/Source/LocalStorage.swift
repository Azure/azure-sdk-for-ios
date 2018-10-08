//
//  LocalStorage.swift
//  AzurePush
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

internal class LocalStorage {
    private static let version = "v1.0.0"

    private let deviceTokenKey: String
    private let versionKey: String
    private let registrationsKey: String
    private var container: [String: Registration] = [:]

    internal var needsRefresh = false
    internal var deviceToken: String? = nil

    internal init(notificationHubPath path: String) {
        self.deviceTokenKey = "\(path)-deviceToken"
        self.versionKey = "\(path)-deviceToken"
        self.registrationsKey = "registrations"

        loadFromUserDefaults()
    }

    internal subscript(index: String) -> Registration? {
        get {
            return container[index]
        }

        set(newValue) {
            container[index] = newValue
            syncWithUserDefaults()
        }
    }

    internal func refresh(withDeviceToken deviceToken: String) {
        needsRefresh = false

        if deviceToken != self.deviceToken {
            self.deviceToken = deviceToken
            syncWithUserDefaults()
        }
    }

    @discardableResult
    internal func removeRegistration(withName name: String) -> Registration? {
        return container.removeValue(forKey: name)
    }

    internal func clear() {
        container.removeAll()
        syncWithUserDefaults()
    }

    @discardableResult
    private func syncWithUserDefaults() -> Bool {
        UserDefaults.standard.set(deviceToken, forKey: deviceTokenKey)
        UserDefaults.standard.set(container.map { (key, value) in value }, forKey: registrationsKey)
        return UserDefaults.standard.synchronize()
    }

    private func loadFromUserDefaults() {
        self.deviceToken = UserDefaults.standard.string(forKey: deviceTokenKey)

        let version = UserDefaults.standard.string(forKey: versionKey)
        if version == nil || version! != LocalStorage.version {
            self.needsRefresh = true
            return
        }

        if let registrations = UserDefaults.standard.object(forKey: registrationsKey) as? [Registration] {
            registrations.forEach { registration in
                container[registration.name] = registration
            }
        }
    }
}
