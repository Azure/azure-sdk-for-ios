//
//  ConnectionParams.swift
//  AzurePush
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

internal struct ConnectionParams {
    private enum Keys: String {
        case endpoint = "Endpoint"
        case sharedAccessKeyName = "SharedAccessKeyName"
        case sharedAccessKey = "SharedAccessKey"
        case sharedSecretIssuer = "SharedSecretIssuer"
        case sharedSecretValue = "SharedSecretValue"
        case stsendpoint = "stsendpoint"
    }

    private var params: [Keys: Any] = [:]

    internal var endpoint: URL { return params[.endpoint] as! URL }

    internal var sharedAccessKeyName: String? { return params[.sharedAccessKeyName] as? String }

    internal var sharedAccessKeyValue: String? { return params[.sharedAccessKey] as? String }

    internal var sharedSecretIssuer: String? { return params[.sharedSecretIssuer] as? String }

    internal var sharedSecretValue: String? { return params[.sharedSecretValue] as? String }

    internal var stsHostName: URL? { return params[.stsendpoint] as? URL }

    init(connectionString string: String) throws {
        let components = string.components(separatedBy: ";")
        let keyValuePairs = components.map { $0.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: true) }
                                      .map { (Keys(rawValue: String($0[0])), String($0[1])) }

        for (key, value) in keyValuePairs {
            guard let key = key else { continue }
            switch key {
            case .endpoint:
                params[.endpoint] = URL(string: value.replacingScheme(with: "https"))
            case .stsendpoint:
                params[.stsendpoint] = URL(string: value)
            default:
                params[key] = value
            }
        }

        let endpoint = params[.endpoint] as? URL
        let sharedAccessKeyName = params[.sharedAccessKeyName] as? String
        let sharedAccessKeyValue = params[.sharedAccessKey] as? String
        let sharedSecretValue = params[.sharedSecretValue] as? String
        let stsHostName = params[.stsendpoint] as? URL
        let sharedSecretIssuer = params[.sharedSecretIssuer] as? String

        if endpoint == nil {
            throw AzurePush.Error.invalidConnectionString("the endpoint is missing or is in an invalid format in the connection string")
        }

        if sharedAccessKeyName == nil && sharedAccessKeyValue == nil && sharedSecretValue == nil {
            throw AzurePush.Error.invalidConnectionString("the security information is missing in the connection string")
        }

        if sharedSecretValue != nil && sharedSecretIssuer == nil {
            params[.sharedSecretIssuer] = "owner"
        }
    }
}

extension String {
    fileprivate func replacingScheme(with scheme: String) -> String {
        guard let previousScheme = self.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: true).first else {
            return "\(scheme)://\(self)/"
        }

        var result = self.replacingOccurrences(of: previousScheme, with: scheme)

        if !result.hasSuffix("/") {
            result = "\(result)/"
        }

        return result
    }
}
