// swift-tools-version:5.3
//  The swift-tools-version declares the minimum version of Swift required to build this package.
//
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

import PackageDescription

let package = Package(
    name: "AzureCommunicationCommon",
    platforms: [
        .macOS(.v10_15), .iOS(.v12)
    ],
    products: [
        .library(name: "AzureCommunicationCommon", targets: ["AzureCommunicationCommon"])
    ],
    dependencies: [
        .package(name: "AzureCore", url: "https://github.com/Azure/SwiftPM-AzureCore.git", from: "1.0.0-beta.12")
    ],
    targets: [
        // Build targets
        .target(
            name: "AzureCommunicationCommon",
            dependencies: ["AzureCore"],
            path: "Source",
            exclude: [
                "README.md",
                "Tests",
                "Source/Supporting Files",
                "LICENSE"
            ]
        ),
        // Test targets
        .testTarget(
            name: "AzureCommunicationCommonTests",
            dependencies: ["AzureCommunicationCommon"],
            path: "Tests",
            exclude: [
                "Info.plist",
                "AzureCommunicationCommonTests-Bridging-Header.h",
                "ObjCCommunicationTokenCredentialTests.m",
                "ObjCCommunicationTokenCredentialAsyncTests.m",
                "ObjCTokenParserTests.m"
            ]
        )
    ],
    swiftLanguageVersions: [.v5]
)
