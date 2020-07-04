// swift-tools-version:5.1
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
    name: "AzureSDK",
    platforms: [
        .macOS(.v10_15), .iOS(.v12), .tvOS(.v12)
    ],
    products: [
        .library(name: "AzureCore", targets: ["AzureCore"]),
        .library(name: "AzureIdentity", targets: ["AzureIdentity"]),
        .library(name: "AzureStorageBlob", targets: ["AzureStorageBlob"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/mitchdenny/microsoft-authentication-library-for-obj",
            .branch("swift-pm-via-binary-framework")
        )
    ],
    targets: [
        // Build targets
        .target(
            name: "AzureCore",
            dependencies: ["microsoft-authentication-library-for-objc"],
            path: "sdk/core/AzureCore",
            sources: ["Source"]
        ),
        .target(
            name: "AzureIdentity",
            dependencies: ["AzureCore", "microsoft-authentication-library-for-objc"],
            path: "sdk/identity/AzureIdentity",
            sources: ["Source"]
        ),
        .target(
            name: "AzureStorageBlob",
            dependencies: ["AzureCore", "microsoft-authentication-library-for-objc"],
            path: "sdk/storage/AzureStorageBlob",
            sources: ["Source"]
        ),
        // Test targets
        .testTarget(
            name: "AzureCoreTests",
            dependencies: ["AzureCore"],
            path: "sdk/core/AzureCore",
            sources: ["Tests"]
        ),
        .testTarget(
            name: "AzureIdentityTests",
            dependencies: ["AzureIdentity"],
            path: "sdk/identity/AzureIdentity",
            sources: ["Tests"]
        ),
        .testTarget(
            name: "AzureStorageBlobTests",
            dependencies: ["AzureStorageBlob"],
            path: "sdk/storage/AzureStorageBlob",
            sources: ["Tests"]
        )
    ],
    swiftLanguageVersions: [.v5]
)
