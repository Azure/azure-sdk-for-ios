// swift-tools-version:4.0
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
    products: [
        .library(name: "AzureCore", targets: ["AzureCore"]),
        .library(name: "AzureAppConfiguration", targets: ["AzureAppConfiguration"]),
        .library(name: "AzureCSComputerVision", targets: ["AzureCSComputerVision"]),
        .library(name: "AzureCSTextAnalytics", targets: ["AzureCSTextAnalytics"]),
        .library(name: "AzureStorageBlob", targets: ["AzureStorageBlob"])
    ],
    dependencies: [
        .package(url: "https://github.com/AzureAD/microsoft-authentication-library-for-objc.git", from: "1.0.0")
    ],
    targets: [
        .target(name: "AzureCore", dependencies: [], path: "AzureCore", sources: ["Source"]),
        .target(name: "AzureAppConfiguration", dependencies: ["AzureCore"], path: "AzureAppConfiguration", sources: ["Source"]),
        .target(name: "AzureCSComputerVision", dependencies: ["AzureCore"], path: "AzureCSComputerVision", sources: ["Source"]),
        .target(name: "AzureCSTextAnalytics", dependencies: ["AzureCore"], path: "AzureCSTextAnalytics", sources: ["Source"]),
        .target(name: "AzureStorageBlob", dependencies: ["AzureCore", "MSAL"], path: "AzureStorageBlob", sources: ["Source"]),
    ],
    swiftLanguageVersions: [5]
)
