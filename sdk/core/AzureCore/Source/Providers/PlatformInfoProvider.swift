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

// MARK: PlatformInfoProvider Protocol

public protocol PlatformInfoProvider {
    var deviceName: String? { get }
    var osVersion: String? { get }
}

// MARK: DevicePlatformInfoProvider

#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
struct DevicePlatformInfoProvider: PlatformInfoProvider {
    // MARK: Computed Properties

    /// e.g. "MacPro4,1" or "iPhone8,1"
    /// NOTE: this is *corrected* on iOS devices to fetch hw.machine
    public var deviceName: String? {
        #if os(iOS) && !arch(x86_64) && !arch(i386)
            return Sysctl.string(for: [CTL_HW, HW_MACHINE])
        #else
            return Sysctl.string(for: [CTL_HW, HW_MODEL])
        #endif
    }

    /// e.g. "15.3.0" or "15.0.0"
    public var osVersion: String? {
        return Sysctl.string(for: [CTL_KERN, KERN_OSRELEASE])
    }
}

// MARK: Sysctl

private enum Sysctl {
    // MARK: Static Methods

    /// Access the raw data for an array of sysctl identifiers.
    public static func data(for keys: [Int32]) -> [Int8]? {
        return keys.withUnsafeBufferPointer { keysPointer -> [Int8]? in
            // Preflight the request to get the required data size
            var requiredSize = 0
            let preFlightResult = Darwin.sysctl(
                UnsafeMutablePointer<Int32>(mutating: keysPointer.baseAddress),
                UInt32(keys.count),
                nil,
                &requiredSize,
                nil,
                0
            )
            if preFlightResult != 0 {
                return nil
            }

            // Run the actual request with an appropriately sized array buffer
            let data = [Int8](repeating: 0, count: requiredSize)
            let result = data.withUnsafeBufferPointer { dataBuffer -> Int32 in
                Darwin.sysctl(
                    UnsafeMutablePointer<Int32>(mutating: keysPointer.baseAddress),
                    UInt32(keys.count),
                    UnsafeMutableRawPointer(mutating: dataBuffer.baseAddress),
                    &requiredSize,
                    nil,
                    0
                )
            }
            if result != 0 {
                return nil
            }

            return data
        }
    }

    /// Invoke `sysctl` with an array of identifers, interpreting the returned buffer as a `String`.
    public static func string(for keys: [Int32]) -> String? {
        guard let data = data(for: keys) else { return nil }
        return data.withUnsafeBufferPointer { dataPointer -> String? in
            dataPointer.baseAddress.flatMap { String(validatingUTF8: $0) }
        }
    }
}
#else
// MARK: Fallback PlatformInfoProvider for non-Apple platforms

struct DevicePlatformInfoProvider: PlatformInfoProvider {
    public var deviceName: String? { return "Unknown" }
    public var osVersion: String? { return "Unknown" }
}
#endif
