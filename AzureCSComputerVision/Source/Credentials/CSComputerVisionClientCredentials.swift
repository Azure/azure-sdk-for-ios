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

    @objc init(withEndpoint _: String, withKey key: String, withRegion region: String?) throws {
        credentials = try CredentialInformation(withKey: key, withRegion: region)
        headerProvider = AuthorizationHeaderProvider(withCredentials: credentials)
    }

    func setAuthorizationheaders(forRequest request: inout URLRequest) {
        headerProvider.setAuthenticationHeaders(forRequest: &request)
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
            request.addValue(credentials.key, forHTTPHeaderField: HttpHeader.ocpApimSubscriptionKey.rawValue)
        }
    }
}
