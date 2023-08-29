# Release History

## 2.6.1 (2023-08-29)

### Bug Fixes 
* Fixed crash related to cameras being updated. 
* Fixed orientation issue when in landscape mode. 

## 2.7.0-beta.2 (2023-08-22)

### Bug Fixes 
* Fixed crash related to cameras being updated. 
* Fixed orientation issue when in landscape mode. 

## 2.7.0-beta.1 (2023-08-17)

### Features Added
* Added support for media stats.
* Updated Captions feature.
* Updated Network Diagnostics feature.
* Added support for Video Constraints.
* Added support for unmixed audio.

## 2.6.0 (2023-08-10)
### Features Added
* New Teams captions feature that allows ACS users to enable closed captions in Teams meeting and allows Microsoft 365 users on ACS SDK to use closed captions in one to one and group calls. Users will also have the ability to update spoken language for the call and caption language for themselves (requires Teams Premium).
* Added support for user facing diagnostics feature.
### Bug Fixes 
* Fixes issues with building targeting Apple Silicon Simulators when installing via CocoaPods.

## 2.6.0-beta.1 (2023-07-20)

### Features Added
* Added support for simulators on M1 machines.
* Added support for Background Blur Video Effect for local video streams.
* Added support for Raw Outgoing Video.
* Added support for Raw Audio.
* Various miscellaneous updates.

## 2.5.1 (2023-07-14)

### Features Added
* Added support for simulators on M1 machines.

## 2.5.0 (2023-07-10)

### Features Added
* Added support for Background Blur Video Effect for local video streams.
* Added support for Raise Hand feature on ACS and Teams meetings.
* Added support for joining a Room.

### Bug Fixes 
* Fixed the issue where outgoing video is available and cannot be turned off when User turns off camera while in Lobby.
* Fixed bug when incoming call is not picked up by the receiver and not able to place any other calls.
* Fix bug when raw audio stops and start event is raised.

## 2.4.1 (2023-06-13)

### Bugs Fixed
- Fixed issue with handling incoming call when the app is running in background or in kill mode.

## 2.4.0 (2023-05-30)

### Features Added
Added support for Callkit Integration
- Application will be able to configure call capabilities with CallKitOptions.
- Application will be able to pass the means to reach a call recipient and the display name with CallKitRemoteInfo.
- Application will be able to use reportIncomingCallToCallKit to handle notification when the app is in kill state.

Added support for Raw Outgoing Video
Added support for Raw Audio

## 2.3.0 (2023-04-14)

### Features Added
- Dominant Speakers
  - Dominant speakers is an extended feature that allows you to obtain a list of the active speakers in the call. The dominant speakers list can change dynamically according to the activity of the participants on the call.

## 2.3.0-beta.5 (2023-04-11)

### Features Added
* New Teams captions feature that allows ACS users to enable closed captions in Teams meeting and allows Microsoft 365 users on ACS SDK to use closed captions in one to one and group calls. Users will also have the ability to update spoken language for the call and caption language for themselves (requires Teams Premium).
* New raise Hand feature on ACS and Teams meetings.
* New user facing diagnostics feature.
* CallKit support improvements.

## 2.3.0-beta.4 (2023-01-05)

### Bug Fixes 
* Fixes issue where one cannot unmute speaker when a call is started with the microphone muted.

## 2.3.0-beta.3 (2022-12-22)

### Features Added
 Added support for [EU Data Boundary(EUDB)](https://blogs.microsoft.com/eupolicy/2021/12/16/eu-data-boundary-for-the-microsoft-cloud-a-progress-report)

### Bug Fixes 
* Fixed a bug when call was started with audio muted, the options were not being read in the CallKit implementation.

### Breaking Changes
* Removing `AudioDeviceCategory` enumeration.
* Removing `audioDeviceCategory` property from `LocalAudioStream` and `RemoteAudioStream`.
* Removing `init(audioDeviceCategory: AudioDeviceCategory)`.

## 2.2.2 (2022-12-23)

 ### Features Added
  - Added support for [EU Data Boundary(EUDB)](https://blogs.microsoft.com/eupolicy/2021/12/16/eu-data-boundary-for-the-microsoft-cloud-a-progress-report)

## 2.3.0-beta.2 (2022-11-07)

### Features Added
- Added support for audio start/stop.
- Added new API for `muteSpeaker` and property `isSpeakerMuted`.
- Add support for `RecordingsUpdated` event which will be triggered when a recording is started or stopped, `Recordings` property to list all current recordings and `RecordingState` indicates the state of a recording. 
- Raw Outgoing Video
- details: 
    - Users will be able to send `CVImageBuffer` frames(in one of the supported formats) to a call through a virtual video stream as an alternative to camera source(local video stream) or through screen sharing stream using [Raw Media APIs](https://github.com/MicrosoftDocs/azure-docs/blob/main/articles/communication-services/quickstarts/voice-video-calling/get-started-raw-media-access.md).
### Bugs fixed
- Fix calling `call.hangup()` with `HangUpOptions` for everybody.
- Fix bug that allowed create several CallAgents for same identity.

## 2.2.1 (2022-11-02)

### Bugs fixed
 - Fix calling `call.hangup()` with `HangUpOptions` for everybody.
 - Fix bug that allowed create several CallAgents for same identity.

## 2.3.0-beta.1 (2022-09-30)

### Features Added
- Azure Communication Services introduces the concept of a `room` for developers who are building structured conversations such as virtual appointments or virtual events. Learn more about rooms [here](https://learn.microsoft.com/azure/communication-services/concepts/rooms/room-concept). Get started using rooms by following the [quick start guides](https://learn.microsoft.com/azure/communication-services/quickstarts/rooms/get-started-rooms).
- Callkit Integration
  - Application will be able to configure call capabilities with `CallKitOptions`.
  - Application will be able to pass the means to reach a call recipient and the display name with `CallKitRemoteInfo`.
  - Application will be able to use `reportIncomingCallToCallKit` to handle notification when the app is in kill state.
- Support for stopping an incoming call because it was answered in another device, or caller cancelled, etc.
- Dominant Speakers
  - Dominant speakers is an extended feature that allows you to obtain a list of the active speakers in the call. The dominant speakers list can change dynamically according to the activity of the participants on the call.

### Bugs fixed
- Fix for issue when a call with a host would not end if the host leaves the call.
- Fix for internal update when Call Id changes in the middle of a call.
- Fix for fetching token from background thread blocks the creation of `CallAgent`.
- Fix for simulator crash when UI window size is returned as zero.
- Fix for audio not flowing issue when resume ACS call from PSTN call.
- Fixed crash when an invalid token is provided.
- Fix for wrong response with isMuted() method when user is trying to mute ACS participant.
- Fix for issue where local user stops streaming during `connecting` state, remote participant sees them as rendering stream.

## 2.2.0 (2022-06-10)

### Features Added
- ⁠Client options diagnostic information.
    - Application will be able to pass custom 'appName', 'appVersion', and additionally set of 'tags' to the SDK that will be sent with telemetry pipeline.

### Bugs fixed
- Fixed crash when an invalid token is provided.

## 2.1.0 (2022-06-03)

### Features Added
- Voice and video calling support in Azure government.
-  Push Notifications support for stopping an incoming call because it was answered in another device, or caller cancelled, etc.

### Bugs fixed
- Fix for internal update when Call Id changes in the middle of a call. 
- Fix for fetching token from background thread blocks the creation of CallAgent. 
- Fix for simulator crash when UI window size is returned as zero. 
- Fix for audio not flowing issue when resume ACS call from PSTN call. 

## 2.0.0 (2021-12-13)

### Breaking Changes
- `Call.addParticipant` API is now a throwable type when trying to add a participant that is already to the call or when a participant is added to an unconnected call.
- `didChangeRecordingState` and `didChangeTranscriptionState` are moved out of `CallDelegate` into `RecordingFeatureDelegate` and into `TranscriptionFeatureDelegate`.
**More documentation on extensions and the breaking change can be found [here](https://docs.microsoft.com/azure/communication-services/quickstarts/voice-video-calling/calling-client-samples?pivots=platform-ios).**

### Features Added
- Added support for specifying emergency country code when creating `CallAgent` by setting the property `emergencyCountryCode` in `CallAgentOptions`.
- Join Teams calls either using a Teams meeting link or using Teams meeting coordinates.
- `Recording` and `Transcription` features are decoupled from `Call` object and now can only be used via extensions.
Usage example:
```
let recordingFeature = self.call!.feature(RecordingFeature.self)
recordingFeature.delegate = self.callObserver
```

### Bugs fixed
- Fix for when camera preview is rotating even if the app supports only portrait mode. [GH#338](https://github.com/Azure/Communication/issues/338)
- Fix for the event `didUpdateRemoteParticipant` event not firing sometimes when `call.AddParticipant` API is called by the application.
- Fix when the camera switch button is pressed several times, the preview of the client's camera can be blocked.
- Fix for crash when signing out and signing in repeatedly.
- `IncomingCall.accept` will now throw errors when trying to accept a terminated call or if already in an active call.

## 2.2.0-beta.1 (2021-12-03)

### Features Added
- Added support for specifying emergency country code when creating `CallAgent` by setting the property `emergencyCountryCode` in `CallAgentOptions`.

## 2.1.0-beta.1 (2021-11-12)

### Breaking Changes
1. `Call.addParticipant` API is now a throwable type when trying to add a participant that is already to the call or when a participant is added to an unconnected call.

### Features Added
- The call extended features now are accessed but the `feature` method call instead of the `api` like previous versions. Also, you can leverage the class `Features` to obtain the list of available features like `Features.RECORDING` and `Features.TRANSCRIPTION`. Classes `RecordingFeature` and `TranscriptionFeature` have been renamed to `RecordingCallFeature` and `TranscriptionCallFeature`. More information on [Record Calls](https://docs.microsoft.com/azure/communication-services/how-tos/calling-sdk/record-calls?pivots=platform-android#record-calls) and [Show Transcription state](https://docs.microsoft.com/azure/communication-services/how-tos/calling-sdk/call-transcription?pivots=platform-android)

- New API to initialize `CallClient` with `CallClientOptions` with property `DiagnosticOptions` with properties `appName`, `appVersion` and `tags` for telemetry purposes to identify which Application is using the SDK.
 
### Bugs fixed
- Fix for crash when user inputs an invalid teams meeting link. [GH#198](https://github.com/Azure/Communication/issues/198)
- Fix for `CallAgent` and `CallClient` dispose methods takes too long to execute. [GH#358](https://github.com/Azure/Communication/issues/358) and [GH#339](https://github.com/Azure/Communication/issues/339)
- Fix for when camera preview is rotating even if the app supports only portrait mode. [GH#338](https://github.com/Azure/Communication/issues/338)
- Fix for the event `didUpdateRemoteParticipant` event not firing sometimes when `call.AddParticipant` API is called by the application.
- Fix when the camera switch button is pressed several times, the preview of the client's camera can be blocked.
- Fix for a freeze when mute/unmute is done when `inLobby` in a Teams call. [GH#276](https://github.com/Azure/Communication/issues/276)
- Fix for the warning displayed in XCode when importing the SDK, `arm64-apple-ios.swiftsourceinfo either malformed or generated by a different Swift version`.
- Fix for crash when signing out and signing in repeatedly.


## 2.0.1-beta.1 (2021-09-09)

### Bugs Fixed
- `IncomingCall.accept` will now throw errors when trying to accept a terminated call or if already in an active call.
- SDK rebuilt with latest available AzureCommunicationCommon `1.0.2` ([#344](https://github.com/Azure/Communication/issues/344)).
- Using `CallKit` implementation in SDK when already in an incoming call another incoming call is recieved, accepting the new call operation now completes successfully.

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
