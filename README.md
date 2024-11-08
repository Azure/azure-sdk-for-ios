# Azure SDK for iOS TEST!

This repository is for active development of the Azure SDK for iOS. For consumers of the SDK we recommend visiting our versioned [developer docs](https://azure.github.io/azure-sdk-for-ios).

> Note: The Azure SDK for iOS replaces a previous offering, known as Azure.iOS. Source code and documentation for Azure.iOS is available in the [legacy](https://github.com/Azure/azure-sdk-for-ios/tree/legacy) branch.

## Getting started

For your convenience, each service has a separate set of libraries that you can choose to use instead of one, large Azure package. To get started with a specific library, see the **README.md** file located in the library's project folder. You can find service libraries in the `/sdk` directory.

### Prerequisites

* The client libraries are written in modern Swift 5. Due to this, Xcode 10.2 or higher is required to use these libraries.
* You must have an [Azure subscription](https://azure.microsoft.com/free/) to use these libraries.

### Libraries available

Releases of all libraries are available here: [releases](https://github.com/Azure/azure-sdk-for-ios/releases)

Currently, the following client libraries are in **beta**. These libraries follow the [Azure SDK Design Guidelines for iOS](https://azure.github.io/azure-sdk/ios_introduction.html) and share a number of core features such as HTTP retries, logging, transport protocols, authentication protocols, etc., so that once you learn how to use these features in one client library, you will know how to use them in other client libraries. You can learn about these shared features in [AzureCore](https://github.com/Azure/azure-sdk-for-ios/blob/main/sdk/core/AzureCore/README.md).

#### Core
- [AzureCore](https://github.com/Azure/azure-sdk-for-ios/blob/main/sdk/core/AzureCore/)

> Note: The SDK is currently in **beta**. The API surface and feature sets are subject to change at any time before they become generally available. We do not currently recommend them for production use.

### Install the libraries
To install the Azure client libraries for iOS, we recommend you use
[Swift Package Manager](#add-a-package-dependency-with-swift-package-manager).
As an alternative, you may also integrate the libraries using
[CocoaPods](#integrate-the-client-libraries-with-cocoapods).

See the README file for individual libraries for instructions.

## Need help?

* File an issue via [GitHub Issues](https://github.com/Azure/azure-sdk-for-ios/issues/new/choose).
* Check [previous questions](https://stackoverflow.com/questions/tagged/azure+ios) or ask new ones on StackOverflow using `azure` and `ios` tags.

### Reporting security issues and security bugs

Security issues and bugs should be reported privately, via email, to the Microsoft Security Response Center (MSRC) <secure@microsoft.com>. You should receive a response within 24 hours. If for some reason you do not, please follow up via email to ensure we received your original message. Further information, including the MSRC PGP key, can be found in the [Security TechCenter](https://www.microsoft.com/msrc/faqs-report-an-issue).

## Contributing
For details on contributing to this repository, see the [contributing guide](https://github.com/Azure/azure-sdk-for-ios/blob/main/CONTRIBUTING.md).

This project welcomes contributions and suggestions. Most contributions require you to agree to a Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us the rights to use your contribution. For details, visit
https://cla.microsoft.com.

When you submit a pull request, a CLA-bot will automatically determine whether you need to provide a CLA and decorate the PR appropriately (e.g., label, comment). Simply follow the instructions provided by the bot. You will only need to do this once across all repositories using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

![Impressions](https://azure-sdk-impressions.azurewebsites.net/api/impressions/azure-sdk-for-ios%2FREADME.png)
