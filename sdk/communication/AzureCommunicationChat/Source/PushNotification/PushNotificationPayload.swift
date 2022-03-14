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

struct PushNotificationBasePayload: Codable {
    let eventId: Int
    let senderId: String
    let recipientId: String
    let groupId: String
}

struct PushNotificationMessageReceivedPayload: Decodable {
    let eventId: Int
    let senderId: String
    let recipientId: String
    let transactionId: String
    let groupId: String
    let messageId: String
    let messageType: String
    let messageBody: String
    let senderDisplayName: String
    let clientMessageId: String
    let originalArrivalTime: String
    let priority: String
    let version: String

    // TODO: add the below field after PNH template is modified
    // let acsChatMessageMetadata: String
}

struct PushNotificationMessageEditedPayload: Decodable {
    let eventId: Int
    let senderId: String
    let recipientId: String
    let groupId: String
    let messageId: String
    let clientMessageId: String
    let senderDisplayName: String
    let messageBody: String
    let version: String
    let edittime: String
    let messageType: String
    let originalArrivalTime: String

    // TODO: add the field after PNH template is modified
    // let acsChatMessageMetadata: String
}

struct PushNotificationMessageDeletedPayload: Decodable {
    let eventId: Int
    let senderId: String
    let recipientId: String
    let groupId: String
    let messageId: String
    let clientMessageId: String
    let senderDisplayName: String
    let version: String
    let deletetime: String
    let messageType: String
    let originalArrivalTime: String
}

struct PushNotificationThreadCreatedPayload: Decodable {
    let eventId: Int
    let threadId: String
    let version: String
    let createTime: String
    let createdBy: String
    let members: String
    let properties: String
}

struct PushNotificationParticipantPayload: Decodable {
    let participantId: String
    let displayName: String?
}

struct PushNotificationChatThreadPropertiesPayload: Decodable {
    let topic: String
}

struct PushNotificationChatThreadPropertiesUpdatedPayload: Decodable {
    let eventId: Int
    let threadId: String
    let version: String
    let editTime: String
    let editedBy: String
    let properties: String
}

struct PushNotificationChatThreadDeletedPayload: Decodable {
    let eventId: Int
    let threadId: String
    let version: String
    let deleteTime: String
    let deletedBy: String
}

struct PushNotificationParticipantsAddedPayload: Decodable {
    let eventId: Int
    let threadId: String
    let version: String
    let time: String
    let addedBy: String
    let participantsAdded: String
}

struct PushNotificationParticipantsRemovedPayload: Decodable {
    let eventId: Int
    let threadId: String
    let version: String
    let time: String
    let removedBy: String
    let participantsRemoved: String
}
