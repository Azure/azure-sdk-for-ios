

# Azure.iOS [![Build Status](https://travis-ci.org/Azure/Azure.iOS.svg?branch=master)](https://travis-ci.org/Azure/Azure.iOS) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![CocoaPod](https://img.shields.io/cocoapods/v/AzureData.svg)](https://cocoapods.org/pods/AzureData) ![Platforms](https://img.shields.io/cocoapods/p/AzureData.svg)
_**This project is in active development and will change.**_

Azure.iOS is a collection of SDKs for rapidly creating iOS apps with modern, highly-scalable backends on Azure.

The SDKs are broken out by function and are designed to work just as well individually as they do together.

| SDK | Status | Pod | Source | Docs | Summary |
|:--- |:------ |:---:|:------:|:----:|:------- |
| **[AzureData](AzureData)**       | :white_check_mark:[Preview Release](https://github.com/Azure/Azure.iOS/releases) | [v0.1.7](https://cocoapods.org/pods/AzureData)              | [source](AzureData)    | [wiki](https://github.com/Azure/Azure.iOS/wiki/AzureData)    | _Online/offline schema-less JSON database_ |
| **[AzureCore](AzureCore)**       | :white_check_mark:[Preview Release](https://github.com/Azure/Azure.iOS/releases) | [v0.1.7](https://cocoapods.org/pods/AzureCore)              | [source](AzureCore)    | [wiki](https://github.com/Azure/Azure.iOS/wiki/AzureCore)    | _Core functionality shared among SDKs_ |
| **[AzureMobile](AzureMobile)**   | [Development](AzureAuth)                                                         | [v0.1.7](https://cocoapods.org/pods/AzureMobile)            | [source](AzureMobile)  | [wiki](https://github.com/Azure/Azure.iOS/wiki/AzureMobile)  | _Authenticate with identity providers SDKs_ |
| **[AzureAuth](AzureAuth)**       | [Development](AzureAuth)                                                         | <!--[v0.1.7](https://cocoapods.org/pods/AzureAuth)--> --    | [source](AzureAuth)    | [wiki](https://github.com/Azure/Azure.iOS/wiki/AzureAuth)    | _Connect to [Azure.Mobile](https://aka.ms/mobile) services_ |
| **[AzurePush](AzurePush)**       | Backlog                                                                          | <!--[v0.1.7](https://cocoapods.org/pods/AzurePush)--> --    | [source](AzurePush)    | [wiki](https://github.com/Azure/Azure.iOS/wiki/AzurePush)    | _Push notifications (current SDK [here](https://github.com/Azure/azure-notificationhubs/tree/master/iOS/WindowsAzureMessaging))_ |
| **[AzureStorage](AzureStorage)** | Backlog                                                                          | <!--[v0.1.7](https://cocoapods.org/pods/AzureStorage)--> -- | [source](AzureStorage) | [wiki](https://github.com/Azure/Azure.iOS/wiki/AzureStorage) | _Cloud storage (current SDK [here](https://github.com/Azure/azure-storage-ios))_ |


# Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects.
You can install it with the following command:

```bash
[sudo] gem install cocoapods
```

> CocoaPods 1.3+ is required.

To integrate the Azure.iOS into your project, specify it in your [Podfile](http://guides.cocoapods.org/using/the-podfile.html):

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '11.0'
use_frameworks!

# pod 'AzureAuth', '~> 0.1'
pod 'AzureData', '~> 0.1'
```

Then, run the following command:

```bash
$ pod install
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate Azure.iOS into your Xcode project using Carthage, specify it in your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile):

```
github "Azure/Azure.iOS" ~> 0.1
```

Run `carthage update` to build the framework and drag the built `AzureData.framework`, `AzureData.framework`, etc. into your Xcode project.


# Getting Started

Once you [add the SDKs to your project](#installation)...

// coming soon

# About
This project is in active development and will change. As the SDKs become ready for use, they will be versioned and released.

We will do our best to conduct all development openly by posting detailed [requirements](https://github.com/Azure/Azure.iOS/wiki/Requirements) and managing the project using [issues](https://github.com/Azure/Azure.iOS/issues), [milestones](https://github.com/Azure/Azure.iOS/milestones), and [projects](https://github.com/Azure/Azure.iOS/projects).

## Contributing
This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).  
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Reporting Security Issues
Security issues and bugs should be reported privately, via email, to the Microsoft Security Response Center (MSRC) at [secure@microsoft.com](mailto:secure@microsoft.com). You should receive a response within 24 hours. If for some reason you do not, please follow up via email to ensure we received your original message. Further information, including the [MSRC PGP](https://technet.microsoft.com/en-us/security/dn606155) key, can be found in the [Security TechCenter](https://technet.microsoft.com/en-us/security/default).

## License
Copyright (c) Microsoft Corporation. All rights reserved.  
Licensed under the MIT License.  See [LICENSE](License) for details.


