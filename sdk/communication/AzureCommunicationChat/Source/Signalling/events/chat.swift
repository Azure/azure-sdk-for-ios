//
//  chat.swift
//  AzureCommunicationSignaling
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunication
import AzureCore
import Foundation

// TODO: Can we use existing models?
public class SignallingChatParticipant {
    public var id: CommunicationIdentifier?
    public var displayName: String?
    public var shareHistoryTime: Iso8601Date?

    init(id: CommunicationIdentifier?, displayName: String? = nil, shareHistoryTime: Iso8601Date? = nil) {
        self.id = id
        self.displayName = displayName
        self.shareHistoryTime = shareHistoryTime
    }
}

public class SignallingChatThreadProperties {
    public var topic: String

    init(topic: String) {
        self.topic = topic
    }
}

public class BaseChatEvent {
    public var threadId: String
    public var sender: CommunicationIdentifier?
    public var senderDisplayName: String?
    public var recipient: CommunicationIdentifier?

    init(
        threadId: String,
        sender: CommunicationIdentifier?,
        senderDisplayName: String? = nil,
        recipient: CommunicationIdentifier?
    ) {
        self.threadId = threadId
        self.sender = sender
        self.senderDisplayName = senderDisplayName
        self.recipient = recipient
    }
}

public class BaseChatThreadEvent {
    public var threadId: String
    public var version: String

    init(threadId: String, version: String) {
        self.threadId = threadId
        self.version = version
    }
}

public class BaseChatMessageEvent: BaseChatEvent {
    public var id: String
    public var createdOn: Iso8601Date?
    public var version: String
    public var type: ChatMessageType

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
        super.init(threadId: threadId, sender: sender, senderDisplayName: senderDisplayName, recipient: recipient)
    }
}

public class ChatMessageReceivedEvent: BaseChatMessageEvent {
    public var message: String

    init(
        threadId: String,
        sender: CommunicationIdentifier?,
        recipient: CommunicationIdentifier?,
        id: String,
        senderDisplayName: String? = nil,
        createdOn: Iso8601Date?,
        version: String,
        type: ChatMessageType,
        message: String
    ) {
        self.message = message
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
}

public class ChatMessageEditedEvent: BaseChatMessageEvent {
    public var message: String
    public var editedOn: Iso8601Date?

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
        editedOn: Iso8601Date?
    ) {
        self.message = message
        self.editedOn = editedOn
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
}

public class ChatMessageDeletedEvent: BaseChatMessageEvent {
    public var deletedOn: Iso8601Date?
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
}

public class TypingIndicatorReceivedEvent: BaseChatEvent {
    public var version: String
    public var receivedOn: Iso8601Date?

    init(
        threadId: String,
        sender: CommunicationIdentifier?,
        recipient: CommunicationIdentifier?,
        version: String,
        receivedOn: Iso8601Date?
    ) {
        self.version = version
        self.receivedOn = receivedOn
        super.init(threadId: threadId, sender: sender, recipient: recipient)
    }
}

public class ReadReceiptReceivedEvent: BaseChatEvent {
    public var chatMessageId: String
    public var readOn: Iso8601Date?

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
}

public class ChatThreadCreatedEvent: BaseChatThreadEvent {
    public var createdOn: Iso8601Date?
    public var properties: SignallingChatThreadProperties?
    public var participants: [SignallingChatParticipant]?
    public var createdBy: SignallingChatParticipant?

    init(
        threadId: String,
        version: String,
        createdOn: Iso8601Date?,
        properties: SignallingChatThreadProperties?,
        participants: [SignallingChatParticipant]?,
        createdBy: SignallingChatParticipant?
    ) {
        self.createdOn = createdOn
        self.properties = properties
        self.participants = participants
        self.createdBy = createdBy
        super.init(threadId: threadId, version: version)
    }
}

public class ChatThreadPropertiesUpdatedEvent: BaseChatThreadEvent {
    public var properties: SignallingChatThreadProperties?
    public var updatedOn: Iso8601Date?
    public var updatedBy: SignallingChatParticipant?

    init(
        threadId: String,
        version: String,
        properties: SignallingChatThreadProperties?,
        updatedOn: Iso8601Date?,
        updatedBy: SignallingChatParticipant?
    ) {
        self.properties = properties
        self.updatedOn = updatedOn
        self.updatedBy = updatedBy
        super.init(threadId: threadId, version: version)
    }
}

public class ChatThreadDeletedEvent: BaseChatThreadEvent {
    public var deletedOn: Iso8601Date?
    public var deletedBy: SignallingChatParticipant?

    init(
        threadId: String,
        version: String,
        deletedOn: Iso8601Date?,
        deletedBy: SignallingChatParticipant?
    ) {
        self.deletedOn = deletedOn
        self.deletedBy = deletedBy
        super.init(threadId: threadId, version: version)
    }
}

public class ParticipantsAddedEvent: BaseChatThreadEvent {
    public var addedOn: Iso8601Date?
    public var participantsAdded: [SignallingChatParticipant]?
    public var addedBy: SignallingChatParticipant?

    init(
        threadId: String,
        version: String,
        addedOn: Iso8601Date?,
        participantsAdded: [SignallingChatParticipant]?,
        addedBy: SignallingChatParticipant?
    ) {
        self.addedOn = addedOn
        self.participantsAdded = participantsAdded
        self.addedBy = addedBy
        super.init(threadId: threadId, version: version)
    }
}

public class ParticipantsRemovedEvent: BaseChatThreadEvent {
    public var removedOn: Iso8601Date?
    public var participantsRemoved: [SignallingChatParticipant]?
    public var removedBy: SignallingChatParticipant?

    init(
        threadId: String,
        version: String,
        removedOn: Iso8601Date?,
        participantsRemoved: [SignallingChatParticipant]?,
        removedBy: SignallingChatParticipant?
    ) {
        self.removedOn = removedOn
        self.participantsRemoved = participantsRemoved
        self.removedBy = removedBy
        super.init(threadId: threadId, version: version)
    }
}

public enum ChatEventId: String {
    case chatMessageReceived = "chatMessageReceived"
    case typingIndicatorReceived = "typingIndicatorReceived"
    case readReceiptReceived = "readReceiptReceived"
    case chatMessageEdited = "chatMessageEdited"
    case chatMessageDeleted = "chatMessageDeleted"
    case chatThreadCreated = "chatThreadCreated"
    case chatThreadPropertiesUpdated = "chatThreadPropertiesUpdated"
    case chatThreadDeleted = "chatThreadDeleted"
    case participantsAdded = "participantsAdded"
    case participantsRemoved = "participantsRemoved"
}
