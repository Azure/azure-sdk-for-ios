//
//  Credentials.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/28/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

@objc public class AccessToken: NSObject {
    @objc public let token: String
    @objc public let expiresOn: Int
    @objc public init(token: String, expiresOn: Int) {
        self.token = token
        self.expiresOn = expiresOn
    }
}

@objc public protocol TokenCredential {
    @objc var scopes: [String] { get }
    @objc func getToken(scopes: [String]) -> AccessToken
}
