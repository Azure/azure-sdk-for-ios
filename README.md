

# Azure.iOS [![Build Status](https://travis-ci.org/Azure/Azure.iOS.svg?branch=master)](https://travis-ci.org/Azure/Azure.iOS) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![CocoaPod](https://img.shields.io/cocoapods/v/AzureData.svg)](https://cocoapods.org/pods/AzureData) ![Platforms](https://img.shields.io/cocoapods/p/AzureData.svg)

Azure.iOS is a collection of SDKs for rapidly creating iOS apps with modern, highly-scalable backends on Azure.

_**This project is in active development and will change.**_

# SDKs

### [AzureData](AzureData)
![Current State: Preview Release](https://img.shields.io/badge/Current_State-Preview_Release-brightgreen.svg)

AzureData is an SDK for interfacing with [Azure Cosmos DB](https://docs.microsoft.com/en-us/azure/cosmos-db/sql-api-introduction) - A schema-less JSON database engine with rich SQL querying capabilities. It currently supports the full SQL (DocumentDB) API, and offline persistence (including read/write).


### [AzureCore](AzureCore)
![Current State: Preview Release](https://img.shields.io/badge/Current_State-Preview_Release-brightgreen.svg)

AzureCore is a shared dependency of the other four SDKs. It includes functionality like secure storage, reachability, logging, etc.


### [AzureMobile](AzureMobile)
![Current State: Development](https://img.shields.io/badge/Current_State-Development-blue.svg)

AzureMobile is an SDK that connects to services deployed using [Azure.Mobile](https://aka.ms/mobile).


### [AzureAuth](AzureAuth)
![Current State: Development](https://img.shields.io/badge/Current_State-Development-blue.svg)

AzureAuth is an SDK that enables authentication with popular identity providers' SDKs to be used to securely access backend services on [Azure App Service](https://docs.microsoft.com/en-us/azure/app-service/app-service-authentication-overview). It supports five identity providers out of the box: Azure Active Directory, Facebook, Google, Microsoft Account, and Twitter.


### [AzurePush](AzurePush)
![Current State: Development](https://img.shields.io/badge/Current_State-Development-blue.svg)

AzurePush will provide push notification functionality.  The current SDK for Azure Notification Hubs can be found [here](https://github.com/Azure/azure-notificationhubs/tree/master/iOS/WindowsAzureMessaging). The intent is to migrate that SDK to this repository, update it, and refactor the API to ensure it works seamlessly with the other SDKs in this project to provide the best possible developer experience.


### [AzureStorage](AzureStorage)
![Current State: Requirements](https://img.shields.io/badge/Current_State-Requirements-red.svg)

AzureStorage will provide cloud storage functionality.  The current SDK for Azure Storage can be found [here](https://github.com/Azure/azure-storage-ios). The intent is to migrate that SDK to this repository, update it, and refactor the API to ensure it works seamlessly with the other SDKs in this project to provide the best possible developer experience.


# Installation

## CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects.
You can install it with the following command:

```bash
[sudo] gem install cocoapods
```

> CocoaPods 1.3+ is required.

To integrate the Azure.iOS into your project, specify it in your [Podfile](http://guides.cocoapods.org/using/the-podfile.html):

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '12.0'
use_frameworks!

# pod 'AzureAuth', '~> 0.3'
pod 'AzureData', '~> 0.3'
```

Then, run the following command:

```bash
$ pod install
```

## Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate Azure.iOS into your Xcode project using Carthage, specify it in your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile):

```
github "Azure/Azure.iOS" ~> 0.3
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


