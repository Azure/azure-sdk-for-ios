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
import Trouter

/// TrouterEventHandler for handling real-time notifications.
public typealias TrouterEventHandler = (_ response: TrouterEvent) -> Void

/// TrouterEvents.
public enum TrouterEvent {
    case realTimeNotificationConnected
    case realTimeNotificationDisconnected
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

    /// Initialize a TrouterEvent given the ChatEventId and the TrouterRequest that contains the event data.
    /// - Parameters:
    ///   - chatEventId: The ChatEventId.
    ///   - request: The TrouterRequest that contains the event data.
    init(chatEventId: ChatEventId, from trouterRequest: TrouterRequest?) throws {
        if chatEventId == ChatEventId.realTimeNotificationConnected {
            self = .realTimeNotificationConnected
            return
        }
        if chatEventId == ChatEventId.realTimeNotificationDisconnected {
            self = .realTimeNotificationDisconnected
            return
        }

        guard let request = trouterRequest else {
            throw AzureError.client("Unable to convert request body to Data.")
        }

        switch chatEventId {
        case .realTimeNotificationConnected:
            self = .realTimeNotificationConnected
        case .realTimeNotificationDisconnected:
            self = .realTimeNotificationDisconnected
        case .chatMessageReceived:
            let event = try ChatMessageReceivedEvent(from: request)
            self = .chatMessageReceivedEvent(event)
        case .typingIndicatorReceived:
            let event = try TypingIndicatorReceivedEvent(from: request)
            self = .typingIndicatorReceived(event)
        case .readReceiptReceived:
            let event = try ReadReceiptReceivedEvent(from: request)
            self = .readReceiptReceived(event)
        case .chatMessageEdited:
            let event = try ChatMessageEditedEvent(from: request)
            self = .chatMessageEdited(event)
        case .chatMessageDeleted:
            let event = try ChatMessageDeletedEvent(from: request)
            self = .chatMessageDeleted(event)
        case .chatThreadCreated:
            let event = try ChatThreadCreatedEvent(from: request)
            self = .chatThreadCreated(event)
        case .chatThreadPropertiesUpdated:
            let event = try ChatThreadPropertiesUpdatedEvent(from: request)
            self = .chatThreadPropertiesUpdated(event)
        case .chatThreadDeleted:
            let event = try ChatThreadDeletedEvent(from: request)
            self = .chatThreadDeleted(event)
        case .participantsAdded:
            let event = try ParticipantsAddedEvent(from: request)
            self = .participantsAdded(event)
        case .participantsRemoved:
            let event = try ParticipantsRemovedEvent(from: request)
            self = .participantsRemoved(event)
        }
    }
}
