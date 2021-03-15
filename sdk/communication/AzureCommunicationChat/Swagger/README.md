## Getting started

```
autorest README.md
--use=<PATH_TO_AUTOREST_SWIFT>
--input-file=<PATH_TO_SWAGGER>
--output-folder=<PATH_TO_AZURE_SDK_FOR_IOS>/azure-sdk-for-ios/sdk/communication/AzureCommunicationChat
```

```yaml
namespace: AzureCommunicationChat

# Rename CreateChatThreadResult to CreateChatThreadResultInternal
directive:
- from: swagger-document
  where: $.definitions.CreateChatThreadResult
  transform: >
    $["x-ms-client-name"] = "CreateChatThreadResultInternal";

# Rename CreateChatThreadRequest to CreateChatThreadRequestInternal
- from: swagger-document
  where: $.definitions.CreateChatThreadRequest
  transform: >
    $["x-ms-client-name"] = "CreateChatThreadRequestInternal";

# Rename ChatMessage to ChatMessageInternal
- from: swagger-document
  where: '$.definitions.ChatMessage'
  transform: >
    $["x-ms-client-name"] = "ChatMessageInternal";

# Rename ChatMessageContent to ChatMessageContentInternal
- from: swagger-document
  where: '$.definitions.ChatMessageContent'
  transform: >
    $["x-ms-client-name"] = "ChatMessageContentInternal";

# Rename ChatParticipant to ChatParticipantInternal
- from: swagger-document
  where: '$.definitions.ChatParticipant'
  transform: >
    $["x-ms-client-name"] = "ChatParticipantInternal";

# Rename ChatMessageReadReceipt to ChatMessageReadReceiptInternal
- from: swagger-document
  where: '$.definitions.ChatMessageReadReceipt'
  transform: >
    $["x-ms-client-name"] = "ChatMessageReadReceiptInternal";

# Rename ChatThreadProperties to ChatThreadPropertiesInternal
- from: swagger-document
  where: '$.definitions.ChatThreadProperties'
  transform: >
    $["x-ms-client-name"] = "ChatThreadPropertiesInternal";

# Rename CommunicationError to ChatError
- from: swagger-document
  where: '$.definitions.CommunicationError'
  transform: >
    $["x-ms-client-name"] = "ChatError";
```