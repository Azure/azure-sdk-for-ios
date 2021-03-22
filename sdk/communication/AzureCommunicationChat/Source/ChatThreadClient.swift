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
    private let endpoint: String
    private let credential: CommunicationTokenCredential
    private let options: AzureCommunicationChatClientOptions
    private let service: ChatThreadOperation

    // MARK: Initializers

    /// Create a ChatThreadClient.
    /// - Parameters:
    ///   - endpoint: The Communication Services endpoint.
    ///   - credential: The user credential.
    ///   - threadId: The chat thread id.
    ///   - options: Options used to configure the client.
    public init(
        endpoint: String,
        credential: CommunicationTokenCredential,
        threadId: String,
        withOptions options: AzureCommunicationChatClientOptions
    ) throws {
        self.threadId = threadId
        self.endpoint = endpoint
        self.credential = credential
        self.options = options

        guard let endpointUrl = URL(string: endpoint) else {
            throw AzureError.client("Unable to form base URL")
        }

        let communicationCredential = TokenCredentialAdapter(credential)
        let authPolicy = BearerTokenCredentialPolicy(credential: communicationCredential, scopes: [])

        let client = try AzureCommunicationChatClient(
            endpoint: endpointUrl,
            authPolicy: authPolicy,
            withOptions: options
        )

        self.service = client.chatThreadOperation
    }

    // MARK: Private Methods

    /// Creates a PagedCollection from the given data and request.
    /// - Parameters:
    ///   - data: The data to initialize the PagedCollection with.
    ///   - request: The HTTPRequest used to make the call.
    ///   - type: The type of the elements in the PagedCollection.
    private func createPagedCollection<T: Codable>(
        from data: Data?,
        withRequest request: HTTPRequest?,
        of _: T.Type
    ) throws -> PagedCollection<T> {
        guard let request = request else {
            throw AzureError.client("HTTPResponse does not contain httpRequest.")
        }

        guard let data = data else {
            throw AzureError.client("HTTPResponse does not contain data.")
        }

        let decoder = JSONDecoder()

        let codingKeys = PagedCodingKeys(
            items: "value",
            continuationToken: "nextLink"
        )

        let context = PipelineContext.of(keyValues: [
            ContextKey.allowedStatusCodes.rawValue: [200, 401, 403, 429, 503] as AnyObject
        ])

        return try PagedCollection<T>(
            client: service.client,
            request: request,
            context: context,
            data: data,
            codingKeys: codingKeys,
            decoder: decoder
        )
    }

    /// Converts Participants to ChatParticipants for internal use.
    /// - Parameter participants: The array of Participants.
    /// - Returns: An array of ChatParticipants.
    private func convert(participants: [Participant]) throws -> [ChatParticipant] {
        return try participants.map { (participant) -> ChatParticipant in
            let identifierModel = try IdentifierSerializer.serialize(identifier: participant.id)
            return ChatParticipant(
                communicationIdentifier: identifierModel,
                displayName: participant.displayName,
                shareHistoryTime: participant.shareHistoryTime
            )
        }
    }

    // MARK: Public Methods

    /// Updates the ChatThread's topic.
    /// - Parameters:
    ///   - topic: The topic.
    ///   - options: Update chat thread options.
    ///   - completionHandler: A completion handler that receives a status code on success.
    public func update(
        topic: String,
        withOptions options: ChatThreadOperation.UpdateChatThreadOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<Void>
    ) {
        let updateChatThreadRequest = UpdateChatThreadRequest(topic: topic)

        service
            .update(
                chatThread: updateChatThreadRequest,
                chatThreadId: threadId,
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

    /// Sends a read receipt.
    /// - Parameters:
    ///   - messageId: The id of the message to send a read receipt for.
    ///   - options: Send read receipt options.
    ///   - completionHandler: A completion handler that receives a status code on success.
    public func sendReadReceipt(
        forMessage messageId: String,
        withOptions options: ChatThreadOperation.SendChatReadReceiptOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<Void>
    ) {
        let sendReadReceiptRequest = SendReadReceiptRequest(chatMessageId: messageId)

        service
            .send(
                chatReadReceipt: sendReadReceiptRequest,
                chatThreadId: threadId,
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

    /// Lists read receipts for the ChatThread.
    /// - Parameters:
    ///   - options: List chat read receipts options.
    ///   - completionHandler: A completion handler that receives the list of read receipts on success.
    public func listReadReceipts(
        withOptions options: ChatThreadOperation.ListChatReadReceiptsOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<PagedCollection<ReadReceipt>>
    ) {
        service.listChatReadReceipts(chatThreadId: threadId, withOptions: options) { result, httpResponse in
            switch result {
            case .success:
                // TODO: https://github.com/Azure/azure-sdk-for-ios/issues/644
                // Construct a new PagedCollection of type ReadReceipt
                do {
                    let readReceipts = try self.createPagedCollection(
                        from: httpResponse?.data,
                        withRequest: httpResponse?.httpRequest,
                        of: ReadReceipt.self
                    )

                    completionHandler(.success(readReceipts), httpResponse)
                } catch {
                    let azureError = AzureError.client(error.localizedDescription, error)
                    completionHandler(.failure(azureError), httpResponse)
                }

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
        withOptions options: ChatThreadOperation.SendTypingNotificationOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<Void>
    ) {
        service.sendTypingNotification(chatThreadId: threadId, withOptions: options) { result, httpResponse in
            switch result {
            case .success:
                completionHandler(.success(()), httpResponse)

            case let .failure(error):
                completionHandler(.failure(error), httpResponse)
            }
        }
    }

    /// Sends a message to a ChatThread.
    /// - Parameters:
    ///    - message : Request that contains the message properties.
    ///    - options: A list of options for the operation.
    ///    - completionHandler: A completion handler that receives a status code on success.
    public func send(
        message: SendChatMessageRequest,
        withOptions options: ChatThreadOperation.SendChatMessageOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<SendChatMessageResult>
    ) {
        service.send(chatMessage: message, chatThreadId: threadId, withOptions: options) { result, httpResponse in
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
    ///    - messageId : The id of the message to get.
    ///    - options: Get chat message options
    ///    - completionHandler: A completion handler that receives the chat message on success.
    public func get(
        message messageId: String,
        withOptions options: ChatThreadOperation.GetChatMessageOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<Message>
    ) {
        service
            .getChatMessage(
                chatThreadId: threadId,
                chatMessageId: messageId,
                withOptions: options
            ) { result, httpResponse in
                switch result {
                case let .success(chatMessage):
                    do {
                        let message = try Message(from: chatMessage)
                        completionHandler(.success(message), httpResponse)
                    } catch {
                        let azureError = AzureError.client(error.localizedDescription, error)
                        completionHandler(.failure(azureError), httpResponse)
                    }

                case let .failure(error):
                    completionHandler(.failure(error), httpResponse)
                }
            }
    }

    /// Updates a message.
    /// - Parameters:
    ///    - message: Request that contains the message properties to update.
    ///    - messageId: The message id.
    ///    - options: Update chat message options
    ///    - completionHandler: A completion handler that receives a status code on success.
    public func update(
        message: UpdateChatMessageRequest,
        messageId: String,
        withOptions options: ChatThreadOperation.UpdateChatMessageOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<Void>
    ) {
        service
            .update(
                chatMessage: message,
                chatThreadId: threadId,
                chatMessageId: messageId,
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
    ///    - messageId : The message id.
    ///    - options: Delete chat message options
    ///    - completionHandler: A completion handler that receives a status code on success.
    public func delete(
        message messageId: String,
        options: ChatThreadOperation.DeleteChatMessageOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<Void>
    ) {
        service
            .deleteChatMessage(
                chatThreadId: threadId,
                chatMessageId: messageId,
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

    /// Gets a list of messages from a ChatThread.
    /// - Parameters:
    ///    - options: List messages options.
    ///    - completionHandler: A completion handler that receives the list of messages on success.
    public func listMessages(
        withOptions options: ChatThreadOperation.ListChatMessagesOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<PagedCollection<Message>>
    ) {
        service.listChatMessages(chatThreadId: threadId, withOptions: options) { result, httpResponse in
            switch result {
            case .success:
                // TODO: github.com/Azure/azure-sdk-for-ios/issues/644
                // Construct a new PagedCollection of type Message
                do {
                    let messages = try self.createPagedCollection(
                        from: httpResponse?.data,
                        withRequest: httpResponse?.httpRequest,
                        of: Message.self
                    )

                    completionHandler(.success(messages), httpResponse)
                } catch {
                    let azureError = AzureError.client(error.localizedDescription, error)
                    completionHandler(.failure(azureError), httpResponse)
                }

            case let .failure(error):
                completionHandler(.failure(error), httpResponse)
            }
        }
    }

    /// Adds thread participants to a Thread. If the participants already exist, no change occurs.
    /// - Parameters:
    ///    - participants : An array of participants to add.
    ///    - options: Add chat participants options.
    ///    - completionHandler: A completion handler that receives a status code on success.
    public func add(
        participants: [Participant],
        withOptions options: ChatThreadOperation.AddChatParticipantsOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<AddChatParticipantsResult>
    ) {
        do {
            // Convert Participants to ChatParticipants
            let chatParticipants = try convert(participants: participants)

            // Convert to AddChatParticipantsRequest for generated code
            let addParticipantsRequest = AddChatParticipantsRequest(
                participants: chatParticipants
            )

            service
                .add(
                    chatParticipants: addParticipantsRequest,
                    chatThreadId: threadId,
                    withOptions: options
                ) { result, httpResponse in
                    switch result {
                    case let .success(addParticipantsResult):
                        completionHandler(.success(addParticipantsResult), httpResponse)

                    case let .failure(error):
                        completionHandler(.failure(error), httpResponse)
                    }
                }
        } catch {
            // Return error from converting participants
            let azureError = AzureError.client("Failed to construct add participants request.", error)
            completionHandler(.failure(azureError), nil)
        }
    }

    /// Removes a participant from the thread.
    /// - Parameters:
    ///    - participantIdentifier : Identifier of the participant to remove.
    ///    - options: Remove participant options
    ///    - completionHandler: A completion handler that receives a status code on success.
    public func remove(
        participant participantIdentifier: CommunicationIdentifier,
        withOptions options: ChatThreadOperation.RemoveChatParticipantOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<Void>
    ) {
        do {
            // Construct CommunicationIdentifierModel from participantId
            let identifierModel = try IdentifierSerializer
                .serialize(identifier: participantIdentifier)

            service
                .remove(
                    chatParticipant: identifierModel,
                    chatThreadId: threadId,
                    withOptions: options
                ) { result, httpResponse in
                    switch result {
                    case .success:
                        completionHandler(.success(()), httpResponse)

                    case let .failure(error):
                        completionHandler(.failure(error), httpResponse)
                    }
                }
        } catch {
            // Return error from serializing the identifier
            let azureError = AzureError.client("Failed to construct remove participant request.", error)
            completionHandler(.failure(azureError), nil)
        }
    }

    /// Gets the participants of the thread.
    /// - Parameters:
    ///    - options: List chat participants options.
    ///    - completionHandler: A completion handler that receives the list of members on success.
    public func listParticipants(
        withOptions options: ChatThreadOperation.ListChatParticipantsOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<PagedCollection<Participant>>
    ) {
        service.listChatParticipants(chatThreadId: threadId, withOptions: options) { result, httpResponse in
            switch result {
            case .success:
                // TODO: https://github.com/Azure/azure-sdk-for-ios/issues/644
                // Construct a new PagedCollection of type Participant
                do {
                    let participants = try self.createPagedCollection(
                        from: httpResponse?.data,
                        withRequest: httpResponse?.httpRequest,
                        of: Participant.self
                    )

                    completionHandler(.success(participants), httpResponse)
                } catch {
                    let azureError = AzureError.client(error.localizedDescription, error)
                    completionHandler(.failure(azureError), httpResponse)
                }

            case let .failure(error):
                completionHandler(.failure(error), httpResponse)
            }
        }
    }
}
