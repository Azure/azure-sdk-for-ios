# Azure Communication Chat Service client library for iOS

This package contains the Chat client library for Azure Communication Services.

[Source code](https://github.com/Azure/azure-sdk-for-ios/tree/master/sdk/communication/AzureCommunicationChat)
| [API reference documentation](https://azure.github.io/azure-sdk-for-ios/AzureCommunicationChat/index.html)
| [Product documentation](https://docs.microsoft.com/azure/communication-services/overview)

## Getting started

### Prerequisites
* The client library is written in modern Swift 5. Due to this, Xcode 10.2 or higher is required to use this library.
* You must have an [Azure subscription](https://azure.microsoft.com/free/) and a
[Communication Services resource](https://docs.microsoft.com/azure/communication-services/quickstarts/create-communication-resource) to use this library.

### Install the library
To install the Azure client libraries for iOS, we recommend you use
[Swift Package Manager](#add-a-package-dependency-with-swift-package-manager).
As an alternative, you may also integrate the libraries using
[CocoaPods](#integrate-the-client-libraries-with-cocoapods).

#### Add a package dependency with Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for managing the distribution of Swift code.
It’s integrated with the Swift build system to automate the process of downloading, compiling, and linking dependencies.

Xcode comes with built-in support for Swift Package Manager and source control accounts and makes it easy to leverage
available Swift packages. Use Xcode to manage the versions of package dependencies and make sure your project has the
most up-to-date code changes.

##### Xcode

To add the library to your application, follow the instructions in
[Adding Package Dependencies to Your App](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app):

With your project open in Xcode 11 or later, select **File > Swift Packages > Add Package Dependency...** Enter the
clone URL of this repository: *https://github.com/Azure/azure-sdk-for-ios.git* and click **Next**. For the version rule,
specify the exact version or version range you wish to use with your application and click **Next**. Finally, place a
checkmark next to the library, ensure your application target is selected in the **Add to target** dropdown, and click
**Finish**.

##### Swift CLI

To add the library to your application, follow the example in
[Importing Dependencies](https://swift.org/package-manager/#importing-dependencies):

Open your project's `Package.swift` file and add a new package dependency to your project's `dependencies` section,
specifying the clone URL of this repository and the version specifier you wish to use:

```swift
    dependencies: [
        ...
        .package(url: "https://github.com/Azure/azure-sdk-for-ios.git", from: "1.0.0-beta.7")
    ],
```

Next, for each target that needs to use the library, add it to the target's array of `dependencies`:
```swift
    targets: [
        ...
        .target(
            name: "MyTarget",
            dependencies: ["AzureCommunicationChat", ...])
    ]
)
```

#### Integrate the client libraries with CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Objective C and Swift projects. You can install it with
the following command:

```bash
$ [sudo] gem install cocoapods
```

> CocoaPods 1.5+ is required.

To integrate one or more client libraries into your project using CocoaPods, specify them in your
[Podfile](https://guides.cocoapods.org/using/the-podfile.html), providing the version specifier you wish to use. To
ensure compatibility when using multiple client libraries in the same project, use the same version specifier for all
Azure SDK client libraries within the project:

```ruby
platform :ios, '12.0'

# Comment the next line if you don't want to use dynamic frameworks
use_frameworks!

target 'MyTarget' do
  pod 'AzureCommunicationChat', '~> 1.0.0-beta.7'
  ...
end
```

## Key concepts

### User and User Access Tokens

User access tokens enable you to build client applications that directly authenticate to Azure Communication Services. Refer [here](https://docs.microsoft.com/azure/communication-services/quickstarts/access-tokens) to learn how to create a user and issue a User Access Token.

The id for the user created above will be necessary later to add said user as a participant of a new chat thread. The initiator of the create request must be in the list of participants of the chat thread.

### Chat Thread

A chat conversation is represented by a chat thread. Each user in the thread is called a thread participant. Thread participants can chat with one another privately in a 1:1 chat or huddle up in a 1:N group chat.

Using the APIs, users can also send typing indicators when typing a message and read receipts for the messages they have read in a chat thread. To learn more, read about chat concepts [here](https://docs.microsoft.com/azure/communication-services/concepts/chat/concepts).

### ChatClient

`ChatClient` is used for performing chat thread operations, listed below.

#### Initialization

To instantiate ChatClient you will need the CommunicationServices resource endpoint, a CommunicationUserCredential created from a User Access Token, and optional options to create the client with.

```swift
import AzureCommunication
import AzureCommunicationChat
import AzureCore

let endpoint = "<communication_resource_endpoint>"

let credential = try CommunicationUserCredential(<"user_access_token>")

let options = AzureCommunicationChatClientOptions(
	logger: ClientLoggers.default,
	dispatchQueue: self.queue
)

let chatClient = ChatClient(endpoint: endpoint, credential: credential, withOptions: options)

```

#### Thread Operations

ChatClient supports the following methods, see the links below for examples.

- [Create a thread](#create-a-thread)
- [Get a thread](#get-a-thread)
- [List threads](#list-threads)
- [Delete a thread](#delete-a-thread)
- [Get a thread client](#get-a-thread-client)

### ChatThreadClient

`ChatThreadClient` provides methods for operations within a chat thread, such as messaging and managing participants.

#### Initialization

ChatThreadClients should be created through the ChatClient. A ChatThreadClient is associated with a specific chat thread and is used to perform operations within the thread. See the list below for examples of each operation that ChatThreadClient supports.

#### Message Operations

- [Send a message](#send-a-message)
- [Get a message](#get-a-message)
- [List messages](#list-messages)
- [Update a message](#update-a-message)
- [Delete a message](#delete-a-message)

#### Thread Participant Operations

- [Get thread participants](#get-thread-participants)
- [Add thread participants](#add-thread-participants)
- [Remove a thread participant](#remove-a-thread-participant)

#### Events Operations

- [Send a typing notification](#send-a-typing-notification)
- [Send read receipt](#send-read-receipt)
- [Get read receipts](#get-read-receipts)

#### Thread Update Operations
- [Update the thread topic](#update-thread-topic)

## Examples

### Thread Operations

#### Create a thread

Use the `create` method of `ChatClient` to create a new thread.

- `CreateChatThreadRequest` is the model to pass to this method. It contains the participants to add to the thread as well as the topic of the thread.

- `CreateChatThreadResult` is the result returned from creating a thread.
- `chatThread` is the ChatThread that was created
- `errors` contains an array of errors for any invalid participants that failed to be added to the chat thread.

```swift
let thread = CreateChatThreadRequest(
    topic: "General",
    participants: [ChatParticipant(
        id: <userId>,
        // Id of this needs to match with the Auth token
        displayName: "initial participant"
    )]
)

chatClient.create(chatThread: thread) { result, _ in
    switch result {
    case let .success(chatThreadResult):
        // Take further action

    case let .failure(error):
        // Display error message
    }
}
```

#### Get a thread

Use the `get` method of `ChatClient` to retrieve a thread.

- `thread` is the unique ID of the thread.

```swift
chatClient.get(thread: threadId) { result, _ in
    switch result {
    case let .success(chatThread):
        // Take further action

    case let .failure(error):
        // Display error message
    }
}
```

#### List threads

Use the `listThreads` method to retrieve a list of threads.

- `ListChatThreadsOptions` is the object representing the options to pass.
- `maxPageSize`, optional, is the maximum number of messages to be returned per page.
- `startTime`, optional, is the thread start time to consider in the query.

`PagedCollection<ChatThreadInfo>` is the response returned from listing threads.

```swift
import AzureCore
let options = ListChatThreadsOptions(maxPageSize: 1)
chatClient.listThreads(withOptions: options) { result, _ in
    switch result {
    case let .success(listThreadsResponse):
        var iterator = listThreadsResponse.syncIterator
        while let threadInfo = iterator.next() {
            // Take further action
        }

    case let .failure(error):
        // Display error message
    }
}
```


#### Delete a thread

Use the `delete` method of `ChatClient` to delete a thread.

- `thread` is the unique ID of the thread.

```swift
chatClient.delete(thread: threadId) { result, httpResponse in
    switch result {
    case .success:
        // Take further action

    case let .failure(error):
        // Display error message
    }
}
```

### Message Operations

#### Send a message

Use the `send` method of `ChatThreadClient` to send a message to a thread.

- `SendChatMessageRequest` is the model to pass to this method.
- `content`, required, is used to provide the chat message content.
- `senderDisplayName` is used to specify the display name of the sender, if not specified, an empty name will be set.
- `type` is the type of message being sent, the supported types are text and html.

`SendChatMessageResult` is the response returned from sending a message, it contains an id, which is the unique ID of the message.

```swift
let message = SendChatMessageRequest(
    content: "Test message 1",
    senderDisplayName: "An Important person"
)

chatThreadClient.send(message: message) { result, _ in
    switch result {
    case let .success(createMessageResponse):
        // Take further action

    case let .failure(error):
        // Display error message
    }
}
```

#### Get a message

Use the `get` method of `ChatThreadClient` to retrieve a message in a thread.

- `message` is the unique ID of the message.

`ChatMessage` is the response returned from getting a message.

```swift
chatThreadClient.get(message: messageId) { result, _ in
    switch result {
    case let .success(message):
        // Take further action

    case let .failure(error):
        // Display error message
    }
}
```

#### List messages

Use the `listMessages` method of `ChatThreadClient` to retrieve messages in a thread.

- `ListChatMessagesOptions` is the optional object representing the options to pass.
- `maxPageSize`, optional, is the maximum number of messages to be returned per page.
- `startTime`, optional, is the thread start time to consider in the query.

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

client.listMessages(withOptions: options) { result, _ in
    switch result {
    case let .success(listMessagesResponse):
        var iterator = listMessagesResponse.syncIterator
        while let message = iterator.next() {
            // Take further action
        }

    case let .failure(error):
        // Display error message
    }
}
```

#### Update a message

Use the `update` method of `ChatThreadClient` to update a message in a thread.

- `UpdateChatMessageRequest` is the model to pass to this method.
- `content` is the message content to be updated.
- `chatMessageId` is the unique ID of the message.

-`messageId` is the unique id of the message.

```swift
let message = UpdateChatMessageRequest(
    content: "A message content with update()"
)

chatThreadClient.update(message: message, messageId: messageId) { result, _ in
    switch result {
    case .success(_):
        // Take further action

    case let .failure(error):
        // Display error message
    }
}
```

#### Delete a message

Use the `delete` method of `ChatThreadClient` to delete a message in a thread.

- `message` is the unique ID of the message.

```swift
chatThreadClient.delete(message: messageId) { result, _ in
    switch result {
    case .success:
        // Take further action

    case let .failure(error):
        // Display error message
    }
}
```

### Thread Participant Operations

#### Get thread participants

Use the `listParticipants` of `ChatThreadClient` method to retrieve the participants of the thread.


`PagedCollection<ChatParticipants>` is the response returned from listing participants.

```swift
chatThreadClient.listParticipants() { result, _ in
    switch result {
    case let .success(threadParticipants):
        var iterator = threadParticipants.syncIterator
        while let threadParticipants = iterator.next() {
            // Take further action
        }

    case let .failure(error):
        // Display error message
    }
}
```

#### Add thread participants

Use the `add` method to add participants to a thread.

- `participants` is an array of `ChatParticipant`'s to add
- `AddChatParticipantsResult` is the model returned, it contains an errors property that has an array of any invalid participants that failed to be added to the chat.

```swift
let threadParticipants = [ChatParticipant(
        id: userId,
        displayName: "a new participant"
    )]

chatThreadClient.add(participants: threadParticipants) { result, _ in
    switch result {
    case let .success(result):
        // Check for invalid participants

    case let .failure(error):
        // Display error message
    }
}
```

#### Remove a thread participant

Use the `remove` method of `ChatThreadClient` to remove a participant from a thread.

- `participant` is id of the participant to remove.

```swift
chatThreadClient.remove(participant: participantId) { result, _ in
    switch result {
    case .success:
        // Take further action

    case let .failure(error):
        // Display error message
    }
}
```

### Events Operations

#### Send a typing notification

Use the `sendTypingNotification` method of `ChatThreadClient` to post a typing notification event to a thread, on behalf of a user.

```swift
chatThreadClient.sendTypingNotification() { result, _ in
    switch result {
    case .success:
        // Take further action

    case let .failure(error):
        // Display error message
    }
}
```

#### Send read receipt

Use the `sendReadReceipt` method of `ChatThreadClient` to post a read receipt event to a thread, on behalf of a user.

-`forMessage` refers to the unique ID of the message that the read receipt is for.

```swift

chatThreadClient.sendReadReceipt(forMessage: messageId) { result, _ in
    switch result {
    case .success:
        // Take further action

    case let .failure(error):
        // Display error message
    }
}
```

#### Get read receipts

Use the `listReadReceipts` method of `ChatThreadClient` to retrieve read receipts for a thread.

`PagedCollection<ReadReceipt>` is the response returned from listing read receipts.

```swift
chatThreadClient.listReadReceipts() { result, _ in
    switch result {
    case let .success(readReceipts):
        var iterator = readReceipts.syncIterator
        while let readReceipt = iterator.next() {
            // Take further action
        }

    case let .failure(error):
        // Display error message
    }
}
```

### Thread Update Operations

#### Update the thread's topic

Use the `update` method of `ChatThreadClient` to update a thread's topic.

- `topic` is the thread's new topic.

```swift
let newTopic = "My new thread topic"

chatThreadClient.update(topic: newTopic) { result, _ in
    switch result {
    case .success:
        // Take further action

    case let .failure(error):
        // Display error message
    }
}
```

## Troubleshooting

When an error occurs, the client calls the callback, passing in a `failure` result. You can use the provided error to act upon the failure.

```swift
client.create(thread: thread) { result, _ in
    switch result {
    case let .failure(error):
        // Display error message
    }
}
```

## Next steps

More sample code should go here, along with links out to the appropriate example tests.

## Contributing

This project welcomes contributions and suggestions. Most contributions require you to agree to a Contributor License
Agreement (CLA) declaring that you have the right to, and actually do, grant us the rights to use your contribution. For
details, visit https://cla.microsoft.com.

When you submit a pull request, a CLA-bot will automatically determine whether you need to provide a CLA and decorate
the PR appropriately (e.g., label, comment). Simply follow the instructions provided by the bot. You will only need to
do this once across all repositories using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact
[opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

![Impressions](https://azure-sdk-impressions.azurewebsites.net/api/impressions/azure-sdk-for-ios%2Fsdk%communication%2FAzureCommunicationChat%2FREADME.png)