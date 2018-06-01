//
//  ADPermissionProviderConfiguration.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

@objc(ADPermissionProviderConfiguration)
public class ADPermissionProviderConfiguration: NSObject {
    @objc
    public static let `default` = ADPermissionProviderConfiguration()

    @objc
    public var defaultPermissionMode = ADPermissionMode.read

    @objc
    public var defaultResourceType: ADResourceType = .collection

    @objc
    public var defaultTokenDuration: Double = 3600

    @objc
    public var tokenRefreshThreshold: Double = 600
}

extension PermissionProviderConfiguration: ObjectiveCBridgeable {
    typealias ObjectiveCType = ADPermissionProviderConfiguration

    func bridgeToObjectiveC() -> ADPermissionProviderConfiguration {
        let configuration = ADPermissionProviderConfiguration()
        configuration.defaultPermissionMode = ADPermissionMode(defaultPermissionMode)
        configuration.defaultResourceType = defaultResourceType?.bridgeToObjectiveC() ?? .collection
        configuration.defaultTokenDuration = defaultTokenDuration
        configuration.tokenRefreshThreshold = tokenRefreshThreshold

        return configuration
    }

    init?(bridgedFromObjectiveC: ADPermissionProviderConfiguration) {
        defaultPermissionMode = bridgedFromObjectiveC.defaultPermissionMode.permissionMode
        defaultResourceType = ResourceType(bridgedFromObjectiveC: bridgedFromObjectiveC.defaultResourceType)
        defaultTokenDuration = bridgedFromObjectiveC.defaultTokenDuration
        tokenRefreshThreshold = bridgedFromObjectiveC.tokenRefreshThreshold
    }
}
