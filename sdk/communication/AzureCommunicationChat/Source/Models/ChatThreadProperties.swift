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

/// Chat thread properties.
public struct ChatThreadProperties: Codable {
    // MARK: Properties

    /// Thread id.
    public let id: String
    /// Thread topic.
    public let topic: String
    /// The timestamp when the thread was created. The timestamp is in RFC3339 format: `yyyy-MM-ddTHH:mm:ssZ`.
    public let createdOn: Iso8601Date
    /// CommunicationIdentifier of the thread owner.
    public let createdBy: CommunicationIdentifier
    /// The timestamp when the thread was deleted. The timestamp is in RFC3339 format: `yyyy-MM-ddTHH:mm:ssZ`.
    public let deletedOn: Iso8601Date?

    // MARK: Initializers

    /// Initialize a `ChatThreadProperties` structure from a ChatThread.
    /// - Parameters:
    ///   - chatThreadPropertiesInternal: The ChatThreadPropertiesInternal to initialize from.
    internal init(
        from chatThreadPropertiesInternal: ChatThreadPropertiesInternal
    ) throws {
        self.id = chatThreadPropertiesInternal.id
        self.topic = chatThreadPropertiesInternal.topic
        self.createdOn = chatThreadPropertiesInternal.createdOn

        // Deserialize the identifier model to CommunicationIdentifier
        self.createdBy = try IdentifierSerializer
            .deserialize(identifier: chatThreadPropertiesInternal.createdByCommunicationIdentifier)

        self.deletedOn = chatThreadPropertiesInternal.deletedOn
    }

    /// Initialize a `ChatThreadProperties` structure.
    /// - Parameters:
    ///   - id: Thread id.
    ///   - topic: Thread topic.
    ///   - createdOn: The timestamp when the thread was created. The timestamp is in RFC3339 format:
    /// `yyyy-MM-ddTHH:mm:ssZ`.
    ///   - createdBy: The thread owner.
    ///   - deletedOn: The timestamp when the thread was deleted. The timestamp is in RFC3339 format:
    /// `yyyy-MM-ddTHH:mm:ssZ`.
    public init(
        id: String,
        topic: String,
        createdOn: Iso8601Date,
        createdBy: CommunicationIdentifier,
        deletedOn: Iso8601Date? = nil
    ) {
        self.id = id
        self.topic = topic
        self.createdOn = createdOn
        self.createdBy = createdBy
        self.deletedOn = deletedOn
    }

    // MARK: Codable

    enum CodingKeys: String, CodingKey {
        case id
        case topic
        case createdOn
        case createdBy = "createdByCommunicationIdentifier"
        case deletedOn
    }

    /// Initialize a `ChatThreadProperties` structure from decoder
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(String.self, forKey: .id)
        self.topic = try container.decode(String.self, forKey: .topic)
        self.createdOn = try container.decode(Iso8601Date.self, forKey: .createdOn)

        // Decode CommunicationIdentifierModel to CommunicationIdentifier
        let identifierModel = try container.decode(CommunicationIdentifierModelInternal.self, forKey: .createdBy)
        self.createdBy = try IdentifierSerializer.deserialize(identifier: identifierModel)

        self.deletedOn = try? container.decode(Iso8601Date.self, forKey: .deletedOn)
    }

    /// Encode a `ChatThreadProperties` structure
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(topic, forKey: .topic)
        try container.encode(createdOn, forKey: .createdOn)

        // Encode CommunicationIdentifier to CommunicationIdentifierModel
        let identifierModel = try IdentifierSerializer.serialize(identifier: createdBy)
        try container.encode(identifierModel, forKey: .createdBy)

        if deletedOn != nil { try? container.encode(deletedOn, forKey: .deletedOn) }
    }
}
