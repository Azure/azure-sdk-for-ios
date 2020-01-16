// --------------------------------------------------------------------------
//
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// The MIT License (MIT)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the ""Software""), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
//
// --------------------------------------------------------------------------

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
            request.addValue(credentials.key, forHTTPHeaderField: HTTPHeader.ocpApimSubscriptionKey.rawValue)
        }
    }
}
