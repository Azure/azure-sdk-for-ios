// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AzureSDKSwiftPM",
    platforms: [.iOS(.v13), .macOS(.v10_15)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(name: "AzureSDKSwiftPM", targets: ["AzureSDKSwiftPM"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "AzureSDK", url: "https://github.com/Azure/azure-sdk-for-ios.git", .branch("feature/CallingSPM")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "AzureSDKSwiftPM",
            dependencies: [
                .product(name: "AzureCore", package: "AzureSDK"),
                .product(name: "AzureCommunication", package: "AzureSDK"),
                .product(name: "AzureCommunicationChat", package: "AzureSDK"),
                .product(name: "AzureCommunicationCalling", package: "AzureSDK"),
            ]),
        .testTarget(
            name: "AzureSDKSwiftPMTests",
            dependencies: ["AzureSDKSwiftPM"]),
    ]
)
