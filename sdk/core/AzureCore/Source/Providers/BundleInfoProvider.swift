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

// MARK: BundleInfoProvider Protocol

public protocol BundleInfoProvider {
    var identifier: String? { get }
    var name: String? { get }
    var version: String? { get }
    var minDeploymentTarget: String? { get }
}

// MARK: DeviceBundleInfoProvider

struct DeviceBundleInfoProvider: BundleInfoProvider {
    // MARK: Properties

    private let bundle: Bundle

    // MARK: Initializers

    public init(for bundle: Bundle) {
        self.bundle = bundle
    }

    // MARK: Computed Properties

    public var identifier: String? {
        return bundle.bundleIdentifier
    }

    public var name: String? {
        return bundle.infoDictionary?["CFBundleName"] as? String
    }

    public var version: String? {
        return bundle.infoDictionary?["CFBundleShortVersionString"] as? String
    }

    public var minDeploymentTarget: String? {
        #if os(iOS) || os(watchOS) || os(tvOS)
            guard let version = bundle.infoDictionary?["MinimumOSVersion"] as? String else { return nil }
            #if targetEnvironment(macCatalyst)
                return "macOS - Catalyst \(version)"
            #else
                return "iOS \(version)"
            #endif
        #elseif os(macOS)
            guard let version = Bundle.main.infoDictionary?["LSMinimumSystemVersion"] as? String else { return nil }
            return "macOS \(version)"
        #else
            return nil
        #endif
    }
}
