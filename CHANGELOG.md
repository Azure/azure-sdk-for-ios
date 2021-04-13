# Release History

## 1.0.0-beta.12 (UNRELEASED)

### New Features
**SERVICE**

### Breaking Changes
**SERVICE**

### Key Bug Fixes
**SERVICE**

## 1.0.0-beta.12 (2021-04-13)
Azure Communication Calling iOS SDK version `1.0.0-beta.12`.

### New features
- `DeviceManager` instance can be obtained irrespective of `CallAgent` creation.

### Breaking changes
- Added `Nullability` annotations for parameters in delegate methods, properties and return types in init. This removes for e.g. the need for the application to force un-wrap objects created by the SDK where applicable.
- Delegate method signatures renamed to confirm with Swift guidelines. Similar to [UIApplicationDelegate](https://developer.apple.com/documentation/uikit/uiapplicationdelegate).
- Block `CallAgent` creation with same user.
- `IsMuted` event is added to the `Call` class. Event will be triggered when the call is locally or remotely muted.
- Multiple classes properties/methods renamed:
   - `Call` class:
       - Property `callDirection` renamed to `direction`.
       - Property `isMicrophoneMuted` renamed to `isMuted`.

    - `VideoOptions` class:
       - `LocalVideoStream` property is now `LocalVideoStreams` making it an array.
       - The constructor for `VideoOptions` now takes an array of `LocalVideoStream` as parameter.

- `RenderingOptions` has been renamed `CreateViewOptions`.

- `startCall` and `join` API's on `CallAgent` are now asynchronous.

- Mandatory to pass completion handler block for all async API's.

### Bug fixes
- SDK Crash when another guest user joins a Teams meeting with Video on. https://github.com/Azure/Communication/issues/218
- `OnRemoteParticipantsUpdated` event updates the participant state to `Idle` when the participant is `InLobby`. https://github.com/Azure/Communication/issues/221
- Speaking Change Listeners were triggered unexpectedly. https://github.com/Azure/Communication/issues/234
- Turning the local video off/on quickly shows a blank local video. https://github.com/Azure/Communication/issues/225
- [iOS] SDK crash if user input an invalid teams meeting link on beta 9.0. https://github.com/Azure/Communication/issues/198
- Issue Implementing Video Calling. https://github.com/Azure/Communication/issues/212
- [iOS] App crash when joining a call with muted and audio permission was not granted. https://github.com/Azure/Communication/issues/90
- Answering an incoming with Video not rendering for local participant.
- SDK crash when another video guest user join the Teams meeting from Web/App. https://github.com/Azure/Communication/issues/216
- Answer an incoming with Video does not show Video streams of remote user.
## 1.0.0-beta.11 (2021-04-07)
### New Features
**Azure Communication Chat**
- `ChatClient` now supports Realtime Notifications for Chat events
- Following methods added to `ChatClient`:
  - `startRealtimeNotifications()`
  - `stopRealtimeNotifications()`
  - `register(event, handler)` registers handlers for Chat events
  - `unregister(event)` unregisters handlers for Chat events

### Breaking Changes
**Azure Communication**
- Updated the Objective-C initializer for `CommunicationUserIdentifier` and `UnknownIdentifier` to be `initWithIdentifier:`. Making it align more with Objective-C guidelines. 
- Updated `CommunicationTokenCredential` init method from `init(with:)` to `init(withOptions:)`. Objective-c method will change from `initWith: error:]` to `initWithOptions: error:]`. 
- Removed `CommunicationPolicyTokenCredential`.
- Typealias `TokenRefreshOnCompletion` renamed to `TokenRefreshHandler`.
- Typealias `TokenRefresherClosure` renamed to `TokenRefresher`.

**Azure Communication Chat**
- Build setting `ENABLE_BITCODE` is no longer supported for `AzureCommunicationChat`. It must be set to NO.
- Renamed `Participant` to `ChatParticipant`
- Renamed `Message` to `ChatMessage`
- Renamed `MessageContent` to `ChatMessageContent`
- Renamed `ReadReceipt` to `ChatMessageReadReceipt`
- Renamed `Thread` to `ChatThreadProperties`
- Renamed `CreateThreadRequest` to `CreateChatThreadRequest`
- Renamed `CreateThreadResult` to `CreateChatThreadResult`
- Renamed `CommunicationError` to `ChatError`
- ChatThreadClient `update()` message accepts a string for the message content instead of an object
- The method for getting thread properties has been moved from `ChatClient` to `ChatThreadClient` and renamed `getProperties()`
- Participants are now optional when creating a thread, the creator of the thread is added automatically

## 1.0.0-beta.9 (2021-03-10)
### New Features
**Azure Communication Chat**
 - Introduction of  a new struct `CommunicationIdentifierModel` to repesent a union type that is either a `communicationUser`, `phoneNumber`, or `microsoftTeamsUser`.

**Azure Communication Calling**
- SDK is now shipped as a XCFramework instead of a FAT framework created using `lipo`.
- Improved caching of objects. 
- Added new call state `Hold` when a remote participant puts the call on hold.

### Breaking Changes
**Azure Communication**
- Removal of `CommunicationCloudEnvironment.fromModel()` method
- Removal of label `identifier` in `CommunicationUserIdentifier` and `UnknownIdentifier`
- `CommunicationIdentifierModel` and `CommunicationIdentifierSerializer` are no longer part of the communication package, they have been moved to AzureCommunicationChat
  
**Azure Communication Chat**
- On `ChatClient` `create(thread)` method, renamed `repeatabilityRequestID` to `repeatabilityRequestId`
- `ChatThreadClient` `remove(participant)` method now accepts `CommunicationIdentifier` instead of a string
- For `Participant` renamed `user` property to `id`

**Azure Communication Calling**
- `Renderer` renamed to `VideoStreamRenderer`.
- `AudioDeviceInfo` removed from `DeviceManager`, please use iOS system API's in your application to switch between audio devices.
- `CallAgent` raises a new event `onIncomingCall` when a new incoming call is received. 
- `CallAgent` raises a new event `onCallEnded` event is raised when the incoming call wasn't answered.
- `Accept` and `Reject` can now be done on `IncomingCall` object and removed from `Call` object.
- For parsing of push notification payload `IncomingCallPushNotification` has been renamed to `PushNotificationInfo`.
- `CallerInfo` class created which provides information about the caller in an incoming call. Can be retrieved from `IncomingCall` and `Call` objects. 


### Key Bug Fixes
**Azure Communication Calling**
- `OnCallsUpdated` event is raised when the call collection on `CallAgent` is updated for outgoing calls.
- `Hold` and `Resume` of an active call is fixed. 


## 1.0.0-beta.8 (2021-02-09)
### New Features

**Azure Communication Calling**
 - Added ability to join a Teams meeting.
 - New event on `Call` `OnIsRecordingActiveChanged` to indicate when the recording has been started and stopped and new property `IsRecordingActive` to indicate if currently the recording is active or not.

**Azure Communication Chat Library**
 - Introduced ChatClient and ChatThreadClient to split operations on threads and operations within a particular thread
 - Create thread sets repeatability-Request-ID for idempotency if not provided
 - Introduced MessageContent model to replace string content property

### Breaking Changes
**Azure Communication Common Library**
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

**Azure Communication Chat Library**
 - ChatThreadMember renamed to Participant, uses CommunicationUserIdentifier
 - ChatMessage renamed to Message, uses CommunicationUserIdentifier
 - ChatThread renamed to Thread, uses CommunicationUserIdentifier
 
 ### Key Bug Fixes
 **Azure Communication Calling**
 - Fix wrong `callId` on the incoming `Call` object https://github.com/Azure/Communication/issues/164
 - When placing outgoing call or joining a group call event will be raised `OnCallsUpdated` when call list is updated.
 - Throw IllegalArgumentException if null camera is passed to constructor of `LocalVideoStream`.
 - Video freezing in landscape mode https://github.com/Azure/Communication/issues/128
 - `RendererView` layout is off after a device rotation https://github.com/Azure/Communication/issues/127
 - `RendererView` is blank when not added to the window right away https://github.com/Azure/Communication/issues/132
 - `RendererView` Issues when joining a call with a reused `groupId` https://github.com/Azure/Communication/issues/111

**Azure Communication Common Library**
 - Removing `CommunicationUserCredentialPolicy`, this policy was a duplicate of cores `BearerTokenCredentialPolicy`.  
  Communication now has new ability to create `BearerTokenCredentialPolicy` using the new `CommunicationPolicyTokenCredential`. 

## 1.0.0-beta.7 (2021-01-12)

### New Features

**Azure Communication Calling Service**
  - Added the ability to set the Caller display name when initializing the library.

**Azure Communication Common Library**
  - Added a new communication identifier `MicrosoftTeamsUserIdentifier`, used to represent a Microsoft Teams user.
  - Introduced the new `CommunicationTokenRefreshOptions` type for specifying communication token refresh options.

### Breaking Changes
**Azure Communication Common Library**
  - Renamed the type `CommunicationUserCredential` to `CommunicationTokenCredential`, as it represents a token.
  - The protocol `CommunicationTokenCredential` has likewise been renamed to `CommunicationTokenCredentialProviding`.
  - All types that conform to the `CommunicationIdentifier` protocol now use the suffix `Identifier`. For example, the
    `PhoneNumber` type used to represent a phone number identifier is now named `PhoneNumberIdentifier`.
  - Updated the `CommunicationTokenCredential` initializer that automatically refreshes the token to accept a single
    `CommunicationTokenRefreshOptions` object instead of multiple parameters.

### Key Bug Fixes

**Azure Communication Calling Service**
  - Fixed an issue where `handlePushNotification` did not return false if the same payload had been processed already.
  - Improved logging to help identify the source of `hangup`-related issues reported in GitHub.
  - Fixed an issue where the remote participant was still available after hangup/disconnect. [#134](https://github.com/Azure/Communication/issues/134)

## 1.0.0-beta.6 (2020-11-23)

### Key Bug Fixes

**Azure Communication Calling Service**
  - Fixed crash on calling `Call.hangup()`. [#106](https://github.com/Azure/Communication/issues/106)
  - Fixed invalid values for `CFBundleVersion` and `CFBundleShortVersionString` in Info.plist. [#113](https://github.com/Azure/Communication/issues/113)

## 1.0.0-beta.5 (2020-11-18)

### New Features
- Added Cocoapods specs for AzureCore, AzureCommunication, AzureCommunicationChat, and AzureCommunicationCalling
  libraries.

### Breaking Changes

**Azure Communication Chat Service**
  - The `baseUrl` parameter has been renamed to `endpoint` in the `AzureCommunicationChatClient` initializers.

**Azure Communication Calling Service**
  - Swift applications will not see the `ACS` prefix for classes and enums. For example, `ACSCallAgent` is now
    `CallAgent` when the library is imported in a Swift application.
  - Parameter labels are now mandatory for all API calls from Swift applications.
  - Except for the first parameter, parameter labels are now mandatory for all other parameters to delegate methods in
    Swift applications.
  - An exception is now thrown if an application tries to render video/camera twice.

### Key Bug Fixes
**Azure Communication Calling Service**
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
