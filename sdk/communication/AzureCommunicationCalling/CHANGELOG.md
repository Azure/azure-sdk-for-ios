# Release History

## 2.0.0-beta.1 (2021-07-14)

*NOTE: Previously released version `1.2.0-beta.1` is functionally identical to `2.0.0-beta.1` version and the only difference is in version number and only `2.0.0-beta.1` version will be available in cocoapods.*

### Features Added
- `Recording` and `Transcription` features are decoupled from `Call` object and now can only be used via extensions.
 Usage example:
```
            let recordingFeature = self.call!.api(RecordingFeature.self)
            recordingFeature.delegate = self.callObserver
```

### Breaking Changes
- Changed: `didChangeRecordingState` and `didChangeTranscriptionState` are moved out of `CallDelegate` into `RecordingFeatureDelegate` and into `TranscriptionFeatureDelegate`.

**More documentation on extensions and the breaking change can be found [here](https://docs.microsoft.com/azure/communication-services/quickstarts/voice-video-calling/calling-client-samples?pivots=platform-ios).**

### Bugs Fixed
- Not triggering calldidChangeState if using createCallAgentWithCallKitOption. And not able to accept the call in App killed state ([#316](https://github.com/Azure/Communication/issues/316)).
- Remote participant stream is stretched after hang-up ([#311](https://github.com/Azure/Communication/issues/311)).
- CallKit bug fixes with sometimes call gets disconnected immediately after picking up the call.
- Intermittent freezing of UI thread issue is fixed when for e.g. reading property `remoteParticipants` in a `Call`.
- `Hold` and `Resume` support fixed with CallKit enabled `CallAgent`'s.

## 1.1.0 (2021-06-30)
Azure Communication Calling iOS SDK version `1.1.0`.

### Features Added
- `CallAgent` and `CallClient` now have `dispose` API to explicitly delete objects instead of relying on ARC.

### Bug fixes
- `ACSRendererView` layout fixed after a device rotation ([#127](https://github.com/Azure/Communication/issues/127)).
- Resizing fixed for animating streams ([#262](https://github.com/Azure/Communication/issues/262)).
- Creating multiple `CallAgent` with same token will now throw an error.
- Fixed issue where `RendererDelegate.onFirstFrameRendered` was marked as optional but crashed if listener did not implement.

## 1.1.0-beta.1 (2021-06-04)
Azure Communication Calling iOS SDK version `1.1.0-beta.1`.

### New features
- Support for CallKit (**Preview mode**)
  - Use the api `createCallAgentWithCallKitOptions` to create `CallAgent` with `CallKit` enabled and SDK will report to `CallKit` about incoming call , outgoing calls and all other call operations like `mute`, `unmute`, `hold`, `resume` as part of the API calls. 
  - When the app is in the killed state and incoming call is received use the api `reportToCallKit`.

- `CallAgent` and `CallClient` now has `dispose` API to explicitly delete the objects instead of relying on ARC.

- Get CorrelationId from `CallInfo` object in `Call` to get the id required for recording feature. 

- Support to start recording by an ACS endpoint.

### Bug fixes
- [iOS] ACSRendererView layout is off after a device rotation https://github.com/Azure/Communication/issues/127.
- [iOS] Resizing issue for animating streams https://github.com/Azure/Communication/issues/262.
- Creating multiple CallAgents with same token will throw error.

-----------

## 1.0.1 (2021-05-03)

Azure Communication Calling iOS SDK version `1.0.1`.

### Bug fixes
- [iOS] Missing required key bundle version for 1.0.0 https://github.com/Azure/Communication/issues/278.

-----------

## 1.0.0 (2021-04-27)
Azure Communication Calling iOS SDK version `1.0.0`.

**This is the first General Availability (GA) release.**

### Breaking changes
- Video removed/added event are not raised when application stops rendering an incoming video.
- Teams interop and all other preview APIs are no longer available in the mainstream SDK drop. Please use libraries marked with the -beta suffix for these features.

-----------

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
