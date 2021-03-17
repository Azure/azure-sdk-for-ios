//
//  TrouterUtils.swift
//  AzureCommunicationSignaling
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunication
import AzureCore
import Foundation
import TrouterModulePrivate

func toEventPayload(request: TrouterRequest, chatEventId: ChatEventId) -> Any? {
    do {
        switch chatEventId {
        case ChatEventId.chatMessageReceived:
            return try toChatMessageReceivedEvent(request: request)
        case ChatEventId.typingIndicatorReceived:
            return try toTypingIndicatorReceivedEvent(request: request)
        case ChatEventId.readReceiptReceived:
            return try toReadReceiptReceivedEvent(request: request)
        case ChatEventId.chatMessageEdited:
            return try toChatMessageEditedEvent(request: request)
        case ChatEventId.chatMessageDeleted:
            return try toChatMessageDeletedEvent(request: request)
        case ChatEventId.chatThreadCreated:
            return try toChatThreadCreatedEvent(request: request)
        case ChatEventId.chatThreadPropertiesUpdated:
            return try toChatThreadPropertiesUpdatedEvent(request: request)
        case ChatEventId.chatThreadDeleted:
            return try toChatThreadDeletedEvent(request: request)
        case ChatEventId.participantsAdded:
            return try toParticipantsAddedEvent(request: request)
        case ChatEventId.participantsRemoved:
            return try toParticipantsRemovedEvent(request: request)
        }
    } catch {
        return nil
    }
}

func toChatMessageReceivedEvent(request: TrouterRequest) throws -> ChatMessageReceivedEvent {
    do {
        let requestJsonData = request.body.data(using: .utf8)!
        let messageReceivedPayload: MessageReceivedPayload = try JSONDecoder()
            .decode(MessageReceivedPayload.self, from: requestJsonData)

        let chatMessageReceivedEvent =
            ChatMessageReceivedEvent(
                threadId: messageReceivedPayload.groupId,
                sender: getIdentifier(from: messageReceivedPayload.senderId),
                recipient: getIdentifier(from: messageReceivedPayload.recipientId),
                id: messageReceivedPayload.messageId,
                senderDisplayName: messageReceivedPayload.senderDisplayName,
                createdOn: Iso8601Date(string: messageReceivedPayload.originalArrivalTime),
                version: messageReceivedPayload.version,
                type: ChatMessageType(messageReceivedPayload.messageType),
                message: messageReceivedPayload.messageBody
            )

        return chatMessageReceivedEvent
    } catch {
        throw AzureError.client("Unable to decode with error: \(error)")
    }
}

func toTypingIndicatorReceivedEvent(request: TrouterRequest) throws -> TypingIndicatorReceivedEvent {
    do {
        let requestJsonData = request.body.data(using: .utf8)!
        let typingIndicatorReceivedPayload: TypingIndicatorReceivedPayload = try JSONDecoder()
            .decode(TypingIndicatorReceivedPayload.self, from: requestJsonData)

        let typingIndicatorReceivedEvent =
            TypingIndicatorReceivedEvent(
                threadId: typingIndicatorReceivedPayload.groupId,
                sender: getIdentifier(from: typingIndicatorReceivedPayload.senderId),
                recipient: getIdentifier(from: typingIndicatorReceivedPayload.recipientId),
                version: typingIndicatorReceivedPayload.version,
                receivedOn: Iso8601Date(string: typingIndicatorReceivedPayload.originalArrivalTime)
            )

        return typingIndicatorReceivedEvent
    } catch {
        throw AzureError.client("Unable to decode with error: \(error)")
    }
}

func toReadReceiptReceivedEvent(request: TrouterRequest) throws -> ReadReceiptReceivedEvent {
    do {
        let requestJsonData = request.body.data(using: .utf8)!
        let readReceiptReceivedPayload: ReadReceiptReceivedPayload = try JSONDecoder()
            .decode(ReadReceiptReceivedPayload.self, from: requestJsonData)

        let readReceiptMessageBodyJsonData = (readReceiptReceivedPayload.messageBody.data(using: .utf8))!

        let readReceiptMessageBody: ReadReceiptMessageBody = try JSONDecoder()
            .decode(ReadReceiptMessageBody.self, from: readReceiptMessageBodyJsonData)

        let consumptionHorizon = readReceiptMessageBody.consumptionhorizon.split(separator: ";")

        let readOn = String(consumptionHorizon[1])

        let readReceiptEvent =
            ReadReceiptReceivedEvent(
                threadId: readReceiptReceivedPayload.groupId,
                sender: getIdentifier(from: readReceiptReceivedPayload.senderId),
                recipient: getIdentifier(from: readReceiptReceivedPayload.recipientId),
                chatMessageId: readReceiptReceivedPayload.messageId,
                readOn: Iso8601Date(string: readOn)
            )

        return readReceiptEvent

    } catch {
        throw AzureError.client("Unable to decode with error: \(error)")
    }
}

func toChatMessageEditedEvent(request: TrouterRequest) throws -> ChatMessageEditedEvent {
    do {
        let requestJsonData = request.body.data(using: .utf8)!
        let chatMessageEditedPayload: MessageEditedPayload = try JSONDecoder()
            .decode(MessageEditedPayload.self, from: requestJsonData)

        let chatMessageEditedEvent =
            ChatMessageEditedEvent(
                threadId: chatMessageEditedPayload.groupId,
                sender: getIdentifier(from: chatMessageEditedPayload.senderId),
                recipient: getIdentifier(from: chatMessageEditedPayload.recipientId),
                id: chatMessageEditedPayload.messageId,
                senderDisplayName: chatMessageEditedPayload.senderDisplayName,
                createdOn: Iso8601Date(string: chatMessageEditedPayload.originalArrivalTime),
                version: chatMessageEditedPayload.version,
                type: ChatMessageType(chatMessageEditedPayload.messageType),
                message: chatMessageEditedPayload.messageBody,
                editedOn: Iso8601Date(string: chatMessageEditedPayload.edittime)
            )

        return chatMessageEditedEvent
    } catch {
        throw AzureError.client("Unable to decode with error: \(error)")
    }
}

func toChatMessageDeletedEvent(request: TrouterRequest) throws -> ChatMessageDeletedEvent {
    do {
        let requestJsonData = request.body.data(using: .utf8)!
        let chatMessageDeletedPayload: MessageDeletedPayload = try JSONDecoder()
            .decode(MessageDeletedPayload.self, from: requestJsonData)

        let chatMessageDeletedEvent =
            ChatMessageDeletedEvent(
                threadId: chatMessageDeletedPayload.groupId,
                sender: getIdentifier(from: chatMessageDeletedPayload.senderId),
                recipient: getIdentifier(from: chatMessageDeletedPayload.recipientId),
                id: chatMessageDeletedPayload.messageId,
                senderDisplayName: chatMessageDeletedPayload.senderDisplayName,
                createdOn: Iso8601Date(string: chatMessageDeletedPayload.originalArrivalTime),
                version: chatMessageDeletedPayload.version,
                type: ChatMessageType(chatMessageDeletedPayload.messageType),
                deletedOn: Iso8601Date(string: chatMessageDeletedPayload.deletetime)
            )

        return chatMessageDeletedEvent
    } catch {
        throw AzureError.client("Unable to decode with error: \(error)")
    }
}

func toChatThreadCreatedEvent(request: TrouterRequest) throws -> ChatThreadCreatedEvent {
    do {
        let requestJsonData = request.body.data(using: .utf8)!
        let chatThreadCreatedPayload: ChatThreadCreatedPayload = try JSONDecoder()
            .decode(ChatThreadCreatedPayload.self, from: requestJsonData)

        let createdByJsonData = (chatThreadCreatedPayload.createdBy.data(using: .utf8))!
        let createdByPayload: ChatParticipantPayload = try JSONDecoder()
            .decode(ChatParticipantPayload.self, from: createdByJsonData)
        let createdBy =
            SignalingChatParticipant(
                id: getIdentifier(from: createdByPayload.participantId),
                displayName: createdByPayload.displayName
            )

        let membersJsonData = (chatThreadCreatedPayload.members.data(using: .utf8))!
        let membersPayload: [ChatParticipantPayload] = try JSONDecoder()
            .decode([ChatParticipantPayload].self, from: membersJsonData)
        let participants: [SignalingChatParticipant] = membersPayload
            .map { (memberPayload: ChatParticipantPayload) -> SignalingChatParticipant in
                SignalingChatParticipant(
                    id: getIdentifier(from: memberPayload.participantId),
                    displayName: memberPayload.displayName
                )
            }

        let propertiesJsonData = (chatThreadCreatedPayload.properties.data(using: .utf8))!
        let propertiesPayload: ChatThreadPropertiesPayload = try JSONDecoder()
            .decode(ChatThreadPropertiesPayload.self, from: propertiesJsonData)
        let properties = SignalingChatThreadProperties(topic: propertiesPayload.topic)

        let chatThreadCreatedEvent =
            ChatThreadCreatedEvent(
                threadId: chatThreadCreatedPayload.threadId,
                version: chatThreadCreatedPayload.version,
                createdOn: Iso8601Date(string: chatThreadCreatedPayload.createTime),
                properties: properties,
                participants: participants,
                createdBy: createdBy
            )

        return chatThreadCreatedEvent
    } catch {
        throw AzureError.client("Unable to decode with error: \(error)")
    }
}

func toChatThreadPropertiesUpdatedEvent(request: TrouterRequest) throws -> ChatThreadPropertiesUpdatedEvent {
    do {
        let requestJsonData = request.body.data(using: .utf8)!
        let chatThreadPropertiesUpdatedPayload: ChatThreadPropertiesUpdatedPayload = try JSONDecoder()
            .decode(ChatThreadPropertiesUpdatedPayload.self, from: requestJsonData)

        let updatedByJsonData = (chatThreadPropertiesUpdatedPayload.editedBy.data(using: .utf8))!
        let updatedByPayload: ChatParticipantPayload = try JSONDecoder()
            .decode(ChatParticipantPayload.self, from: updatedByJsonData)
        let updatedBy =
            SignalingChatParticipant(
                id: getIdentifier(from: updatedByPayload.participantId),
                displayName: updatedByPayload.displayName
            )

        let propertiesJsonData = (chatThreadPropertiesUpdatedPayload.properties.data(using: .utf8))!
        let propertiesPayload: ChatThreadPropertiesPayload = try JSONDecoder()
            .decode(ChatThreadPropertiesPayload.self, from: propertiesJsonData)
        let properties = SignalingChatThreadProperties(topic: propertiesPayload.topic)

        let chatThreadPropertiesUpdatedEvent =
            ChatThreadPropertiesUpdatedEvent(
                threadId: chatThreadPropertiesUpdatedPayload.threadId,
                version: chatThreadPropertiesUpdatedPayload.version,
                properties: properties,
                updatedOn: Iso8601Date(string: chatThreadPropertiesUpdatedPayload.editTime),
                updatedBy: updatedBy
            )

        return chatThreadPropertiesUpdatedEvent

    } catch {
        throw AzureError.client("Unable to decode with error: \(error)")
    }
}

func toChatThreadDeletedEvent(request: TrouterRequest) throws -> ChatThreadDeletedEvent {
    do {
        let requestJsonData = request.body.data(using: .utf8)!
        let chatThreadDeletedPayload: ChatThreadDeletedPayload = try JSONDecoder()
            .decode(ChatThreadDeletedPayload.self, from: requestJsonData)

        let deletedByJsonData = (chatThreadDeletedPayload.deletedBy.data(using: .utf8))!
        let deletedByPayload: ChatParticipantPayload = try JSONDecoder()
            .decode(ChatParticipantPayload.self, from: deletedByJsonData)
        let deletedBy = SignalingChatParticipant(
            id: getIdentifier(from: deletedByPayload.participantId),
            displayName: deletedByPayload.displayName
        )

        let chatThreadDeletedEvent =
            ChatThreadDeletedEvent(
                threadId: chatThreadDeletedPayload.threadId,
                version: chatThreadDeletedPayload.version,
                deletedOn: Iso8601Date(string: chatThreadDeletedPayload.deleteTime),
                deletedBy: deletedBy
            )

        return chatThreadDeletedEvent

    } catch {
        throw AzureError.client("Unable to decode with error: \(error)")
    }
}

func toParticipantsAddedEvent(request: TrouterRequest) throws -> ParticipantsAddedEvent {
    do {
        let requestJsonData = request.body.data(using: .utf8)!
        let participantsAddedPayload: ParticipantsAddedPayload = try JSONDecoder()
            .decode(ParticipantsAddedPayload.self, from: requestJsonData)

        let addeddByJsonData = (participantsAddedPayload.addedBy.data(using: .utf8))!
        let addedByPayload: ChatParticipantPayload = try JSONDecoder()
            .decode(ChatParticipantPayload.self, from: addeddByJsonData)
        let addedBy = SignalingChatParticipant(
            id: getIdentifier(from: addedByPayload.participantId),
            displayName: addedByPayload.displayName
        )

        let participantsJsonData = (participantsAddedPayload.participantsAdded.data(using: .utf8))!
        let participantsPayload: [ChatParticipantPayload] = try JSONDecoder()
            .decode([ChatParticipantPayload].self, from: participantsJsonData)

        let participants: [SignalingChatParticipant] = participantsPayload
            .map { (memberPayload: ChatParticipantPayload) -> SignalingChatParticipant in
                SignalingChatParticipant(
                    id: getIdentifier(from: memberPayload.participantId),
                    displayName: memberPayload.displayName,
                    shareHistoryTime: Iso8601Date(string: toISO8601Date(unixTime: memberPayload.shareHistoryTime))
                )
            }

        let participantsAddedEvent =
            ParticipantsAddedEvent(
                threadId: participantsAddedPayload.threadId,
                version: participantsAddedPayload.version,
                addedOn: Iso8601Date(string: participantsAddedPayload.time),
                participantsAdded: participants,
                addedBy: addedBy
            )

        return participantsAddedEvent
    } catch {
        throw AzureError.client("Unable to decode with error: \(error)")
    }
}

func toParticipantsRemovedEvent(request: TrouterRequest) throws -> ParticipantsRemovedEvent {
    do {
        let requestJsonData = request.body.data(using: .utf8)!
        let participantsRemovedPayload: ParticipantsRemovedPayload = try JSONDecoder()
            .decode(ParticipantsRemovedPayload.self, from: requestJsonData)

        let removedByJsonData = (participantsRemovedPayload.removedBy.data(using: .utf8))!
        let removedByPayload: ChatParticipantPayload = try JSONDecoder()
            .decode(ChatParticipantPayload.self, from: removedByJsonData)
        let removedBy = SignalingChatParticipant(
            id: getIdentifier(from: removedByPayload.participantId),
            displayName: removedByPayload.displayName
        )

        let participantsJsonData = (participantsRemovedPayload.participantsRemoved.data(using: .utf8))!
        let participantsPayload: [ChatParticipantPayload] = try JSONDecoder()
            .decode([ChatParticipantPayload].self, from: participantsJsonData)
        let participants: [SignalingChatParticipant] = participantsPayload
            .map { (memberPayload: ChatParticipantPayload) -> SignalingChatParticipant in
                SignalingChatParticipant(
                    id: getIdentifier(from: memberPayload.participantId),
                    displayName: memberPayload.displayName,
                    shareHistoryTime: Iso8601Date(string: toISO8601Date(unixTime: memberPayload.shareHistoryTime))
                )
            }

        let participantsRemovedEvent =
            ParticipantsRemovedEvent(
                threadId: participantsRemovedPayload.threadId,
                version: participantsRemovedPayload.version,
                removedOn: Iso8601Date(string: participantsRemovedPayload.time),
                participantsRemoved: participants,
                removedBy: removedBy
            )

        return participantsRemovedEvent
    } catch {
        throw AzureError.client("Unable to decode with error: \(error)")
    }
}

func toISO8601Date(unixTime: Int? = 0) -> String {
    let unixTimeInMilliSeconds = Double(unixTime ?? 0) / 1000
    let date = Date(timeIntervalSince1970: TimeInterval(unixTimeInMilliSeconds))
    let iso8601DateFormatter = ISO8601DateFormatter()
    iso8601DateFormatter.formatOptions = [.withInternetDateTime]
    return iso8601DateFormatter.string(from: date)
}

/// Parses out the id/phone number portion of an MRI.
/// - Parameters:
///   - mri: The original MRI.
///   - prefix: The MRI prefix.
/// - Returns: The part of the MRI after the prefix that corresponds to the id or phone number of a user.
func parse(mri: String, prefix: String) -> String {
    let index = mri.index(mri.startIndex, offsetBy: prefix.count)
    return String(mri.suffix(from: index))
}

/// Constructs a CommunicationIdentifier from an MRI.
/// - Parameter mri: The MRI.
/// - Returns: The CommunicationIdentifier.
func getIdentifier(from mri: String) -> CommunicationIdentifier {
    let publicTeamsUserPrefix = "8:orgid:"
    let dodTeamsUserPrefix = "8:dod:"
    let gcchTeamsUserPrefix = "8:gcch:"
    let teamsVisitorUserPrefix = "8:teamsvisitor:"
    let phoneNumberPrefix = "4:"
    let acsUserPrefix = "8:acs:"
    let spoolUserPrefix = "8:spool:"

    if mri.starts(with: publicTeamsUserPrefix) {
        return MicrosoftTeamsUserIdentifier(
            userId: parse(mri: mri, prefix: publicTeamsUserPrefix),
            isAnonymous: false,
            rawId: mri,
            cloudEnvironment: CommunicationCloudEnvironment.Public
        )
    } else if mri.starts(with: dodTeamsUserPrefix) {
        return MicrosoftTeamsUserIdentifier(
            userId: parse(mri: mri, prefix: dodTeamsUserPrefix),
            isAnonymous: false,
            rawId: mri,
            cloudEnvironment: CommunicationCloudEnvironment.Dod
        )
    } else if mri.starts(with: gcchTeamsUserPrefix) {
        return MicrosoftTeamsUserIdentifier(
            userId: parse(mri: mri, prefix: gcchTeamsUserPrefix),
            isAnonymous: false,
            rawId: mri,
            cloudEnvironment: CommunicationCloudEnvironment.Gcch
        )
    } else if mri.starts(with: teamsVisitorUserPrefix) {
        return MicrosoftTeamsUserIdentifier(
            userId: parse(mri: mri, prefix: teamsVisitorUserPrefix),
            isAnonymous: true
        )
    } else if mri.starts(with: phoneNumberPrefix) {
        return PhoneNumberIdentifier(
            phoneNumber: parse(mri: mri, prefix: phoneNumberPrefix),
            rawId: mri
        )
    } else if mri.starts(with: acsUserPrefix) || mri.starts(with: spoolUserPrefix) {
        return CommunicationUserIdentifier(mri)
    } else {
        return UnknownIdentifier(mri)
    }
}
