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

@testable import AzureCommunicationChat
import AzureCommunicationCommon
import AzureCore
import AzureTest
import DVR
import OHHTTPStubs.Swift
import XCTest

class RegistrarClientTests: RecordableXCTestCase<TestSettings> {
    private var mode = environmentVariable(forKey: "TEST_MODE", default: "playback")

    private var registrarEndpoint: String!

    // RegistrarClient initialied in setup
    private var registrarClient: RegistrarClient!

    // add URLfilter in refactoring
    private var urlFilter: RequestURLFilter {
        let defaults = TestSettings()
        let textFilter = RequestURLFilter()
        textFilter.register(replacement: defaults.endpoint, for: settings.endpoint)
        return textFilter
    }

    override func setUpTestWithError() throws {
        registrarEndpoint = (mode != "playback") ? RegistrarSettings
            .endpoint : "https://endpoint/registrations"
        let settings = TestSettings()
        let token = settings.token
        let credential = try CommunicationTokenCredential(token: token)
        let registrationId = UUID().uuidString

        // add these in refactoring
        let communicationCredential = TokenCredentialAdapter(credential)
        let authPolicy = BearerTokenCredentialPolicy(credential: communicationCredential, scopes: [])
        let userOptions = AzureCommunicationChatClientOptions(transportOptions: transportOptions)
        var options = userOptions
        if userOptions.telemetryOptions.applicationId == nil {
            let apiVersion = AzureCommunicationChatClientOptions.ApiVersion(userOptions.apiVersion)
            let telemetryOptions = TelemetryOptions(
                telemetryDisabled: userOptions.telemetryOptions.telemetryDisabled,
                applicationId: ""
            )

            options = AzureCommunicationChatClientOptions(
                apiVersion: apiVersion,
                logger: userOptions.logger,
                telemetryOptions: telemetryOptions,
                transportOptions: userOptions.transportOptions,
                dispatchQueue: userOptions.dispatchQueue,
                signalingErrorHandler: userOptions.signalingErrorHandler
            )
        }

        let internalOptions = AzureCommunicationChatClientOptionsInternal(
            apiVersion: AzureCommunicationChatClientOptionsInternal.ApiVersion(options.apiVersion),
            logger: options.logger,
            telemetryOptions: options.telemetryOptions,
            transportOptions: options.transportOptions,
            dispatchQueue: options.dispatchQueue
        )

        registrarClient = try RegistrarClient(
            endpoint: registrarEndpoint,
            credential: credential,
            registrationId: registrationId,
            authPolicy: authPolicy,
            withOptions: internalOptions
        )
    }

    // Question：Can I use the actual RegistrarSettings?
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
        ) { result in
            switch result {
            case let .success(response):
                XCTAssertEqual(response?.statusCode, RegistrarStatusCode.success.rawValue)
            case let .failure(error):
                XCTFail("Create thread failed with error: \(error)")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10.0) { error in
            if let error = error {
                XCTFail("Set registration timed out: \(error)")
            }
        }
    }

    /*
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
            ) { result in
                switch result {
                case let .success(response):
                    if response?.statusCode == RegistrarStatusCode.success.rawValue {
                        self.registrarClient.deleteRegistration { result in
                            switch result {
                            case let .success(response):
                                XCTAssertEqual(response?.statusCode, RegistrarStatusCode.success.rawValue)
                            case let .failure(error):
                                XCTFail("Create thread failed with error: \(error)")
                            }
                        }
                    } else {
                        XCTFail("Failed to set registration.")
                    }
                case let .failure(error):
                    XCTFail("Create thread failed with error: \(error)")
                }
                expectation.fulfill()

                self.waitForExpectations(timeout: 10.0) { error in
                    if let error = error {
                        XCTFail("Delete registration timed out: \(error)")
                    }
                }
            }
        }
     */
}
