# Azure Communication Chat Service client library for iOS
This package contains a iOS SDK for Azure Communication Services for Chat.
Read more about Azure Communication Services [here](https://docs.microsoft.com/azure/communication-services/overview)

# Getting started

## Prerequisites

- An Azure Communication Resource, learn how to create one from [Create an Azure Communication Resource](https://docs.microsoft.com/azure/communication-services/quickstarts/create-communication-resource)


## User and User Access Tokens

User access tokens enable you to build client applications that directly authenticate to Azure Communication Services. Refer [here](https://docs.microsoft.com/azure/communication-services/quickstarts/access-tokens) to learn how to create a user and issue an User Access Token

The user id `CommunicationUser.identifier`  created above will be used later, because that user should be added as a member of new chat thread when you creating
it with this token. It is because the initiator of the create request must be in the list of the members of the chat thread.

## Create the AzureCommunicationChatClient

```swift
import AzureCommunication
import AzureCommunicationChat

guard let baseUrl = URL(string: "https://<resource>.communication.azure.com") else {
    fatalError("Unable to form base URL")
}

let authPolicy = try CommunicationUserCredentialPolicy(
    credential: credential ?? CommunicationUserCredential(token: <user_access_token>)
)
let options = AzureCommunicationChatClientOptions(
    logger: ClientLoggers.none,
    dispatchQueue: self.queue
)
let client = AzureCommunicationChatClient(baseUrl: baseUrl, authPolicy: authPolicy, withOptions: options)
```

# Key concepts

A chat conversation is represented by a chat thread. Each user in the thread is called a thread member. Thread members can chat with one another privately in a 1:1 chat or huddle up in a 1:N group chat. Users also get near real-time updates for when others are typing and when they have read the messages.

Once you initialized a `AzureCommunicationChatClient` class, you can do the following chat operations:

## Create, get, update, list, and delete threads

```swift
client.create(chatThread: thread)
client.getChatThread(chatThreadId: threadId)
client.update(chatThread: thread, chatThreadId: threadId)
client.listChatThreads(withOptions: options)
client.deleteChatThread(chatThreadId: threadId)
```

## Send, get, update, and delete messages

```swift
client.send(chatMessage: message, chatThreadId: threadId)
client.getChatMessage(chatThreadId: threadId, chatMessageId: messageId)
client.update(chatMessage: message, chatThreadId: threadId, chatMessageId: messageId)
client.deleteChatMessage(chatThreadId: threadId, chatMessageId: messageId)
```

## list, add, and remove members

```swift
client.listChatThreadMembers(chatThreadId: threadId)
client.add(chatThreadMembers: threadMembers, chatThreadId: threadId)
client.removeChatThreadMember(chatThreadId: threadId, chatMemberId: memberId)
```

## Send typing notification

```swift
client.sendTypingNotification(chatThreadId: threadId)
```

## Send and get read receipt

Notify the service that a message is read and get list of read messages.

```swift
client.send(chatReadReceipt: readReceipt, chatThreadId: threadId)
client.listChatReadReceipts(chatThreadId: threadId)
```

# Examples

## Thread Operations

### Create a thread

Use the `create` method to create a chat thread client object.

- `CreateChatThreadRequest` is the model to pass to this method
- Use `topic` to give a thread topic;
- Use `members` to list the `ChatThreadMember` to be added to the thread;
- `id`, required, it is the `CommunicationUser.identifier` you created before, refer to [User and User Access Tokens](#User-and-User-Access-Tokens)
- `displayName`, optional, is the display name for the thread member.
- `shareHistoryTime`, optional, time from which the chat history is shared with the member.

`MultiStatusResponse` is the result returned from creating a thread, it has 'multipleStatus' which is a list of `IndividualStatusResponse`

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
            assert(response.id != nil, "Thread id should not be nil")

            if response.id?.hasSuffix("@thread.v2") ?? false,
                response.type ?? "" == "Thread" {
                threadId = response.id
            }
        }
        guard let thread = threadId else { fatalError("ThreadId not found.") }
        print("<- SUCCESS! in createThread. Thread id= \(thread)")

    case let .failure(error):
        print("!! FAIL! in createThread.")
        fatalError(error.message)
    }
}
```

### Get a thread

The `getChatThread` method retrieves a thread from the service.
`chatThreadId` is the unique ID of the thread.

```swift
client.getChatThread(chatThreadId: threadId) { result, _ in
    switch result {
    case let .success(thread):
        print("<- SUCCESS! in getThread. response createdBy= \(thread.createdBy ?? "Not found")")

        for threadMember in thread.members ?? [] {
            print("\t Thread Member name=\(threadMember.displayName ?? "Not found")")
        }

    case let .failure(error):
        print("!! FAIL! ")
        fatalError(error.message)
    }
}
```

### List chat threads
The `listChatThreads` method retrieves the list of created chat threads

- `ListChatThreadsOptions` is the options to pass
- `maxPageSize`, optional, The maximum number of messages to be returned per page.
- `startTime`, optional, The start time where the range query.

`PagedCollection<ChatThreadInfo>` is the response returned from listing threads

```swift
import AzureCore
let options = ListChatThreadsOptions(maxPageSize: 1)
client.listChatThreads(withOptions: options) { result, _ in
    switch result {
    case let .success(listThreadsResponse):
        var iterator = listThreadsResponse.syncIterator
        while let threadInfo = iterator.next() {
            print("\t \(threadInfo.id)")
        }
        print("<- SUCCESS! .")

    case let .failure(error):
        print("!! FAIL! .")
        fatalError(error.message)
    }
}
```

### Update a thread

Use `update` method to update a thread's properties
`threadId` is the unique ID of the thread.
`UpdateChatThreadRequest` is the model to pass
`topic` is used to describe the change of the thread topic

- Use `topic` to give thread a new topic;

```swift
 let thread = UpdateChatThreadRequest(
    topic: "A new topic update with update()"
)

client.update(chatThread: thread, chatThreadId: threadId) { result, _ in
    switch result {
    case .success:
        print("<- SUCCESS! in updateThread.")

    case let .failure(error):
        print("!! FAIL! in updateThread.")
        fatalError(error.message)
    }
}
```

### Delete a thread

Use `deleteChatThread` method to delete a thread
`threadId` is the unique ID of the thread.

```swift
client.deleteChatThread(chatThreadId: threadId) { result, httpResponse in
    switch result {
    case .success:
        print("<- SUCCESS! in deleteThread.")

    case let .failure(error):
        print("!! FAIL! in deleteThread.")
        fatalError(error.message)
    }
}
```

## Message Operations

### Send a message

Use `send` method to sends a message to a thread identified by threadId.

`threadId` is the unique ID of the thread.
`SendChatMessageRequest` is the model to pass
- Use `content` to provide the chat message content, it is required
- Use `priority` to specify the message priority level, such as 'Normal' or 'High', if not specified, 'Normal' will be set
- Use `senderDisplayName` to specify the display name of the sender, if not specified, empty name will be set

`SendChatMessageResult` is the response returned from sending a message, it contains an id, which is the unique ID of the message.

```swift
let message = SendChatMessageRequest(
    priority: ChatMessagePriority.High,
    content: "Test message 1",
    senderDisplayName: "An Important person"
)

getClient().send(chatMessage: message, chatThreadId: threadId) { result, _ in
    switch result {
    case let .success(createMessageResponse):
        print("<- SUCCESS! in sendMessage. Message id= \(createMessageResponse.id ?? "Not found")")

    case let .failure(error):
        print("!! FAIL! in sendMessage.")
        print(error)
    }
}
```

### Get a message

The `getChatMessage` method retrieves a message from the service.
`chatMessageId` is the unique ID of the message.

`ChatMessage` is the response returned from getting a message.

```swift
client.getChatMessage(chatThreadId: threadId, chatMessageId: messageId) { result, _ in
    switch result {
    case let .success(message):
        if let timeData = message.createdOn {
            print("<- SUCCESS! in getMessage. response createdOn= \(timeData)")
        } else {
            print("<- FAILED!! in finding createdOn in response")
        }

    case let .failure(error):
        print("!! FAIL! in getMessage.")
        fatalError(error.message)
    }
}
```

### Get messages

The `listChatMessages` method retrieves messages from the service.

`ListChatMessagesOptions` is the options to pass
- `maxPageSize`, optional, The maximum number of messages to be returned per page.
- `startTime`, optional, The start time where the range query.

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
        print("<- SUCCESS! in ListMessages.")
        var iterator = listMessagesResponse.syncIterator
        while let message = iterator.next() {
            print("\tMessage content=\(message.content ?? "Not found") ")
            if let timeData = message.createdOn {
                print("\tcreatedOn in response= \(timeData)")
            } else {
                print("-> FAILED!! in finding createdOn in response")
            }
        }

    case let .failure(error):
        print("!! FAIL! in listMessages")
        fatalError(error.message)
    }
}
```

### Update a message

Use `update` to update a message identified by threadId and messageId.
`UpdateChatMessageRequest` is the passed request model
`priority` is the chat message priority `ChatMessagePriority`, such as 'Normal' or 'High', if not specified, 'Normal' will be set
`content` is the message content to be updated.

```swift
let message = UpdateChatMessageRequest(
    content: "A message content with update()"
)

getClient().update(chatMessage: message, chatThreadId: threadId, chatMessageId: messageId) { result, _ in
    switch result {
    case .success(_):
        print("<- SUCCESS! in updateMessage.")

    case let .failure(error):
        print("!! FAIL! in updateMessage.")
        fatalError(error.message)
    }
}
```

### Delete a message

Use `deleteChatMessage` to delete a message.
`chatMessageId` is the unique ID of the message.

```swift
getClient().deleteChatMessage(chatThreadId: threadId, chatMessageId: messageId) { result, _ in
    switch result {
    case .success:
        print("<- SUCCESS! in deleteMessage.")

    case let .failure(error):
        print("!! FAIL! in deleteMessage.")
        fatalError(error.message)
    }
}
```

## Thread Member Operations

### Get thread members

Use `listChatThreadMembers` to retrieve the members of the thread.

`PagedCollection<ChatThreadMember>` is the response returned from listing members

```swift
client.listChatThreadMembers(chatThreadId: threadId) { result, _ in
    switch result {
    case let .success(threadmembers):
        print("<- SUCCESS! in listThreadMembers.")

        var iterator = threadmembers.syncIterator
        while let threadMember = iterator.next() {
            print("\tThread Member name=\(threadMember.displayName ?? "Not found")")
        }

    case let .failure(error):
        print("!! FAIL! in listThreadMembers.")
        fatalError(error.message)
    }
}
```

### Add thread members

Use `add` method to add thread members to the thread.

- Use `AddChatThreadMembersRequest` to list the `ChatThreadMember` to be added to the thread;
- `id`, required, it is the `CommunicationUser.identifier` you created before, refer to [User and User Access Tokens](#User-and-User-Access-Tokens)
- `displayName`, optional, is the display name for the thread member.
- `shareHistoryTime`, optional, time from which the chat history is shared with the member.

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
        print("<- SUCCESS! in addThreadMembers.")

    case let .failure(error):
        print("!! FAIL! in addThreadMembers.")
        fatalError(error.message)
    }
}
```

### Remove thread member

Use `removeChatThreadMember` method to remove thread member from the thread identified by threadId.
`chatMemberId` is the user id that in this chat thread members list.

```swift
client.removeChatThreadMember(chatThreadId: threadId, chatMemberId: memberId) { result, _ in
    switch result {
    case .success:
        print("<- SUCCESS! in removeThreadMember.")

    case let .failure(error):
        print("!! FAIL! in removeThreadMember.")
        fatalError(error.message)
    }
}
```

## Events Operations

### Send typing notification

Use `sendTypingNotification` method to post a typing notification event to a thread, on behalf of a user.

```swift
client.sendTypingNotification(chatThreadId: threadId) { result, _ in
    switch result {
    case .success:
        print("<- SUCCESS! in notifyUserTyping.")

    case let .failure(error):
        print("!! FAIL! in notifyUserTyping.")
        fatalError(error.message)
    }
}
```

### Send read receipt

Use `send` method to post a read receipt event to a thread, on behalf of a user.

```swift
let readReceipt = SendReadReceiptRequest(chatMessageId: messageId)

client.send(chatReadReceipt: readReceipt, chatThreadId: threadId) { result, _ in
    switch result {
    case .success:
        print("<- SUCCESS! in sendReadReceipt.")

    case let .failure(error):
        print("!! FAIL! in sendReadReceipt.")
        fatalError(error.message)
    }
}
```

### Get read receipts

use `listChatReadReceipts` method retrieves read receipts for a thread.

`PagedCollection<ReadReceipt>` is the response returned from listing read receipts

```swift
client.listChatReadReceipts(chatThreadId: threadId) { result, _ in
    switch result {
    case let .success(readReceipts):
        print("<- SUCCESS! in listReadReceipts.")

        var iterator = readReceipts.syncIterator
        while let readReceipt = iterator.next() {
            print("\tchatMessageId content=\(readReceipt.chatMessageId ?? "Not found") ")
            print("\tsenderId content=\(readReceipt.senderId ?? "Not found") ")
        }

    case let .failure(error):
        print("!! FAIL! in listReadReceipts.")
        fatalError(error.message)
    }
}
```

# Troubleshooting

Running into issues? This section should contain details as to what to do there.

# Next steps

More sample code should go here, along with links out to the appropriate example tests.

# Contributing
This project welcomes contributions and suggestions.  Most contributions require you to agree to a Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us the rights to use your contribution. For details, visit https://cla.microsoft.com.

When you submit a pull request, a CLA-bot will automatically determine whether you need to provide a CLA and decorate the PR appropriately (e.g., label, comment). Simply follow the instructions provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

![Impressions](TODO: Find impressions URL)

