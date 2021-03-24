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

import Foundation

class BasePayload: Decodable {
    // swiftlint:disable identifier_name
    var _eventId: Int
    // swiftlint:enable identifier_name
    var senderId: String
    var recipientId: String
    var groupId: String
}

class MessageReceivedPayload: Decodable {
    // swiftlint:disable identifier_name
    var _eventId: Int
    // swiftlint:enable identifier_name
    var senderId: String
    var recipientId: String
    var transactionId: String
    var groupId: String
    var messageId: String
    var messageType: String
    var messageBody: String
    var senderDisplayName: String
    var clientMessageId: String
    var originalArrivalTime: String
    var priority: String
    var version: String
}

class TypingIndicatorReceivedPayload: Decodable {
    // swiftlint:disable identifier_name
    var _eventId: Int
    // swiftlint:enable identifier_name
    var senderId: String
    var recipientId: String
    var groupId: String
    var version: String
    var originalArrivalTime: String
}

class ReadReceiptMessageBody: Decodable {
    var user: String
    var consumptionhorizon: String
    var messageVisibilityTime: Int
    var version: String
}

class ReadReceiptReceivedPayload: Decodable {
    // swiftlint:disable identifier_name
    var _eventId: Int
    // swiftlint:enable identifier_name
    var senderId: String
    var recipientId: String
    var groupId: String
    var messageId: String
    var clientMessageId: String
    var messageBody: String
}

class MessageEditedPayload: Decodable {
    // swiftlint:disable identifier_name
    var _eventId: Int
    // swiftlint:enable identifier_name
    var senderId: String
    var recipientId: String
    var groupId: String
    var messageId: String
    var clientMessageId: String
    var senderDisplayName: String
    var messageBody: String
    var version: String
    var edittime: String
    var messageType: String
    var originalArrivalTime: String
}

class MessageDeletedPayload: Decodable {
    // swiftlint:disable identifier_name
    var _eventId: Int
    // swiftlint:enable identifier_name
    var senderId: String
    var recipientId: String
    var groupId: String
    var messageId: String
    var clientMessageId: String
    var senderDisplayName: String
    var version: String
    var deletetime: String
    var messageType: String
    var originalArrivalTime: String
}

class ChatThreadPayload: Decodable {
    // swiftlint:disable identifier_name
    var _eventId: Int
    // swiftlint:enable identifier_name
    var threadId: String
    var version: String
}

class ChatParticipantPayload: Decodable {
    var participantId: String
    var displayName: String
    var shareHistoryTime: Int?
}

class ChatThreadCreatedPayload: Decodable {
    // swiftlint:disable identifier_name
    var _eventId: Int
    // swiftlint:enable identifier_name
    var threadId: String
    var version: String
    var createTime: String
    var createdBy: String
    var members: String
    var properties: String
}

class ChatThreadPropertiesPayload: Decodable {
    var topic: String
}

class ChatThreadPropertiesUpdatedPayload: Decodable {
    // swiftlint:disable identifier_name
    var _eventId: Int
    // swiftlint:enable identifier_name
    var threadId: String
    var version: String
    var editTime: String
    var editedBy: String
    var properties: String
}

class ChatThreadDeletedPayload: Decodable {
    // swiftlint:disable identifier_name
    var _eventId: Int
    // swiftlint:enable identifier_name
    var threadId: String
    var version: String
    var deleteTime: String
    var deletedBy: String
}

class ParticipantsAddedPayload: Decodable {
    // swiftlint:disable identifier_name
    var _eventId: Int
    // swiftlint:enable identifier_name
    var threadId: String
    var version: String
    var time: String
    var addedBy: String
    var participantsAdded: String
}

class ParticipantsRemovedPayload: Decodable {
    // swiftlint:disable identifier_name
    var _eventId: Int
    // swiftlint:enable identifier_name
    var threadId: String
    var version: String
    var time: String
    var removedBy: String
    var participantsRemoved: String
}

var eventIds: [Int: ChatEventId] =
    [
        200: ChatEventId.chatMessageReceived,
        245: ChatEventId.typingIndicatorReceived,
        246: ChatEventId.readReceiptReceived,
        247: ChatEventId.chatMessageEdited,
        248: ChatEventId.chatMessageDeleted,
        257: ChatEventId.chatThreadCreated,
        258: ChatEventId.chatThreadPropertiesUpdated,
        259: ChatEventId.chatThreadDeleted,
        260: ChatEventId.participantsAdded,
        261: ChatEventId.participantsRemoved
    ]
