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

import AzureCommunicationCommon
import AzureCore
import Foundation

/// Chat message.
public struct ChatMessage: Codable {
    // MARK: Properties

    /// The id of the message. This id is server generated.
    public let id: String
    /// The message type.
    public let type: ChatMessageType
    /// Sequence of the message in the conversation.
    public let sequenceId: String
    /// Version of the message.
    public let version: String
    /// Content of the message.
    public let content: ChatMessageContent?
    /// The display name of the message sender. This property is used to populate sender name for push notifications.
    public let senderDisplayName: String?
    /// The timestamp when the message arrived at the server. The timestamp is in RFC3339 format:
    /// `yyyy-MM-ddTHH:mm:ssZ`.
    public let createdOn: Iso8601Date
    /// The sender of the message.
    public let sender: CommunicationIdentifier?
    /// The timestamp (if applicable) when the message was deleted. The timestamp is in RFC3339 format:
    /// `yyyy-MM-ddTHH:mm:ssZ`.
    public let deletedOn: Iso8601Date?
    /// The last timestamp (if applicable) when the message was edited. The timestamp is in RFC3339 format:
    /// `yyyy-MM-ddTHH:mm:ssZ`.
    public let editedOn: Iso8601Date?
    /// Optional metadata provided when sending the ChatMessage, data is stringified.
    public let metadata: [String: String?]?

    // MARK: Initializers

    /// Initialize a `ChatMessage` structure from a ChatMessageInternal.
    /// - Parameters:
    ///   - chatMessage: The ChatMessageInternal to initialize from.
    internal init(
        from chatMessageInternal: ChatMessageInternal
    ) throws {
        self.id = chatMessageInternal.id
        self.type = chatMessageInternal.type
        self.sequenceId = chatMessageInternal.sequenceId
        self.version = chatMessageInternal.version

        // Convert ChatMessageContentInternal to ChatMessageContent
        if let content = chatMessageInternal.content {
            self.content = try ChatMessageContent(from: content)
        } else {
            self.content = nil
        }

        self.senderDisplayName = chatMessageInternal.senderDisplayName
        self.createdOn = chatMessageInternal.createdOn

        // Deserialize the identifier model to CommunicationIdentifier
        if let identifierModel = chatMessageInternal.senderCommunicationIdentifier {
            self.sender = try IdentifierSerializer.deserialize(identifier: identifierModel)
        } else {
            self.sender = nil
        }

        self.deletedOn = chatMessageInternal.deletedOn
        self.editedOn = chatMessageInternal.editedOn
        self.metadata = chatMessageInternal.metadata
    }

    /// Initialize a `ChatMessage` structure.
    /// - Parameters:
    ///   - id: The id of the message. This id is server generated.
    ///   - type: The chat message type.
    ///   - sequenceId: Sequence of the message in the conversation.
    ///   - version: Version of the message.
    ///   - content: Content of a message.
    ///   - senderDisplayName: The display name of the message sender. This property is used to populate sender name for
    /// push notifications.
    ///   - createdOn: The timestamp when the message arrived at the server. The timestamp is in RFC3339 format:
    /// `yyyy-MM-ddTHH:mm:ssZ`.
    ///   - sender: The sender of the message.
    ///   - deletedOn: The timestamp (if applicable) when the message was deleted. The timestamp is in RFC3339 format:
    /// `yyyy-MM-ddTHH:mm:ssZ`.
    ///   - editedOn: The last timestamp (if applicable) when the message was edited. The timestamp is in RFC3339
    /// format: `yyyy-MM-ddTHH:mm:ssZ`.
    public init(
        id: String,
        type: ChatMessageType,
        sequenceId: String,
        version: String,
        content: ChatMessageContent? = nil,
        senderDisplayName: String? = nil,
        createdOn: Iso8601Date,
        sender: CommunicationIdentifier? = nil,
        deletedOn: Iso8601Date? = nil,
        editedOn: Iso8601Date? = nil,
        metadata: [String: String?]? = nil
    ) {
        self.id = id
        self.type = type
        self.sequenceId = sequenceId
        self.version = version
        self.content = content
        self.senderDisplayName = senderDisplayName
        self.createdOn = createdOn
        self.sender = sender
        self.deletedOn = deletedOn
        self.editedOn = editedOn
        self.metadata = metadata
    }

    // MARK: Codable

    enum CodingKeys: String, CodingKey {
        case id
        case type
        case sequenceId
        case version
        case content
        case senderDisplayName
        case createdOn
        case sender = "senderCommunicationIdentifier"
        case deletedOn
        case editedOn
        case metadata
    }

    /// Initialize a `ChatMessage` structure from decoder
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(String.self, forKey: .id)
        self.type = try container.decode(ChatMessageType.self, forKey: .type)
        self.sequenceId = try container.decode(String.self, forKey: .sequenceId)
        self.version = try container.decode(String.self, forKey: .version)

        // Convert ChatMessageContentInternal to ChatMessageContent
        let chatMessageContent = try? container.decode(ChatMessageContentInternal.self, forKey: .content)
        self.content = try? ChatMessageContent(from: chatMessageContent)

        self.senderDisplayName = try? container.decode(String.self, forKey: .senderDisplayName)
        self.createdOn = try container.decode(Iso8601Date.self, forKey: .createdOn)

        // Decode CommunicationIdentifierModel to CommunicationIdentifier
        if let identifierModel = try? container.decode(CommunicationIdentifierModelInternal.self, forKey: .sender) {
            self.sender = try IdentifierSerializer
                .deserialize(identifier: identifierModel)
        } else {
            self.sender = nil
        }

        self.deletedOn = try? container.decode(Iso8601Date.self, forKey: .deletedOn)
        self.editedOn = try? container.decode(Iso8601Date.self, forKey: .editedOn)
        self.metadata = try? container.decode([String: String?].self, forKey: .metadata)
    }

    /// Encode a `ChatMessage` structure
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encode(sequenceId, forKey: .sequenceId)
        try container.encode(version, forKey: .version)
        if content != nil { try? container.encode(content, forKey: .content) }
        if senderDisplayName != nil { try? container.encode(senderDisplayName, forKey: .senderDisplayName) }
        try container.encode(createdOn, forKey: .createdOn)

        // Encode CommunicationIdentifier to CommunicationIdentifierModel
        if let identifier = sender {
            let identifierModel = try IdentifierSerializer.serialize(identifier: identifier)
            try? container.encode(identifierModel, forKey: .sender)
        }

        if deletedOn != nil { try? container.encode(deletedOn, forKey: .deletedOn) }
        if editedOn != nil { try? container.encode(editedOn, forKey: .editedOn) }
    }
}
