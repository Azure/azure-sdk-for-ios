//
//  chat.swift
//  AzureCommunicationSignaling
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

public class CommunicationUser {
    public var communicationUserId: String

    init(communicationUserId: String) {
        self.communicationUserId = communicationUserId
    }
}

public class SignalingChatParticipant {
    public var user: CommunicationUser?
    public var displayName: String?
    public var shareHistoryTime: String?

    init(user: CommunicationUser?, displayName: String? = nil, shareHistoryTime: String? = nil) {
        self.user = user
        self.displayName = displayName
        self.shareHistoryTime = shareHistoryTime
    }
}

public class ChatThreadProperties {
    public var topic: String

    init(topic: String) {
        self.topic = topic
    }
}

public class BaseEvent {
    public var threadId: String
    public var sender: CommunicationUser?
    public var recipient: CommunicationUser?

    init(threadId: String, sender: CommunicationUser?, recipient: CommunicationUser?) {
        self.threadId = threadId
        self.sender = sender
        self.recipient = recipient
    }
}

public class ChatThreadEvent {
    public var threadId: String
    public var version: String

    init(threadId: String, version: String) {
        self.threadId = threadId
        self.version = version
    }
}

public class ChatMessageEvent: BaseEvent {
    public var id: String
    public var senderDisplayName: String?
    public var createdOn: String
    public var version: String

    init(
        threadId: String,
        sender: CommunicationUser?,
        recipient: CommunicationUser?,
        id: String,
        senderDisplayName: String? = nil,
        createdOn: String,
        version: String
    ) {
        self.id = id
        self.senderDisplayName = senderDisplayName
        self.createdOn = createdOn
        self.version = version
        super.init(threadId: threadId, sender: sender, recipient: recipient)
    }
}

public class ChatMessageReceivedEvent: ChatMessageEvent {
    public var type: String
    public var content: String
    public var priority: String

    init(
        threadId: String,
        sender: CommunicationUser?,
        recipient: CommunicationUser?,
        id: String,
        senderDisplayName: String? = nil,
        createdOn: String,
        version: String,
        type: String,
        content: String,
        priority: String
    ) {
        self.type = type
        self.content = content
        self.priority = priority
        super.init(
            threadId: threadId,
            sender: sender,
            recipient: recipient,
            id: id,
            senderDisplayName: senderDisplayName,
            createdOn: createdOn,
            version: version
        )
    }
}

public class ChatMessageEditedEvent: ChatMessageEvent {
    public var content: String
    public var editedOn: String

    init(
        threadId: String,
        sender: CommunicationUser?,
        recipient: CommunicationUser?,
        id: String,
        senderDisplayName: String? = nil,
        createdOn: String,
        version: String,
        content: String,
        editedOn: String
    ) {
        self.content = content
        self.editedOn = editedOn
        super.init(
            threadId: threadId,
            sender: sender,
            recipient: recipient,
            id: id,
            senderDisplayName: senderDisplayName,
            createdOn: createdOn,
            version: version
        )
    }
}

public class ChatMessageDeletedEvent: ChatMessageEvent {
    public var deletedOn: String

    init(
        threadId: String,
        sender: CommunicationUser?,
        recipient: CommunicationUser?,
        id: String,
        senderDisplayName: String? = nil,
        createdOn: String,
        version: String,
        deletedOn: String
    ) {
        self.deletedOn = deletedOn
        super.init(
            threadId: threadId,
            sender: sender,
            recipient: recipient,
            id: id,
            senderDisplayName: senderDisplayName,
            createdOn: createdOn,
            version: version
        )
    }
}

public class TypingIndicatorReceivedEvent: BaseEvent {
    public var version: String
    public var receivedOn: String

    init(
        threadId: String,
        sender: CommunicationUser?,
        recipient: CommunicationUser?,
        version: String,
        receivedOn: String
    ) {
        self.version = version
        self.receivedOn = receivedOn
        super.init(threadId: threadId, sender: sender, recipient: recipient)
    }
}

public class ReadReceiptReceivedEvent: BaseEvent {
    public var chatMessageId: String
    public var readOn: String

    init(
        threadId: String,
        sender: CommunicationUser?,
        recipient: CommunicationUser?,
        chatMessageId: String,
        readOn: String
    ) {
        self.chatMessageId = chatMessageId
        self.readOn = readOn
        super.init(threadId: threadId, sender: sender, recipient: recipient)
    }
}

public class ChatThreadCreatedEvent: ChatThreadEvent {
    public var createdOn: String
    public var properties: ChatThreadProperties?
    public var participants: [SignalingChatParticipant]?
    public var createdBy: SignalingChatParticipant?

    init(
        threadId: String,
        version: String,
        createdOn: String,
        properties: ChatThreadProperties?,
        participants: [SignalingChatParticipant]?,
        createdBy: SignalingChatParticipant?
    ) {
        self.createdOn = createdOn
        self.properties = properties
        self.participants = participants
        self.createdBy = createdBy
        super.init(threadId: threadId, version: version)
    }
}

public class ChatThreadPropertiesUpdatedEvent: ChatThreadEvent {
    public var properties: ChatThreadProperties?
    public var updatedOn: String
    public var updatedBy: SignalingChatParticipant?

    init(
        threadId: String,
        version: String,
        properties: ChatThreadProperties?,
        updatedOn: String,
        updatedBy: SignalingChatParticipant?
    ) {
        self.properties = properties
        self.updatedOn = updatedOn
        self.updatedBy = updatedBy
        super.init(threadId: threadId, version: version)
    }
}

public class ChatThreadDeletedEvent: ChatThreadEvent {
    public var deletedOn: String
    public var deletedBy: SignalingChatParticipant?

    init(
        threadId: String,
        version: String,
        deletedOn: String,
        deletedBy: SignalingChatParticipant?
    ) {
        self.deletedOn = deletedOn
        self.deletedBy = deletedBy
        super.init(threadId: threadId, version: version)
    }
}

public class ParticipantsAddedEvent: ChatThreadEvent {
    public var addedOn: String
    public var participantsAdded: [SignalingChatParticipant]?
    public var addedBy: SignalingChatParticipant?

    init(
        threadId: String,
        version: String,
        addedOn: String,
        participantsAdded: [SignalingChatParticipant]?,
        addedBy: SignalingChatParticipant?
    ) {
        self.addedOn = addedOn
        self.participantsAdded = participantsAdded
        self.addedBy = addedBy
        super.init(threadId: threadId, version: version)
    }
}

public class ParticipantsRemovedEvent: ChatThreadEvent {
    public var removedOn: String
    public var participantsRemoved: [SignalingChatParticipant]?
    public var removedBy: SignalingChatParticipant?

    init(
        threadId: String,
        version: String,
        removedOn: String,
        participantsRemoved: [SignalingChatParticipant]?,
        removedBy: SignalingChatParticipant?
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
