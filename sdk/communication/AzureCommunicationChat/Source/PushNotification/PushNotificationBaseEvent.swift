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
/// BaseChatThreadEvent for push notifications.
public class PNBaseChatThreadEvent {
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

/// BaseChatMessageEvent for push notifications.
public class PNBaseChatMessageEvent {
    // MARK: Properties

    /// The id of the message. This id is server generated.
    public var messageId: String
    /// The message type.
    public var type: ChatMessageType
    /// Chat thread id.
    public var threadId: String
    /// Sender Id
    public var senderId: String
    /// Recipient Id
    public var recipientId: String
    /// Sender display name.
    public var senderDisplayName: String?
    /// The timestamp when the message arrived at the server. The timestamp is in RFC3339 format: `yyyy-MM-ddTHH:mm:ssZ`.
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
        senderId: String,
        recipientId: String,
        senderDisplayName: String? = nil,
        originalArrivalTime: Iso8601Date? = nil,
        version: String
    ) {
        self.messageId = messageId
        self.type = type
        self.threadId = threadId
        self.senderId = senderId
        self.recipientId = recipientId
        self.senderDisplayName = senderDisplayName
        self.originalArrivalTime = originalArrivalTime
        self.version = version
    }
}

/// Chat Participant for push notification events.
public struct PNChatParticipant {
    // MARK: Properties

    /// The  id of the participant.
    public let participantId: String?
    /// Display name for the participant.
    public let displayName: String?

    // MARK: Initializers

    /// Initialize a PushNotificationChatParticipant
    /// - Parameters:
    ///   - id: The  identifier of the participant.
    ///   - displayName: Display name for the participant.
    init(participantId: String? = nil, displayName: String? = nil) {
        self.participantId = participantId
        self.displayName = displayName
    }
}

/// ChatThreadProperties for push notification events.
public struct PNChatThreadProperties {
    // MARK: Properties

    /// Thread topic.
    public let topic: String

    // MARK: Initializers

    /// Initialize a PushNotificationChatThreadProperties
    /// - Parameter topic: Thread topic.
    init(topic: String) {
        self.topic = topic
    }
}

/// ChatThreadCreatedEvent for push notifications.
public class PNChatThreadCreatedEvent: PNBaseChatThreadEvent {
    // MARK: Properties

    /// The timestamp when the thread was created. The timestamp is in RFC3339 format: `yyyy-MM-ddTHH:mm:ssZ`.
    public var createdTime: Iso8601Date?

    /// ChatThread properties, contains the thread topic.
    public var properties: PNChatThreadProperties?

    /// List of participants currently in the thread.
    public var participants: [PNChatParticipant]?

    /// The participant that created the thread.
    public var createdBy: PNChatParticipant?

    // MARK: Initializers

    /// Initialize a ChatThreadCreatedEvent from Data.
    /// - Parameter data: The payload data.
    init(from data: Data) throws {
        let pushNotificationChatThreadCreatedPayload: PushNotificationThreadCreatedPayload = try JSONDecoder()
            .decode(PushNotificationThreadCreatedPayload.self, from: data)

        // Chat thread creator
        guard let createdByJsonData = pushNotificationChatThreadCreatedPayload.createdBy.data(using: .utf8) else {
            throw AzureError.client("Unable to convert payload createdBy to Data.")
        }

        let createdByPayload: PushNotificationParticipantPayload = try JSONDecoder()
            .decode(PushNotificationParticipantPayload.self, from: createdByJsonData)
        let createdBy =
            PNChatParticipant(
                participantId: createdByPayload.participantId,
                displayName: createdByPayload.displayName
            )

        // Chat thread members
        guard let membersJsonData = pushNotificationChatThreadCreatedPayload.members.data(using: .utf8) else {
            throw AzureError.client("Unable to convert payload members to Data.")
        }

        let membersPayload: [PushNotificationParticipantPayload] = try JSONDecoder()
            .decode([PushNotificationParticipantPayload].self, from: membersJsonData)
        let participants: [PNChatParticipant] = membersPayload
            .map { (memberPayload: PushNotificationParticipantPayload) -> PNChatParticipant in
                PNChatParticipant(
                    participantId: memberPayload.participantId,
                    displayName: memberPayload.displayName
                )
            }

        // Chat thread properties
        guard let propertiesJsonData = pushNotificationChatThreadCreatedPayload.properties.data(using: .utf8) else {
            throw AzureError.client("Unable to convert payload properties to Data.")
        }

        let propertiesPayload: PushNotificationChatThreadPropertiesPayload = try JSONDecoder()
            .decode(PushNotificationChatThreadPropertiesPayload.self, from: propertiesJsonData)
        let properties = PNChatThreadProperties(topic: propertiesPayload.topic)

        // Other components in Chat Thread
        self.createdTime = Iso8601Date(string: pushNotificationChatThreadCreatedPayload.createTime)
        self.properties = properties
        self.participants = participants
        self.createdBy = createdBy

        super.init(
            threadId: pushNotificationChatThreadCreatedPayload.threadId,
            version: pushNotificationChatThreadCreatedPayload.version
        )
    }
}

/// ChatThreadPropertiesUpdatedEvent for push notifications.
public class PNChatThreadPropertiesUpdatedEvent: PNBaseChatThreadEvent {
    // MARK: Properties

    /// The chat thread properties, includes the thread topic.
    public var properties: PNChatThreadProperties?
    /// The timestamp when the thread was updated. The timestamp is in RFC3339 format: `yyyy-MM-ddTHH:mm:ssZ`.
    public var updatedOn: Iso8601Date?
    /// The participant that updated the thread.
    public var updatedBy: PNChatParticipant?

    // MARK: Initializers

    /// Initialize a ChatThreadPropertiesUpdatedEvent from Data.
    /// - Parameter data: The payload data.
    init(from data: Data) throws {
        let pushNotificationChatThreadPropertiesUpdatedPayload: PushNotificationChatThreadPropertiesUpdatedPayload =
            try JSONDecoder()
                .decode(PushNotificationChatThreadPropertiesUpdatedPayload.self, from: data)

        guard let updatedByJsonData = pushNotificationChatThreadPropertiesUpdatedPayload.editedBy.data(using: .utf8)
        else {
            throw AzureError.client("Unable to convert payload editedBy to Data.")
        }

        let updatedByPayload: PushNotificationParticipantPayload = try JSONDecoder()
            .decode(PushNotificationParticipantPayload.self, from: updatedByJsonData)
        let updatedBy =
            PNChatParticipant(
                participantId: updatedByPayload.participantId,
                displayName: updatedByPayload.displayName
            )

        guard let propertiesJsonData = pushNotificationChatThreadPropertiesUpdatedPayload.properties.data(using: .utf8)
        else {
            throw AzureError.client("Unable to convert payload properties Data.")
        }

        let propertiesPayload: PushNotificationChatThreadPropertiesPayload = try JSONDecoder()
            .decode(PushNotificationChatThreadPropertiesPayload.self, from: propertiesJsonData)
        let properties = PNChatThreadProperties(topic: propertiesPayload.topic)

        self.properties = properties
        self.updatedOn = Iso8601Date(string: pushNotificationChatThreadPropertiesUpdatedPayload.editTime)
        self.updatedBy = updatedBy
        super.init(
            threadId: pushNotificationChatThreadPropertiesUpdatedPayload.threadId,
            version: pushNotificationChatThreadPropertiesUpdatedPayload.version
        )
    }
}

/// ChatThreadDeletedEvent for push notifications.
public class PNChatThreadDeletedEvent: PNBaseChatThreadEvent {
    // MARK: Properties

    /// The timestamp when the thread was deleted. The timestamp is in RFC3339 format: `yyyy-MM-ddTHH:mm:ssZ`.
    public var deletedOn: Iso8601Date?
    /// The participant that deleted the chat thread.
    public var deletedBy: PNChatParticipant?

    /// Initialize a ChatThreadDeletedEvent from Data.
    /// - Parameter request: The payload data.
    init(from data: Data) throws {
        let pushNotificationChatThreadDeletedPayload: PushNotificationChatThreadDeletedPayload = try JSONDecoder()
            .decode(PushNotificationChatThreadDeletedPayload.self, from: data)

        guard let deletedByJsonData = pushNotificationChatThreadDeletedPayload.deletedBy.data(using: .utf8) else {
            throw AzureError.client("Unable to convert payload deletedBy to Data.")
        }

        let deletedByPayload: PushNotificationParticipantPayload = try JSONDecoder()
            .decode(PushNotificationParticipantPayload.self, from: deletedByJsonData)
        let deletedBy = PNChatParticipant(
            participantId: deletedByPayload.participantId,
            displayName: deletedByPayload.displayName
        )

        self.deletedOn = Iso8601Date(string: pushNotificationChatThreadDeletedPayload.deleteTime)
        self.deletedBy = deletedBy
        super.init(
            threadId: pushNotificationChatThreadDeletedPayload.threadId,
            version: pushNotificationChatThreadDeletedPayload.version
        )
    }
}

/// ParticipantsAddedEvent for push notifications.
public class PNChatParticipantsAddedEvent: PNBaseChatThreadEvent {
    // MARK: Properties

    /// The timestamp when the participant(s) were added. The timestamp is in RFC3339 format: `yyyy-MM-ddTHH:mm:ssZ`.
    public var addedOn: Iso8601Date?
    /// The participants that were added.
    public var participantsAdded: [PNChatParticipant]?
    /// The participant that added the new participant(s).
    public var addedBy: PNChatParticipant?

    // MARK: Initializers

    /// Initialize a ParticipantsAddedEvent from Data.
    /// - Parameter request: The payload data.
    init(from data: Data) throws {
        let pushNotificationparticipantsAddedPayload: PushNotificationParticipantsAddedPayload = try JSONDecoder()
            .decode(PushNotificationParticipantsAddedPayload.self, from: data)

        guard let addeddByJsonData = pushNotificationparticipantsAddedPayload.addedBy.data(using: .utf8) else {
            throw AzureError.client("Unable to convert payload addedBy to Data.")
        }

        let addedByPayload: PushNotificationParticipantPayload = try JSONDecoder()
            .decode(PushNotificationParticipantPayload.self, from: addeddByJsonData)
        let addedBy = PNChatParticipant(
            participantId: addedByPayload.participantId,
            displayName: addedByPayload.displayName
        )

        guard let participantsJsonData = pushNotificationparticipantsAddedPayload.participantsAdded.data(using: .utf8)
        else {
            throw AzureError.client("Unable to convert payload participantsAdded to Data.")
        }

        let participantsPayload: [PushNotificationParticipantPayload] = try JSONDecoder()
            .decode([PushNotificationParticipantPayload].self, from: participantsJsonData)

        let participants: [PNChatParticipant] = participantsPayload
            .map { (memberPayload: PushNotificationParticipantPayload) -> PNChatParticipant in
                PNChatParticipant(
                    participantId: memberPayload.participantId,
                    displayName: memberPayload.displayName
                )
            }

        self.addedOn = Iso8601Date(string: pushNotificationparticipantsAddedPayload.time)
        self.participantsAdded = participants
        self.addedBy = addedBy
        super.init(
            threadId: pushNotificationparticipantsAddedPayload.threadId,
            version: pushNotificationparticipantsAddedPayload.version
        )
    }
}

/// ParticipantsRemovedEvent for push notifications.
public class PNChatParticipantsRemovedEvent: PNBaseChatThreadEvent {
    // MARK: Properties

    /// The timestamp when the participant(s) were removed. The timestamp is in RFC3339 format: `yyyy-MM-ddTHH:mm:ssZ`.
    public var removedOn: Iso8601Date?
    // TODO: Should this be singular?
    public var participantsRemoved: [PNChatParticipant]?
    /// The participant that initiated the removal.
    public var removedBy: PNChatParticipant?

    // MARK: Initializers

    /// Initialize a ParticipantsRemovedEvent from Data.
    /// - Parameter data: The payload data.
    init(from data: Data) throws {
        let pushNotificationParticipantsRemovedPayload: PushNotificationParticipantsRemovedPayload = try JSONDecoder()
            .decode(PushNotificationParticipantsRemovedPayload.self, from: data)

        guard let removedByJsonData = pushNotificationParticipantsRemovedPayload.removedBy.data(using: .utf8) else {
            throw AzureError.client("Unable to convert payload removedBy to Data.")
        }

        let removedByPayload: PushNotificationParticipantPayload = try JSONDecoder()
            .decode(PushNotificationParticipantPayload.self, from: removedByJsonData)
        let removedBy = PNChatParticipant(
            participantId: removedByPayload.participantId,
            displayName: removedByPayload.displayName
        )

        guard let participantsJsonData = pushNotificationParticipantsRemovedPayload.participantsRemoved
            .data(using: .utf8)
        else {
            throw AzureError.client("Unable to convert payload participantsRemoved to Data.")
        }

        let participantsPayload: [PushNotificationParticipantPayload] = try JSONDecoder()
            .decode([PushNotificationParticipantPayload].self, from: participantsJsonData)
        let participants: [PNChatParticipant] = participantsPayload
            .map { (memberPayload: PushNotificationParticipantPayload) -> PNChatParticipant in
                PNChatParticipant(
                    participantId: memberPayload.participantId,
                    displayName: memberPayload.displayName
                )
            }

        self.removedOn = Iso8601Date(string: pushNotificationParticipantsRemovedPayload.time)
        self.participantsRemoved = participants
        self.removedBy = removedBy
        super.init(
            threadId: pushNotificationParticipantsRemovedPayload.threadId,
            version: pushNotificationParticipantsRemovedPayload.version
        )
    }
}

/// ChatMessageReceivedEvent for push notifications.
public class PNChatMessageReceivedEvent: PNBaseChatMessageEvent {
    // MARK: Properties

    /// The content of the message.
    public var message: String

    // TODO: Add it after PNH template modification
    /// The message metadata.
    // public var metadata: [String: String?]?

    // MARK: Initializers

    /// Initialize a ChatMessageReceivedEvent from Data.
    /// - Parameter data: The payload data.
    init(from data: Data) throws {
        let pushNotificationMessageReceivedPayload: PushNotificationMessageReceivedPayload = try JSONDecoder()
            .decode(PushNotificationMessageReceivedPayload.self, from: data)

        self.message = pushNotificationMessageReceivedPayload.messageBody

        /*
         if messageReceivedPayload.acsChatMessageMetadata != "null" {
             if let acsChatMetadata = messageReceivedPayload.acsChatMessageMetadata.data(using: .utf8) {
                 self.metadata = try JSONDecoder().decode([String: String?].self, from: acsChatMetadata)
             }
         }
         */

        super.init(
            messageId: pushNotificationMessageReceivedPayload.messageId,
            type: ChatMessageType(pushNotificationMessageReceivedPayload.messageType),
            threadId: pushNotificationMessageReceivedPayload.groupId,
            senderId: pushNotificationMessageReceivedPayload.senderId,
            recipientId: pushNotificationMessageReceivedPayload.recipientId,
            senderDisplayName: pushNotificationMessageReceivedPayload.senderDisplayName,
            originalArrivalTime: Iso8601Date(string: pushNotificationMessageReceivedPayload.originalArrivalTime),
            version: pushNotificationMessageReceivedPayload.version
        )
    }
}

/// ChatMessageEditedEvent for push notifications.
public class PNChatMessageEditedEvent: PNBaseChatMessageEvent {
    // MARK: Properties

    /// The message content.
    public var message: String
    /// The timestamp when the message was edited. The timestamp is in RFC3339 format: `yyyy-MM-ddTHH:mm:ssZ`.
    public var editedOn: Iso8601Date?

    // TODO: Add it after PNH template modification
    /// The message metadata
    // public var metadata: [String: String?]?

    // MARK: Initializers

    /// Initialize a ChatMessageEditedEvent from Data.
    /// - Parameter data: The payload data.
    init(from data: Data) throws {
        let pushNotificationMessageEditedPayload: PushNotificationMessageEditedPayload = try JSONDecoder()
            .decode(PushNotificationMessageEditedPayload.self, from: data)

        self.message = pushNotificationMessageEditedPayload.messageBody
        self.editedOn = Iso8601Date(string: pushNotificationMessageEditedPayload.edittime)

        /*
         if chatMessageEditedPayload.acsChatMessageMetadata != "null" {
             if let acsChatMetadata = chatMessageEditedPayload.acsChatMessageMetadata.data(using: .utf8) {
                 self.metadata = try JSONDecoder().decode([String: String?].self, from: acsChatMetadata)
             }
         }
          */

        super.init(
            messageId: pushNotificationMessageEditedPayload.messageId,
            type: ChatMessageType(pushNotificationMessageEditedPayload.messageType),
            threadId: pushNotificationMessageEditedPayload.groupId,
            senderId: pushNotificationMessageEditedPayload.senderId,
            recipientId: pushNotificationMessageEditedPayload.recipientId,
            senderDisplayName: pushNotificationMessageEditedPayload.senderDisplayName,
            originalArrivalTime: Iso8601Date(string: pushNotificationMessageEditedPayload.originalArrivalTime),
            version: pushNotificationMessageEditedPayload.version
        )
    }
}

/// ChatMessageDeletedEvent for push notifications.
public class PNChatMessageDeletedEvent: PNBaseChatMessageEvent {
    // MARK: Properties

    /// The timestamp when the message was deleted. The timestamp is in RFC3339 format: `yyyy-MM-ddTHH:mm:ssZ`.
    public var deletedOn: Iso8601Date?

    // MARK: Initializers

    /// Initialize a ChatMessageDeletedEvent from Data.
    /// - Parameter request: The payload data.
    init(from data: Data) throws {
        let pushNotificationMessageDeletedPayload: PushNotificationMessageDeletedPayload = try JSONDecoder()
            .decode(PushNotificationMessageDeletedPayload.self, from: data)

        self.deletedOn = Iso8601Date(string: pushNotificationMessageDeletedPayload.deletetime)
        super.init(
            messageId: pushNotificationMessageDeletedPayload.messageId,
            type: ChatMessageType(pushNotificationMessageDeletedPayload.messageType),
            threadId: pushNotificationMessageDeletedPayload.groupId,
            senderId: pushNotificationMessageDeletedPayload.senderId,
            recipientId: pushNotificationMessageDeletedPayload.recipientId,
            senderDisplayName: pushNotificationMessageDeletedPayload.senderDisplayName,
            originalArrivalTime: Iso8601Date(string: pushNotificationMessageDeletedPayload.originalArrivalTime),
            version: pushNotificationMessageDeletedPayload.version
        )
    }
}
