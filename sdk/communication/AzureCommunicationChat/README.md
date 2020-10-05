# Azure Communication Chat Service client library for iOS
This package contains the iOS SDK for Azure Communication Services for Chat.
Read more about Azure Communication Services [here](https://docs.microsoft.com/azure/communication-services/overview).

# Getting started

## Prerequisites

- An Azure Communication Resource, learn how to create one from [Create an Azure Communication Resource](https://docs.microsoft.com/azure/communication-services/quickstarts/create-communication-resource)

## User and User Access Tokens

User access tokens enable you to build client applications that directly authenticate to Azure Communication Services. Refer [here](https://docs.microsoft.com/azure/communication-services/quickstarts/access-tokens) to learn how to create a user and issue a User Access Token.

The id for the user created above will be necessary later to add said user as a member of a new chat thread. The initiator of the create request must be in the list of members of the chat thread.

## Create the AzureCommunicationChatClient

```swift
import AzureCommunication
import AzureCommunicationChat

guard let baseUrl = URL(string: "https://<resource>.communication.azure.com") else {
    //TODO: Display error message
}

let authPolicy = try CommunicationUserCredentialPolicy(
    credential: credential ?? CommunicationUserCredential(token: <user_access_token>)
)
let options = AzureCommunicationChatClientOptions(
    logger: ClientLoggers.default,
    dispatchQueue: self.queue
)
let client = AzureCommunicationChatClient(baseUrl: baseUrl, authPolicy: authPolicy, withOptions: options)
```

# Key concepts

A chat conversation is represented by a chat thread. Each user in the thread is called a thread member. Thread members can chat with one another privately in a 1:1 chat or huddle up in a 1:N group chat.

Using the APIs, users can also send typing indicators when typing a message and read receipts for the messages they have read in a chat thread. To learn more, read about chat concepts [here](https://docs.microsoft.com/azure/communication-services/concepts/chat/concepts).

Once you initialize an `AzureCommunicationChatClient` class, you can perform the following chat operations:

## Thread Operations

- [Create a thread](#create-a-thread)
- [Get a thread](#get-a-thread)
- [List threads](#list-threads)
- [Update a thread](#update-a-thread)
- [Delete a thread](#delete-a-thread)

## Message Operations

- [Send a message](#send-a-message)
- [Get a message](#get-a-message)
- [List messages](#list-messages)
- [Update a message](#update-a-message)
- [Delete a message](#delete-a-message)

## Thread Member Operations

- [Get thread members](#get-thread-members)
- [Add thread members](#add-thread-members)
- [Remove a thread member](#remove-a-thread-member)

## Events Operations

- [Send a typing notification](#send-a-typing-notification)
- [Send read receipt](#send-read-receipt)
- [Get read receipts](#get-read-receipts)

# Examples

## Thread Operations

### Create a thread

Use the `create` method to create a thread.

- `CreateChatThreadRequest` is the model to pass to this method.
- `topic` is used to provide a topic for the thread.
- `members` is used to list the `ChatThreadMember` to be added to the thread.
- `id`, required, is the `CommunicationUser.identifier` you created before. Refer to [User and User Access Tokens](#User-and-User-Access-Tokens).
- `displayName`, optional, is the display name for the thread member.
- `shareHistoryTime`, optional, is the time from which the chat history is shared with the member.

`MultiStatusResponse` is the result returned from creating a thread. It has a 'multipleStatus' property which represents a list of `IndividualStatusResponse`.

```swift
let thread = CreateChatThreadRequest(
    topic: "General",
    members: [ChatThreadMember(
        id: <userId>,
        // Id of this needs to match with the Auth token
        displayName: "initial member"
    )]
)

client.create(chatThread: thread) { result, _ in
    switch result {
    case let .success(createThreadResponse):
        var threadId: String? = nil
        for response in createThreadResponse.multipleStatus ?? [] {
            if response.id?.hasSuffix("@thread.v2") ?? false,
                response.type ?? "" == "Thread" {
                threadId = response.id
            }
        }
        //TODO: Take further action

    case let .failure(error):
        //TODO: Display error message
    }
}
```

### Get a thread

Use the `getChatThread` method to retrieve a thread.

- `chatThreadId` is the unique ID of the thread.

```swift
client.getChatThread(chatThreadId: threadId) { result, _ in
    switch result {
    case let .success(thread):
        //TODO: Take further action

    case let .failure(error):
        //TODO: Display error message
    }
}
```

### List threads

Use the `listChatThreads` method to retrieve a list of threads.

- `ListChatThreadsOptions` is the object representing the options to pass.
- `maxPageSize`, optional, is the maximum number of messages to be returned per page.
- `startTime`, optional, is the thread start time to consider in the query.

`PagedCollection<ChatThreadInfo>` is the response returned from listing threads.

```swift
import AzureCore
let options = ListChatThreadsOptions(maxPageSize: 1)
client.listChatThreads(withOptions: options) { result, _ in
    switch result {
    case let .success(listThreadsResponse):
        var iterator = listThreadsResponse.syncIterator
        while let threadInfo = iterator.next() {
            //TODO: Take further action
        }

    case let .failure(error):
        //TODO: Display error message
    }
}
```

### Update a thread

Use the `update` method to update a thread's properties.

- `UpdateChatThreadRequest` is the model to pass to this method.
- `topic` is used to give a thread a new topic.
- `chatThreadId` is the unique ID of the thread.

```swift
 let thread = UpdateChatThreadRequest(
    topic: "A new topic update with update()"
)

client.update(chatThread: thread, chatThreadId: threadId) { result, _ in
    switch result {
    case .success:
        //TODO: Take further action

    case let .failure(error):
        //TODO: Display error message
    }
}
```

### Delete a thread

Use `deleteChatThread` method to delete a thread.

- `chatThreadId` is the unique ID of the thread.

```swift
client.deleteChatThread(chatThreadId: threadId) { result, httpResponse in
    switch result {
    case .success:
        //TODO: Take further action

    case let .failure(error):
        //TODO: Display error message
    }
}
```

## Message Operations

### Send a message

Use the `send` method to send a message to a thread.

- `SendChatMessageRequest` is the model to pass to this method.
- `priority` is used to specify the message priority level, such as 'normal' or 'high', if not specified, 'normal' will be set.
- `content`, required, is used to provide the chat message content.
- `senderDisplayName` is used to specify the display name of the sender, if not specified, an empty name will be set.
- `chatThreadId` is the unique ID of the thread.

`SendChatMessageResult` is the response returned from sending a message, it contains an id, which is the unique ID of the message.

```swift
let message = SendChatMessageRequest(
    priority: ChatMessagePriority.high,
    content: "Test message 1",
    senderDisplayName: "An Important person"
)

getClient().send(chatMessage: message, chatThreadId: threadId) { result, _ in
    switch result {
    case let .success(createMessageResponse):
        //TODO: Take further action

    case let .failure(error):
        //TODO: Display error message
    }
}
```

### Get a message

Use the `getChatMessage` method to retrieve a message in a thread.

- `chatThreadId` is the unique ID of the thread.
- `chatMessageId` is the unique ID of the message.

`ChatMessage` is the response returned from getting a message.

```swift
client.getChatMessage(chatThreadId: threadId, chatMessageId: messageId) { result, _ in
    switch result {
    case let .success(message):
        //TODO: Take further action

    case let .failure(error):
        //TODO: Display error message
    }
}
```

### List messages

Use the `listChatMessages` method to retrieve messages in a thread.

- `ListChatMessagesOptions` is the object representing the options to pass.
- `maxPageSize`, optional, is the maximum number of messages to be returned per page.
- `startTime`, optional, is the thread start time to consider in the query.
- `chatThreadId` is the unique ID of the thread.

`<PagedCollection<ChatMessage>` is the response returned from listing messages

```swift
let dateFormatter = DateFormatter()
dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

var options: ListChatMessagesOptions? = nil
if let date = dateFormatter.date(from: "2020-08-27T17:55:50Z") {
    options = ListChatMessagesOptions(
        startTime: date
    )
}

client.listChatMessages(chatThreadId: threadId, withOptions: options) { result, _ in
    switch result {
    case let .success(listMessagesResponse):
        var iterator = listMessagesResponse.syncIterator
        while let message = iterator.next() {
            //TODO: Take further action
        }

    case let .failure(error):
        //TODO: Display error message
    }
}
```

### Update a message

Use the `update` method to update a message in a thread.

- `UpdateChatMessageRequest` is the model to pass to this method.
- `priority` is the chat message priority `ChatMessagePriority`, such as 'Normal' or 'High', if not specified, 'Normal' will be set.
- `content` is the message content to be updated.
- `chatThreadId` is the unique ID of the thread.
- `chatMessageId` is the unique ID of the message.

```swift
let message = UpdateChatMessageRequest(
    content: "A message content with update()"
)

getClient().update(chatMessage: message, chatThreadId: threadId, chatMessageId: messageId) { result, _ in
    switch result {
    case .success(_):
        //TODO: Take further action

    case let .failure(error):
        //TODO: Display error message
    }
}
```

### Delete a message

Use the `deleteChatMessage` method to delete a message in a thread.

- `chatThreadId` is the unique ID of the thread.
- `chatMessageId` is the unique ID of the message.

```swift
getClient().deleteChatMessage(chatThreadId: threadId, chatMessageId: messageId) { result, _ in
    switch result {
    case .success:
        //TODO: Take further action

    case let .failure(error):
        //TODO: Display error message
    }
}
```

## Thread Member Operations

### Get thread members

Use the `listChatThreadMembers` method to retrieve the members participating in a thread.

- `chatThreadId` is the unique ID of the thread.

`PagedCollection<ChatThreadMember>` is the response returned from listing members.

```swift
client.listChatThreadMembers(chatThreadId: threadId) { result, _ in
    switch result {
    case let .success(threadmembers):
        var iterator = threadmembers.syncIterator
        while let threadMember = iterator.next() {
            //TODO: Take further action
        }

    case let .failure(error):
        //TODO: Display error message
    }
}
```

### Add thread members

Use the `add` method to add members to a thread.

- `AddChatThreadMembersRequest` is used to list the `ChatThreadMember`s to be added to the thread.
- `id`, required, is the `CommunicationUser.identifier` you created before. Refer to [User and User Access Tokens](#User-and-User-Access-Tokens).
- `displayName`, optional, is the display name for the thread member.
- `shareHistoryTime`, optional, is the time from which the chat history is shared with the member.
- `chatThreadId` is the unique ID of the thread.

```swift
let threadMembers = AddChatThreadMembersRequest(
    members: [ChatThreadMember(
        id: userId,
        displayName: "a new member"
    )]
)
client.add(chatThreadMembers: threadMembers, chatThreadId: threadId) { result, _ in
    switch result {
    case .success:
        //TODO: Take further action

    case let .failure(error):
        //TODO: Display error message
    }
}
```

### Remove a thread member

Use the `removeChatThreadMember` method to remove a member from a thread.

- `chatThreadId` is the unique ID of the thread.
- `chatMemberId` is the user ID in the chat thread's member list.

```swift
client.removeChatThreadMember(chatThreadId: threadId, chatMemberId: memberId) { result, _ in
    switch result {
    case .success:
        //TODO: Take further action

    case let .failure(error):
        //TODO: Display error message
    }
}
```

## Events Operations

### Send a typing notification

Use the `sendTypingNotification` method to post a typing notification event to a thread, on behalf of a user.

```swift
client.sendTypingNotification(chatThreadId: threadId) { result, _ in
    switch result {
    case .success:
        //TODO: Take further action

    case let .failure(error):
        //TODO: Display error message
    }
}
```

### Send read receipt

Use the `send` method to post a read receipt event to a thread, on behalf of a user.

- `SendReadReceiptRequest` is the model to be passed to this method.
- `chatMessageId` is the unique ID of the message.
- `chatThreadId` is the unique ID of the thread.

```swift
let readReceipt = SendReadReceiptRequest(chatMessageId: messageId)

client.send(chatReadReceipt: readReceipt, chatThreadId: threadId) { result, _ in
    switch result {
    case .success:
        //TODO: Take further action

    case let .failure(error):
        //TODO: Display error message
    }
}
```

### Get read receipts

Use the `listChatReadReceipts` method to retrieve read receipts for a thread.

- `chatThreadId` is the unique ID of the thread.

`PagedCollection<ReadReceipt>` is the response returned from listing read receipts.

```swift
client.listChatReadReceipts(chatThreadId: threadId) { result, _ in
    switch result {
    case let .success(readReceipts):
        var iterator = readReceipts.syncIterator
        while let readReceipt = iterator.next() {
            //TODO: Take further action
        }

    case let .failure(error):
        //TODO: Display error message
    }
}
```

# Troubleshooting

## General

The client raises AzureError defined in AzureCore

```swift
client.create(chatThread: thread) { result, _ in
    switch result {
    case let .failure(error):
        //TODO: Display error message
    }
}
```

# Next steps

More sample code should go here, along with links out to the appropriate example tests.

# Contributing
This project welcomes contributions and suggestions.  Most contributions require you to agree to a Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us the rights to use your contribution. For details, visit https://cla.microsoft.com.

When you submit a pull request, a CLA-bot will automatically determine whether you need to provide a CLA and decorate the PR appropriately (e.g., label, comment). Simply follow the instructions provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

![Impressions](TODO: Find impressions URL)
