# Release History

## 1.0.1 (Upcoming)
### New Features
- Removing dependency on AzureCore
- `StaticTokenCredential` and `CommunicationTokenCredential` now throw `NSError` instead of an `AzureError`.

## 1.0.0 (2021-04-26)
### New Features
- `AzureCommunicationCommon` is GA.

### Breaking Changes
- `AzureCommunication` has been renamed `AzureCommunicationCommon`.
- Swift PM user should now target the `SwiftPM-AzureCommunicationCommon` repo.

## 1.0.0-beta.12 (2021-04-26)
Marking `AzureCommunication` as deprecated in favor of `AzureCommunicationCommon`.

## 1.0.0-beta.11 (2021-04-07)
### Breaking Changes
- Swift PM user should now target the `SwiftPM-AzureCommunication` repo.
- AzureCommunication can now version independently of other libraries.
- Updated the Objective-C initializer for `CommunicationUserIdentifier` and `UnknownIdentifier` to be `initWithIdentifier:`. Making it align more with Objective-C guidelines.
- Updated `CommunicationTokenCredential` init method from `init(with:)` to `init(withOptions:)`. Objective-c method will change from `initWith: error:]` to `initWithOptions: error:]`.
- Removed `CommunicationPolicyTokenCredential`.
- Typealias `TokenRefreshOnCompletion` renamed to `TokenRefreshHandler`.
- Typealias `TokenRefresherClosure` renamed to `TokenRefresher`.

## 1.0.0-beta.9 (2021-03-10)

### Breaking Changes
- Removal of `CommunicationCloudEnvironment.fromModel()` method
- Removal of label `identifier` in `CommunicationUserIdentifier` and `UnknownIdentifier`
- `CommunicationIdentifierModel` and `CommunicationIdentifierSerializer` are no longer part of the communication package, they have been moved to AzureCommunicationChat

## 1.0.0-beta.8 (2021-02-09)

### Breaking Changes
 - Renamed the type `CommunicationUserCredential` to `CommunicationTokenCredential`, as it represents a token.
 - Communication identifier `MicrosoftTeamsUserIdentifier` property `identifier` renamed to `userId` since identifier was too generic.
 - Communication identifier `MicrosoftTeamsUserIdentifier` property `id` renamed to `rawId` to represent full MRI.
 - Communication identifier `PhoneNumberIdentifier` property `id` renamed to `rawId` to represent full MRI.
 - Removed `CallingApplicationIdentifier` as it is currently unused by any service.
 - The protocol `CommunicationTokenCredential` has likewise been renamed to `CommunicationTokenCredentialProviding`.
 - All types that conform to the `CommunicationIdentifier` protocol now use the suffix `Identifier`. For example, the
    `PhoneNumber` type used to represent a phone number identifier is now named `PhoneNumberIdentifier`.
 - Updated the `CommunicationTokenCredential` initializer that automatically refreshes the token to accept a single
    `CommunicationTokenRefreshOptions` object instead of multiple parameters.

 ### Key Bug Fixes
 - Removing `CommunicationUserCredentialPolicy`, this policy was a duplicate of cores `BearerTokenCredentialPolicy`.
  Communication now has new ability to create `BearerTokenCredentialPolicy` using the new `CommunicationPolicyTokenCredential`.

## 1.0.0-beta.7 (2021-01-12)

### New Features
  - Added a new communication identifier `MicrosoftTeamsUserIdentifier`, used to represent a Microsoft Teams user.
  - Introduced the new `CommunicationTokenRefreshOptions` type for specifying communication token refresh options.

### Breaking Changes
  - Renamed the type `CommunicationUserCredential` to `CommunicationTokenCredential`, as it represents a token.
  - The protocol `CommunicationTokenCredential` has likewise been renamed to `CommunicationTokenCredentialProviding`.
  - All types that conform to the `CommunicationIdentifier` protocol now use the suffix `Identifier`. For example, the
    `PhoneNumber` type used to represent a phone number identifier is now named `PhoneNumberIdentifier`.
  - Updated the `CommunicationTokenCredential` initializer that automatically refreshes the token to accept a single
    `CommunicationTokenRefreshOptions` object instead of multiple parameters.

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

- Azure Communication Services common ([AzureCommunication](https://github.com/Azure/azure-sdk-for-ios/tree/main/sdk/communication/AzureCommunicationCommon))
  - This library is used by other libraries in this SDK, as well as by libraries in the [Azure Communication SDKs](https://github.com/Azure/Communication).
