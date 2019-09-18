//
//  CSComputerVisionCredentials.swift
//  DemoAppObjC
//
//  Created by Travis Prescott on 8/12/19.
//  Copyright © 2019 Travis Prescott. All rights reserved.
//

import AzureCore
import Foundation

@objc
class CSComputerVisionClientCredentials: NSObject {
    let credentials: CredentialInformation
    let headerProvider: AuthorizationHeaderProvider

    @objc init(withEndpoint endpoint: String, withKey key: String, withRegion region: String?) throws {
        self.credentials = try CredentialInformation.init(withKey: key, withRegion: region)
        self.headerProvider = AuthorizationHeaderProvider.init(withCredentials: self.credentials)
    }

    func setAuthorizationheaders(forRequest request: inout URLRequest) {
        self.headerProvider.setAuthenticationHeaders(forRequest: &request)
    }

    class CredentialInformation {

        var key: String
        var region: String?

        init(withKey key: String, withRegion region: String?) throws {
            self.key = key
            self.region = region
        }
    }

    class AuthorizationHeaderProvider {
        let credentials: CredentialInformation

        init(withCredentials credentials: CredentialInformation) {
            self.credentials = credentials
        }

        func setAuthenticationHeaders(forRequest request: inout URLRequest) {
            request.addValue(self.credentials.key, forHTTPHeaderField: HttpHeader.ocpApimSubscriptionKey.rawValue)
        }
    }
}
