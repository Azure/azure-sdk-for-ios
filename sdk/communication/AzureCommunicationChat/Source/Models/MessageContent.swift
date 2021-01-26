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

/// Content of a message.
public struct MessageContent: Codable {
    // MARK: Properties

    /// Chat message content for messages of types text or html.
    public let message: String?
    /// Chat message content for messages of type topicUpdated.
    public let topic: String?
    /// Chat message content for messages of types participantAdded or participantRemoved.
    public let participants: [Participant]?
    /// Chat message content for messages of types participantAdded or participantRemoved.
    public let initiator: String?

    // MARK: Initializers

    /// Initializes a `MessageContent` structure from a ChatMessageContent.
    /// - Parameters:
    ///   - chatMessageContent: ChatMessageContent to initialize from.
    public init(
        from chatMessageContent: ChatMessageContent
    ) {
        self.message = chatMessageContent.message
        self.topic = chatMessageContent.topic
        self.participants = (chatMessageContent.participants != nil) ? chatMessageContent.participants!
            .map { Participant(from: $0) } : nil
        self.initiator = chatMessageContent.initiator
    }

    /// Initialize a `MessageContent` structure.
    /// - Parameters:
    ///   - message: Message content for messages of types text or html.
    ///   - topic: Message content for messages of type topicUpdated.
    ///   - participants: Message content for messages of types participantAdded or participantRemoved.
    ///   - initiator: Message content for messages of types participantAdded or participantRemoved.
    public init(
        message: String? = nil,
        topic: String? = nil,
        participants: [Participant]? = nil,
        initiator: String? = nil
    ) {
        self.message = message
        self.topic = topic
        self.participants = participants
        self.initiator = initiator
    }

    // MARK: Codable

    enum CodingKeys: String, CodingKey {
        case message
        case topic
        case participants
        case initiator
    }

    /// Initialize a `MessageContent` structure from decoder
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.message = try? container.decode(String.self, forKey: .message)
        self.topic = try? container.decode(String.self, forKey: .topic)

        // Convert ChatParticipants to Participants
        let chatParticipants = try? container.decode([ChatParticipant].self, forKey: .participants)
        self.participants = (chatParticipants != nil) ?
            chatParticipants!.map { Participant(from: $0) } : nil

        self.initiator = try? container.decode(String.self, forKey: .initiator)
    }

    /// Encode a `MessageContent` structure
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if message != nil { try? container.encode(message, forKey: .message) }
        if topic != nil { try? container.encode(topic, forKey: .topic) }

        // Encode Participant to ChatParticipant format
        if participants != nil {
            let test = participants!.map {
                ChatParticipant(
                    id: $0.user.identifier,
                    displayName: $0.displayName,
                    shareHistoryTime: $0.shareHistoryTime
                )
            }
            try? container.encode(test, forKey: .participants)
        }

        if initiator != nil { try? container.encode(initiator, forKey: .initiator) }
    }
}
