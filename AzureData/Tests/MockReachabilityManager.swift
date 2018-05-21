//
//  MockReachabilityManager.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCore

class MockReachabilityManager: ReachabilityManagerType {
    var networkReachabilityStatus: NetworkReachabilityStatus = .reachable(.ethernetOrWiFi) {
        didSet {
            if isListening { listener?(networkReachabilityStatus) }
        }
    }

    var listener: ReachabilityStatusListener?
    var isListening = false

    init(_ status: NetworkReachabilityStatus) {
        self.networkReachabilityStatus = status
    }

    func registerListener(_ listener: @escaping ReachabilityStatusListener) {
        self.listener = listener
    }

    func startListening() -> Bool {
        isListening = true
        listener?(networkReachabilityStatus)
        return true
    }

    func stopListening() {
        isListening = false
    }
}
