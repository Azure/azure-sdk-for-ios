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
import AzureIdentity
@testable import AzureTest
import XCTest

final class AzureTestTests: XCTestCase {

    private var client: ResourceUtilityClient

    override func setUp() {
        let endpoint = URL(string: "www.test.com")!
        let subscriptionId = environmentVariable(forKey: "AZURE_SUBSCRIPTION_ID", default: "")
        let tenantId = environmentVariable(forKey: "AZURE_TENANT_ID", default: "")
        let clientId = environmentVariable(forKey: "AZURE_CLIENT_ID", default: "")
        let authority = URL(string: "login.microsoftonline.com")!
        let credential = MSALCredential(tenant: tenant, clientId: clientId, authority: authority)
        let authPolicy = BearerTokenCredentialPolicy(credential: credential, scopes: [""])
        let options = ResourceUtilityClientOptions()
        client = ResourceUtilityClient(
            endpoint: endpoint,
            subscriptionId: subscriptionId,
            authPolicy: authPolicy,
            withOptions: options
        )
    }

    func test_deleteResourceGroup() {

    }
}
