# Azure SDK for iOS

This repository is for active development of the Azure SDK for iOS. For consumers of the SDK we recommend visiting our versioned [developer docs](https://azure.github.io/azure-sdk-for-ios).

> Note: The Azure SDK for iOS replaces a previous offering, known as Azure.iOS. Source code and documentation for Azure.iOS is available in the [legacy](https://github.com/Azure/azure-sdk-for-ios/tree/legacy) branch.

## Getting started

For your convenience, each service has a separate set of libraries that you can choose to use instead of one, large Azure package. To get started with a specific library, see the **README.md** file located in the library's project folder. You can find service libraries in the `/sdk` directory.

### Prerequisites

* The client libraries are written in modern Swift 5. Due to this, Xcode 10.2 or higher is required to use these libraries.
* You must have an [Azure subscription](https://azure.microsoft.com/free/) to use these libraries.

### Libraries available

The latest version of the SDK is [1.0.0-beta.7](https://github.com/Azure/azure-sdk-for-ios/releases/tag/1.0.0-beta.7). Older [releases](https://github.com/Azure/azure-sdk-for-ios/releases) are also available.

Currently, the client libraries are in **beta**. These libraries follow the [Azure SDK Design Guidelines for iOS](https://azure.github.io/azure-sdk/ios_introduction.html) and share a number of core features such as HTTP retries, logging, transport protocols, authentication protocols, etc., so that once you learn how to use these features in one client library, you will know how to use them in other client libraries. You can learn about these shared features in [AzureCore](https://github.com/Azure/azure-sdk-for-ios/blob/master/sdk/core/AzureCore/README.md).

The following libraries are currently in **beta**:

#### Core
- [AzureCore](https://github.com/Azure/azure-sdk-for-ios/blob/master/sdk/core/AzureCore/)

#### Azure Communication Services
- [AzureCommunication](https://github.com/Azure/azure-sdk-for-ios/blob/master/sdk/communication/AzureCommunication/)
- [AzureCommunicationCalling](https://github.com/Azure/Communication/releases)
- [AzureCommunicationChat](https://github.com/Azure/azure-sdk-for-ios/blob/master/sdk/communication/AzureCommunicationChat/)

> Note: The SDK is currently in **beta**. The API surface and feature sets are subject to change at any time before they become generally available. We do not currently recommend them for production use.

### Install the libraries
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

To add the Azure SDK for iOS to your application, follow the instructions in
[Adding Package Dependencies to Your App](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app):

With your project open in Xcode 11 or later, select **File > Swift Packages > Add Package Dependency...** Enter the
clone URL of this repository: *https://github.com/Azure/azure-sdk-for-ios.git* and click **Next**. For the version rule,
specify the exact version or version range you wish to use with your application and click **Next**. Finally, place a
checkmark next to each client library you wish to use with your application, ensure your application target is selected
in the **Add to target** dropdown, and click **Finish**.

##### Swift CLI

To add the Azure SDK for iOS to your application, follow the example in
[Importing Dependencies](https://swift.org/package-manager/#importing-dependencies):

Open your project's `Package.swift` file and add a new package dependency to your project's `dependencies` section,
specifying the clone URL of this repository and the version specifier you wish to use:

```swift
    dependencies: [
        ...
        .package(url: "https://github.com/Azure/azure-sdk-for-ios.git", from: "1.0.0-beta.7")
    ],
```

Next, add each client library you wish to use in a target to the target's array of `dependencies`:
```swift
    targets: [
        ...
        .target(
            name: "MyTarget",
            dependencies: ["AzureCommunicationChat", ...])
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
  pod 'AzureCommunicationChat', '~> 1.0.0-beta.7'
  ...
end
```

Then, run the following command:

```bash
$ pod install
```

## Need help?

* File an issue via [GitHub Issues](https://github.com/Azure/azure-sdk-for-ios/issues/new/choose).
* Check [previous questions](https://stackoverflow.com/questions/tagged/azure+ios) or ask new ones on StackOverflow using `azure` and `ios` tags.

### Reporting security issues and security bugs

Security issues and bugs should be reported privately, via email, to the Microsoft Security Response Center (MSRC) <secure@microsoft.com>. You should receive a response within 24 hours. If for some reason you do not, please follow up via email to ensure we received your original message. Further information, including the MSRC PGP key, can be found in the [Security TechCenter](https://www.microsoft.com/msrc/faqs-report-an-issue).

## Contributing
For details on contributing to this repository, see the [contributing guide](https://github.com/Azure/azure-sdk-for-ios/blob/master/CONTRIBUTING.md).

This project welcomes contributions and suggestions. Most contributions require you to agree to a Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us the rights to use your contribution. For details, visit
https://cla.microsoft.com.

When you submit a pull request, a CLA-bot will automatically determine whether you need to provide a CLA and decorate the PR appropriately (e.g., label, comment). Simply follow the instructions provided by the bot. You will only need to do this once across all repositories using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

![Impressions](https://azure-sdk-impressions.azurewebsites.net/api/impressions/azure-sdk-for-ios%2FREADME.png)
