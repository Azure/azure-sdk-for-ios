//
//  Credentials.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/28/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

public class AccessToken {
    public let token: String
    public let expiresOn: Int

    public init(token: String, expiresOn: Int) {
        self.token = token
        self.expiresOn = expiresOn
    }
}

public protocol TokenCredential {
    var scopes: [String] { get }
    func getToken(scopes: [String]) -> AccessToken
}
