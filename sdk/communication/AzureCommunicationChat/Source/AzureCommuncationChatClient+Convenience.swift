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

import AzureCore
import Foundation

extension AzureCommunicationChatClient {
    /// Gets read receipts for a thread.
    /// - Parameters:
    ///    - chatThreadId : Thread id to get the read receipts for.
    ///    - options: A list of options for the operation
    ///    - completionHandler: A completion handler that receives a status code on
    ///     success.
    public func listChatReadReceipts(
        chatThreadId: String,
        withOptions options: AzureCommunicationChatService.ListChatReadReceiptsOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<PagedCollection<ChatMessageReadReceipt>>
    ) {
        return azureCommunicationChatService.listChatReadReceipts(
            chatThreadId: chatThreadId,
            withOptions: options,
            completionHandler: completionHandler
        )
    }

    /// Sends a read receipt event to a thread, on behalf of a user.
    /// - Parameters:
    ///    - chatReadReceipt : Read receipt details.
    ///    - chatThreadId : Thread id to send the read receipt event to.
    ///    - options: A list of options for the operation
    ///    - completionHandler: A completion handler that receives a status code on
    ///     success.
    public func send(
        chatReadReceipt: SendReadReceiptRequest,
        chatThreadId: String,
        withOptions options: AzureCommunicationChatService.SendChatReadReceiptOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<Void>
    ) {
        return azureCommunicationChatService.send(
            chatReadReceipt: chatReadReceipt,
            chatThreadId: chatThreadId,
            withOptions: options,
            completionHandler: completionHandler
        )
    }

    /// Sends a message to a thread.
    /// - Parameters:
    ///    - chatMessage : Details of the message to send.
    ///    - chatThreadId : The thread id to send the message to.
    ///    - options: A list of options for the operation
    ///    - completionHandler: A completion handler that receives a status code on
    ///     success.
    public func send(
        chatMessage: SendChatMessageRequest,
        chatThreadId: String,
        withOptions options: AzureCommunicationChatService.SendChatMessageOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<SendChatMessageResult>
    ) {
        return azureCommunicationChatService.send(
            chatMessage: chatMessage,
            chatThreadId: chatThreadId,
            withOptions: options,
            completionHandler: completionHandler
        )
    }

    /// Gets a list of messages from a thread.
    /// - Parameters:
    ///    - chatThreadId : The thread id of the message.
    ///    - options: A list of options for the operation
    ///    - completionHandler: A completion handler that receives a status code on
    ///     success.
    public func listChatMessages(
        chatThreadId: String,
        withOptions options: AzureCommunicationChatService.ListChatMessagesOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<PagedCollection<ChatMessage>>
    ) {
        return azureCommunicationChatService.listChatMessages(
            chatThreadId: chatThreadId,
            withOptions: options,
            completionHandler: completionHandler
        )
    }

    /// Gets a message by id.
    /// - Parameters:
    ///    - chatThreadId : The thread id to which the message was sent.
    ///    - chatMessageId : The message id.
    ///    - options: A list of options for the operation
    ///    - completionHandler: A completion handler that receives a status code on
    ///     success.
    public func getChatMessage(
        chatThreadId: String,
        chatMessageId: String,
        withOptions options: AzureCommunicationChatService.GetChatMessageOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<ChatMessage>
    ) {
        return azureCommunicationChatService.getChatMessage(
            chatThreadId: chatThreadId,
            chatMessageId: chatMessageId,
            withOptions: options,
            completionHandler: completionHandler
        )
    }

    /// Updates a message.
    /// - Parameters:
    ///    - chatMessage : Details of the request to update the message.
    ///    - chatThreadId : The thread id to which the message was sent.
    ///    - chatMessageId : The message id.
    ///    - options: A list of options for the operation
    ///    - completionHandler: A completion handler that receives a status code on
    ///     success.
    public func update(
        chatMessage: UpdateChatMessageRequest,
        chatThreadId: String,
        chatMessageId: String,
        withOptions options: AzureCommunicationChatService.UpdateChatMessageOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<Void>
    ) {
        return azureCommunicationChatService.update(
            chatMessage: chatMessage,
            chatThreadId: chatThreadId,
            chatMessageId: chatMessageId,
            withOptions: options,
            completionHandler: completionHandler
        )
    }

    /// Deletes a message.
    /// - Parameters:
    ///    - chatThreadId : The thread id to which the message was sent.
    ///    - chatMessageId : The message id.
    ///    - options: A list of options for the operation
    ///    - completionHandler: A completion handler that receives a status code on
    ///     success.
    public func deleteChatMessage(
        chatThreadId: String,
        chatMessageId: String,
        withOptions options: AzureCommunicationChatService.DeleteChatMessageOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<Void>
    ) {
        return azureCommunicationChatService.deleteChatMessage(
            chatThreadId: chatThreadId,
            chatMessageId: chatMessageId,
            withOptions: options,
            completionHandler: completionHandler
        )
    }

    /// Posts a typing event to a thread, on behalf of a user.
    /// - Parameters:
    ///    - chatThreadId : Id of the thread.
    ///    - options: A list of options for the operation
    ///    - completionHandler: A completion handler that receives a status code on
    ///     success.
    public func sendTypingNotification(
        chatThreadId: String,
        withOptions options: AzureCommunicationChatService.SendTypingNotificationOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<Void>
    ) {
        return azureCommunicationChatService.sendTypingNotification(
            chatThreadId: chatThreadId,
            withOptions: options,
            completionHandler: completionHandler
        )
    }

    /// Gets the participants of a thread.
    /// - Parameters:
    ///    - chatThreadId : Thread id to get participants for.
    ///    - options: A list of options for the operation
    ///    - completionHandler: A completion handler that receives a status code on
    ///     success.
    public func listChatParticipants(
        chatThreadId: String,
        withOptions options: AzureCommunicationChatService.ListChatParticipantsOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<PagedCollection<ChatParticipant>>
    ) {
        return azureCommunicationChatService.listChatThreadMembers(
            chatThreadId: chatThreadId,
            withOptions: options,
            completionHandler: completionHandler
        )
    }

    /// Adds thread participants to a thread. If participants already exist, no change occurs.
    /// - Parameters:
    ///    - chatParticipants : Thread participants to be added to the thread.
    ///    - chatThreadId : Id of the thread to add participants to.
    ///    - options: A list of options for the operation
    ///    - completionHandler: A completion handler that receives a status code on
    ///     success.
    public func add(
        chatParticipants: AddChatParticipantsRequest,
        chatThreadId: String,
        withOptions options: AzureCommunicationChatService.AddChatParticipantsOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<Void>
    ) {
        return azureCommunicationChatService.add(
            chatThreadMembers: chatThreadMembers,
            chatThreadId: chatThreadId,
            withOptions: options,
            completionHandler: completionHandler
        )
    }

    /// Remove a participant from a thread.
    /// - Parameters:
    ///    - chatThreadId : Thread id to remove the participant from.
    ///    - chatParticipantId : Id of the thread participant to remove from the thread.
    ///    - options: A list of options for the operation
    ///    - completionHandler: A completion handler that receives a status code on
    ///     success.
    public func removeChatParticipant(
        chatThreadId: String,
        chatParticipantId: String,
        withOptions options: AzureCommunicationChatService.RemoveChatParticipantOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<Void>
    ) {
        return azureCommunicationChatService.removeChatThreadMember(
            chatThreadId: chatThreadId,
            chatMemberId: chatMemberId,
            withOptions: options,
            completionHandler: completionHandler
        )
    }

    /// Creates a chat thread.
    /// - Parameters:
    ///    - chatThread : Request payload for creating a chat thread.
    ///    - options: A list of options for the operation
    ///    - completionHandler: A completion handler that receives a status code on
    ///     success.
    public func create(
        chatThread: CreateChatThreadRequest,
        withOptions options: AzureCommunicationChatService.CreateChatThreadOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<ChatThread>
    ) {
        return azureCommunicationChatService.create(
            chatThread: chatThread,
            withOptions: options,
            completionHandler: completionHandler
        )
    }

    /// Gets the list of chat threads of a user.
    /// - Parameters:

    ///    - options: A list of options for the operation
    ///    - completionHandler: A completion handler that receives a status code on
    ///     success.
    public func listChatThreads(
        withOptions options: AzureCommunicationChatService.ListChatThreadsOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<PagedCollection<ChatThreadInfo>>
    ) {
        return azureCommunicationChatService.listChatThreads(withOptions: options, completionHandler: completionHandler)
    }

    /// Updates a thread's properties.
    /// - Parameters:
    ///    - chatThread : Request payload for updating a chat thread.
    ///    - chatThreadId : The id of the thread to update.
    ///    - options: A list of options for the operation
    ///    - completionHandler: A completion handler that receives a status code on
    ///     success.
    public func update(
        chatThread: UpdateChatThreadRequest,
        chatThreadId: String,
        withOptions options: AzureCommunicationChatService.UpdateChatThreadOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<Void>
    ) {
        return azureCommunicationChatService.update(
            chatThread: chatThread,
            chatThreadId: chatThreadId,
            withOptions: options,
            completionHandler: completionHandler
        )
    }

    /// Gets a chat thread.
    /// - Parameters:
    ///    - chatThreadId : Thread id to get.
    ///    - options: A list of options for the operation
    ///    - completionHandler: A completion handler that receives a status code on
    ///     success.
    public func getChatThread(
        chatThreadId: String,
        withOptions options: AzureCommunicationChatService.GetChatThreadOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<ChatThread>
    ) {
        return azureCommunicationChatService.getChatThread(
            chatThreadId: chatThreadId,
            withOptions: options,
            completionHandler: completionHandler
        )
    }

    /// Deletes a thread.
    /// - Parameters:
    ///    - chatThreadId : Thread id to delete.
    ///    - options: A list of options for the operation
    ///    - completionHandler: A completion handler that receives a status code on
    ///     success.
    public func deleteChatThread(
        chatThreadId: String,
        withOptions options: AzureCommunicationChatService.DeleteChatThreadOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<Void>
    ) {
        return azureCommunicationChatService.deleteChatThread(
            chatThreadId: chatThreadId,
            withOptions: options,
            completionHandler: completionHandler
        )
    }
}
