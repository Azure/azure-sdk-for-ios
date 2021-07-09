# Release History

## 1.0.0
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
### New Features
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
### New Features
 - Introduction of  a new struct `CommunicationIdentifierModel` to repesent a union type that is either a `communicationUser`, `phoneNumber`, or `microsoftTeamsUser`.

### Breaking Changes
- On `ChatClient` `create(thread)` method, renamed `repeatabilityRequestID` to `repeatabilityRequestId`
- `ChatThreadClient` `remove(participant)` method now accepts `CommunicationIdentifier` instead of a string
- For `Participant` renamed `user` property to `id`


### Key Bug Fixes
- `OnCallsUpdated` event is raised when the call collection on `CallAgent` is updated for outgoing calls.
- `Hold` and `Resume` of an active call is fixed.


## 1.0.0-beta.8 (2021-02-09)
### New Features
 - Introduced ChatClient and ChatThreadClient to split operations on threads and operations within a particular thread
 - Create thread sets repeatability-Request-ID for idempotency if not provided
 - Introduced MessageContent model to replace string content property

### Breaking Changes
 - ChatThreadMember renamed to Participant, uses CommunicationUserIdentifier
 - ChatMessage renamed to Message, uses CommunicationUserIdentifier
 - ChatThread renamed to Thread, uses CommunicationUserIdentifier

## 1.0.0-beta.5 (2020-11-18)

### New Features
- Added Cocoapods specs for AzureCore, AzureCommunication, AzureCommunicationChat, and AzureCommunicationCalling
  libraries.

### Breaking Changes
  - The `baseUrl` parameter has been renamed to `endpoint` in the `AzureCommunicationChatClient` initializers.

## 1.0.0-beta.2 (2020-10-05)

Version 1.0.0-beta.2 adds the Azure Communication Services Chat to the SDK.

### Added Libraries

- Azure Communication Services Chat ([AzureCommunicationChat](https://github.com/Azure/azure-sdk-for-ios/tree/main/sdk/communication/AzureCommunicationChat))
