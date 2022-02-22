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

import AzureCore
import Foundation

/// PushNotificationEventHandler for handling push notifications.
public typealias PushNotificationEventHandler = (_ response: PushNotificationEvent?, _ error: Error?) -> Void

/// PushNotificationEvents.
public enum PushNotificationEvent {
    case chatMessageReceivedEvent(ChatMessageReceivedEvent)
    case typingIndicatorReceived(TypingIndicatorReceivedEvent)
    case readReceiptReceived(ReadReceiptReceivedEvent)
    case chatMessageEdited(ChatMessageEditedEvent)
    case chatMessageDeleted(ChatMessageDeletedEvent)
    case chatThreadCreated(ChatThreadCreatedEvent)
    case chatThreadPropertiesUpdated(ChatThreadPropertiesUpdatedEvent)
    case chatThreadDeleted(ChatThreadDeletedEvent)
    case participantsAdded(ParticipantsAddedEvent)
    case participantsRemoved(ParticipantsRemovedEvent)

    /// Initialize a PushNotificationEvent given the ChatEventId and the event payload data.
    /// - Parameters:
    ///   - chatEventId: The ChatEventId.
    ///   - data: The payload Data.
    init(chatEventId: ChatEventId, from data: Data) throws {
        switch chatEventId {
        case ChatEventId.chatMessageReceived:
            let event = try ChatMessageReceivedEvent(from: data)
            self = .chatMessageReceivedEvent(event)
        case .chatMessageEdited:
            let event = try ChatMessageEditedEvent(from: data)
            self = .chatMessageEdited(event)
        case .chatMessageDeleted:
            let event = try ChatMessageDeletedEvent(from: data)
            self = .chatMessageDeleted(event)
        case .chatThreadCreated:
            let event = try ChatThreadCreatedEvent(from: data)
            self = .chatThreadCreated(event)
        case .chatThreadPropertiesUpdated:
            let event = try ChatThreadPropertiesUpdatedEvent(from: data)
            self = .chatThreadPropertiesUpdated(event)
        case .chatThreadDeleted:
            let event = try ChatThreadDeletedEvent(from: data)
            self = .chatThreadDeleted(event)
        case .participantsAdded:
            let event = try ParticipantsAddedEvent(from: data)
            self = .participantsAdded(event)
        case .participantsRemoved:
            let event = try ParticipantsRemovedEvent(from: data)
            self = .participantsRemoved(event)
        case .readReceiptReceived:
            throw AzureError.client("Event 'readReceiptReceived' is unsupported")
        case .typingIndicatorReceived:
            throw AzureError.client("Event 'typingIndicatorReceived' is unsupported")
        }
    }
}
