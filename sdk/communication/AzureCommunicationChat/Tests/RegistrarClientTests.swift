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
import XCTest

class RegistrarClientTests: RecordableXCTestCase<TestSettings> {
    // RegistrarClient initialied in setup
    private var registrarClient: RegistrarClient!
    private let aesKey = "0000000000000000B00000000000000000000000AES="
    private let authKey = "0000000000000000B0000000000000000000000AUTH="
    private let cryptoMethod = "0x70"

    override func setUpTestWithError() throws {
        let token = settings.token
        let credential = try CommunicationTokenCredential(token: token)
        let registrationId = "0E0F0BE0-0000-00C0-B000-A00A00E00BD0"
        let registrarServiceUrl = try getRegistrarServiceUrl(token: token)

        let httpHeaders = [
            RegistrarHeader.contentType.rawValue: RegistrarMimeType.json.rawValue,
            RegistrarHeader.skypeTokenHeader.rawValue: token
        ]
        let headersPolicy = HeadersPolicy(addingHeaders: httpHeaders)
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
            endpoint: registrarServiceUrl,
            credential: credential,
            registrationId: registrationId,
            headersPolicy: headersPolicy,
            withOptions: internalOptions
        )
    }

    func test_setRegistration_ReturnsSuccess() {
        let expectation = self.expectation(description: "Set Registration")

        let clientDescription = RegistrarClientDescription(
            aesKey: aesKey,
            authKey: authKey,
            cryptoMethod: cryptoMethod
        )

        let registrarTransportSettings = RegistrarTransportSettings(
            path: "mockDeviceToken"
        )

        registrarClient.setRegistration(
            with: clientDescription,
            for: [registrarTransportSettings]
        ) { result in
            switch result {
            case let .success(response):
                XCTAssertEqual(response?.statusCode, 202)
                expectation.fulfill()
            case let .failure(error):
                XCTFail("Create thread failed with error: \(error)")
            }
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
            aesKey: aesKey,
            authKey: authKey,
            cryptoMethod: cryptoMethod
        )

        let registrarTransportSettings = RegistrarTransportSettings(
            path: "mockDeviceToken"
        )

        registrarClient.setRegistration(
            with: clientDescription,
            for: [registrarTransportSettings]
        ) { result in
            switch result {
            case let .success(response):
                if response?.statusCode == 202 {
                    self.registrarClient.deleteRegistration { result in
                        switch result {
                        case let .success(response):
                            XCTAssertEqual(response?.statusCode, 202)
                            expectation.fulfill()
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
        }

        waitForExpectations(timeout: 10.0) { error in
            if let error = error {
                XCTFail("Delete registration timed out: \(error)")
            }
        }
    }
}
