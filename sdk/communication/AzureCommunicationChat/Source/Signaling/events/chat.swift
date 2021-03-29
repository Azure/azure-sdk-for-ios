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
import TrouterClientIos

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

    init(from request: TrouterRequest) throws {
        guard let requestJsonData = request.body.data(using: .utf8) else {
            throw AzureError.client("Unable to convert request body to Data.")
        }

        let messageReceivedPayload: MessageReceivedPayload = try JSONDecoder()
            .decode(MessageReceivedPayload.self, from: requestJsonData)

        self.message = messageReceivedPayload.messageBody
        super.init(
            threadId: messageReceivedPayload.groupId,
            sender: TrouterEventUtil.getIdentifier(from: messageReceivedPayload.senderId),
            recipient: TrouterEventUtil.getIdentifier(from: messageReceivedPayload.recipientId),
            id: messageReceivedPayload.messageId,
            senderDisplayName: messageReceivedPayload.senderDisplayName,
            createdOn: Iso8601Date(string: messageReceivedPayload.originalArrivalTime),
            version: messageReceivedPayload.version,
            type: ChatMessageType(messageReceivedPayload.messageType)
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

    init(from request: TrouterRequest) throws {
        guard let requestJsonData = request.body.data(using: .utf8) else {
            throw AzureError.client("Unable to convert request body to Data.")
        }

        let chatMessageEditedPayload: MessageEditedPayload = try JSONDecoder()
            .decode(MessageEditedPayload.self, from: requestJsonData)

        self.message = chatMessageEditedPayload.messageBody
        self.editedOn = Iso8601Date(string: chatMessageEditedPayload.edittime)
        super.init(
            threadId: chatMessageEditedPayload.groupId,
            sender: TrouterEventUtil.getIdentifier(from: chatMessageEditedPayload.senderId),
            recipient: TrouterEventUtil.getIdentifier(from: chatMessageEditedPayload.recipientId),
            id: chatMessageEditedPayload.messageId,
            senderDisplayName: chatMessageEditedPayload.senderDisplayName,
            createdOn: Iso8601Date(string: chatMessageEditedPayload.originalArrivalTime),
            version: chatMessageEditedPayload.version,
            type: ChatMessageType(chatMessageEditedPayload.messageType)
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

    init(from request: TrouterRequest) throws {
        guard let requestJsonData = request.body.data(using: .utf8) else {
            throw AzureError.client("Unable to convert request body to Data.")
        }

        let chatMessageDeletedPayload: MessageDeletedPayload = try JSONDecoder()
            .decode(MessageDeletedPayload.self, from: requestJsonData)

        self.deletedOn = Iso8601Date(string: chatMessageDeletedPayload.deletetime)
        super.init(
            threadId: chatMessageDeletedPayload.groupId,
            sender: TrouterEventUtil.getIdentifier(from: chatMessageDeletedPayload.senderId),
            recipient: TrouterEventUtil.getIdentifier(from: chatMessageDeletedPayload.recipientId),
            id: chatMessageDeletedPayload.messageId,
            senderDisplayName: chatMessageDeletedPayload.senderDisplayName,
            createdOn: Iso8601Date(string: chatMessageDeletedPayload.originalArrivalTime),
            version: chatMessageDeletedPayload.version,
            type: ChatMessageType(chatMessageDeletedPayload.messageType)
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

    init(from request: TrouterRequest) throws {
        guard let requestJsonData = request.body.data(using: .utf8) else {
            throw AzureError.client("Unable to convert request body to Data.")
        }

        let typingIndicatorReceivedPayload: TypingIndicatorReceivedPayload = try JSONDecoder()
            .decode(TypingIndicatorReceivedPayload.self, from: requestJsonData)

        self.version = typingIndicatorReceivedPayload.version
        self.receivedOn = Iso8601Date(string: typingIndicatorReceivedPayload.originalArrivalTime)

        super.init(
            threadId: typingIndicatorReceivedPayload.groupId,
            sender: TrouterEventUtil.getIdentifier(from: typingIndicatorReceivedPayload.senderId),
            recipient: TrouterEventUtil.getIdentifier(from: typingIndicatorReceivedPayload.recipientId)
        )
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

        let consumptionHorizon = readReceiptMessageBody.consumptionhorizon.split(separator: ";")
        let readOn = String(consumptionHorizon[1])

        self.chatMessageId = readReceiptReceivedPayload.messageId
        self.readOn = Iso8601Date(string: readOn)
        super.init(
            threadId: readReceiptReceivedPayload.groupId,
            sender: TrouterEventUtil.getIdentifier(from: readReceiptReceivedPayload.senderId),
            recipient: TrouterEventUtil.getIdentifier(from: readReceiptReceivedPayload.recipientId)
        )
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
                id: TrouterEventUtil.getIdentifier(from: createdByPayload.participantId),
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
                    id: TrouterEventUtil.getIdentifier(from: memberPayload.participantId),
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
                id: TrouterEventUtil.getIdentifier(from: updatedByPayload.participantId),
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
            id: TrouterEventUtil.getIdentifier(from: deletedByPayload.participantId),
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
            id: TrouterEventUtil.getIdentifier(from: addedByPayload.participantId),
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
                    id: TrouterEventUtil.getIdentifier(from: memberPayload.participantId),
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
            id: TrouterEventUtil.getIdentifier(from: removedByPayload.participantId),
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
                    id: TrouterEventUtil.getIdentifier(from: memberPayload.participantId),
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
