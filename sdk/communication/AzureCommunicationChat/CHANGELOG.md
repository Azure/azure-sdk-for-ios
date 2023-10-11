# Release History

## 1.3.3 (2023-10-11)
### Bugs Fixed
- Reverted reference to .cloudEnvironment enum that's only available in AzureCommunicationCommon version 1.2.0-beta.1 onwards. This resolves the issue in releasing AzureCommunicationChat version 1.3.2

## 1.3.2 (2023-10-04)
### Feature Added
- Added support for [EU Data Boundary(EUDB)](https://blogs.microsoft.com/eupolicy/2021/12/16/eu-data-boundary-for-the-microsoft-cloud-a-progress-report)

## 1.3.1 (2023-03-27)
### Bugs Fixed
- Added ARM64 simulator support

## 1.3.0 (2022-09-13)
### New Features
- `ChatClient` now supports Push Notifications for Chat events
- Following methods added to `ChatClient`:
  - `startPushNotifications(deviceToken:)`
  - `stopPushNotifications()`
- Added the prototol `PushNotificationKeyStorage` and the class `AppGroupPushNotificationKeyStorage` to support PushNotification Encryption Key Management

## 1.3.0-beta.1 (2022-07-25)
### New Features
- `ChatClient` now supports Push Notifications for Chat events
- Following methods added to `ChatClient`:
  - `startPushNotifications(deviceToken:)`
  - `stopPushNotifications()`
- Added the prototol`PushNotificationKeyHandler` and the class `AppGroupPushNotificationKeyHandler` to support PushNotification Encryption Key Management

## 1.2.0 (2022-05-16)
### Features Added
- Added two new events `realTimeNotificationConnected` and `realTimeNotificationDisconnected` that allow the developer to know when the connection to the real time notification server is active.

## 1.1.0 (2022-04-11)
Updated service API version to 2021-09-07.

## 1.1.0-beta.2 (2021-09-30)
### Bugs Fixed
- Fix missing AzureTest dependency in Package.swift

## 1.1.0-beta.1 (2021-09-30)
### Features Added
- `ChatMessage` supports metadata, provide optional metadata when sending a `ChatMessage`
- `ChatMessageReceivedEvent` and `ChatMessageEditedEvent` also contain metadata
- Typing notifications support sender display name, `sendTypingNotification()` accepts an optional `senderDisplayName`

## 1.0.2 (2021-09-02)
### Features Added
- Added `CommunicationSignalingErrorHandler` to `AzureCommunicationChatClientOptions` for handling signaling errors.

### Bugs Fixed
- Fixed realtime notifications to handle nil `displayName`.
- Fixed `readOn` property in `readReceiptReceived` events.
- Fixed recipient id format in events.

## 1.0.1 (2021-07-26)
### Features Added
- ChatClient sets `applicationId` to be empty by default instead of using the bundle identifier

## 1.0.0 (2021-07-20)
### Breaking Changes
- Update message parameters updated to `update(message: String, parameters: UpdateChatMessageRequest)`
- `EventHandler` renamed to `TrouterEventHandler`
- Removed `AddChatParticipantsRequest`, `UpdateChatThreadRequest`, `CommunicationIdentifierModel`

## 1.0.0-beta.12 (2021-06-07)
### Breaking Changes
- Changed the way in which options are instantiated for the following classes: `CreateChatThreadOptions`, `DeleteChatThreadOptions`,  `ListChatThreadsOptions`, `AddChatParticipantsOptions`, `DeleteChatMessageOptions`, `GetChatMessageOptions`, `GetChatThreadPropertiesOptions`, `ListChatMessagesOptions`, `ListChatParticipantsOptions`, `ListChatReadReceiptsOptions`, `RemoveChatParticipantOptions`, `SendChatMessageOptions`, `SendChatReadReceiptOptions`, `SendTypingNotificationOptions`, `UpdateChatMessageOptions`, `UpdateChatThreadPropertiesOptions`.
    - old:
        `let options = Chat.CreatChatThreadOptions()`
    - new:
        `let options = CreateChatThreadOptions()`
- Moved `AzureCommunicationChatClient.ApiVersion` to `AzureCommunicationChatClientOptions.ApiVersion`.
- Renamed `CommunicationError` to `ChatError`
- Removed following classes:  `CreateChatThreadResult`, `CreateChatThreadRequest`, `ChatMessage`, `ChatMessageContent`, `ChatParticipant`, `ChatMessageReadReceipt`, `ChatThreadProperties`.
- Removed Any type in TrouterEventUtil, and create a new enum TrouterEvent
- Signaling event handlers now only accept a single enum argument, `TrouterEvent` instead of type Any and a ChatEventId. This eliminates the need to cast event payloads. Instead, developers can simply using a switch/case statement on the relevant `TrouterEvent` values.
- The TrouterEventUtil.create method now returns the strongly-typed enum `TrouterEvent` instead of Any.

## 1.0.0-beta.11 (2021-04-07)
### Features Added
- Swift PM user should now target the `SwiftPM-AzureCommunicationChat` repo.
- AzureCommunicationChat can now version independently of other libraries.
- `ChatClient` now supports Realtime Notifications for Chat events
- Following methods added to `ChatClient`:
  - `startRealtimeNotifications()`
  - `stopRealtimeNotifications()`
  - `register(event, handler)` registers handlers for Chat events
  - `unregister(event)` unregisters handlers for Chat events

### Breaking Changes
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
### Features Added
 - Introduction of  a new struct `CommunicationIdentifierModel` to repesent a union type that is either a `communicationUser`, `phoneNumber`, or `microsoftTeamsUser`.

### Breaking Changes
- On `ChatClient` `create(thread)` method, renamed `repeatabilityRequestID` to `repeatabilityRequestId`
- `ChatThreadClient` `remove(participant)` method now accepts `CommunicationIdentifier` instead of a string
- For `Participant` renamed `user` property to `id`


### Bugs Fixed
- `OnCallsUpdated` event is raised when the call collection on `CallAgent` is updated for outgoing calls.
- `Hold` and `Resume` of an active call is fixed.


## 1.0.0-beta.8 (2021-02-09)
### Features Added
 - Introduced ChatClient and ChatThreadClient to split operations on threads and operations within a particular thread
 - Create thread sets repeatability-Request-ID for idempotency if not provided
 - Introduced MessageContent model to replace string content property

### Breaking Changes
 - ChatThreadMember renamed to Participant, uses CommunicationUserIdentifier
 - ChatMessage renamed to Message, uses CommunicationUserIdentifier
 - ChatThread renamed to Thread, uses CommunicationUserIdentifier

## 1.0.0-beta.5 (2020-11-18)
### Features Added
- Added Cocoapods specs for AzureCore, AzureCommunication, AzureCommunicationChat, and AzureCommunicationCalling
  libraries.

### Breaking Changes
  - The `baseUrl` parameter has been renamed to `endpoint` in the `AzureCommunicationChatClient` initializers.

## 1.0.0-beta.2 (2020-10-05)

Version 1.0.0-beta.2 adds the Azure Communication Services Chat to the SDK.

### Added Libraries

- Azure Communication Services Chat ([AzureCommunicationChat](https://github.com/Azure/azure-sdk-for-ios/tree/main/sdk/communication/AzureCommunicationChat))
