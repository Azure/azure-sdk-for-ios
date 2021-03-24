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

public class SignalingChatParticipant {
    public var id: CommunicationIdentifier?
    public var displayName: String?
    public var shareHistoryTime: Iso8601Date?

    init(id: CommunicationIdentifier?, displayName: String? = nil, shareHistoryTime: Iso8601Date? = nil) {
        self.id = id
        self.displayName = displayName
        self.shareHistoryTime = shareHistoryTime
    }
}

public class SignalingChatThreadProperties {
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
    public var properties: SignalingChatThreadProperties?
    public var participants: [SignalingChatParticipant]?
    public var createdBy: SignalingChatParticipant?

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
}

public class ChatThreadPropertiesUpdatedEvent: BaseChatThreadEvent {
    public var properties: SignalingChatThreadProperties?
    public var updatedOn: Iso8601Date?
    public var updatedBy: SignalingChatParticipant?

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
}

public class ChatThreadDeletedEvent: BaseChatThreadEvent {
    public var deletedOn: Iso8601Date?
    public var deletedBy: SignalingChatParticipant?

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
}

public class ParticipantsAddedEvent: BaseChatThreadEvent {
    public var addedOn: Iso8601Date?
    public var participantsAdded: [SignalingChatParticipant]?
    public var addedBy: SignalingChatParticipant?

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
}

public class ParticipantsRemovedEvent: BaseChatThreadEvent {
    public var removedOn: Iso8601Date?
    public var participantsRemoved: [SignalingChatParticipant]?
    public var removedBy: SignalingChatParticipant?

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
}

public enum ChatEventId: String {
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
            self = .chatMessageDeleted
        case 260:
            self = .participantsAdded
        case 261:
            self = .participantsRemoved
        default:
            throw AzureError.client("Event code: \(code) is unsupported")
        }
    }
}
