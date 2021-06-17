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

import AzureCommunicationCommon
import OHHTTPStubsSwift
import XCTest

class RegistrarClientTests: XCTestCase {
    private var mode = getEnvironmentVariable(withKey: "TEST_MODE", default: "playback")

    private var registrarEndpoint: String!

    private var registrarClient: RegistrarClient!

    override func setUpWithError() throws {
        registrarEndpoint = (mode != "playback") ? RegistrarSettings.endpoint : "https://endpoint/registrations"
        let token = generateToken()
        let credential = try CommunicationTokenCredential(token: token)
        let registrationId = UUID().uuidString

        registrarClient = try RegistrarClient(
            endpoint: registrarEndpoint,
            credential: credential,
            registrationId: registrationId
        )

        // Register stubs
        if mode == "playback" {
            let bundle = Bundle(for: type(of: self))
            let path = bundle.path(forResource: "noContent", ofType: "json") ?? ""
            stub(condition: isMethodPOST() && isPath("/registrations")) { _ in
                fixture(filePath: path, status: 202, headers: nil)
            }
            stub(condition: isMethodDELETE() && pathStartsWith("/registrations")) { _ in
                fixture(filePath: path, status: 202, headers: nil)
            }
        }
    }

    override func tearDown() {
        // Delete any registrations that were created by tests
        if mode != "playback" {
            registrarClient.deleteRegistration { response, error in
                if (error != nil) || (response?.statusCode != 202) {
                    print("Failed to delete test registration.")
                }
            }
        }
    }

    func test_setRegistration_ReturnsSuccess() {
        let expectation = self.expectation(description: "Set Registration")

        let clientDescription = RegistrarClientDescription(
            appId: RegistrarSettings.appId,
            languageId: RegistrarSettings.languageId,
            platform: RegistrarSettings.platform,
            platformUIVersion: RegistrarSettings.platformUIVersion,
            templateKey: RegistrarSettings.templateKey
        )

        let transport = RegistrarTransport(
            ttl: 10,
            path: "mockDeviceToken",
            context: RegistrarSettings.context
        )

        registrarClient.setRegistration(
            with: clientDescription,
            for: [transport]
        ) { response, error in
            XCTAssertNil(error)
            XCTAssertEqual(response?.statusCode, RegistrarStatusCode.success)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10.0) { error in
            if let error = error {
                XCTFail("Set registration timed out: \(error)")
            }
        }
    }

    func test_deleteRegistration_ReturnsSuccess() {
        let expectation = self.expectation(description: "Delete Registration")

        let clientDescription = RegistrarClientDescription(
            appId: RegistrarSettings.appId,
            languageId: RegistrarSettings.languageId,
            platform: RegistrarSettings.platform,
            platformUIVersion: RegistrarSettings.platformUIVersion,
            templateKey: RegistrarSettings.templateKey
        )

        let transport = RegistrarTransport(
            ttl: 100,
            path: "mockDeviceToken",
            context: RegistrarSettings.context
        )

        registrarClient.setRegistration(
            with: clientDescription,
            for: [transport]
        ) { response, error in
            if error == nil, response?.statusCode == RegistrarStatusCode.success {
                self.registrarClient.deleteRegistration { response, error in
                    XCTAssertNil(error)
                    XCTAssertEqual(response?.statusCode, RegistrarStatusCode.success)
                    expectation.fulfill()
                }
            } else {
                XCTFail("Failed to set registration.")
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 10.0) { error in
            if let error = error {
                XCTFail("Delete registration timed out: \(error)")
            }
        }
    }
}
