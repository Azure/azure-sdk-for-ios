# Azure Template client library for iOS

This package has no functionality and is only used for testing Engineering System deployments.

## Getting started

### Prerequisites
* The client library is written in modern Swift 5. Due to this, Xcode 10.2 or higher is required to use this library.

### Install the library
To install the Azure client libraries for iOS, we recommend you use
[Swift Package Manager](#add-a-package-dependency-with-swift-package-manager).
As an alternative, you may also integrate the libraries using
[CocoaPods](#integrate-the-client-libraries-with-cocoapods).

#### Add a package dependency with Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for managing the distribution of Swift code.
It’s integrated with the Swift build system to automate the process of downloading, compiling, and linking dependencies.

Xcode comes with built-in support for Swift Package Manager and source control accounts and makes it easy to leverage
available Swift packages. Use Xcode to manage the versions of package dependencies and make sure your project has the
most up-to-date code changes.

##### Xcode

To add the library to your application, follow the instructions in
[Adding Package Dependencies to Your App](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app):

In order to independently version packages with Swift Package Manager, we mirror the code from azure-sdk-for-ios into separate
repositories. Your Swift Package Manager-based app should target these repos instead of the azure-sdk-for-ios repo.

With your project open in Xcode 11 or later, select **File > Swift Packages > Add Package Dependency...** Enter the
clone URL of the Swift Package Manager mirror repository: *https://github.com/Azure/SwiftPM-AzureTemplate.git*
and click **Next**. For the version rule, specify the exact version or version range you wish to use with your application and
click **Next**. Finally, place a checkmark next to the library, ensure your application target is selected in the **Add to target**
dropdown, and click **Finish**.

##### Swift CLI

To add the library to your application, follow the example in
[Importing Dependencies](https://swift.org/package-manager/#importing-dependencies):

Open your project's `Package.swift` file and add a new package dependency to your project's `dependencies` section,
specifying the clone URL of this repository and the version specifier you wish to use:

```swift
// swift-tools-version:5.3
    dependencies: [
        ...
        .package(name: "AzureTemplate", url: "https://github.com/Azure/SwiftPM-AzureTemplate.git", from: "1.7.0-beta.4")
    ],
```

Next, for each target that needs to use the library, add it to the target's array of `dependencies`:
```swift
    targets: [
        ...
        .target(
            name: "MyTarget",
            dependencies: ["AzureTemplate", ...])
    ]
)
```

#### Integrate the client libraries with CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Objective C and Swift projects. You can install it with
the following command:

```bash
$ [sudo] gem install cocoapods
```

> CocoaPods 1.5+ is required.

To integrate one or more client libraries into your project using CocoaPods, specify them in your
[Podfile](https://guides.cocoapods.org/using/the-podfile.html), providing the version specifier you wish to use. To
ensure compatibility when using multiple client libraries in the same project, use the same version specifier for all
Azure SDK client libraries within the project:

```ruby
platform :ios, '12.0'

# Comment the next line if you don't want to use dynamic frameworks
use_frameworks!

target 'MyTarget' do
  pod 'AzureTemplate', '1.7.0-beta.4'
  ...
end
```

Then, run the following command:

```bash
$ pod install
```

## Key concepts

Not applicable.

## Examples

Not applicable.

## Troubleshooting

Not applicable.

## Next steps

Explore and install
[available Azure SDK libraries](https://github.com/Azure/azure-sdk-for-ios/blob/main/README.md#libraries-available).

## Contributing

This project welcomes contributions and suggestions. All code contributions should be made in the [Azure SDK for iOS]
(https://github.com/Azure/azure-sdk-for-ios) repository.

Most contributions require you to agree to a Contributor License
Agreement (CLA) declaring that you have the right to, and actually do, grant us the rights to use your contribution. For
details, visit https://cla.microsoft.com.

When you submit a pull request, a CLA-bot will automatically determine whether you need to provide a CLA and decorate
the PR appropriately (e.g., label, comment). Simply follow the instructions provided by the bot. You will only need to
do this once across all repositories using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact
[opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.


