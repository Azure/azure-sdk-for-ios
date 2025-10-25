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
import Trouter

/// Chat Participant for real-time notification events.
public struct SignalingChatParticipant {
    // MARK: Properties

    /// The  identifier of the participant.
    public let id: CommunicationIdentifier?
    /// Display name for the participant.
    public let displayName: String?
    /// Time from which the chat history is shared with the participant. The timestamp is in RFC3339 format:
    /// `yyyy-MM-ddTHH:mm:ssZ`.
    public let shareHistoryTime: Iso8601Date?

    // MARK: Initializers

    /// Initialize a SignalingChatParticipant
    /// - Parameters:
    ///   - id: The  identifier of the participant.
    ///   - displayName: Display name for the participant.
    ///   - shareHistoryTime: Time from which the chat history is shared with the participant. The timestamp is in
    /// RFC3339 format: `yyyy-MM-ddTHH:mm:ssZ`.
    init(id: CommunicationIdentifier?, displayName: String? = nil, shareHistoryTime: Iso8601Date? = nil) {
        self.id = id
        self.displayName = displayName
        self.shareHistoryTime = shareHistoryTime
    }
}

/// ChatThreadProperties for real-time notification events.
public struct SignalingChatThreadProperties {
    // MARK: Properties

    /// Thread topic.
    public let topic: String

    // MARK: Initializers

    /// Initialize a SignalingChatThreadProperties
    /// - Parameter topic: Thread topic.
    init(topic: String) {
        self.topic = topic
    }
}

/// BaseChatEvent for real-time notifications.
public class BaseChatEvent {
    // MARK: Properties

    /// Chat thread id.
    public var threadId: String
    /// Sender identifier.
    public var sender: CommunicationIdentifier?
    /// Recipient identifier.
    public var recipient: CommunicationIdentifier?

    // MARK: Initializers

    /// Initialize a BaseChatEvent
    /// - Parameters:
    ///   - threadId: ChatThread id.
    ///   - sender: Sender identifier.
    ///   - recipient: Recipient identifier.
    init(
        threadId: String,
        sender: CommunicationIdentifier?,
        recipient: CommunicationIdentifier?
    ) {
        self.threadId = threadId
        self.sender = sender
        self.recipient = recipient
    }
}

/// BaseChatThreadEvent for real-time notifications.
public class BaseChatThreadEvent {
    // MARK: Properties

    /// Chat thread id.
    public var threadId: String
    /// Version of the thread.
    public var version: String

    // MARK: Initializers

    /// Initialize a BaseChatThreadEvent
    /// - Parameters:
    ///   - threadId: ChatThread id.
    ///   - version: Version of the thread.
    init(threadId: String, version: String) {
        self.threadId = threadId
        self.version = version
    }
}

/// BaseChatMessageEvent for real-time notifications.
public class BaseChatMessageEvent: BaseChatEvent {
    // MARK: Properties

    /// The id of the message. This id is server generated.
    public var id: String
    /// The timestamp when the message arrived at the server. The timestamp is in RFC3339 format:
    /// `yyyy-MM-ddTHH:mm:ssZ`.
    public var createdOn: Iso8601Date?
    /// Version of the message.
    public var version: String
    /// The message type.
    public var type: ChatMessageType
    /// Sender display name.
    public var senderDisplayName: String?

    // MARK: Initializers

    /// Initialize a BaseChatMessageEvent.
    /// - Parameters:
    ///   - threadId: Chat thread id.
    ///   - sender: Sender identifier.
    ///   - recipient: Recipient identifier.
    ///   - id: Message id.
    ///   - senderDisplayName: Sender display name.
    ///   - createdOn: Time that the message was created.
    ///   - version: Message version.
    ///   - type: Message type.
    init(
        threadId: String,
        sender: CommunicationIdentifier?,
        recipient: CommunicationIdentifier?,
        id: String,
        senderDisplayName: String? = nil,
        createdOn: Iso8601Date? = nil,
        version: String,
        type: ChatMessageType
    ) {
        self.id = id
        self.createdOn = createdOn
        self.version = version
        self.type = type
        self.senderDisplayName = senderDisplayName
        super.init(threadId: threadId, sender: sender, recipient: recipient)
    }
}

/// ChatMessageReceivedEvent for real-time notifications.
public class ChatMessageReceivedEvent: BaseChatMessageEvent {
    // MARK: Properties

    /// The content of the message.
    public var message: String

    /// The message metadata.
    public var metadata: [String: String?]?

    // MARK: Initializers

    /// Initialize a ChatMessageReceivedEvent.
    /// - Parameters:
    ///   - threadId: Chat thread id.
    ///   - sender: Sender identifier.
    ///   - recipient: Recipient identifier.
    ///   - id: Message id.
    ///   - senderDisplayName: Sender display name.
    ///   - createdOn: Time that the message was created.
    ///   - version: Message version.
    ///   - type: Message type.
    ///   - message: Message content.
    init(
        threadId: String,
        sender: CommunicationIdentifier?,
        recipient: CommunicationIdentifier?,
        id: String,
        senderDisplayName: String? = nil,
        createdOn: Iso8601Date?,
        version: String,
        type: ChatMessageType,
        message: String,
        metadata: [String: String?]? = nil
    ) {
        self.message = message
        self.metadata = metadata
        super.init(
            threadId: threadId,
            sender: sender,
            recipient: recipient,
            id: id,
            senderDisplayName: senderDisplayName,
            createdOn: createdOn,
            version: version,
            type: type
        )
    }

    /// Initialize a ChatMessageReceivedEvent from a TrouterRequest
    /// - Parameter request: The TrouterRequest.
    init(from request: TrouterRequest) throws {
        guard let requestJsonData = request.body.data(using: .utf8) else {
            throw AzureError.client("Unable to convert request body to Data.")
        }

        let messageReceivedPayload: MessageReceivedPayload = try JSONDecoder()
            .decode(MessageReceivedPayload.self, from: requestJsonData)

        self.message = messageReceivedPayload.messageBody

        if messageReceivedPayload.acsChatMessageMetadata != "null" {
            if let acsChatMetadata = messageReceivedPayload.acsChatMessageMetadata.data(using: .utf8) {
                self.metadata = try JSONDecoder().decode([String: String?].self, from: acsChatMetadata)
            }
        }

        super.init(
            threadId: messageReceivedPayload.groupId,
            sender: createCommunicationIdentifier(fromRawId: messageReceivedPayload.senderId),
            recipient: createCommunicationIdentifier(fromRawId: messageReceivedPayload.recipientMri),
            id: messageReceivedPayload.messageId,
            senderDisplayName: messageReceivedPayload.senderDisplayName,
            createdOn: Iso8601Date(string: messageReceivedPayload.originalArrivalTime),
            version: messageReceivedPayload.version,
            type: ChatMessageType(messageReceivedPayload.messageType)
        )
    }
}

/// ChatMessageEditedEvent for real-time notifications.
public class ChatMessageEditedEvent: BaseChatMessageEvent {
    // MARK: Properties

    /// The message content.
    public var message: String
    /// The timestamp when the message was edited. The timestamp is in RFC3339 format: `yyyy-MM-ddTHH:mm:ssZ`.
    public var editedOn: Iso8601Date?
    /// The message metadata
    public var metadata: [String: String?]?

    // MARK: Initializers

    /// Initialize a ChatMessageEditedEvent.
    /// - Parameters:
    ///   - threadId: Chat thread id.
    ///   - sender: Sender identifier.
    ///   - recipient: Recipient identifier.
    ///   - id: Message id.
    ///   - senderDisplayName: Sender display name.
    ///   - createdOn: Created on timestamp.
    ///   - version: Message version.
    ///   - type: Message type.
    ///   - message: Message content.
    ///   - editedOn: Time that the message was edited.
    init(
        threadId: String,
        sender: CommunicationIdentifier?,
        recipient: CommunicationIdentifier?,
        id: String,
        senderDisplayName: String? = nil,
        createdOn: Iso8601Date?,
        version: String,
        type: ChatMessageType,
        message: String,
        editedOn: Iso8601Date?,
        metadata: [String: String?]? = nil
    ) {
        self.message = message
        self.editedOn = editedOn
        self.metadata = metadata
        super.init(
            threadId: threadId,
            sender: sender,
            recipient: recipient,
            id: id,
            senderDisplayName: senderDisplayName,
            createdOn: createdOn,
            version: version,
            type: type
        )
    }

    /// Initialize a ChatMessageEditedEvent from a TrouterRequest.
    /// - Parameter request: The TrouterRequest.
    init(from request: TrouterRequest) throws {
        guard let requestJsonData = request.body.data(using: .utf8) else {
            throw AzureError.client("Unable to convert request body to Data.")
        }

        let chatMessageEditedPayload: MessageEditedPayload = try JSONDecoder()
            .decode(MessageEditedPayload.self, from: requestJsonData)

        self.message = chatMessageEditedPayload.messageBody
        self.editedOn = Iso8601Date(string: chatMessageEditedPayload.edittime)

        if chatMessageEditedPayload.acsChatMessageMetadata != "null" {
            if let acsChatMetadata = chatMessageEditedPayload.acsChatMessageMetadata.data(using: .utf8) {
                self.metadata = try JSONDecoder().decode([String: String?].self, from: acsChatMetadata)
            }
        }

        super.init(
            threadId: chatMessageEditedPayload.groupId,
            sender: createCommunicationIdentifier(fromRawId: chatMessageEditedPayload.senderId),
            recipient: createCommunicationIdentifier(fromRawId: chatMessageEditedPayload.recipientMri),
            id: chatMessageEditedPayload.messageId,
            senderDisplayName: chatMessageEditedPayload.senderDisplayName,
            createdOn: Iso8601Date(string: chatMessageEditedPayload.originalArrivalTime),
            version: chatMessageEditedPayload.version,
            type: ChatMessageType(chatMessageEditedPayload.messageType)
        )
    }
}

/// ChatMessageDeletedEvent for real-time notifications.
public class ChatMessageDeletedEvent: BaseChatMessageEvent {
    // MARK: Properties

    /// The timestamp when the message was deleted. The timestamp is in RFC3339 format: `yyyy-MM-ddTHH:mm:ssZ`.
    public var deletedOn: Iso8601Date?

    // MARK: Initializers

    /// Initialize a ChatMessageDeletedEvent.
    /// - Parameters:
    ///   - threadId: Chat thread id.
    ///   - sender: Sender identifier.
    ///   - recipient: Recipient identifier.
    ///   - id: Message id.
    ///   - senderDisplayName: Sender display name.
    ///   - createdOn: Time that the message was created.
    ///   - version: Message version.
    ///   - type: Message type.
    ///   - deletedOn: Time that the message was deleted on.
    init(
        threadId: String,
        sender: CommunicationIdentifier?,
        recipient: CommunicationIdentifier?,
        id: String,
        senderDisplayName: String? = nil,
        createdOn: Iso8601Date?,
        version: String,
        type: ChatMessageType,
        deletedOn: Iso8601Date?
    ) {
        self.deletedOn = deletedOn
        super.init(
            threadId: threadId,
            sender: sender,
            recipient: recipient,
            id: id,
            senderDisplayName: senderDisplayName,
            createdOn: createdOn,
            version: version,
            type: type
        )
    }

    /// Initialize a ChatMessageDeletedEvent from a TrouterRequest.
    /// - Parameter request: The TrouterRequest.
    init(from request: TrouterRequest) throws {
        guard let requestJsonData = request.body.data(using: .utf8) else {
            throw AzureError.client("Unable to convert request body to Data.")
        }

        let chatMessageDeletedPayload: MessageDeletedPayload = try JSONDecoder()
            .decode(MessageDeletedPayload.self, from: requestJsonData)

        self.deletedOn = Iso8601Date(string: chatMessageDeletedPayload.deletetime)
        super.init(
            threadId: chatMessageDeletedPayload.groupId,
            sender: createCommunicationIdentifier(fromRawId: chatMessageDeletedPayload.senderId),
            recipient: createCommunicationIdentifier(fromRawId: chatMessageDeletedPayload.recipientMri),
            id: chatMessageDeletedPayload.messageId,
            senderDisplayName: chatMessageDeletedPayload.senderDisplayName,
            createdOn: Iso8601Date(string: chatMessageDeletedPayload.originalArrivalTime),
            version: chatMessageDeletedPayload.version,
            type: ChatMessageType(chatMessageDeletedPayload.messageType)
        )
    }
}

/// TypingIndicatorReceivedEvent for real-time notifications.
public class TypingIndicatorReceivedEvent: BaseChatEvent {
    // MARK: Properties

    // TODO:
    public var version: String

    /// The timestamp when the indicator was received. The timestamp is in RFC3339 format: `yyyy-MM-ddTHH:mm:ssZ`.
    public var receivedOn: Iso8601Date?

    /// The sender displayName.
    public var senderDisplayName: String?

    // MARK: Initializers

    /// Initialize a TypingIndicatorReceivedEvent.
    /// - Parameters:
    ///   - threadId: Chat thread id.
    ///   - sender: Sender identifier.
    ///   - recipient: Recipient identifier.
    ///   - version: Version.
    ///   - receivedOn: Time that the indicator was received.
    init(
        threadId: String,
        sender: CommunicationIdentifier?,
        recipient: CommunicationIdentifier?,
        version: String,
        receivedOn: Iso8601Date?,
        senderDisplayName: String? = nil
    ) {
        self.version = version
        self.receivedOn = receivedOn
        self.senderDisplayName = senderDisplayName
        super.init(threadId: threadId, sender: sender, recipient: recipient)
    }

    /// Initialize a TypingIndicatorReceivedEvent from a TrouterRequest.
    /// - Parameter request: The TrouterRequest.
    init(from request: TrouterRequest) throws {
        guard let requestJsonData = request.body.data(using: .utf8) else {
            throw AzureError.client("Unable to convert request body to Data.")
        }

        let typingIndicatorReceivedPayload: TypingIndicatorReceivedPayload = try JSONDecoder()
            .decode(TypingIndicatorReceivedPayload.self, from: requestJsonData)

        self.version = typingIndicatorReceivedPayload.version
        self.receivedOn = Iso8601Date(string: typingIndicatorReceivedPayload.originalArrivalTime)
        self.senderDisplayName = typingIndicatorReceivedPayload.senderDisplayName
        super.init(
            threadId: typingIndicatorReceivedPayload.groupId,
            sender: createCommunicationIdentifier(fromRawId: typingIndicatorReceivedPayload.senderId),
            recipient: createCommunicationIdentifier(fromRawId: typingIndicatorReceivedPayload.recipientMri)
        )
    }
}

/// ReadReceiptReceivedEvent for real-time notifications.
public class ReadReceiptReceivedEvent: BaseChatEvent {
    // MARK: Properties

    /// Id of the chat message that has been read. This id is generated by the server.
    public var chatMessageId: String
    /// The time at which the message was read. The timestamp is in RFC3339 format: `yyyy-MM-ddTHH:mm:ssZ`.
    public var readOn: Iso8601Date?

    // MARK: Initializers

    /// Initialize a ReadReceiptReceivedEvent.
    /// - Parameters:
    ///   - threadId: Chat thread id,
    ///   - sender: Sender identifier.
    ///   - recipient: Recipient identifier.
    ///   - chatMessageId: Id of the message that was read.
    ///   - readOn: Time that the message was read.
    init(
        threadId: String,
        sender: CommunicationIdentifier?,
        recipient: CommunicationIdentifier?,
        chatMessageId: String,
        readOn: Iso8601Date?
    ) {
        self.chatMessageId = chatMessageId
        self.readOn = readOn
        super.init(threadId: threadId, sender: sender, recipient: recipient)
    }

    /// Initialize a ReadReceiptReceivedEvent from a TrouterRequest.
    /// - Parameter request: The TrouterRequest.
    init(from request: TrouterRequest) throws {
        guard let requestJsonData = request.body.data(using: .utf8) else {
            throw AzureError.client("Unable to convert request body to Data.")
        }

        let readReceiptReceivedPayload: ReadReceiptReceivedPayload = try JSONDecoder()
            .decode(ReadReceiptReceivedPayload.self, from: requestJsonData)

        guard let readReceiptMessageBodyJsonData = readReceiptReceivedPayload.messageBody.data(using: .utf8) else {
            throw AzureError.client("Unable to convert payload messageBody to Data.")
        }

        let readReceiptMessageBody: ReadReceiptMessageBody = try JSONDecoder()
            .decode(ReadReceiptMessageBody.self, from: readReceiptMessageBodyJsonData)

        // Extract readOn value from consumptionHorizon
        let consumptionHorizon = readReceiptMessageBody.consumptionhorizon.split(separator: ";")
        guard let readOnMs = Double(consumptionHorizon[1]) else {
            throw AzureError.client("Failed to construct Int from consumptionHorizon for readOn property.")
        }

        // In the payload readOn is represented as epoch time in milliseconds
        let readOnSeconds = readOnMs / 1000
        let readOnDate = Date(timeIntervalSince1970: TimeInterval(readOnSeconds))

        self.chatMessageId = readReceiptReceivedPayload.messageId
        self.readOn = Iso8601Date(readOnDate)
        super.init(
            threadId: readReceiptReceivedPayload.groupId,
            sender: createCommunicationIdentifier(fromRawId: readReceiptReceivedPayload.senderId),
            recipient: createCommunicationIdentifier(fromRawId: readReceiptReceivedPayload.recipientMri)
        )
    }
}

/// ChatThreadCreatedEvent for real-time notifications.
public class ChatThreadCreatedEvent: BaseChatThreadEvent {
    // MARK: Properties

    /// The timestamp when the thread was created. The timestamp is in RFC3339 format: `yyyy-MM-ddTHH:mm:ssZ`.
    public var createdOn: Iso8601Date?

    /// ChatThread properties, contains the thread topic.
    public var properties: SignalingChatThreadProperties?

    /// List of participants currently in the thread.
    public var participants: [SignalingChatParticipant]?

    /// The participant that created the thread.
    public var createdBy: SignalingChatParticipant?

    // MARK: Initializers

    /// Initialize a ChatThreadCreatedEvent.
    /// - Parameters:
    ///   - threadId: Chat thread id,
    ///   - version: Chat thread version.
    ///   - createdOn: Time that the chat thread was created.
    ///   - properties: Properties of the chat thread.
    ///   - participants: Participants in the thread.
    ///   - createdBy: Participant that created the thread.
    init(
        threadId: String,
        version: String,
        createdOn: Iso8601Date?,
        properties: SignalingChatThreadProperties?,
        participants: [SignalingChatParticipant]?,
        createdBy: SignalingChatParticipant?
    ) {
        self.createdOn = createdOn
        self.properties = properties
        self.participants = participants
        self.createdBy = createdBy
        super.init(threadId: threadId, version: version)
    }

    /// Initialize a ChatThreadCreatedEvent from a TrouterRequest.
    /// - Parameter request: The TrouterRequest.
    init(from request: TrouterRequest) throws {
        guard let requestJsonData = request.body.data(using: .utf8) else {
            throw AzureError.client("Unable to convert request body to Data.")
        }

        let chatThreadCreatedPayload: ChatThreadCreatedPayload = try JSONDecoder()
            .decode(ChatThreadCreatedPayload.self, from: requestJsonData)

        guard let createdByJsonData = chatThreadCreatedPayload.createdBy.data(using: .utf8) else {
            throw AzureError.client("Unable to convert payload createdBy to Data.")
        }

        let createdByPayload: ChatParticipantPayload = try JSONDecoder()
            .decode(ChatParticipantPayload.self, from: createdByJsonData)
        let createdBy =
            SignalingChatParticipant(
                id: createCommunicationIdentifier(fromRawId: createdByPayload.participantId),
                displayName: createdByPayload.displayName
            )

        guard let membersJsonData = chatThreadCreatedPayload.members.data(using: .utf8) else {
            throw AzureError.client("Unable to convert payload members to Data.")
        }

        let membersPayload: [ChatParticipantPayload] = try JSONDecoder()
            .decode([ChatParticipantPayload].self, from: membersJsonData)
        let participants: [SignalingChatParticipant] = membersPayload
            .map { (memberPayload: ChatParticipantPayload) -> SignalingChatParticipant in
                SignalingChatParticipant(
                    id: createCommunicationIdentifier(fromRawId: memberPayload.participantId),
                    displayName: memberPayload.displayName
                )
            }

        guard let propertiesJsonData = chatThreadCreatedPayload.properties.data(using: .utf8) else {
            throw AzureError.client("Unable to convert payload properties to Data.")
        }

        let propertiesPayload: ChatThreadPropertiesPayload = try JSONDecoder()
            .decode(ChatThreadPropertiesPayload.self, from: propertiesJsonData)
        let properties = SignalingChatThreadProperties(topic: propertiesPayload.topic)

        self.createdOn = Iso8601Date(string: chatThreadCreatedPayload.createTime)
        self.properties = properties
        self.participants = participants
        self.createdBy = createdBy
        super.init(
            threadId: chatThreadCreatedPayload.threadId,
            version: chatThreadCreatedPayload.version
        )
    }
}

/// ChatThreadPropertiesUpdatedEvent for real-time notifications.
public class ChatThreadPropertiesUpdatedEvent: BaseChatThreadEvent {
    // MARK: Properties

    /// The chat thread properties, includes the thread topic.
    public var properties: SignalingChatThreadProperties?
    /// The timestamp when the thread was updated. The timestamp is in RFC3339 format: `yyyy-MM-ddTHH:mm:ssZ`.
    public var updatedOn: Iso8601Date?
    /// The participant that updated the thread.
    public var updatedBy: SignalingChatParticipant?

    // MARK: Initializers

    /// Initialize a ChatThreadPropertiesUpdatedEvent.
    /// - Parameters:
    ///   - threadId: Chat thread id.
    ///   - version: Chat thread version.
    ///   - properties: Chat thread properties, contains the thread topic.
    ///   - updatedOn: Time that the thread was updated.
    ///   - updatedBy: Participant that updated the thread.
    init(
        threadId: String,
        version: String,
        properties: SignalingChatThreadProperties?,
        updatedOn: Iso8601Date?,
        updatedBy: SignalingChatParticipant?
    ) {
        self.properties = properties
        self.updatedOn = updatedOn
        self.updatedBy = updatedBy
        super.init(threadId: threadId, version: version)
    }

    /// Initialize a ChatThreadPropertiesUpdatedEvent from a TrouterRequest.
    /// - Parameter request: The TrouterRequest.
    init(from request: TrouterRequest) throws {
        guard let requestJsonData = request.body.data(using: .utf8) else {
            throw AzureError.client("Unable to convert request body to Data.")
        }

        let chatThreadPropertiesUpdatedPayload: ChatThreadPropertiesUpdatedPayload = try JSONDecoder()
            .decode(ChatThreadPropertiesUpdatedPayload.self, from: requestJsonData)

        guard let updatedByJsonData = chatThreadPropertiesUpdatedPayload.editedBy.data(using: .utf8) else {
            throw AzureError.client("Unable to convert payload editedBy to Data.")
        }

        let updatedByPayload: ChatParticipantPayload = try JSONDecoder()
            .decode(ChatParticipantPayload.self, from: updatedByJsonData)
        let updatedBy =
            SignalingChatParticipant(
                id: createCommunicationIdentifier(fromRawId: updatedByPayload.participantId),
                displayName: updatedByPayload.displayName
            )

        guard let propertiesJsonData = chatThreadPropertiesUpdatedPayload.properties.data(using: .utf8) else {
            throw AzureError.client("Unable to convert payload properties Data.")
        }

        let propertiesPayload: ChatThreadPropertiesPayload = try JSONDecoder()
            .decode(ChatThreadPropertiesPayload.self, from: propertiesJsonData)
        let properties = SignalingChatThreadProperties(topic: propertiesPayload.topic)

        self.properties = properties
        self.updatedOn = Iso8601Date(string: chatThreadPropertiesUpdatedPayload.editTime)
        self.updatedBy = updatedBy
        super.init(
            threadId: chatThreadPropertiesUpdatedPayload.threadId,
            version: chatThreadPropertiesUpdatedPayload.version
        )
    }
}

/// ChatThreadDeletedEvent for real-time notifications.
public class ChatThreadDeletedEvent: BaseChatThreadEvent {
    // MARK: Properties

    /// The timestamp when the thread was deleted. The timestamp is in RFC3339 format: `yyyy-MM-ddTHH:mm:ssZ`.
    public var deletedOn: Iso8601Date?
    /// The participant that deleted the chat thread.
    public var deletedBy: SignalingChatParticipant?

    // MARK: Initializers

    /// Initialize a ChatThreadDeletedEvent.
    /// - Parameters:
    ///   - threadId: Chat thread id.
    ///   - version: Chat thread version.
    ///   - deletedOn: Time that the thread was deleted.
    ///   - deletedBy: Participant that deleted the thread.
    init(
        threadId: String,
        version: String,
        deletedOn: Iso8601Date?,
        deletedBy: SignalingChatParticipant?
    ) {
        self.deletedOn = deletedOn
        self.deletedBy = deletedBy
        super.init(threadId: threadId, version: version)
    }

    /// Initialize a ChatThreadDeletedEvent from a TrouterRequest.
    /// - Parameter request: The TrouterRequest.
    init(from request: TrouterRequest) throws {
        guard let requestJsonData = request.body.data(using: .utf8) else {
            throw AzureError.client("Unable to convert request body to Data.")
        }

        let chatThreadDeletedPayload: ChatThreadDeletedPayload = try JSONDecoder()
            .decode(ChatThreadDeletedPayload.self, from: requestJsonData)

        guard let deletedByJsonData = chatThreadDeletedPayload.deletedBy.data(using: .utf8) else {
            throw AzureError.client("Unable to convert payload deletedBy to Data.")
        }

        let deletedByPayload: ChatParticipantPayload = try JSONDecoder()
            .decode(ChatParticipantPayload.self, from: deletedByJsonData)
        let deletedBy = SignalingChatParticipant(
            id: createCommunicationIdentifier(fromRawId: deletedByPayload.participantId),
            displayName: deletedByPayload.displayName
        )

        self.deletedOn = Iso8601Date(string: chatThreadDeletedPayload.deleteTime)
        self.deletedBy = deletedBy
        super.init(
            threadId: chatThreadDeletedPayload.threadId,
            version: chatThreadDeletedPayload.version
        )
    }
}

/// ParticipantsAddedEvent for real-time notifications.
public class ParticipantsAddedEvent: BaseChatThreadEvent {
    // MARK: Properties

    /// The timestamp when the participant(s) were added. The timestamp is in RFC3339 format: `yyyy-MM-ddTHH:mm:ssZ`.
    public var addedOn: Iso8601Date?
    /// The participants that were added.
    public var participantsAdded: [SignalingChatParticipant]?
    /// The participant that added the new participant(s).
    public var addedBy: SignalingChatParticipant?

    // MARK: Initializers

    /// Initialize a ParticipantsAddedEvent.
    /// - Parameters:
    ///   - threadId: Chat thread id.
    ///   - version: Chat thread version.
    ///   - addedOn: Time that the participant(s) were added.
    ///   - participantsAdded: Array of the participant(s) that were added.
    ///   - addedBy: Participant who added the new participant(s).
    init(
        threadId: String,
        version: String,
        addedOn: Iso8601Date?,
        participantsAdded: [SignalingChatParticipant]?,
        addedBy: SignalingChatParticipant?
    ) {
        self.addedOn = addedOn
        self.participantsAdded = participantsAdded
        self.addedBy = addedBy
        super.init(threadId: threadId, version: version)
    }

    /// Initialize a ParticipantsAddedEvent from a TrouterRequest.
    /// - Parameter request: The TrouterRequest.
    init(from request: TrouterRequest) throws {
        guard let requestJsonData = request.body.data(using: .utf8) else {
            throw AzureError.client("Unable to convert request body to Data.")
        }

        let participantsAddedPayload: ParticipantsAddedPayload = try JSONDecoder()
            .decode(ParticipantsAddedPayload.self, from: requestJsonData)

        guard let addeddByJsonData = participantsAddedPayload.addedBy.data(using: .utf8) else {
            throw AzureError.client("Unable to convert payload addedBy to Data.")
        }

        let addedByPayload: ChatParticipantPayload = try JSONDecoder()
            .decode(ChatParticipantPayload.self, from: addeddByJsonData)
        let addedBy = SignalingChatParticipant(
            id: createCommunicationIdentifier(fromRawId: addedByPayload.participantId),
            displayName: addedByPayload.displayName
        )

        guard let participantsJsonData = participantsAddedPayload.participantsAdded.data(using: .utf8) else {
            throw AzureError.client("Unable to convert payload participantsAdded to Data.")
        }

        let participantsPayload: [ChatParticipantPayload] = try JSONDecoder()
            .decode([ChatParticipantPayload].self, from: participantsJsonData)

        let participants: [SignalingChatParticipant] = participantsPayload
            .map { (memberPayload: ChatParticipantPayload) -> SignalingChatParticipant in
                SignalingChatParticipant(
                    id: createCommunicationIdentifier(fromRawId: memberPayload.participantId),
                    displayName: memberPayload.displayName,
                    shareHistoryTime: Iso8601Date(
                        string: TrouterEventUtil
                            .toIso8601Date(unixTime: memberPayload.shareHistoryTime)
                    )
                )
            }

        self.addedOn = Iso8601Date(string: participantsAddedPayload.time)
        self.participantsAdded = participants
        self.addedBy = addedBy
        super.init(
            threadId: participantsAddedPayload.threadId,
            version: participantsAddedPayload.version
        )
    }
}

/// ParticipantsRemovedEvent for real-time notifications.
public class ParticipantsRemovedEvent: BaseChatThreadEvent {
    // MARK: Properties

    /// The timestamp when the participant(s) were removed. The timestamp is in RFC3339 format: `yyyy-MM-ddTHH:mm:ssZ`.
    public var removedOn: Iso8601Date?
    // TODO: Should this be singular?
    public var participantsRemoved: [SignalingChatParticipant]?
    /// The participant that initiated the removal.
    public var removedBy: SignalingChatParticipant?

    // MARK: Initializers

    /// Initialize a ParticipantsRemovedEvent
    /// - Parameters:
    ///   - threadId: Chat thread id.
    ///   - version: Chat thread version.
    ///   - removedOn: Time that the participant was removed.
    ///   - participantsRemoved: TODO
    ///   - removedBy: Participant that initiated the removal.
    init(
        threadId: String,
        version: String,
        removedOn: Iso8601Date?,
        participantsRemoved: [SignalingChatParticipant]?,
        removedBy: SignalingChatParticipant?
    ) {
        self.removedOn = removedOn
        self.participantsRemoved = participantsRemoved
        self.removedBy = removedBy
        super.init(threadId: threadId, version: version)
    }

    /// Initialize a ParticipantsRemovedEvent from a TrouterRequest.
    /// - Parameter request: The TrouterRequest.
    init(from request: TrouterRequest) throws {
        guard let requestJsonData = request.body.data(using: .utf8) else {
            throw AzureError.client("Unable to convert request body to Data.")
        }

        let participantsRemovedPayload: ParticipantsRemovedPayload = try JSONDecoder()
            .decode(ParticipantsRemovedPayload.self, from: requestJsonData)

        guard let removedByJsonData = participantsRemovedPayload.removedBy.data(using: .utf8) else {
            throw AzureError.client("Unable to convert payload removedBy to Data.")
        }

        let removedByPayload: ChatParticipantPayload = try JSONDecoder()
            .decode(ChatParticipantPayload.self, from: removedByJsonData)
        let removedBy = SignalingChatParticipant(
            id: createCommunicationIdentifier(fromRawId: removedByPayload.participantId),
            displayName: removedByPayload.displayName
        )

        guard let participantsJsonData = participantsRemovedPayload.participantsRemoved.data(using: .utf8) else {
            throw AzureError.client("Unable to convert payload participantsRemoved to Data.")
        }

        let participantsPayload: [ChatParticipantPayload] = try JSONDecoder()
            .decode([ChatParticipantPayload].self, from: participantsJsonData)
        let participants: [SignalingChatParticipant] = participantsPayload
            .map { (memberPayload: ChatParticipantPayload) -> SignalingChatParticipant in
                SignalingChatParticipant(
                    id: createCommunicationIdentifier(fromRawId: memberPayload.participantId),
                    displayName: memberPayload.displayName,
                    shareHistoryTime: Iso8601Date(
                        string: TrouterEventUtil
                            .toIso8601Date(unixTime: memberPayload.shareHistoryTime)
                    )
                )
            }

        self.removedOn = Iso8601Date(string: participantsRemovedPayload.time)
        self.participantsRemoved = participants
        self.removedBy = removedBy
        super.init(
            threadId: participantsRemovedPayload.threadId,
            version: participantsRemovedPayload.version
        )
    }
}

/// ChatEventId representing the different events for real-time notifications
public enum ChatEventId: String {
    case realTimeNotificationConnected
    case realTimeNotificationDisconnected
    case chatMessageReceived
    case typingIndicatorReceived
    case readReceiptReceived
    case chatMessageEdited
    case chatMessageDeleted
    case chatThreadCreated
    case chatThreadPropertiesUpdated
    case chatThreadDeleted
    case participantsAdded
    case participantsRemoved

    init(forCode code: Int) throws {
        switch code {
        case 200:
            self = .chatMessageReceived
        case 245:
            self = .typingIndicatorReceived
        case 246:
            self = .readReceiptReceived
        case 247:
            self = .chatMessageEdited
        case 248:
            self = .chatMessageDeleted
        case 257:
            self = .chatThreadCreated
        case 258:
            self = .chatThreadPropertiesUpdated
        case 259:
            self = .chatThreadDeleted
        case 260:
            self = .participantsAdded
        case 261:
            self = .participantsRemoved
        default:
            throw AzureError.client("Event code: \(code) is unsupported")
        }
    }
}
