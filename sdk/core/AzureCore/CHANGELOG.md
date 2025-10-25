# Release History

## 1.0.0-beta.16 (2025-04-02)
### Bugs Fixed
- Fixed compilation error on XCode 16.3 with `Equatable` and `Comparable` protocols.

### New Features
- Added async wrappers to PageCollection nextPage and nextItem

## 1.0.0-beta.15 (2022-03-08)
### Bugs Fixed
- Fixed issue where pipeline calls multiple callback if a bad status code was received.

## 1.0.0-beta.14 (2022-02-10)

### Bugs Fixed
- Fixed issue where certain system errors would be swallowed by AzureCore instead of passed
  along to the developer.

## 1.0.0-beta.13 (2021-09-02)
### Bugs Fixed
- Changed the format for application ID in `UserAgentPolicy` to remove the square brackets around it.  

## 1.0.0-beta.12 (2021-04-22)
Minor update for Swift Package Manager.

## 1.0.0-beta.11 (2021-04-07)
### New Features

### Breaking Changes
- Swift PM user should now target the `SwiftPM-AzureCore` repo.
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

- Azure SDK for iOS core ([AzureCore](https://github.com/Azure/azure-sdk-for-ios/tree/main/sdk/core/AzureCore))
