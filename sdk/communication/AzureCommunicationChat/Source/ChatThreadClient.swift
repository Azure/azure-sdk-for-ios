// --------------------------------------------------------------------------
//
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// The MIT License (MIT)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the ""Software""), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
//
// --------------------------------------------------------------------------

import AzureCommunication
import AzureCore
import Foundation

public class ChatThreadClient {
    // MARK: Properties

    public let threadId: String
    private let client: AzureCommunicationChatClient
    private let credential: CommunicationUserCredential
    private let endpoint: String
    private let options: AzureCommunicationChatClientOptions

    // MARK: Initializers

    /// Create a ChatThreadClient.
    /// - Parameters:
    ///   - threadId: The chat thread id.
    ///   - endpoint: The Communication Services endpoint.
    ///   - credential: The user credential.
    ///   - options: Options used to configure the client.
    public init(
        threadId: String,
        endpoint: String,
        credential: CommunicationUserCredential,
        withOptions options: AzureCommunicationChatClientOptions
    ) throws {
        self.threadId = threadId
        self.endpoint = endpoint
        self.credential = credential
        self.options = options

        guard let endpointUrl = URL(string: endpoint) else {
            throw AzureError.client("Unable to form base URL")
        }

        let authPolicy = CommunicationUserCredentialPolicy(credential: credential)

        self.client = try AzureCommunicationChatClient(endpoint: endpointUrl, authPolicy: authPolicy, withOptions: options)
    }

    // MARK: Public Methods

    /// Updates the ChatThread's properties.
    /// - Parameters:
    ///   - request: Request for updating a chat thread.
    ///   - options: Update chat thread options.
    ///   - completionHandler: A completion handler that receives a status code on success.
    public func updateThread(
        request: UpdateChatThreadRequest,
        withOptions options: AzureCommunicationChatService.UpdateChatThreadOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<Void>
    ) {
        client.update(chatThread: request, chatThreadId: threadId, withOptions: options) { result, httpResponse in
            switch result {
            case .success:
                completionHandler(.success(()), httpResponse)

            case let .failure(error):
                completionHandler(.failure(error), httpResponse)
            }
        }
    }

    /// Sends a read receipt..
    /// - Parameters:
    ///   - request: Request for sending a read receipt.
    ///   - options: Send read receipt options.
    ///   - completionHandler: A completion handler that receives a status code on success.
    public func sendReadReceipt(
        request: SendReadReceiptRequest,
        withOptions options: AzureCommunicationChatService.SendChatReadReceiptOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<Void>
    ) {
        client.send(chatReadReceipt: request, chatThreadId: threadId, withOptions: options) { result, httpResponse in
            switch result {
            case .success:
                completionHandler(.success(()), httpResponse)

            case let .failure(error):
                completionHandler(.failure(error), httpResponse)
            }
        }
    }

    /// Lists read receipts for the chat thread.
    /// - Parameters:
    ///   - options: List chat read receipts options.
    ///   - completionHandler: A completion handler that receives the list of read receipts on success.
    public func listReadReceipts(
        withOptions options: AzureCommunicationChatService.ListChatReadReceiptsOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<PagedCollection<ChatMessageReadReceipt>>
    ) {
        client.listChatReadReceipts(chatThreadId: threadId, withOptions: options) { result, httpResponse in
            switch result {
            case let .success(readReceipts):
                completionHandler(.success(readReceipts), httpResponse)

            case let .failure(error):
                completionHandler(.failure(error), httpResponse)
            }
        }
    }

    /// Sends a typing notification.
    /// - Parameters:
    ///    - options: Send typing notification options
    ///    - completionHandler: A completion handler that receives a status code on success.
    public func sendTypingNotification(
        withOptions options: AzureCommunicationChatService.SendTypingNotificationOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<Void>
    ) {
        client.sendTypingNotification(chatThreadId: threadId, withOptions: options) { result, httpResponse in
            switch result {
            case .success:
                completionHandler(.success(()), httpResponse)

            case let .failure(error):
                completionHandler(.failure(error), httpResponse)
            }
        }
    }

    /// Sends a message to a thread.
    /// - Parameters:
    ///    - chatMessage : Request for sending a message.
    ///    - options: A list of options for the operation.
    ///    - completionHandler: A completion handler that receives a status code on success.
    public func sendMessage(
        request: SendChatMessageRequest,
        withOptions options: AzureCommunicationChatService.SendChatMessageOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<SendChatMessageResult>
    ) {
        client.send(chatMessage: request, chatThreadId: threadId, withOptions: options) { result, httpResponse in
            switch result {
            case let .success(sendMessageResult):
                completionHandler(.success(sendMessageResult), httpResponse)

            case let .failure(error):
                completionHandler(.failure(error), httpResponse)
            }
        }
    }

    /// Gets a message by id.
    /// - Parameters:
    ///    - chatMessageId : The message id.
    ///    - options: Get chat message options
    ///    - completionHandler: A completion handler that receives the chat message on success.
    public func getMessage(
        chatMessageId: String,
        withOptions options: AzureCommunicationChatService.GetChatMessageOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<ChatMessage>
    ) {
        client
            .getChatMessage(
                chatThreadId: threadId,
                chatMessageId: chatMessageId,
                withOptions: options
            ) { result, httpResponse in
                switch result {
                case let .success(chatMessage):
                    completionHandler(.success(chatMessage), httpResponse)

                case let .failure(error):
                    completionHandler(.failure(error), httpResponse)
                }
            }
    }

    /// Updates a message.
    /// - Parameters:
    ///    - request: Request to update the message.
    ///    - chatMessageId : The message id.
    ///    - options: Update chat message options
    ///    - completionHandler: A completion handler that receives a status code on success.
    public func updateMessage(
        request: UpdateChatMessageRequest,
        chatMessageId: String,
        withOptions options: AzureCommunicationChatService.UpdateChatMessageOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<Void>
    ) {
        client
            .update(
                chatMessage: request,
                chatThreadId: threadId,
                chatMessageId: chatMessageId,
                withOptions: options
            ) { result, httpResponse in
                switch result {
                case .success:
                    completionHandler(.success(()), httpResponse)

                case let .failure(error):
                    completionHandler(.failure(error), httpResponse)
                }
            }
    }

    /// Deletes a message.
    /// - Parameters:
    ///    - chatMessageId : The message id.
    ///    - options: Delete chat message options
    ///    - completionHandler: A completion handler that receives a status code on success.
    public func deleteMessage(
        chatMessageId: String,
        options: AzureCommunicationChatService.DeleteChatMessageOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<Void>
    ) {
        client
            .deleteChatMessage(
                chatThreadId: threadId,
                chatMessageId: chatMessageId,
                withOptions: options
            ) { result, httpResponse in
                switch result {
                case .success:
                    completionHandler(.success(()), httpResponse)

                case let .failure(error):
                    completionHandler(.failure(error), httpResponse)
                }
            }
    }

    /// Gets a list of messages from a thread.
    /// - Parameters:
    ///    - options: List messages options.
    ///    - completionHandler: A completion handler that receives the list of messages on success.
    public func listMessages(
        withOptions options: AzureCommunicationChatService.ListChatMessagesOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<PagedCollection<ChatMessage>>
    ) {
        client.listChatMessages(chatThreadId: threadId, withOptions: options) { result, httpResponse in
            switch result {
            case let .success(messages):
                completionHandler(.success(messages), httpResponse)

            case let .failure(error):
                completionHandler(.failure(error), httpResponse)
            }
        }
    }

    /// Adds thread participants to a thread. If the participants already exist, no change occurs.
    /// - Parameters:
    ///    - request : The request with thread participants to be added to the thread.
    ///    - options: Add chat participants options.
    ///    - completionHandler: A completion handler that receives a status code on success.
    public func addParticipants(
        request: AddChatParticipantsRequest,
        withOptions options: AzureCommunicationChatService.AddChatParticipantsOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<Void>
    ) {
        client.add(chatParticipants: request, chatThreadId: threadId, withOptions: options) { result, httpResponse in
            switch result {
            case .success:
                completionHandler(.success(()), httpResponse)

            case let .failure(error):
                completionHandler(.failure(error), httpResponse)
            }
        }
    }

    /// Removes a participant from the thread.
    /// - Parameters:
    ///    - chatMemberId : Id of the participant to remove.
    ///    - options: Remove participant options
    ///    - completionHandler: A completion handler that receives a status code on success.
    public func removeParticipant(
        chatParticipantId: String,
        withOptions options: AzureCommunicationChatService.RemoveChatParticipantOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<Void>
    ) {
        client
            .removeChatParticipant(
                chatThreadId: threadId,
                chatParticipantId: chatParticipantId,
                withOptions: options
            ) { result, httpResponse in
                switch result {
                case .success:
                    completionHandler(.success(()), httpResponse)

                case let .failure(error):
                    completionHandler(.failure(error), httpResponse)
                }
            }
    }

    /// Gets the participants of the thread.
    /// - Parameters:
    ///    - options: List chat participants options.
    ///    - completionHandler: A completion handler that receives the list of members on success.
    public func listParticipants(
        withOptions options: AzureCommunicationChatService.ListChatParticipantsOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<PagedCollection<ChatParticipant>>
    ) {
        client.listChatParticipants(chatThreadId: threadId, withOptions: options) { result, httpResponse in
            switch result {
            case let .success(participants):
                completionHandler(.success(participants), httpResponse)

            case let .failure(error):
                completionHandler(.failure(error), httpResponse)
            }
        }
    }
}
