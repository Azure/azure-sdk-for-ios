//
//  AzureKeys.swift
//  AzureCore
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

public class AzureKeys: Codable {
    enum CodingKeys: String, CodingKey {
        case accountName = "AzureAccountName"
        case masterKey = "AzureAccountMasterKey"
    }

    public let accountName: String
    public let masterKey: String

    public var hasValidAccountName: Bool {
        return !accountName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    public var hasValidMasterKey: Bool {
        return !masterKey.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private init?(from info: [String: Any]) {
        guard let accountName = info[CodingKeys.accountName.rawValue] as? String else { return nil }
        guard let masterKey = info[CodingKeys.masterKey.rawValue] as? String else { return nil }

        self.accountName = accountName
        self.masterKey = masterKey
    }

    public static func loadFromPlist(named name: String? = nil) -> AzureKeys? {
        let decoder = PropertyListDecoder()

        if let name = name,
           let data = Bundle.current.plist(named: name),
           let keys = try? decoder.decode(AzureKeys.self, from: data),
           (keys.hasValidAccountName && keys.hasValidMasterKey) {
            return keys
        }

        if let data = Bundle.current.plist(named: "Azure"),
           let keys = try? decoder.decode(AzureKeys.self, from: data),
           (keys.hasValidAccountName && keys.hasValidMasterKey) {
            return keys
        }

        if let info = Bundle.current.infoDictionary,
           let keys = AzureKeys(from: info),
           (keys.hasValidAccountName && keys.hasValidMasterKey) {
            return keys
        }

        return nil
    }
}

// MARK: - Extensions

extension Bundle {
    fileprivate static var current: Bundle {
        return ProcessInfo.isRunningTests ? Bundle(for: AzureKeys.self) : Bundle.main
    }

    fileprivate func plist(named name: String) -> Data? {
        if let url = url(forResource: name.removingSuffix(".plist"), withExtension: "plist") {
            return try? Data(contentsOf: url)
        }
        return nil
    }
}

extension String {
    fileprivate func removingSuffix(_ suffix: String) -> String {
        guard hasSuffix(suffix) else { return self }
        return String(dropLast(suffix.count))
    }
}

extension Optional where Wrapped == String {
    fileprivate var isNilOrEmpty: Bool {
        guard let string = self else { return true }
        return string.trimmingCharacters(in: .whitespaces).isEmpty
    }
}

extension ProcessInfo {
    fileprivate static var isRunningTests: Bool {
        return ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }
}
