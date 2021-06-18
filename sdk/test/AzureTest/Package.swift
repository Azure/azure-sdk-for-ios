// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AzureTest",
    platforms: [
        .macOS(.v10_15), .iOS(.v12)
    ],
    products: [
        .library(name: "AzureTest", targets: ["AzureTest"])
    ],
    dependencies: [
        .package(name: "AzureCore", url: "https://github.com/Azure/SwiftPM-AzureCore.git", from: "1.0.0-beta.12"),
        .package(name: "DVR", url: "https://github.com/tjprescott/DVR.git", .branch: "main")
    ],
    targets: [
        // Build targets
        .target(
            name: "AzureTest",
            dependencies: ["AzureCore", "DVR"]
        ),
        // Test targets
        .testTarget(
            name: "AzureTestTests",
            dependencies: ["AzureTest"]
        )
    ]
)
