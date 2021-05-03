# Release History

## 1.0.1 (2021-05-03)

Azure Communication Calling iOS SDK version `1.0.1`.

## Bug fixes
- [iOS] Missing required key bundle version for 1.0.0 https://github.com/Azure/Communication/issues/278.

## 1.0.0 (2021-04-27)
Azure Communication Calling iOS SDK version `1.0.0`.

**This is the first General Availability (GA) release.**

# Breaking changes
- Video removed/added event are not raised when application stops rendering an incoming video.
- Teams interop and all other preview APIs are no longer available in the mainstream SDK drop. Please use libraries marked with the -beta suffix for these features.

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
