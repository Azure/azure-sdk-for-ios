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
        case cosmosAccountName = "AzureCosmosDbDatabaseAccountName"
        case cosmosMasterKey = "AzureCosmosDbDatabaseAccountMasterKey"
    }

    public let cosmosAccountName: String
    public let cosmosMasterKey: String

    public var hasValidCosmosAccountName: Bool {
        return !cosmosAccountName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    public var hasValidCosmosMasterKey: Bool {
        return !cosmosMasterKey.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private init?(from info: [String: Any]) {
        guard let accountName = info[CodingKeys.cosmosAccountName.rawValue] as? String else { return nil }
        guard let masterKey = info[CodingKeys.cosmosMasterKey.rawValue] as? String else { return nil }

        self.cosmosAccountName = accountName
        self.cosmosMasterKey = masterKey
    }

    public static func loadFromPlist(named name: String? = nil) -> AzureKeys? {
        let decoder = PropertyListDecoder()

        if let name = name,
           let data = Bundle.current.plist(named: name),
           let keys = try? decoder.decode(AzureKeys.self, from: data),
           (keys.hasValidCosmosAccountName && keys.hasValidCosmosMasterKey) {
            return keys
        }

        if let data = Bundle.current.plist(named: "Azure"),
           let keys = try? decoder.decode(AzureKeys.self, from: data),
           (keys.hasValidCosmosAccountName && keys.hasValidCosmosMasterKey) {
            return keys
        }

        if let info = Bundle.current.infoDictionary,
           let keys = AzureKeys(from: info),
           (keys.hasValidCosmosAccountName && keys.hasValidCosmosMasterKey) {
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
