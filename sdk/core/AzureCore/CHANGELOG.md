# Release History

## 1.0.0-beta.10 (Unreleased)
### New Features

### Breaking Changes
**Azure Core**
- Swift PM user should now target the `azure-sdk-for-ios-core` repo. 
- AzureCore can now version independently of other libraries.

## 1.0.0-beta.5 (2020-11-18)

### New Features
- Added Cocoapods specs for AzureCore, AzureCommunication, AzureCommunicationChat, and AzureCommunicationCalling
  libraries.

## 1.0.0-beta.1 (2020-09-21):

Version 1.0.0-beta.1 is a beta of our efforts in creating a client library that is developer-friendly, idiomatic to
the iOS ecosystem, and as consistent across different languages and platforms as possible. The principles that guide
our efforts can be found in the
[Azure SDK Design Guidelines for iOS](https://azure.github.io/azure-sdk/ios_introduction.html).

### Added Libraries

- Azure SDK for iOS core ([AzureCore](https://github.com/Azure/azure-sdk-for-ios/tree/master/sdk/core/AzureCore))
- Azure Communication Services common ([AzureCommunication](https://github.com/Azure/azure-sdk-for-ios/tree/master/sdk/communication/AzureCommunication))
  - This library is used by other libraries in this SDK, as well as by libraries in the [Azure Communication SDKs](https://github.com/Azure/Communication).
