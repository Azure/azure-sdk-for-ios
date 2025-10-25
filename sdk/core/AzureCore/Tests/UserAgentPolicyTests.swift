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

@testable import AzureCore
import XCTest

class UserAgentPolicyTests: XCTestCase {
    /// Test that the user agent policy creates the correct user agent when all optional parts are omitted
    func test_UserAgentPolicy_WithRequiredPartsOnly() {
        let policy = UserAgentPolicy(
            sdkName: "Test",
            sdkVersion: "1.0",
            platformInfoProvider: nil,
            appBundleInfoProvider: nil,
            localeInfoProvider: nil
        )
        let userAgent = policy.userAgent
        XCTAssertEqual(userAgent, "azsdk-ios-Test/1.0")
    }

    /// Test that the user agent policy creates the correct user agent when the applicationId only is provided
    func test_UserAgentPolicy_WithAppIdOnly() {
        let policy = UserAgentPolicy(
            sdkName: "Test",
            sdkVersion: "1.0",
            telemetryOptions: TelemetryOptions(applicationId: "MyApplication"),
            platformInfoProvider: nil,
            appBundleInfoProvider: nil,
            localeInfoProvider: nil
        )
        let userAgent = policy.userAgent
        XCTAssertEqual(userAgent, "MyApplication azsdk-ios-Test/1.0")
    }

    /// Test that the user agent policy truncates an applicationId >24 characters
    func test_UserAgentPolicy_WithAppIdTooLong_TruncatesAppId() {
        let policy = UserAgentPolicy(
            sdkName: "Test",
            sdkVersion: "1.0",
            telemetryOptions: TelemetryOptions(applicationId: "MyExtremelyLongApplication"),
            platformInfoProvider: nil,
            appBundleInfoProvider: nil,
            localeInfoProvider: nil
        )
        let userAgent = policy.userAgent
        XCTAssertEqual(userAgent, "MyExtremelyLongApplicati azsdk-ios-Test/1.0")
    }

    /// Test that the user agent policy removes whitespaces from an applicationId
    func test_UserAgentPolicy_WithAppIdContainingWhitespace_StripsWhitespace() {
        let policy = UserAgentPolicy(
            sdkName: "Test",
            sdkVersion: "1.0",
            telemetryOptions: TelemetryOptions(
                applicationId: "\u{3000}My\u{2003}Long\u{000d}\u{000a}App\u{0009}  Na\u{200b}me\u{00a0} "
            ),
            platformInfoProvider: nil,
            appBundleInfoProvider: nil,
            localeInfoProvider: nil
        )
        let userAgent = policy.userAgent
        XCTAssertEqual(userAgent, "MyLongAppName azsdk-ios-Test/1.0")
    }

    /// Test that the user agent policy truncates an applicationId only after first stripping whitespace
    func test_UserAgentPolicy_WithAppIdMadeTooLongByWhitespace_StripsWhitespaceBeforeTruncating() {
        let policy = UserAgentPolicy(
            sdkName: "Test",
            sdkVersion: "1.0",
            telemetryOptions: TelemetryOptions(applicationId: " My Very Long Application "),
            platformInfoProvider: nil,
            appBundleInfoProvider: nil,
            localeInfoProvider: nil
        )
        let userAgent = policy.userAgent
        XCTAssertEqual(userAgent, "MyVeryLongApplication azsdk-ios-Test/1.0")
    }

    /// Test that the user agent policy omits the applicationId if it is empty after stripping whitespace
    func test_UserAgentPolicy_WithAppIdContainingOnlyWhitespace_OmitsAppId() {
        let policy = UserAgentPolicy(
            sdkName: "Test",
            sdkVersion: "1.0",
            telemetryOptions: TelemetryOptions(
                applicationId: "\u{3000}\u{2003}\u{000d}\u{000a}\u{0009}  \u{200b}\u{00a0} "
            ),
            platformInfoProvider: nil,
            appBundleInfoProvider: nil,
            localeInfoProvider: nil
        )
        let userAgent = policy.userAgent
        XCTAssertEqual(userAgent, "azsdk-ios-Test/1.0")
    }

    /// Test that the user agent policy creates the correct user agent when the applicationId is explicitly provided
    /// and is also available from the bundleInfoProvider
    func test_UserAgentPolicy_WithBundleInfoAndAppId_UsesAppId() {
        let policy = UserAgentPolicy(
            sdkName: "Test",
            sdkVersion: "1.0",
            telemetryOptions: TelemetryOptions(applicationId: "MyApplication"),
            platformInfoProvider: nil,
            appBundleInfoProvider: TestBundleInfoProvider(identifier: "BundleApplicationId"),
            localeInfoProvider: nil
        )
        let userAgent = policy.userAgent
        XCTAssertEqual(userAgent, "MyApplication azsdk-ios-Test/1.0")
    }

    /// Test that the user agent policy omits the applicationId when the applicationId is explicitly provided as an
    /// empty string and is also available from the bundleInfoProvider
    func test_UserAgentPolicy_WithBundleInfoAndEmptyAppId_OmitsAppId() {
        let policy = UserAgentPolicy(
            sdkName: "Test",
            sdkVersion: "1.0",
            telemetryOptions: TelemetryOptions(applicationId: ""),
            platformInfoProvider: nil,
            appBundleInfoProvider: TestBundleInfoProvider(identifier: "BundleApplicationId"),
            localeInfoProvider: nil
        )
        let userAgent = policy.userAgent
        XCTAssertEqual(userAgent, "azsdk-ios-Test/1.0")
    }

    /// Test that the user agent policy creates the correct user agent when the applicationId is not explicitly provided
    /// but is available from the bundleInfoProvider
    func test_UserAgentPolicy_WithBundleInfoAndNoAppId_UsesAppIdFromBundle() {
        let policy = UserAgentPolicy(
            sdkName: "Test",
            sdkVersion: "1.0",
            platformInfoProvider: nil,
            appBundleInfoProvider: TestBundleInfoProvider(identifier: "BundleApplicationId"),
            localeInfoProvider: nil
        )
        let userAgent = policy.userAgent
        XCTAssertEqual(userAgent, "BundleApplicationId azsdk-ios-Test/1.0")
    }

    /// Test that the user agent policy creates the correct user agent when all the bundle info is available
    func test_UserAgentPolicy_WithAllBundleInfo_AppendsInfoSuffix() {
        let policy = UserAgentPolicy(
            sdkName: "Test",
            sdkVersion: "1.0",
            telemetryOptions: TelemetryOptions(applicationId: "MyApplication"),
            platformInfoProvider: nil,
            appBundleInfoProvider: TestBundleInfoProvider(
                name: "MyBundle",
                version: "2.0",
                minDeploymentTarget: "iOS 9.0"
            ),
            localeInfoProvider: nil
        )
        let userAgent = policy.userAgent
        XCTAssertEqual(userAgent, "MyApplication azsdk-ios-Test/1.0 (MyBundle:2.0 -> iOS 9.0)")
    }

    /// Test that the user agent policy creates the correct user agent when only the bundle name & version are available
    func test_UserAgentPolicy_WithBundleNameVersionOnly_AppendsInfoSuffix() {
        let policy = UserAgentPolicy(
            sdkName: "Test",
            sdkVersion: "1.0",
            telemetryOptions: TelemetryOptions(applicationId: "MyApplication"),
            platformInfoProvider: nil,
            appBundleInfoProvider: TestBundleInfoProvider(name: "MyBundle", version: "2.0"),
            localeInfoProvider: nil
        )
        let userAgent = policy.userAgent
        XCTAssertEqual(userAgent, "MyApplication azsdk-ios-Test/1.0 (MyBundle:2.0)")
    }

    /// Test that the user agent policy creates the correct user agent when platform info is available
    func test_UserAgentPolicy_WithPlatformInfo_AppendsInfoSuffix() {
        let policy = UserAgentPolicy(
            sdkName: "Test",
            sdkVersion: "1.0",
            telemetryOptions: TelemetryOptions(applicationId: "MyApplication"),
            platformInfoProvider: TestPlatformInfoProvider(deviceName: "iPhone6,2", osVersion: "13.2"),
            appBundleInfoProvider: nil,
            localeInfoProvider: nil
        )
        let userAgent = policy.userAgent
        XCTAssertEqual(userAgent, "MyApplication azsdk-ios-Test/1.0 (iPhone6,2 - 13.2)")
    }

    /// Test that the user agent policy creates the correct user agent when locale info is available
    func test_UserAgentPolicy_WithLocaleInfo_AppendsInfoSuffix() {
        let policy = UserAgentPolicy(
            sdkName: "Test",
            sdkVersion: "1.0",
            telemetryOptions: TelemetryOptions(applicationId: "MyApplication"),
            platformInfoProvider: nil,
            appBundleInfoProvider: nil,
            localeInfoProvider: TestLocaleInfoProvider(language: "en", region: "US")
        )
        let userAgent = policy.userAgent
        XCTAssertEqual(userAgent, "MyApplication azsdk-ios-Test/1.0 (en_US)")
    }

    /// Test that the user agent policy correctly separates and orders multiple parts of the info suffix
    func test_UserAgentPolicy_WithMultipleInfoParts_AppendsInfoSuffixPartsInCorrectOrder() {
        let policy = UserAgentPolicy(
            sdkName: "Test",
            sdkVersion: "1.0",
            telemetryOptions: TelemetryOptions(applicationId: "MyApplication"),
            platformInfoProvider: TestPlatformInfoProvider(deviceName: "iPhone6,2", osVersion: "13.2"),
            appBundleInfoProvider: TestBundleInfoProvider(
                name: "MyBundle",
                version: "2.0",
                minDeploymentTarget: "iOS 9.0"
            ),
            localeInfoProvider: TestLocaleInfoProvider(language: "en", region: "US")
        )
        let userAgent = policy.userAgent
        XCTAssertEqual(
            userAgent,
            "MyApplication azsdk-ios-Test/1.0 (iPhone6,2 - 13.2; MyBundle:2.0 -> iOS 9.0; en_US)"
        )
    }

    /// Test that the user agent policy correctly omits the info sufix when telemetry is disabled
    func test_UserAgentPolicy_WithTelemetryDisabled_OmitsInfoSuffix() {
        let policy = UserAgentPolicy(
            sdkName: "Test",
            sdkVersion: "1.0",
            telemetryOptions: TelemetryOptions(telemetryDisabled: true),
            platformInfoProvider: TestPlatformInfoProvider(deviceName: "iPhone6,2", osVersion: "13.2"),
            appBundleInfoProvider: TestBundleInfoProvider(
                name: "MyBundle",
                version: "2.0",
                minDeploymentTarget: "iOS 9.0"
            ),
            localeInfoProvider: TestLocaleInfoProvider(language: "en", region: "US")
        )
        let userAgent = policy.userAgent
        XCTAssertEqual(userAgent, "azsdk-ios-Test/1.0")
    }

    /// Test that the user agent policy adds the user agent header to the request when none exists
    func test_UserAgentPolicy_WithoutCurrentUserAgent_AddsHeaderToRequest() {
        let policy = UserAgentPolicy(
            sdkName: "Test",
            sdkVersion: "1.0",
            platformInfoProvider: nil,
            appBundleInfoProvider: nil,
            localeInfoProvider: nil
        )
        let req = PipelineRequest()
        policy.on(request: req) { _, _ in }
        XCTAssertEqual(req.httpRequest.headers[.userAgent], "azsdk-ios-Test/1.0")
    }

    /// Test that the user agent policy replaces an existing user agent header generated by the policy
    func test_UserAgentPolicy_WithCurrentDefaultUserAgent_ReplacesHeaderValue() {
        let policy = UserAgentPolicy(
            sdkName: "Test",
            sdkVersion: "1.0",
            platformInfoProvider: nil,
            appBundleInfoProvider: nil,
            localeInfoProvider: nil
        )
        let headers = HTTPHeaders([.userAgent: "azsdk-ios-Garbage/0.0"])
        let req = PipelineRequest(headers: headers)
        policy.on(request: req) { _, _ in }
        XCTAssertEqual(req.httpRequest.headers[.userAgent], "azsdk-ios-Test/1.0")
    }

    /// Test that the user agent policy prepends its user agent header value if a user agent header already exists
    func test_UserAgentPolicy_WithCurrentNonDefaultUserAgent_PrependsHeaderValue() {
        let policy = UserAgentPolicy(
            sdkName: "Test",
            sdkVersion: "1.0",
            platformInfoProvider: nil,
            appBundleInfoProvider: nil,
            localeInfoProvider: nil
        )
        let headers = HTTPHeaders([.userAgent: "CustomUserAgent/8.0"])
        let req = PipelineRequest(headers: headers)
        policy.on(request: req) { _, _ in }
        XCTAssertEqual(req.httpRequest.headers[.userAgent], "azsdk-ios-Test/1.0 CustomUserAgent/8.0")
    }
}

public extension UserAgentPolicy {
    convenience init(
        sdkName: String,
        sdkVersion: String,
        platformInfoProvider: PlatformInfoProvider? = DeviceProviders.platformInfo,
        appBundleInfoProvider: BundleInfoProvider? = DeviceProviders.appBundleInfo,
        localeInfoProvider: LocaleInfoProvider? = DeviceProviders.localeInfo
    ) {
        self.init(
            sdkName: sdkName,
            sdkVersion: sdkVersion,
            telemetryOptions: TelemetryOptions(),
            platformInfoProvider: platformInfoProvider,
            appBundleInfoProvider: appBundleInfoProvider,
            localeInfoProvider: localeInfoProvider
        )
    }
}
