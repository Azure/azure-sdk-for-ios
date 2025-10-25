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
import OHHTTPStubs.Swift
import XCTest

// swiftlint:disable all
class TrouterSettingsUnitTests: XCTestCase {
    private var testSettings = TestSettings()
    var eudbToken: String = {
        let fakeValue =
            "{\"iss\":\"ACS\",\"iat\": 1608152725,\"exp\": 1739688725,\"aud\": \"\",\"sub\": \"\",\"resourceLocation\": \"europe\"}"
                .base64EncodedString()
        let token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9." + fakeValue + ".EMS0ExXqRuobm34WKJE8mAfZ7KppU5kEHl0OFdyree8"
        return token
    }()

    var gcchToken: String = {
        let fakeValue =
            "{\"skypeid\":\"gcch:c17ab671\",\"iss\":\"ACS\",\"iat\": 1608152725,\"exp\": 1739688725,\"aud\": \"\",\"sub\": \"\"}"
                .base64EncodedString()
        let token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9." + fakeValue + ".EMS0ExXqRuobm34WKJE8mAfZ7KppU5kEHl0OFdyree8"
        return token
    }()

    var dodToken: String = {
        let fakeValue =
            "{\"skypeid\":\"dod:c17ab671\",\"iss\":\"ACS\",\"iat\": 1608152725,\"exp\": 1739688725,\"aud\": \"\",\"sub\": \"\"}"
                .base64EncodedString()
        let token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9." + fakeValue + ".EMS0ExXqRuobm34WKJE8mAfZ7KppU5kEHl0OFdyree8"
        return token
    }()

    func test_GetTrouterSettings_ReturnDefault() {
        do {
            let settings = try getTrouterSettings(token: testSettings.token)
            XCTAssertEqual(settings.trouterHostname, defaultTrouterHostname)
            XCTAssertEqual(settings.registrarHostnameAndBasePath, defaultRegistrarHostnameAndBasePath)
        } catch {
            XCTFail()
        }
    }

    func test_GetTrouterSettings_ReturnEudbServiceUrl() {
        do {
            let settings = try getTrouterSettings(token: eudbToken)
            XCTAssertEqual(settings.trouterHostname, eudbTrouterHostname)
            XCTAssertEqual(settings.registrarHostnameAndBasePath, defaultRegistrarHostnameAndBasePath)
        } catch {
            XCTFail()
        }
    }

    func test_GetTrouterSettings_ReturnGcch() {
        do {
            let settings = try getTrouterSettings(token: gcchToken)
            XCTAssertEqual(settings.trouterHostname, gcchTrouterHostname)
            XCTAssertEqual(settings.registrarHostnameAndBasePath, gcchRegistrarHostnameAndBasePath)
        } catch {
            XCTFail()
        }
    }

    func test_GetTrouterSettings_ReturnDod() {
        do {
            let settings = try getTrouterSettings(token: dodToken)
            XCTAssertEqual(settings.trouterHostname, dodTrouterHostname)
            XCTAssertEqual(settings.registrarHostnameAndBasePath, dodRegistrarHostnameAndBasePath)
        } catch {
            XCTFail()
        }
    }
}
