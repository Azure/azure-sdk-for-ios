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
    case chatMessageReceivedEvent(PNChatMessageReceivedEvent)
    case chatMessageEditedEvent(PNChatMessageEditedEvent)
    case chatMessageDeletedEvent(PNChatMessageDeletedEvent)
    case chatThreadCreatedEvent(PNChatThreadCreatedEvent)
    case chatThreadPropertiesUpdatedEvent(PNChatThreadPropertiesUpdatedEvent)
    case chatThreadDeletedEvent(PNChatThreadDeletedEvent)
    case participantsAddedEvent(PNChatParticipantsAddedEvent)
    case participantsRemovedEvent(PNChatParticipantsRemovedEvent)

    /// Initialize a PushNotificationEvent given the ChatEventType and the event payload data.
    /// - Parameters:
    ///   - chatEventId: The ChatEventId.
    ///   - data: The payload Data.
    init(chatEventType: PushNotificationChatEventType, from data: Data) throws {
        switch chatEventType {
        case .chatMessageReceived:
            let event = try PNChatMessageReceivedEvent(from: data)
            self = .chatMessageReceivedEvent(event)
        case .chatMessageEdited:
            let event = try PNChatMessageEditedEvent(from: data)
            self = .chatMessageEditedEvent(event)
        case .chatMessageDeleted:
            let event = try PNChatMessageDeletedEvent(from: data)
            self = .chatMessageDeletedEvent(event)
        case .chatThreadCreated:
            let event = try PNChatThreadCreatedEvent(from: data)
            self = .chatThreadCreatedEvent(event)
        case .chatThreadPropertiesUpdated:
            let event = try PNChatThreadPropertiesUpdatedEvent(from: data)
            self = .chatThreadPropertiesUpdatedEvent(event)
        case .chatThreadDeleted:
            let event = try PNChatThreadDeletedEvent(from: data)
            self = .chatThreadDeletedEvent(event)
        case .participantsAdded:
            let event = try PNChatParticipantsAddedEvent(from: data)
            self = .participantsAddedEvent(event)
        case .participantsRemoved:
            let event = try PNChatParticipantsRemovedEvent(from: data)
            self = .participantsRemovedEvent(event)
        }
    }
}
