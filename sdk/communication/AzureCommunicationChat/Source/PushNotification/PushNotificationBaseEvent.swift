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

// swiftlint:disable file_length
/// BaseChatMessageEvent for push notifications.
public class PushNotificationChatMessageEvent {
    // MARK: Properties

    /// The id of the message. This id is server generated.
    public var messageId: String
    /// The message type.
    public var type: ChatMessageType
    /// Chat thread id.
    public var threadId: String
    /// Sender Id
    public var sender: CommunicationIdentifier
    /// Recipient Id
    public var recipient: CommunicationIdentifier
    /// Sender display name.
    public var senderDisplayName: String?
    /// The timestamp when the message arrived at the server. The timestamp is in RFC3339 format:
    /// `yyyy-MM-ddTHH:mm:ssZ`.
    public var originalArrivalTime: Iso8601Date?
    /// Version of the message.
    public var version: String

    // MARK: Initializers

    /// Initialize a BaseChatMessageEvent.
    /// - Parameters:
    ///   - messageId: Message id.
    ///   - type: Message type.
    ///   - threadId: Chat thread id.
    ///   - senderId: Sender id
    ///   - recipientId: Recipient id.
    ///   - senderDisplayName: Sender display name.
    ///   - originalArrivalTime: Time that the message was created.
    ///   - version: Message version.
    init(
        messageId: String,
        type: ChatMessageType,
        threadId: String,
        sender: CommunicationIdentifier,
        recipient: CommunicationIdentifier,
        senderDisplayName: String? = nil,
        originalArrivalTime: Iso8601Date? = nil,
        version: String
    ) {
        self.messageId = messageId
        self.type = type
        self.threadId = threadId
        self.sender = sender
        self.recipient = recipient
        self.senderDisplayName = senderDisplayName
        self.originalArrivalTime = originalArrivalTime
        self.version = version
    }
}

/// ChatMessageReceivedEvent for push notifications.
public class PushNotificationChatMessageReceivedEvent: PushNotificationChatMessageEvent {
    // MARK: Properties

    /// The content of the message.
    public var message: String

    /// The message metadata.
    public var metadata: [String: String?]?

    // MARK: Initializers

    /// Initialize a ChatMessageReceivedEvent from Data.
    /// - Parameter data: The payload data.
    init(from data: Data) throws {
        let pushNotificationMessageReceivedPayload: PushNotificationMessageReceivedPayload = try JSONDecoder()
            .decode(PushNotificationMessageReceivedPayload.self, from: data)

        self.message = pushNotificationMessageReceivedPayload.messageBody

        if pushNotificationMessageReceivedPayload.acsChatMessageMetadata != "null" {
            if let acsChatMetadata = pushNotificationMessageReceivedPayload.acsChatMessageMetadata.data(using: .utf8) {
                self.metadata = try JSONDecoder().decode([String: String?].self, from: acsChatMetadata)
            }
        }

        super.init(
            messageId: pushNotificationMessageReceivedPayload.messageId,
            type: ChatMessageType(pushNotificationMessageReceivedPayload.messageType),
            threadId: pushNotificationMessageReceivedPayload.groupId,
            sender: createCommunicationIdentifier(fromRawId: pushNotificationMessageReceivedPayload.senderId),
            recipient: createCommunicationIdentifier(fromRawId: pushNotificationMessageReceivedPayload.recipientId),
            senderDisplayName: pushNotificationMessageReceivedPayload.senderDisplayName,
            originalArrivalTime: Iso8601Date(string: pushNotificationMessageReceivedPayload.originalArrivalTime),
            version: pushNotificationMessageReceivedPayload.version
        )
    }
}
