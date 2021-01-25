# Release History

## 1.0.0-beta.8 (Unreleased)

### Breaking Changes
- Azure Communication Common Library
  - Removing `CommunicationUserCredentialPolicy`, this policy was a duplicate of cores `BearerTokenCredentialPolicy`.  
  Communication now has new ability to create `BearerTokenCredentialPolicy` using the new `CommunicationPolicyTokenCredential`. 
  - Communication identifier `MicrosoftTeamsUserIdentifier` property `identifier` renamed to `userId` since identifier was too generic.

## 1.0.0-beta.7 (2021-01-12)

### New Features

- Azure Communication Calling Service
  - Added the ability to set the Caller display name when initializing the library.

- Azure Communication Common Library
  - Added a new communication identifier `MicrosoftTeamsUserIdentifier`, used to represent a Microsoft Teams user.
  - Introduced the new `CommunicationTokenRefreshOptions` type for specifying communication token refresh options.

### Breaking Changes
- Azure Communication Common Library
  - Renamed the type `CommunicationUserCredential` to `CommunicationTokenCredential`, as it represents a token.
  - The protocol `CommunicationTokenCredential` has likewise been renamed to `CommunicationTokenCredentialProviding`.
  - All types that conform to the `CommunicationIdentifier` protocol now use the suffix `Identifier`. For example, the
    `PhoneNumber` type used to represent a phone number identifier is now named `PhoneNumberIdentifier`.
  - Updated the `CommunicationTokenCredential` initializer that automatically refreshes the token to accept a single
    `CommunicationTokenRefreshOptions` object instead of multiple parameters.

### Key Bug Fixes

- Azure Communication Calling Service
  - Fixed an issue where `handlePushNotification` did not return false if the same payload had been processed already.
  - Improved logging to help identify the source of `hangup`-related issues reported in GitHub.
  - Fixed an issue where the remote participant was still available after hangup/disconnect. [#134](https://github.com/Azure/Communication/issues/134)

## 1.0.0-beta.6 (2020-11-23)

### Key Bug Fixes

- Azure Communication Calling Service
  - Fixed crash on calling `Call.hangup()`. [#106](https://github.com/Azure/Communication/issues/106)
  - Fixed invalid values for `CFBundleVersion` and `CFBundleShortVersionString` in Info.plist. [#113](https://github.com/Azure/Communication/issues/113)

## 1.0.0-beta.5 (2020-11-18)

### New Features
- Added Cocoapods specs for AzureCore, AzureCommunication, AzureCommunicationChat, and AzureCommunicationCalling
  libraries.

### Breaking Changes
- Azure Communication Chat Service
  - The `baseUrl` parameter has been renamed to `endpoint` in the `AzureCommunicationChatClient` initializers.

- Azure Communication Calling Service
  - Swift applications will not see the `ACS` prefix for classes and enums. For example, `ACSCallAgent` is now
    `CallAgent` when the library is imported in a Swift application.
  - Parameter labels are now mandatory for all API calls from Swift applications.
  - Except for the first parameter, parameter labels are now mandatory for all other parameters to delegate methods in
    Swift applications.
  - An exception is now thrown if an application tries to render video/camera twice.

### Key Bug Fixes
- Azure Communication Calling Service
  - Fixed a deadlock when deleting an `ACSCallAgent` object.
  - The `Call.hangup()` method will return only after all necessary events are delivered to the app. [#85](https://github.com/Azure/Communication/issues/85)
  - The `Call.hangup()` method now terminates a call if the call is in the `Connecting` or `Ringing` state. [#96](https://github.com/Azure/Communication/issues/96)
  - The library was raising a `RemoteVideoStream Removed` event when app stopped rendering a stream. The library now
    also raises a follow-up `RemoteVideoStream Added` event once the stream is ready to be rendered again. [#95](https://github.com/Azure/Communication/issues/95)

## 1.0.0-beta.2 (2020-10-05)

Version 1.0.0-beta.2 adds the Azure Communication Services Chat to the SDK.

### Added Libraries

- Azure Communication Services Chat ([AzureCommunicationChat](https://github.com/Azure/azure-sdk-for-ios/tree/master/sdk/communication/AzureCommunicationChat))

## 1.0.0-beta.1 (2020-09-21):

Version 1.0.0-beta.1 is a beta of our efforts in creating a client library that is developer-friendly, idiomatic to
the iOS ecosystem, and as consistent across different languages and platforms as possible. The principles that guide
our efforts can be found in the
[Azure SDK Design Guidelines for iOS](https://azure.github.io/azure-sdk/ios_introduction.html).

### Added Libraries

- Azure SDK for iOS core ([AzureCore](https://github.com/Azure/azure-sdk-for-ios/tree/master/sdk/core/AzureCore))
- Azure Communication Services common ([AzureCommunication](https://github.com/Azure/azure-sdk-for-ios/tree/master/sdk/communication/AzureCommunication))
  - This library is used by other libraries in this SDK, as well as by libraries in the [Azure Communication SDKs](https://github.com/Azure/Communication).
