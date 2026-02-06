// swift-tools-version:5.9
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
    name: "AzureCommunicationCalling",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        // Expose Calling as its own product
        .library(
            name: "AzureCommunicationCalling",
            targets: ["AzureCommunicationCalling"]
        ),
        // Expose Common as its own product
        .library(
            name: "AzureCommunicationCommon",
            targets: ["AzureCommunicationCommon"]
        )
    ],
    targets: [
        .binaryTarget(
            name: "AzureCommunicationCalling",
            url: "https://github.com/Azure/Communication/releases/download/v2.18.1/AzureCommunicationCalling-2.18.1.zip",
            checksum: "cacc1b4d23e72dbbf7719bbf1ba662e7cd11b88eafccc88693617fea60e7418a"
        ),
        .binaryTarget(
            name: "AzureCommunicationCommon",
            url:"https://github.com/Azure/azure-sdk-for-ios/releases/download/AzureCommunicationCommon_1.3.3/AzureCommunicationCommon_1.3.3.xcframework.zip",
            checksum: "4694c77d1ef30178197c458195474b78b4e28098c821e0392c420cf5f0762568"
        )
    ]
)
