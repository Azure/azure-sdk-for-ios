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

import AzureCommunicationCommon
import AzureCore
import Foundation

/// ChatThreadClient class for operations within a ChatThread.
// swiftlint:disable:next type_body_length
public class ChatThreadClient {
    // MARK: Properties

    public let threadId: String
    private let endpoint: String
    private let credential: CommunicationTokenCredential
    private let options: AzureCommunicationChatClientOptions
    private let service: ChatThread

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

        // Internal options do not use the CommunicationSignalingErrorHandler
        let internalOptions = AzureCommunicationChatClientOptionsInternal(
            apiVersion: AzureCommunicationChatClientOptionsInternal.ApiVersion(options.apiVersion),
            logger: options.logger,
            telemetryOptions: options.telemetryOptions,
            transportOptions: options.transportOptions,
            dispatchQueue: options.dispatchQueue
        )

        let communicationCredential = TokenCredentialAdapter(credential)
        let authPolicy = BearerTokenCredentialPolicy(credential: communicationCredential, scopes: [])

        let client = try ChatClientInternal(
            endpoint: endpointUrl,
            authPolicy: authPolicy,
            withOptions: internalOptions
        )

        self.service = client.chatThread
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

    /// Converts [ChatParticipant] to [ChatParticipantInternal] for internal use.
    /// - Parameter participants: The array of ChatParticipants.
    /// - Returns: An array of ChatParticipantInternal.
    private func convert(participants: [ChatParticipant]) throws -> [ChatParticipantInternal] {
        return try participants.map { participant -> ChatParticipantInternal in
            let identifierModel = try IdentifierSerializer.serialize(identifier: participant.id)
            return ChatParticipantInternal(
                communicationIdentifier: identifierModel,
                displayName: participant.displayName,
                shareHistoryTime: participant.shareHistoryTime
            )
        }
    }

    // MARK: Public Methods

    /// Get the ChatThreadProperties for the chat thread.
    /// - Parameters:
    ///   - options: Get chat thread options.
    ///   - completionHandler: A completion handler that receives the chat thread properties on success.
    public func getProperties(
        withOptions options: GetChatThreadPropertiesOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<ChatThreadProperties>
    ) {
        service.getChatThreadProperties(chatThreadId: threadId, withOptions: options) { result, httpResponse in
            switch result {
            case let .success(chatThreadProperties):
                do {
                    let thread = try ChatThreadProperties(from: chatThreadProperties)
                    completionHandler(.success(thread), httpResponse)
                } catch {
                    let azureError = AzureError.client(error.localizedDescription, error)
                    completionHandler(.failure(azureError), httpResponse)
                }

            case let .failure(error):
                completionHandler(.failure(error), httpResponse)
            }
        }
    }

    /// Updates the ChatThread's topic.
    /// - Parameters:
    ///   - topic: The topic.
    ///   - options: Update chat thread options.
    ///   - completionHandler: A completion handler that receives a status code on success.
    public func update(
        topic: String,
        withOptions options: UpdateChatThreadPropertiesOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<Void>
    ) {
        let updateChatThreadRequest = UpdateChatThreadRequestInternal(topic: topic)

        service
            .update(
                chatThreadProperties: updateChatThreadRequest,
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
        withOptions options: SendChatReadReceiptOptions? = nil,
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
        withOptions options: ListChatReadReceiptsOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<PagedCollection<ChatMessageReadReceipt>>
    ) {
        service.listChatReadReceipts(chatThreadId: threadId, withOptions: options) { result, httpResponse in
            switch result {
            case .success:
                // TODO: https://github.com/Azure/azure-sdk-for-ios/issues/644
                // Construct a new PagedCollection of type ChatMessageReadReceipt
                do {
                    let readReceipts = try self.createPagedCollection(
                        from: httpResponse?.data,
                        withRequest: httpResponse?.httpRequest,
                        of: ChatMessageReadReceipt.self
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
    ///    - senderDisplayName: Display name for the typing notification.
    ///    - options: Send typing notification options
    ///    - completionHandler: A completion handler that receives a status code on success.
    public func sendTypingNotification(
        from senderDisplayName: String? = nil,
        withOptions options: SendTypingNotificationOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<Void>
    ) {
        // Send the displayName if provided
        var request: SendTypingNotificationRequest?
        if let displayName = senderDisplayName {
            request = SendTypingNotificationRequest(senderDisplayName: displayName)
        }
        service
            .send(typingNotification: request, chatThreadId: threadId, withOptions: options) { result, httpResponse in
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
        withOptions options: SendChatMessageOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<SendChatMessageResult>
    ) {
        service
            .send(chatMessage: message, chatThreadId: threadId, withOptions: options) { result, httpResponse in
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
        withOptions options: GetChatMessageOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<ChatMessage>
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
                        let message = try ChatMessage(from: chatMessage)
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
    ///    - message: The message id.
    ///    - parameters: The UpdateChatMessageRequest.
    ///    - options: Update chat message options
    ///    - completionHandler: A completion handler that receives a status code on success.
    public func update(
        message messageId: String,
        parameters: UpdateChatMessageRequest,
        withOptions options: UpdateChatMessageOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<Void>
    ) {
        service
            .update(
                chatMessage: parameters,
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
        options: DeleteChatMessageOptions? = nil,
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
        withOptions options: ListChatMessagesOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<PagedCollection<ChatMessage>>
    ) {
        service.listChatMessages(chatThreadId: threadId, withOptions: options) { result, httpResponse in
            switch result {
            case .success:
                // TODO: github.com/Azure/azure-sdk-for-ios/issues/644
                // Construct a new PagedCollection of type ChatMessage
                do {
                    let messages = try self.createPagedCollection(
                        from: httpResponse?.data,
                        withRequest: httpResponse?.httpRequest,
                        of: ChatMessage.self
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

    /// Adds participants to a ChatThread. If the participants already exist, no change occurs.
    /// - Parameters:
    ///    - participants : An array of chat participants to add.
    ///    - options: Add chat participants options.
    ///    - completionHandler: A completion handler that receives a status code on success.
    public func add(
        participants: [ChatParticipant],
        withOptions options: AddChatParticipantsOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<AddChatParticipantsResult>
    ) {
        // Convert to ChatParticipantInternal for request
        let participantsInternal: [ChatParticipantInternal]
        do {
            participantsInternal = try convert(participants: participants)
        } catch {
            completionHandler(
                .failure(AzureError.client("Failed to convert participants to ChatParticipantInternal")),
                nil
            )
            return
        }

        // Convert to AddChatParticipantsRequest for generated code
        let addParticipantsRequest = AddChatParticipantsRequestInternal(
            participants: participantsInternal
        )

        service.add(
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
    }

    /// Removes a participant from the thread.
    /// - Parameters:
    ///    - participantIdentifier : Identifier of the participant to remove.
    ///    - options: Remove participant options
    ///    - completionHandler: A completion handler that receives a status code on success.
    public func remove(
        participant participantIdentifier: CommunicationIdentifier,
        withOptions options: RemoveChatParticipantOptions? = nil,
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
        withOptions options: ListChatParticipantsOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<PagedCollection<ChatParticipant>>
    ) {
        service.listChatParticipants(chatThreadId: threadId, withOptions: options) { result, httpResponse in
            switch result {
            case .success:
                // TODO: https://github.com/Azure/azure-sdk-for-ios/issues/644
                // Construct a new PagedCollection of type ChatParticipant
                do {
                    let participants = try self.createPagedCollection(
                        from: httpResponse?.data,
                        withRequest: httpResponse?.httpRequest,
                        of: ChatParticipant.self
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
