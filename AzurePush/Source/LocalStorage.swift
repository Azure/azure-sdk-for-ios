//
//  LocalStorage.swift
//  AzurePush
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

#if os(iOS)

import Foundation

internal class LocalStorage {
    private static let version = "v1.0.0"

    // MARK: - Keys

    private let deviceTokenKey: String
    private let versionKey: String
    private let registrationsKey: String

    // MARK: -

    private var container: [String: Registration] = [:]

    // MARK: - Encoding & Decoding

    private lazy var encoder = JSONEncoder()
    private lazy var decoder = JSONDecoder()

    // MARK: - API

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

    // MARK: - Private helpers

    @discardableResult
    private func syncWithUserDefaults() -> Bool {
        UserDefaults.standard.set(deviceToken, forKey: deviceTokenKey)
        UserDefaults.standard.set(container.compactMap { (key, value) in try? encoder.encode(value) }, forKey: registrationsKey)
        return UserDefaults.standard.synchronize()
    }

    private func loadFromUserDefaults() {
        self.deviceToken = UserDefaults.standard.string(forKey: deviceTokenKey)

        let version = UserDefaults.standard.string(forKey: versionKey)
        if version == nil || version! != LocalStorage.version {
            self.needsRefresh = true
            return
        }

        if let data = UserDefaults.standard.object(forKey: registrationsKey) as? [Data] {
            let registrations = data.compactMap { try? decoder.decode(Registration.self, from: $0) }
            registrations.forEach { registration in
                container[registration.name] = registration
            }
        }
    }
}

#endif
