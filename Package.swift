// swift-tools-version:4.0
//  The swift-tools-version declares the minimum version of Swift required to build this package.
//
//  Package.swift
//  Azure.iOS
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import PackageDescription

let package = Package(
    name: "Azure.iOS",
    products: [
        .library(name: "AzureCore", targets: ["AzureCore"]),
        .library(name: "AzureAuth", targets: ["AzureAuth"]),
        .library(name: "AzureData", targets: ["AzureData"]),
        .library(name: "AzurePush", targets: ["AzurePush"]),
        .library(name: "AzureStorage", targets: ["AzureStorage"]),
        .library(name: "AzureMobile", targets: ["AzureMobile"])
    ],
    dependencies: [
        .package(url: "https://github.com/Nike-Inc/Willow.git", from: "5.0.2"),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: "3.1.1"),
    ],
    targets: [
        .target(name: "AzureCore", dependencies: ["Willow", "KeychainAccess"], path: "AzureCore", sources: ["Source"]),
        .target(name: "AzureAuth", dependencies: ["AzureCore"], path: "AzureAuth", sources: ["Source"]),
        .target(name: "AzureData", dependencies: ["AzureCore"], path: "AzureData", sources: ["Source"]),
        .target(name: "AzurePush", dependencies: ["AzureCore"], path: "AzurePush", sources: ["Source"]),
        .target(name: "AzureStorage", dependencies: ["AzureCore"], path: "AzureStorage", sources: ["Source"]),
        .target(name: "AzureMobile", dependencies: ["AzureCore"], path: "AzureMobile", sources: ["Source"])
    ],
    swiftLanguageVersions: [4]
)
