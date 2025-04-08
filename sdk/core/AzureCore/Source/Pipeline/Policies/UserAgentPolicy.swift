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

import Foundation

public class UserAgentPolicy: PipelineStage {
    // MARK: Properties

    public var next: PipelineStage?

    private static let defaultUserAgent = "azsdk-ios"

    // From the design guidelines, the full user agent header format is:
    // [<application_id>] azsdk-ios-<sdk_name>/<sdk_version> (<platform_info>; <application_info>; <user_locale_info>)
    private static let userAgentFormat = defaultUserAgent + "-%@/%@"
    private static let appIdPrefixFormat = "%@ "
    private static let infoSuffixFormat = " (%@)"
    private static let infoSuffixSeparator = "; "

    // From the design guidelines, the platform info user agent header format is:
    // <device_name> - <os_version>
    private static let platformInfoFormat = "%@ - %@"

    // From the design guidelines, the application info user agent header format is:
    // <bundle_name>:<bundle_version> -> <deployment_target>
    private static let bundleInfoFormat = "%@:%@"
    private static let deploymentTargetSeparator = " -> "

    // From the design guidelines, the user locale info user agent header format is:
    // <user_language>_<user_region>
    private static let userLocaleInfoFormat = "%@_%@"

    let userAgent: String

    // MARK: Initializers

    public convenience init(for clazz: AnyClass, telemetryOptions: TelemetryOptions) {
        let libraryBundleInfo = DeviceProviders.bundleInfo(for: clazz)
        let sdkName = libraryBundleInfo?.name ?? ""
        let sdkVersion = libraryBundleInfo?.version ?? ""
        self.init(sdkName: sdkName, sdkVersion: sdkVersion, telemetryOptions: telemetryOptions)
    }

    public init(
        sdkName: String,
        sdkVersion: String,
        telemetryOptions: TelemetryOptions,
        platformInfoProvider: PlatformInfoProvider? = DeviceProviders.platformInfo,
        appBundleInfoProvider: BundleInfoProvider? = DeviceProviders.appBundleInfo,
        localeInfoProvider: LocaleInfoProvider? = DeviceProviders.localeInfo
    ) {
        var userAgent = String(format: UserAgentPolicy.userAgentFormat, sdkName, sdkVersion)

        let applicationId = telemetryOptions.applicationId ?? appBundleInfoProvider?.identifier
        if var applicationId = applicationId, !applicationId.isEmpty {
            // From the design guidelines, applicationId must not contain a space
            if applicationId.rangeOfCharacter(from: .whitespacesAndNewlines) != nil {
                applicationId = applicationId.components(separatedBy: .whitespacesAndNewlines).joined()
            }
            // From the design guidelines, applicationId must not be more than 24 characters in length
            if applicationId.count > 24 {
                applicationId = String(applicationId.prefix(24))
            }
            // Don't use the applicationId if it's empty after applying the validations above
            if !applicationId.isEmpty {
                userAgent = String(format: UserAgentPolicy.appIdPrefixFormat, applicationId) + userAgent
            }
        }

        if !telemetryOptions.telemetryDisabled, let infoSuffix = UserAgentPolicy.getInfoSuffix(
            platform: platformInfoProvider,
            bundle: appBundleInfoProvider,
            locale: localeInfoProvider
        ) {
            userAgent += String(format: UserAgentPolicy.infoSuffixFormat, infoSuffix)
        }
        self.userAgent = userAgent
    }

    // MARK: Private Methods

    private static func getInfoSuffix(
        platform: PlatformInfoProvider? = nil,
        bundle: BundleInfoProvider? = nil,
        locale: LocaleInfoProvider? = nil
    ) -> String? {
        var infoParts: [String] = []

        if let deviceName = platform?.deviceName, let osVersion = platform?.osVersion {
            infoParts.append(String(format: UserAgentPolicy.platformInfoFormat, deviceName, osVersion))
        }

        if let bundleName = bundle?.name, let bundleVersion = bundle?.version {
            var bundlePart = String(format: UserAgentPolicy.bundleInfoFormat, bundleName, bundleVersion)
            if let minTarget = bundle?.minDeploymentTarget {
                bundlePart += "\(UserAgentPolicy.deploymentTargetSeparator)\(minTarget)"
            }
            infoParts.append(bundlePart)
        }

        if let language = locale?.language, let region = locale?.region {
            infoParts.append(String(format: UserAgentPolicy.userLocaleInfoFormat, language, region))
        }

        if infoParts.count > 0 {
            return infoParts.joined(separator: UserAgentPolicy.infoSuffixSeparator)
        }
        return nil
    }

    // MARK: PipelineStage Methods

    public func on(request: PipelineRequest, completionHandler: @escaping OnRequestCompletionHandler) {
        if let currentUserAgent = request.httpRequest.headers[.userAgent],
           !currentUserAgent.contains(UserAgentPolicy.defaultUserAgent)
        {
            request.httpRequest.headers[.userAgent] = "\(userAgent) \(currentUserAgent)"
        } else {
            request.httpRequest.headers[.userAgent] = userAgent
        }
        completionHandler(request, nil)
    }
}
